import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('zh'),
    Locale('hi'),
    Locale('fr'),
    Locale('ar'),
    Locale('de'),
    Locale('ja'),
    Locale('pt'),
    Locale('ko'),
    Locale('ru'),
    Locale('it')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'CalcMaster'**
  String get appTitle;

  /// Tagline shown under the app title in the Convert hero.
  ///
  /// In en, this message translates to:
  /// **'World calculator & converter'**
  String get appTagline;

  /// No description provided for @tabConvert.
  ///
  /// In en, this message translates to:
  /// **'Convert'**
  String get tabConvert;

  /// No description provided for @tabCalculate.
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get tabCalculate;

  /// No description provided for @tabFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get tabFinance;

  /// No description provided for @tabTools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get tabTools;

  /// No description provided for @tabNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get tabNotes;

  /// No description provided for @pillUnitConversion.
  ///
  /// In en, this message translates to:
  /// **'Unit Conversion'**
  String get pillUnitConversion;

  /// No description provided for @pillCalculators.
  ///
  /// In en, this message translates to:
  /// **'Calculators'**
  String get pillCalculators;

  /// No description provided for @pillFinanceTools.
  ///
  /// In en, this message translates to:
  /// **'Finance Tools'**
  String get pillFinanceTools;

  /// No description provided for @pillUtilityTools.
  ///
  /// In en, this message translates to:
  /// **'Utility Tools'**
  String get pillUtilityTools;

  /// No description provided for @pillSavedNotes.
  ///
  /// In en, this message translates to:
  /// **'Saved Notes'**
  String get pillSavedNotes;

  /// No description provided for @convertHubHeading.
  ///
  /// In en, this message translates to:
  /// **'Convert'**
  String get convertHubHeading;

  /// No description provided for @convertHubSubheading.
  ///
  /// In en, this message translates to:
  /// **'Tap any unit to convert instantly'**
  String get convertHubSubheading;

  /// No description provided for @calculateHubHeading.
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get calculateHubHeading;

  /// No description provided for @calculateHubSubheading.
  ///
  /// In en, this message translates to:
  /// **'Standard · Scientific · Percentage · Base · Fraction'**
  String get calculateHubSubheading;

  /// No description provided for @financeHubHeading.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get financeHubHeading;

  /// No description provided for @financeHubSubheading.
  ///
  /// In en, this message translates to:
  /// **'Tax · Tip & Split · Discount · Compound Interest · EMI · Currency · Unit Price'**
  String get financeHubSubheading;

  /// No description provided for @toolsHubHeading.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get toolsHubHeading;

  /// No description provided for @toolsHubSubheading.
  ///
  /// In en, this message translates to:
  /// **'GPS · Ohm\'s Law · BMI · Date Diff · Time Zones · ADC/DAC · Age · Aspect Ratio'**
  String get toolsHubSubheading;

  /// No description provided for @notesHubHeading.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesHubHeading;

  /// No description provided for @notesHubSubheading.
  ///
  /// In en, this message translates to:
  /// **'Save calculations, formulas, and reminders'**
  String get notesHubSubheading;

  /// No description provided for @categoryDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get categoryDistance;

  /// No description provided for @categoryVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get categoryVolume;

  /// No description provided for @categoryWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get categoryWeight;

  /// No description provided for @categoryTemperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get categoryTemperature;

  /// No description provided for @categorySpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get categorySpeed;

  /// No description provided for @categoryArea.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get categoryArea;

  /// No description provided for @categoryDataSize.
  ///
  /// In en, this message translates to:
  /// **'Data Size'**
  String get categoryDataSize;

  /// No description provided for @categoryFuelEconomy.
  ///
  /// In en, this message translates to:
  /// **'Fuel Economy'**
  String get categoryFuelEconomy;

  /// No description provided for @categoryPressure.
  ///
  /// In en, this message translates to:
  /// **'Pressure'**
  String get categoryPressure;

  /// No description provided for @categoryEnergy.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get categoryEnergy;

  /// No description provided for @labelFrom.
  ///
  /// In en, this message translates to:
  /// **'FROM'**
  String get labelFrom;

  /// No description provided for @labelTo.
  ///
  /// In en, this message translates to:
  /// **'TO'**
  String get labelTo;

  /// No description provided for @labelAllConversions.
  ///
  /// In en, this message translates to:
  /// **'ALL CONVERSIONS'**
  String get labelAllConversions;

  /// No description provided for @labelUnitsAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count} units available'**
  String labelUnitsAvailable(int count);

  /// No description provided for @calcStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get calcStandard;

  /// No description provided for @calcScientific.
  ///
  /// In en, this message translates to:
  /// **'Scientific'**
  String get calcScientific;

  /// No description provided for @calcPercentage.
  ///
  /// In en, this message translates to:
  /// **'Percentage'**
  String get calcPercentage;

  /// No description provided for @calcBase.
  ///
  /// In en, this message translates to:
  /// **'Base'**
  String get calcBase;

  /// No description provided for @calcFraction.
  ///
  /// In en, this message translates to:
  /// **'Fraction'**
  String get calcFraction;

  /// No description provided for @financeTax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get financeTax;

  /// No description provided for @financeTip.
  ///
  /// In en, this message translates to:
  /// **'Tip & Split'**
  String get financeTip;

  /// No description provided for @financeDiscount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get financeDiscount;

  /// No description provided for @financeCompound.
  ///
  /// In en, this message translates to:
  /// **'Compound Interest'**
  String get financeCompound;

  /// No description provided for @financeEMI.
  ///
  /// In en, this message translates to:
  /// **'EMI / Loan'**
  String get financeEMI;

  /// No description provided for @financeCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get financeCurrency;

  /// No description provided for @financeUnitPrice.
  ///
  /// In en, this message translates to:
  /// **'Unit Price'**
  String get financeUnitPrice;

  /// No description provided for @toolGps.
  ///
  /// In en, this message translates to:
  /// **'GPS Coordinates'**
  String get toolGps;

  /// No description provided for @toolOhm.
  ///
  /// In en, this message translates to:
  /// **'Ohm\'s Law'**
  String get toolOhm;

  /// No description provided for @toolBmi.
  ///
  /// In en, this message translates to:
  /// **'BMI'**
  String get toolBmi;

  /// No description provided for @toolDateDiff.
  ///
  /// In en, this message translates to:
  /// **'Date Difference'**
  String get toolDateDiff;

  /// No description provided for @toolTimeZones.
  ///
  /// In en, this message translates to:
  /// **'Time Zones'**
  String get toolTimeZones;

  /// No description provided for @toolAdcDac.
  ///
  /// In en, this message translates to:
  /// **'ADC / DAC'**
  String get toolAdcDac;

  /// No description provided for @toolAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get toolAge;

  /// No description provided for @toolAspectRatio.
  ///
  /// In en, this message translates to:
  /// **'Aspect Ratio'**
  String get toolAspectRatio;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSubscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get settingsSubscription;

  /// No description provided for @settingsSubscribePro.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to Pro'**
  String get settingsSubscribePro;

  /// No description provided for @settingsCalcMasterPro.
  ///
  /// In en, this message translates to:
  /// **'CalcMaster Pro'**
  String get settingsCalcMasterPro;

  /// No description provided for @settingsRestorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get settingsRestorePurchases;

  /// No description provided for @settingsPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settingsPreferences;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get settingsHelp;

  /// No description provided for @settingsSendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get settingsSendFeedback;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About CalcMaster'**
  String get settingsAbout;

  /// No description provided for @paywallTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock CalcMaster Pro'**
  String get paywallTitle;

  /// No description provided for @paywallSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Remove ads, get advanced insights, refresh currency rates instantly, and support indie development.'**
  String get paywallSubtitle;

  /// No description provided for @paywallBenefitAdFree.
  ///
  /// In en, this message translates to:
  /// **'Ad-free experience'**
  String get paywallBenefitAdFree;

  /// No description provided for @paywallBenefitAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced tax + finance insights'**
  String get paywallBenefitAdvanced;

  /// No description provided for @paywallBenefitRealtime.
  ///
  /// In en, this message translates to:
  /// **'Real-time currency refresh'**
  String get paywallBenefitRealtime;

  /// No description provided for @paywallBenefitSupport.
  ///
  /// In en, this message translates to:
  /// **'Priority email support'**
  String get paywallBenefitSupport;

  /// No description provided for @paywallTierMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get paywallTierMonthly;

  /// No description provided for @paywallTierAnnual.
  ///
  /// In en, this message translates to:
  /// **'Annual'**
  String get paywallTierAnnual;

  /// No description provided for @paywallTierLifetime.
  ///
  /// In en, this message translates to:
  /// **'Lifetime'**
  String get paywallTierLifetime;

  /// No description provided for @paywallBadgeBestValue.
  ///
  /// In en, this message translates to:
  /// **'BEST VALUE'**
  String get paywallBadgeBestValue;

  /// No description provided for @paywallContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get paywallContinue;

  /// No description provided for @paywallProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing…'**
  String get paywallProcessing;

  /// No description provided for @paywallRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get paywallRestore;

  /// No description provided for @paywallTermsFooter.
  ///
  /// In en, this message translates to:
  /// **'By continuing you agree to our Terms and Privacy Policy.'**
  String get paywallTermsFooter;

  /// No description provided for @paywallTermsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get paywallTermsOfUse;

  /// No description provided for @paywallSubscriptionsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions are not yet enabled in this build.'**
  String get paywallSubscriptionsDisabled;

  /// No description provided for @paywallCancelAnytime.
  ///
  /// In en, this message translates to:
  /// **'Cancel anytime'**
  String get paywallCancelAnytime;

  /// No description provided for @paywallAnnualSavings.
  ///
  /// In en, this message translates to:
  /// **'Save 44% · most popular'**
  String get paywallAnnualSavings;

  /// No description provided for @paywallLifetimeForever.
  ///
  /// In en, this message translates to:
  /// **'Pay once, own it forever'**
  String get paywallLifetimeForever;

  /// No description provided for @regionPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Select region'**
  String get regionPickerTitle;

  /// No description provided for @notesAddNote.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get notesAddNote;

  /// No description provided for @notesSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get notesSaveChanges;

  /// No description provided for @notesSearch.
  ///
  /// In en, this message translates to:
  /// **'Search notes'**
  String get notesSearch;

  /// No description provided for @notesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notes yet. Add your first one above.'**
  String get notesEmpty;

  /// No description provided for @notesDeleteHint.
  ///
  /// In en, this message translates to:
  /// **'Tip: long-press a note to delete.'**
  String get notesDeleteHint;

  /// No description provided for @notesNewTitleHint.
  ///
  /// In en, this message translates to:
  /// **'New note title'**
  String get notesNewTitleHint;

  /// No description provided for @notesTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get notesTitleHint;

  /// No description provided for @notesBodyHint.
  ///
  /// In en, this message translates to:
  /// **'Body'**
  String get notesBodyHint;

  /// No description provided for @actionCopy.
  ///
  /// In en, this message translates to:
  /// **'Copied: {value}'**
  String actionCopy(String value);

  /// No description provided for @actionUseMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get actionUseMyLocation;

  /// No description provided for @actionLocating.
  ///
  /// In en, this message translates to:
  /// **'Locating…'**
  String get actionLocating;

  /// No description provided for @actionPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get actionPermissionDenied;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get aboutVersion;

  /// No description provided for @aboutBuild.
  ///
  /// In en, this message translates to:
  /// **'Build'**
  String get aboutBuild;

  /// No description provided for @aboutMadeWith.
  ///
  /// In en, this message translates to:
  /// **'Made with'**
  String get aboutMadeWith;

  /// No description provided for @aboutBlurb.
  ///
  /// In en, this message translates to:
  /// **'CalcMaster bundles the calculators most people actually use — unit conversions, percentages, scientific math, tax + finance, electronics, and a notes pad — in one polished app that respects your privacy and your battery.'**
  String get aboutBlurb;

  /// No description provided for @aiChatHint.
  ///
  /// In en, this message translates to:
  /// **'Ask CalcMaster AI...'**
  String get aiChatHint;

  /// No description provided for @aiChatTitle.
  ///
  /// In en, this message translates to:
  /// **'CalcMaster AI'**
  String get aiChatTitle;

  /// No description provided for @aiChatEmpty.
  ///
  /// In en, this message translates to:
  /// **'Ask me anything about calculations, conversions, or finance.'**
  String get aiChatEmpty;

  /// No description provided for @authTwoFactor.
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication'**
  String get authTwoFactor;

  /// No description provided for @authCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get authCancel;

  /// No description provided for @authVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get authVerify;

  /// No description provided for @authOtpHint.
  ///
  /// In en, this message translates to:
  /// **'000000'**
  String get authOtpHint;

  /// No description provided for @privacyAtGlance.
  ///
  /// In en, this message translates to:
  /// **'Privacy at a glance'**
  String get privacyAtGlance;

  /// No description provided for @deleteNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this note?'**
  String get deleteNoteTitle;

  /// No description provided for @deleteNoteCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get deleteNoteCancel;

  /// No description provided for @deleteNoteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteNoteConfirm;

  /// No description provided for @labelFilingStatus.
  ///
  /// In en, this message translates to:
  /// **'Filing status'**
  String get labelFilingStatus;

  /// No description provided for @labelCompoundFreq.
  ///
  /// In en, this message translates to:
  /// **'Compounding frequency'**
  String get labelCompoundFreq;

  /// No description provided for @labelInputBase.
  ///
  /// In en, this message translates to:
  /// **'Input base'**
  String get labelInputBase;

  /// No description provided for @labelOperator.
  ///
  /// In en, this message translates to:
  /// **'Operator'**
  String get labelOperator;

  /// No description provided for @labelPerUnit.
  ///
  /// In en, this message translates to:
  /// **'Per unit'**
  String get labelPerUnit;

  /// No description provided for @labelXofY.
  ///
  /// In en, this message translates to:
  /// **'X% of Y'**
  String get labelXofY;

  /// No description provided for @labelXisWhatPctOfY.
  ///
  /// In en, this message translates to:
  /// **'X is what % of Y'**
  String get labelXisWhatPctOfY;

  /// No description provided for @labelPctChangeXtoY.
  ///
  /// In en, this message translates to:
  /// **'% change from X to Y'**
  String get labelPctChangeXtoY;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ar',
        'de',
        'en',
        'es',
        'fr',
        'hi',
        'it',
        'ja',
        'ko',
        'pt',
        'ru',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
