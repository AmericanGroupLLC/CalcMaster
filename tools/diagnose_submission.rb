#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Why can't this version be reviewed? Dumps the fields App Store Connect
# requires before it will accept a review submission.
#
#   bundle exec ruby tools/diagnose_submission.rb

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

def api(method, path)
  uri = URI("https://api.appstoreconnect.apple.com#{path}")
  klass = { get: Net::HTTP::Get, delete: Net::HTTP::Delete }.fetch(method)
  req = klass.new(uri)
  req['Authorization'] = "Bearer #{token}"
  res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |h| h.request(req) }
  [res.code, (JSON.parse(res.body) rescue {})]
end

puts '--- app ---'
code, body = api(:get, "/v1/apps/#{APP}")
a = body.dig('data', 'attributes') || {}
puts "  contentRightsDeclaration: #{a['contentRightsDeclaration'].inspect}"
puts "  name: #{a['name'].inspect}  sku: #{a['sku'].inspect}"

puts '--- version ---'
code, body = api(:get, "/v1/apps/#{APP}/appStoreVersions?limit=1")
v = body['data'].first
va = v['attributes']
puts "  #{va['versionString']} state=#{va['appStoreState'] || va['appVersionState']}"
puts "  releaseType=#{va['releaseType']} earliestReleaseDate=#{va['earliestReleaseDate'].inspect}"

puts '--- review detail ---'
code, body = api(:get, "/v1/appStoreVersions/#{v['id']}/appStoreReviewDetail")
if code == '200'
  d = body.dig('data', 'attributes') || {}
  %w[contactFirstName contactLastName contactPhone contactEmail
     demoAccountName demoAccountRequired notes].each do |k|
    puts "  #{k}: #{d[k].inspect}"
  end
else
  puts "  HTTP #{code} — review detail missing"
end

puts '--- idfa / export compliance ---'
code, body = api(:get, "/v1/appStoreVersions/#{v['id']}/idfaDeclaration")
puts "  idfaDeclaration: HTTP #{code} #{body['data'] ? 'present' : 'absent'}"
# NB: the version list above does not include the build relationship, so look
# the builds up directly rather than dereferencing a nil id (that silently
# 404s and prints nothing).
code, body = api(:get, "/v1/apps/#{APP}/builds?limit=5")
(body['data'] || []).each do |b|
  puts "  build #{b.dig('attributes', 'version')} " \
       "usesNonExemptEncryption=#{b.dig('attributes', 'usesNonExemptEncryption').inspect} " \
       "processing=#{b.dig('attributes', 'processingState')}"
end

puts '--- age rating ---'
code, body = api(:get, "/v1/apps/#{APP}/appInfos?include=ageRatingDeclaration,primaryCategory")
info = (body['data'] || []).first
puts "  appInfo state: #{info.dig('attributes', 'appStoreState') || info.dig('attributes', 'state')}"
puts "  primaryCategory: #{info.dig('relationships', 'primaryCategory', 'data', 'id').inspect}"

puts '--- existing review submissions ---'
code, body = api(:get, "/v1/apps/#{APP}/reviewSubmissions?limit=10")
(body['data'] || []).each do |s|
  puts "  #{s['id']} state=#{s.dig('attributes', 'state')} submitted=#{s.dig('attributes', 'submitted')}"
  c2, b2 = api(:get, "/v1/reviewSubmissions/#{s['id']}/items")
  puts "    items: #{(b2['data'] || []).size}"
  if ARGV.include?('--clean') && s.dig('attributes', 'state') == 'READY_FOR_REVIEW' && (b2['data'] || []).empty?
    c3, = api(:delete, "/v1/reviewSubmissions/#{s['id']}")
    puts "    deleted empty submission -> HTTP #{c3}"
  end
end
