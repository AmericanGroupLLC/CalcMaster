#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Pull a version back out of review.
#
#   bundle exec ruby tools/cancel_review_submission.rb            # list
#   bundle exec ruby tools/cancel_review_submission.rb --cancel
#
# Equivalent of "Remove from Review" in App Store Connect. Needed when a
# version was submitted without its in-app purchases attached.

require 'jwt'
require 'openssl'
require 'net/http'
require 'json'

KEY = File.expand_path('../AuthKey_UV8NYF9767.p8', __dir__)
APP = '6781554668'
PK  = OpenSSL::PKey::EC.new(File.read(KEY))
DO_CANCEL = ARGV.include?('--cancel')

def token
  now = Time.now.to_i
  JWT.encode({ iss: 'ec93cc91-97c2-4b03-860b-697d7ec5d1fb', iat: now,
               exp: now + 900, aud: 'appstoreconnect-v1' },
             PK, 'ES256', { kid: 'UV8NYF9767', typ: 'JWT' })
end

def api(method, path, body = nil)
  uri = URI("https://api.appstoreconnect.apple.com#{path}")
  req = { get: Net::HTTP::Get, patch: Net::HTTP::Patch,
          delete: Net::HTTP::Delete }.fetch(method).new(uri)
  req['Authorization'] = "Bearer #{token}"
  req['Content-Type'] = 'application/json'
  req.body = JSON.dump(body) if body
  res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |h| h.request(req) }
  [res.code, (JSON.parse(res.body) rescue {})]
end

def errors(b)
  (b['errors'] || []).map { |e| "#{e['status']} #{e['code']}: #{e['detail']}" }.join("\n    ")
end

_, body = api(:get, "/v1/apps/#{APP}/reviewSubmissions?limit=10")
subs = body['data'] || []
puts "review submissions: #{subs.size}"
subs.each { |s| puts "  #{s['id']} state=#{s.dig('attributes', 'state')}" }

exit 0 unless DO_CANCEL

subs.each do |s|
  state = s.dig('attributes', 'state')
  next unless %w[WAITING_FOR_REVIEW IN_REVIEW READY_FOR_REVIEW].include?(state)

  # Preferred: mark the submission canceled.
  code, resp = api(:patch, "/v1/reviewSubmissions/#{s['id']}",
                   { data: { type: 'reviewSubmissions', id: s['id'],
                             attributes: { canceled: true } } })
  if %w[200 201].include?(code)
    puts "✓ canceled #{s['id']}"
    next
  end
  puts "  PATCH canceled -> #{code}\n    #{errors(resp)}"

  # Fallback: an unsubmitted submission can simply be deleted.
  code, resp = api(:delete, "/v1/reviewSubmissions/#{s['id']}")
  if %w[200 204].include?(code)
    puts "✓ deleted #{s['id']}"
  else
    puts "  DELETE -> #{code}\n    #{errors(resp)}"
  end
end

_, body = api(:get, "/v1/apps/#{APP}/appStoreVersions?limit=1")
v = (body['data'] || []).first
puts "\nversion #{v.dig('attributes', 'versionString')} state=" \
     "#{v.dig('attributes', 'appStoreState') || v.dig('attributes', 'appVersionState')}"
