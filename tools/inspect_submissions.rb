#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Show what each review submission actually contains. Useful when the App
# Store Connect UI reports "To submit your items for review, add an app
# version for the selected platform" — that means a submission holds only
# in-app purchases with no appStoreVersion alongside them.

require 'jwt'
require 'openssl'
require 'net/http'
require 'json'

KEY = File.expand_path('../AuthKey_UV8NYF9767.p8', __dir__)
APP = '6781554668'
PK  = OpenSSL::PKey::EC.new(File.read(KEY))

def token
  now = Time.now.to_i
  JWT.encode({ iss: 'ec93cc91-97c2-4b03-860b-697d7ec5d1fb', iat: now,
               exp: now + 900, aud: 'appstoreconnect-v1' },
             PK, 'ES256', { kid: 'UV8NYF9767', typ: 'JWT' })
end

def get(path)
  uri = URI("https://api.appstoreconnect.apple.com#{path}")
  req = Net::HTTP::Get.new(uri)
  req['Authorization'] = "Bearer #{token}"
  res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |h| h.request(req) }
  [res.code, (JSON.parse(res.body) rescue {})]
end

_, body = get("/v1/apps/#{APP}/reviewSubmissions?limit=10")
(body['data'] || []).each do |s|
  puts "submission #{s['id']}  state=#{s.dig('attributes', 'state')}"
  _, items = get("/v1/reviewSubmissions/#{s['id']}/items")
  (items['data'] || []).each do |it|
    rels = (it['relationships'] || {}).reject { |_, v| v['data'].nil? }
    rels.each do |name, v|
      puts "    #{name}: #{v.dig('data', 'id')}  (state=#{it.dig('attributes', 'state')})"
    end
    puts "    (no populated relationship)" if rels.empty?
  end
  puts '    (empty)' if (items['data'] || []).empty?
end
