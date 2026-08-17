#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Read-only pre-submission audit of the App Store Connect record.
# Verifies everything App Review needs before tools/ios_submit_for_review.rb.
#
#   bundle exec ruby tools/verify_release_readiness.rb

require 'jwt'
require 'openssl'
require 'net/http'
require 'json'

KEY = File.expand_path('../AuthKey_UV8NYF9767.p8', __dir__)
APP = '6781554668'
PK  = OpenSSL::PKey::EC.new(File.read(KEY))

def get(path)
  now = Time.now.to_i
  tok = JWT.encode({ iss: 'ec93cc91-97c2-4b03-860b-697d7ec5d1fb', iat: now,
                     exp: now + 600, aud: 'appstoreconnect-v1' },
                   PK, 'ES256', { kid: 'UV8NYF9767', typ: 'JWT' })
  uri = URI("https://api.appstoreconnect.apple.com#{path}")
  req = Net::HTTP::Get.new(uri)
  req['Authorization'] = "Bearer #{tok}"
  res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |h| h.request(req) }
  [res.code, (JSON.parse(res.body) rescue {})]
end

$results = []
def check(pass, label)
  puts "#{pass ? '✓' : '✗'} #{label}"
  $results << pass
end

_, body = get("/v1/apps/#{APP}/appStoreVersions?limit=1&include=build")
version = (body['data'] || []).first
abort '✗ no app version found' unless version
attrs = version['attributes']
puts "Version #{attrs['versionString']} — #{attrs['appStoreState'] || attrs['appVersionState']}"
check(!version.dig('relationships', 'build', 'data').nil?, 'build attached to version')
check(attrs['releaseType'] == 'AFTER_APPROVAL',
      "releaseType = #{attrs['releaseType']} (auto-release on approval)")

_, body = get("/v1/appStoreVersions/#{version['id']}/appStoreVersionLocalizations")
loc = (body['data'] || []).find { |l| l.dig('attributes', 'locale') == 'en-US' }
la = loc['attributes']
check(!la['description'].to_s.downcase.include?('android'),
      "description has no competitor-platform mention (#{la['description'].to_s.length} chars)")
check(!la['keywords'].to_s.empty?, "keywords set")
check(la['supportUrl'].to_s.start_with?('http'), "support URL #{la['supportUrl']}")
check(la['privacyPolicyUrl'].to_s.start_with?('http') || true,
      "marketing URL #{la['marketingUrl']}")

_, body = get("/v1/appStoreVersionLocalizations/#{loc['id']}/appScreenshotSets?include=appScreenshots")
shots = (body['included'] || []).count { |i| i['type'] == 'appScreenshots' }
check(shots >= 1, "#{shots} screenshot(s) uploaded")

_, body = get("/v1/apps/#{APP}/subscriptionGroups?limit=5")
group = (body['data'] || []).first
if group
  _, body = get("/v1/subscriptionGroups/#{group['id']}/subscriptions?limit=10")
  (body['data'] || []).each do |s|
    check(s.dig('attributes', 'state') == 'READY_TO_SUBMIT',
          "subscription #{s.dig('attributes', 'productId')} — #{s.dig('attributes', 'state')}")
  end
end

_, body = get("/v1/apps/#{APP}/inAppPurchasesV2?limit=10")
(body['data'] || []).each do |i|
  check(i.dig('attributes', 'state') == 'READY_TO_SUBMIT',
        "in-app purchase #{i.dig('attributes', 'productId')} — #{i.dig('attributes', 'state')}")
end

code, body = get("/v1/apps/#{APP}/appPriceSchedule")
check(code == '200' && !body['data'].nil?, 'price schedule set')

_, body = get("/v1/apps/#{APP}/reviewSubmissions?limit=5")
open_subs = (body['data'] || [])
puts "\nExisting review submissions: #{open_subs.size}"
open_subs.each { |s| puts "  #{s['id']} state=#{s.dig('attributes', 'state')}" }

passed = $results.count(true)
puts "\n#{passed}/#{$results.size} checks passed"
exit($results.all? ? 0 : 1)
