// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CalcMaster';

  @override
  String get appTagline => 'World calculator & converter';

  @override
  String get tabConvert => 'Convert';

  @override
  String get tabCalculate => 'Calculate';

  @override
  String get tabFinance => 'Finance';

  @override
  String get tabTools => 'Tools';

  @override
  String get tabNotes => 'Notes';

  @override
  String get pillUnitConversion => 'Unit Conversion';

  @override
  String get pillCalculators => 'Calculators';

  @override
  String get pillFinanceTools => 'Finance Tools';

  @override
  String get pillUtilityTools => 'Utility Tools';

  @override
  String get pillSavedNotes => 'Saved Notes';

  @override
  String get convertHubHeading => 'Convert';

  @override
  String get convertHubSubheading => 'Tap any unit to convert instantly';

  @override
  String get calculateHubHeading => 'Calculate';

  @override
  String get calculateHubSubheading =>
      'Standard · Scientific · Percentage · Base · Fraction';

  @override
  String get financeHubHeading => 'Finance';

  @override
  String get financeHubSubheading =>
      'Tax · Tip & Split · Discount · Compound Interest · EMI · Currency · Unit Price';

  @override
  String get toolsHubHeading => 'Tools';

  @override
  String get toolsHubSubheading =>
      'GPS · Ohm\'s Law · BMI · Date Diff · Time Zones · ADC/DAC · Age · Aspect Ratio';

  @override
  String get notesHubHeading => 'Notes';

  @override
  String get notesHubSubheading => 'Save calculations, formulas, and reminders';

  @override
  String get categoryDistance => 'Distance';

  @override
  String get categoryVolume => 'Volume';

  @override
  String get categoryWeight => 'Weight';

  @override
  String get categoryTemperature => 'Temperature';

  @override
  String get categorySpeed => 'Speed';

  @override
  String get categoryArea => 'Area';

  @override
  String get categoryDataSize => 'Data Size';

  @override
  String get categoryFuelEconomy => 'Fuel Economy';

  @override
  String get categoryPressure => 'Pressure';

  @override
  String get categoryEnergy => 'Energy';

  @override
  String get labelFrom => 'FROM';

  @override
  String get labelTo => 'TO';

  @override
  String get labelAllConversions => 'ALL CONVERSIONS';

  @override
  String labelUnitsAvailable(int count) {
    return '$count units available';
  }

  @override
  String get calcStandard => 'Standard';

  @override
  String get calcScientific => 'Scientific';

  @override
  String get calcPercentage => 'Percentage';

  @override
  String get calcBase => 'Base';

  @override
  String get calcFraction => 'Fraction';

  @override
  String get financeTax => 'Tax';

  @override
  String get financeTip => 'Tip & Split';

  @override
  String get financeDiscount => 'Discount';

  @override
  String get financeCompound => 'Compound Interest';

  @override
  String get financeEMI => 'EMI / Loan';

  @override
  String get financeCurrency => 'Currency';

  @override
  String get financeUnitPrice => 'Unit Price';

  @override
  String get toolGps => 'GPS Coordinates';

  @override
  String get toolOhm => 'Ohm\'s Law';

  @override
  String get toolBmi => 'BMI';

  @override
  String get toolDateDiff => 'Date Difference';

  @override
  String get toolTimeZones => 'Time Zones';

  @override
  String get toolAdcDac => 'ADC / DAC';

  @override
  String get toolAge => 'Age';

  @override
  String get toolAspectRatio => 'Aspect Ratio';

  @override
  String get toolCalendar => 'Calendar';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubscription => 'Subscription';

  @override
  String get settingsSubscribePro => 'Subscribe to Pro';

  @override
  String get settingsCalcMasterPro => 'CalcMaster Pro';

  @override
  String get settingsRestorePurchases => 'Restore purchases';

  @override
  String get settingsPreferences => 'Preferences';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsHelp => 'Help';

  @override
  String get settingsSendFeedback => 'Send feedback';

  @override
  String get settingsPrivacyPolicy => 'Privacy policy';

  @override
  String get settingsAbout => 'About CalcMaster';

  @override
  String get paywallTitle => 'Unlock CalcMaster Pro';

  @override
  String get paywallSubtitle =>
      'Remove ads, get advanced insights, refresh currency rates instantly, and support indie development.';

  @override
  String get paywallBenefitAdFree => 'Ad-free experience';

  @override
  String get paywallBenefitAdvanced => 'Advanced tax + finance insights';

  @override
  String get paywallBenefitRealtime => 'Real-time currency refresh';

  @override
  String get paywallBenefitSupport => 'Priority email support';

  @override
  String get paywallTierMonthly => 'Monthly';

  @override
  String get paywallTierAnnual => 'Annual';

  @override
  String get paywallTierLifetime => 'Lifetime';

  @override
  String get paywallBadgeBestValue => 'BEST VALUE';

  @override
  String get paywallContinue => 'Continue';

  @override
  String get paywallProcessing => 'Processing…';

  @override
  String get paywallRestore => 'Restore purchases';

  @override
  String get paywallTermsFooter =>
      'By continuing you agree to our Terms and Privacy Policy.';

  @override
  String get paywallSubscriptionsDisabled =>
      'Subscriptions are not yet enabled in this build.';

  @override
  String get paywallCancelAnytime => 'Cancel anytime';

  @override
  String get paywallAnnualSavings => 'Save 44% · most popular';

  @override
  String get paywallLifetimeForever => 'Pay once, own it forever';

  @override
  String get regionPickerTitle => 'Select region';

  @override
  String get notesAddNote => 'Add note';

  @override
  String get notesSaveChanges => 'Save changes';

  @override
  String get notesSearch => 'Search notes';

  @override
  String get notesEmpty => 'No notes yet. Add your first one above.';

  @override
  String get notesDeleteHint => 'Tip: long-press a note to delete.';

  @override
  String get notesNewTitleHint => 'New note title';

  @override
  String get notesTitleHint => 'Title';

  @override
  String get notesBodyHint => 'Body';

  @override
  String actionCopy(String value) {
    return 'Copied: $value';
  }

  @override
  String get actionUseMyLocation => 'Use my location';

  @override
  String get actionLocating => 'Locating…';

  @override
  String get actionPermissionDenied => 'Location permission denied';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutBuild => 'Build';

  @override
  String get aboutMadeWith => 'Made with';

  @override
  String get aboutBlurb =>
      'CalcMaster bundles the calculators most people actually use — unit conversions, percentages, scientific math, tax + finance, electronics, and a notes pad — in one polished app that respects your privacy and your battery.';

  @override
  String get aiChatHint => 'Ask CalcMaster AI...';

  @override
  String get aiChatTitle => 'CalcMaster AI';

  @override
  String get aiChatEmpty =>
      'Ask me anything about calculations, conversions, or finance.';

  @override
  String get authTwoFactor => 'Two-Factor Authentication';

  @override
  String get authCancel => 'Cancel';

  @override
  String get authVerify => 'Verify';

  @override
  String get authOtpHint => '000000';

  @override
  String get privacyAtGlance => 'Privacy at a glance';

  @override
  String get deleteNoteTitle => 'Delete this note?';

  @override
  String get deleteNoteCancel => 'Cancel';

  @override
  String get deleteNoteConfirm => 'Delete';

  @override
  String get labelFilingStatus => 'Filing status';

  @override
  String get labelCompoundFreq => 'Compounding frequency';

  @override
  String get labelInputBase => 'Input base';

  @override
  String get labelOperator => 'Operator';

  @override
  String get labelPerUnit => 'Per unit';

  @override
  String get labelXofY => 'X% of Y';

  @override
  String get labelXisWhatPctOfY => 'X is what % of Y';

  @override
  String get labelPctChangeXtoY => '% change from X to Y';
}
