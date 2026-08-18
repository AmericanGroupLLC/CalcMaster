#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Rewrite the App Review Information notes for the current (rejected) version.
# Apple's Guideline 2.1 "Information Needed" rejection asks for seven specific
# items; NOTES below answers all of them. Run after any change to the app that
# invalidates a claim in the text.
#
#   ruby tools/update_review_notes.rb            # patch
#   ruby tools/update_review_notes.rb --dry-run  # print only

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

def api(method, path, payload = nil)
  uri = URI("https://api.appstoreconnect.apple.com#{path}")
  klass = { get: Net::HTTP::Get, patch: Net::HTTP::Patch }.fetch(method)
  req = klass.new(uri)
  req['Authorization'] = "Bearer #{token}"
  if payload
    req['Content-Type'] = 'application/json'
    req.body = JSON.dump(payload)
  end
  res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |h| h.request(req) }
  [res.code, (JSON.parse(res.body) rescue {})]
end

NOTES = <<~TXT
  CALCMASTER 4.0.2 (5) — REVIEW INFORMATION (Guideline 2.1 response)

  1. SCREEN RECORDING
  A recording of this build, captured on a physical iPhone 16 Pro Max running iOS 26.6, is attached to our Resolution Center reply. It starts at app launch and shows unit conversion, the calculators, the finance and utility tools, notes, the location permission prompt, and the full subscription purchase flow.

  2. DEVICES AND OS VERSIONS TESTED
  - iPhone 16 Pro Max, iOS 26.6 (physical device)
  - iPhone 13 Pro, iOS 26.6 (physical device)
  - iPhone 17 Pro Max simulator, iOS 26 (Xcode)
  Minimum deployment target iOS 15.0. iPhone only, portrait.

  3. WHAT THE APP DOES AND WHO IT IS FOR
  CalcMaster is an offline-first calculator, unit converter and everyday finance toolkit; all math runs on the device. It has 10 unit-conversion categories (distance, volume, weight, temperature, speed, area, data, fuel, pressure, energy), 5 calculators (standard, scientific, percentage, base-N, fraction), 7 finance tools (income tax, tip, discount, compound interest, EMI/loan, currency, unit price), 9 utility tools (GPS coordinates, Ohm's law, BMI, date difference, time zones, ADC/DAC, age, aspect ratio, calendar) and local notes.
  It replaces the several single-purpose, network-dependent calculators people usually install, in one app that works offline in 12 languages with 11 region presets.
  Audience: students, travellers, engineers and tradespeople, general consumers. Rated 4+. Nothing is shared between users — notes stay on the device — so no content reporting or blocking applies.

  4. SETUP AND ACCESS TO THE MAIN FEATURES
  No account and no sample files are required. The app opens straight to the calculator after a ~2 second splash; there is no login gate.
  a) Bottom tab bar: Convert, Calculate, Finance, Tools, Notes.
  b) Convert: tap a category card, type a value, see all conversions.
  c) Finance > Currency: European Central Bank rates via api.frankfurter.dev, with bundled offline fallback rates.
  d) Tools > GPS Coordinates > "Use my location": the only place location is requested. Coordinates are shown on-device and never uploaded.
  e) Settings (gear, top right) > "Subscribe to Pro" opens the paywall: Pro Monthly (USD 2.99), Annual (USD 19.99), Lifetime (USD 49.99, non-consumable). Purchases use StoreKit and work with a sandbox Apple ID; "Restore purchases" is on the same screen.
  f) Optional sign-in, if you wish to exercise it: Settings > Sign in. Test account qa@safecodeg.com / QATest@2024!. No feature requires an account; a signed-in user can sign out from Settings.

  5. EXTERNAL SERVICES USED
  - Frankfurter (api.frankfurter.dev): ECB reference exchange rates for the currency converter. No personal data is sent.
  - Supabase (hosted GoTrue): optional email/password and Google sign-in only.
  - Apple StoreKit via the in_app_purchase plugin: subscriptions and the lifetime purchase. No third-party payment processor.
  - Google Mobile Ads SDK: linked in the binary, but this version ships placeholder ad units, so no ads are served and no App Tracking Transparency prompt is presented.
  - No AI service, analytics SDK or push notifications.

  6. REGIONAL DIFFERENCES
  The app behaves identically everywhere. The only variation is user-selectable: 12 interface languages and 11 region presets (US, UK, EU, CA, AU, IN, JP, BR, MX, KR, AE) that set the default currency, number and date formatting, and the published 2025-26 income-tax brackets used by the tax calculator. Nothing is unlocked or withheld by location.

  7. REGULATED INDUSTRY AND THIRD-PARTY MATERIAL
  CalcMaster is not in a regulated industry. It gives no financial, tax, medical or legal advice, holds no funds, and only computes on values the user types in. Artwork and code are original or permissively licensed; exchange rates are public ECB data via Frankfurter and tax brackets are published government figures. No protected third-party material is included.

  Contact: contact@safecodeg.com — we reply within one business day.
TXT

code, body = api(:get, "/v1/apps/#{APP}/appStoreVersions?limit=1")
abort("could not list versions: HTTP #{code}") unless code == '200'
version = body['data'].first
vid = version['id']
puts "version #{version.dig('attributes', 'versionString')} (#{vid}) " \
     "state=#{version.dig('attributes', 'appStoreState') || version.dig('attributes', 'appVersionState')}"

code, body = api(:get, "/v1/appStoreVersions/#{vid}/appStoreReviewDetail")
abort("no review detail: HTTP #{code}") unless code == '200'
detail_id = body.dig('data', 'id')

puts "notes: #{NOTES.length} chars"
if ARGV.include?('--dry-run')
  puts NOTES
  exit
end

code, body = api(:patch, "/v1/appStoreReviewDetails/#{detail_id}",
                 { data: { type: 'appStoreReviewDetails', id: detail_id,
                           attributes: { notes: NOTES, demoAccountRequired: false } } })
puts "PATCH appStoreReviewDetails/#{detail_id} -> HTTP #{code}"
puts JSON.pretty_generate(body) unless code == '200'
