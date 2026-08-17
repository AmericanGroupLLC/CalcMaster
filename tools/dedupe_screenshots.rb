#!/usr/bin/env ruby
# frozen_string_literal: true
#
# List (and optionally remove) duplicate App Store screenshots.
#
#   bundle exec ruby tools/dedupe_screenshots.rb            # list only
#   bundle exec ruby tools/dedupe_screenshots.rb --prune    # delete duplicates
#
# deliver retries the whole screenshot batch when it thinks an upload failed.
# When the first attempt actually succeeded, every image lands twice and the
# store listing shows each shot two times. Apple caps a display type at 10, so
# a 5-shot set silently fills up. This keeps the first copy of each fileName
# and deletes the rest.

require 'jwt'
require 'openssl'
require 'net/http'
require 'json'

KEY = File.expand_path('../AuthKey_UV8NYF9767.p8', __dir__)
APP = '6781554668'
PK  = OpenSSL::PKey::EC.new(File.read(KEY))
PRUNE = ARGV.include?('--prune')

def token
  now = Time.now.to_i
  JWT.encode({ iss: 'ec93cc91-97c2-4b03-860b-697d7ec5d1fb', iat: now,
               exp: now + 900, aud: 'appstoreconnect-v1' },
             PK, 'ES256', { kid: 'UV8NYF9767', typ: 'JWT' })
end

def api(method, path)
  uri = URI("https://api.appstoreconnect.apple.com#{path}")
  klass = { get: Net::HTTP::Get, delete: Net::HTTP::Delete }.fetch(method)
  req = klass.new(uri)
  req['Authorization'] = "Bearer #{token}"
  res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |h| h.request(req) }
  [res.code, (JSON.parse(res.body) rescue {})]
end

_, body = api(:get, "/v1/apps/#{APP}/appStoreVersions?limit=1")
version = body['data'].first['id']
_, body = api(:get, "/v1/appStoreVersions/#{version}/appStoreVersionLocalizations")
loc = body['data'].find { |l| l.dig('attributes', 'locale') == 'en-US' }['id']
_, body = api(:get, "/v1/appStoreVersionLocalizations/#{loc}/appScreenshotSets")

total_dupes = 0
(body['data'] || []).each do |set|
  display = set.dig('attributes', 'screenshotDisplayType')
  _, shots = api(:get, "/v1/appScreenshotSets/#{set['id']}/appScreenshots?limit=20")
  list = shots['data'] || []
  puts "#{display}: #{list.size} screenshot(s)"

  seen = {}
  list.each do |s|
    name = s.dig('attributes', 'fileName')
    if seen[name]
      total_dupes += 1
      if PRUNE
        code, = api(:delete, "/v1/appScreenshots/#{s['id']}")
        puts "   #{%w[200 204].include?(code) ? 'deleted' : "FAILED #{code}"} duplicate #{name}"
      else
        puts "   duplicate: #{name} (#{s['id']})"
      end
    else
      seen[name] = true
      puts "   keep: #{name}"
    end
  end
end

puts
if total_dupes.zero?
  puts '✓ No duplicate screenshots'
elsif PRUNE
  puts "✓ Removed #{total_dupes} duplicate screenshot(s)"
else
  puts "#{total_dupes} duplicate(s) found — re-run with --prune to remove them"
end
