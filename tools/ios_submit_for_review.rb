#!/usr/bin/env ruby
# frozen_string_literal: true
#
# CalcMaster · attach the app version + all in-app purchases to ONE App Review
# submission, then submit.
#
#   bundle exec ruby tools/ios_submit_for_review.rb            # dry run
#   bundle exec ruby tools/ios_submit_for_review.rb --submit   # actually submit
#
# Why this exists: fastlane's `submit_for_review: true` submits only the app
# VERSION. On a first release Apple requires the in-app purchases to be
# reviewed alongside the binary, and there is no deliver option for that. The
# ReviewSubmission API bundles them into a single submission.
#
# A reviewSubmission cannot be created until a build is attached to the
# version, so run this AFTER tools/ios_appstore_submit.sh has uploaded and the
# build has finished processing (usually 5–15 minutes).

require 'jwt'
require 'openssl'
require 'net/http'
require 'json'

KEY_PATH = ENV.fetch('ASC_KEY_PATH', File.expand_path('../AuthKey_UV8NYF9767.p8', __dir__))
KEY_ID   = ENV.fetch('ASC_KEY_ID', 'UV8NYF9767')
ISSUER   = ENV.fetch('ASC_ISSUER_ID', 'ec93cc91-97c2-4b03-860b-697d7ec5d1fb')
APP_ID   = ENV.fetch('ASC_APP_ID', '6781554668')
SUBMIT   = ARGV.include?('--submit')

abort "✗ No .p8 at #{KEY_PATH} (override with ASC_KEY_PATH)" unless File.exist?(KEY_PATH)

PK = OpenSSL::PKey::EC.new(File.read(KEY_PATH))

def token
  now = Time.now.to_i
  JWT.encode({ iss: ISSUER, iat: now, exp: now + 900, aud: 'appstoreconnect-v1' },
             PK, 'ES256', { kid: KEY_ID, typ: 'JWT' })
end

def api(method, path, body = nil)
  uri = URI("https://api.appstoreconnect.apple.com#{path}")
  klass = { get: Net::HTTP::Get, post: Net::HTTP::Post, patch: Net::HTTP::Patch }.fetch(method)
  req = klass.new(uri)
  req['Authorization'] = "Bearer #{token}"
  req['Content-Type'] = 'application/json'
  req.body = JSON.dump(body) if body
  res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |h| h.request(req) }
  [res.code, (JSON.parse(res.body) rescue {})]
end

def errors(body)
  (body['errors'] || []).map { |e| "#{e['status']} #{e['code']}: #{e['detail']}" }.join("\n    ")
end

# Plain method body, not an endless def — this has to parse under the system
# Ruby 2.6 that fastlane runs on.
def ok?(code)
  %w[200 201 204].include?(code)
end

# --- 1. Version must exist and have a build --------------------------------
code, body = api(:get, "/v1/apps/#{APP_ID}/appStoreVersions?limit=1&include=build")
version = (body['data'] || []).first
abort "✗ No app version found (HTTP #{code})" unless version

state = version.dig('attributes', 'appStoreState') || version.dig('attributes', 'appVersionState')
puts "Version #{version.dig('attributes', 'versionString')} — #{state}"

build = version.dig('relationships', 'build', 'data')
unless build
  abort "✗ No build attached to this version yet.\n" \
        "  Run tools/ios_appstore_submit.sh first and wait for processing to finish."
end
puts "Build attached: #{build['id']}"

# --- 2. Collect the in-app purchases ---------------------------------------
items = [{ appStoreVersion: version['id'] }]

code, body = api(:get, "/v1/apps/#{APP_ID}/subscriptionGroups?limit=10")
(body['data'] || []).each do |group|
  c, b = api(:get, "/v1/subscriptionGroups/#{group['id']}/subscriptions?limit=50")
  (b['data'] || []).each do |sub|
    st = sub.dig('attributes', 'state')
    puts "  subscription #{sub.dig('attributes', 'productId')} — #{st}"
    items << { subscription: sub['id'] } if st == 'READY_TO_SUBMIT'
  end
end

code, body = api(:get, "/v1/apps/#{APP_ID}/inAppPurchasesV2?limit=50")
(body['data'] || []).each do |iap|
  st = iap.dig('attributes', 'state')
  puts "  in-app purchase #{iap.dig('attributes', 'productId')} — #{st}"
  items << { inAppPurchaseV2: iap['id'] } if st == 'READY_TO_SUBMIT'
end

puts "\n#{items.size} item(s) would be submitted together."
unless SUBMIT
  puts 'Dry run — re-run with --submit to create and submit the review.'
  exit 0
end

# --- 3. Create the review submission ---------------------------------------
code, body = api(:post, '/v1/reviewSubmissions', {
                   data: { type: 'reviewSubmissions',
                           attributes: { platform: 'IOS' },
                           relationships: { app: { data: { type: 'apps', id: APP_ID } } } } })
unless ok?(code)
  # An open submission already exists — reuse it rather than failing.
  c, b = api(:get, "/v1/apps/#{APP_ID}/reviewSubmissions?filter[state]=READY_FOR_REVIEW,UNRESOLVED_ISSUES,WAITING_FOR_REVIEW&limit=1")
  existing = (b['data'] || []).first
  abort "✗ Could not create reviewSubmission (HTTP #{code})\n    #{errors(body)}" unless existing
  body = { 'data' => existing }
  puts "Reusing existing review submission #{existing['id']}"
end
submission_id = body.dig('data', 'id')
puts "Review submission: #{submission_id}"

# --- 4. Add each item ------------------------------------------------------
items.each do |item|
  key, id = item.first
  type = { appStoreVersion: 'appStoreVersions',
           subscription: 'subscriptions',
           inAppPurchaseV2: 'inAppPurchases' }.fetch(key)
  code, body = api(:post, '/v1/reviewSubmissionItems', {
                     data: { type: 'reviewSubmissionItems',
                             relationships: {
                               reviewSubmission: { data: { type: 'reviewSubmissions', id: submission_id } },
                               key => { data: { type: type, id: id } }
                             } } })
  puts ok?(code) ? "  + #{key} #{id}" : "  ! #{key} #{id} -> #{code}\n    #{errors(body)}"
end

# --- 5. Submit -------------------------------------------------------------
code, body = api(:patch, "/v1/reviewSubmissions/#{submission_id}", {
                   data: { type: 'reviewSubmissions', id: submission_id,
                           attributes: { submitted: true } } })
if ok?(code)
  puts "\n✓ Submitted for App Review — track at https://appstoreconnect.apple.com"
else
  abort "\n✗ Submit failed (HTTP #{code})\n    #{errors(body)}"
end
