#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Submit the in-app purchases for review.
#
#   bundle exec ruby tools/submit_iaps.rb            # dry run
#   bundle exec ruby tools/submit_iaps.rb --submit
#
# Apple decoupled IAP review from app review. They are NOT valid
# reviewSubmissionItem relationships — attaching them that way returns
# "'subscription' is not a relationship on the resource
# 'reviewSubmissionItems'". Each product type has its own submission resource:
#
#   subscriptions      -> POST /v1/subscriptionSubmissions
#   non-consumables    -> POST /v1/inAppPurchaseSubmissions
#
# Without this the app can ship approved while its products stay
# READY_TO_SUBMIT, leaving a paywall that cannot transact.

require 'jwt'
require 'openssl'
require 'net/http'
require 'json'

KEY = File.expand_path('../AuthKey_UV8NYF9767.p8', __dir__)
APP = '6781554668'
PK  = OpenSSL::PKey::EC.new(File.read(KEY))
SUBMIT = ARGV.include?('--submit')

def token
  now = Time.now.to_i
  JWT.encode({ iss: 'ec93cc91-97c2-4b03-860b-697d7ec5d1fb', iat: now,
               exp: now + 900, aud: 'appstoreconnect-v1' },
             PK, 'ES256', { kid: 'UV8NYF9767', typ: 'JWT' })
end

def api(method, path, body = nil)
  uri = URI("https://api.appstoreconnect.apple.com#{path}")
  req = { get: Net::HTTP::Get, post: Net::HTTP::Post }.fetch(method).new(uri)
  req['Authorization'] = "Bearer #{token}"
  req['Content-Type'] = 'application/json'
  req.body = JSON.dump(body) if body
  res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |h| h.request(req) }
  [res.code, (JSON.parse(res.body) rescue {})]
end

def errors(b)
  (b['errors'] || []).map { |e| "#{e['status']} #{e['code']}: #{e['detail']}" }.join("\n    ")
end

targets = []

_, body = api(:get, "/v1/apps/#{APP}/subscriptionGroups?limit=10")
(body['data'] || []).each do |group|
  _, subs = api(:get, "/v1/subscriptionGroups/#{group['id']}/subscriptions?limit=50")
  (subs['data'] || []).each do |s|
    targets << { kind: :subscription, id: s['id'],
                 product: s.dig('attributes', 'productId'),
                 state: s.dig('attributes', 'state') }
  end
end

_, body = api(:get, "/v1/apps/#{APP}/inAppPurchasesV2?limit=50")
(body['data'] || []).each do |i|
  targets << { kind: :iap, id: i['id'],
               product: i.dig('attributes', 'productId'),
               state: i.dig('attributes', 'state') }
end

targets.each { |t| puts "  #{t[:product]} — #{t[:state]}" }
pending = targets.select { |t| t[:state] == 'READY_TO_SUBMIT' }

if pending.empty?
  puts "\n✓ Nothing to submit — no product is in READY_TO_SUBMIT."
  exit 0
end

puts "\n#{pending.size} product(s) to submit."
unless SUBMIT
  puts 'Dry run — re-run with --submit.'
  exit 0
end

failed = 0
pending.each do |t|
  path, type, rel = if t[:kind] == :subscription
                      ['/v1/subscriptionSubmissions', 'subscriptionSubmissions', 'subscription']
                    else
                      ['/v1/inAppPurchaseSubmissions', 'inAppPurchaseSubmissions', 'inAppPurchaseV2']
                    end
  rel_type = t[:kind] == :subscription ? 'subscriptions' : 'inAppPurchases'
  code, body = api(:post, path, {
                     data: { type: type,
                             relationships: { rel => { data: { type: rel_type, id: t[:id] } } } } })
  if %w[200 201].include?(code)
    puts "  ✓ submitted #{t[:product]}"
  else
    failed += 1
    puts "  ✗ #{t[:product]} -> HTTP #{code}\n    #{errors(body)}"
  end
end

exit(failed.zero? ? 0 : 1)
