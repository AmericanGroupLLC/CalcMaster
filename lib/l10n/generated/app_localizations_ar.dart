// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'CalcMaster';

  @override
  String get appTagline => 'حاسبة ومحوّل عالمي';

  @override
  String get tabConvert => 'تحويل';

  @override
  String get tabCalculate => 'حساب';

  @override
  String get tabFinance => 'مالية';

  @override
  String get tabTools => 'أدوات';

  @override
  String get tabNotes => 'ملاحظات';

  @override
  String get pillUnitConversion => 'تحويل الوحدات';

  @override
  String get pillCalculators => 'حاسبات';

  @override
  String get pillFinanceTools => 'أدوات مالية';

  @override
  String get pillUtilityTools => 'أدوات مفيدة';

  @override
  String get pillSavedNotes => 'الملاحظات المحفوظة';

  @override
  String get convertHubHeading => 'تحويل';

  @override
  String get convertHubSubheading => 'اضغط على أي وحدة للتحويل فورًا';

  @override
  String get calculateHubHeading => 'حساب';

  @override
  String get calculateHubSubheading => 'قياسي · علمي · نسبة مئوية · أساس · كسر';

  @override
  String get financeHubHeading => 'مالية';

  @override
  String get financeHubSubheading =>
      'ضريبة · بقشيش · خصم · فائدة مركبة · قسط · عملة · سعر الوحدة';

  @override
  String get toolsHubHeading => 'أدوات';

  @override
  String get toolsHubSubheading =>
      'GPS · قانون أوم · BMI · فرق التواريخ · المناطق الزمنية · ADC/DAC · العمر · النسبة';

  @override
  String get notesHubHeading => 'ملاحظات';

  @override
  String get notesHubSubheading => 'احفظ الحسابات والمعادلات والتذكيرات';

  @override
  String get categoryDistance => 'المسافة';

  @override
  String get categoryVolume => 'الحجم';

  @override
  String get categoryWeight => 'الوزن';

  @override
  String get categoryTemperature => 'درجة الحرارة';

  @override
  String get categorySpeed => 'السرعة';

  @override
  String get categoryArea => 'المساحة';

  @override
  String get categoryDataSize => 'حجم البيانات';

  @override
  String get categoryFuelEconomy => 'استهلاك الوقود';

  @override
  String get categoryPressure => 'الضغط';

  @override
  String get categoryEnergy => 'الطاقة';

  @override
  String get labelFrom => 'من';

  @override
  String get labelTo => 'إلى';

  @override
  String get labelAllConversions => 'جميع التحويلات';

  @override
  String labelUnitsAvailable(int count) {
    return '$count وحدات متاحة';
  }

  @override
  String get calcStandard => 'قياسي';

  @override
  String get calcScientific => 'علمي';

  @override
  String get calcPercentage => 'نسبة مئوية';

  @override
  String get calcBase => 'أساس';

  @override
  String get calcFraction => 'كسر';

  @override
  String get financeTax => 'ضريبة';

  @override
  String get financeTip => 'بقشيش وتقسيم';

  @override
  String get financeDiscount => 'خصم';

  @override
  String get financeCompound => 'فائدة مركبة';

  @override
  String get financeEMI => 'قسط / قرض';

  @override
  String get financeCurrency => 'عملة';

  @override
  String get financeUnitPrice => 'سعر الوحدة';

  @override
  String get toolGps => 'إحداثيات GPS';

  @override
  String get toolOhm => 'قانون أوم';

  @override
  String get toolBmi => 'BMI';

  @override
  String get toolDateDiff => 'فرق التواريخ';

  @override
  String get toolTimeZones => 'المناطق الزمنية';

  @override
  String get toolAdcDac => 'ADC / DAC';

  @override
  String get toolAge => 'العمر';

  @override
  String get toolAspectRatio => 'نسبة العرض';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsSubscription => 'الاشتراك';

  @override
  String get settingsSubscribePro => 'اشترك في Pro';

  @override
  String get settingsCalcMasterPro => 'CalcMaster Pro';

  @override
  String get settingsRestorePurchases => 'استعادة المشتريات';

  @override
  String get settingsPreferences => 'التفضيلات';

  @override
  String get settingsNotifications => 'الإشعارات';

  @override
  String get settingsHelp => 'المساعدة';

  @override
  String get settingsSendFeedback => 'إرسال ملاحظات';

  @override
  String get settingsPrivacyPolicy => 'سياسة الخصوصية';

  @override
  String get settingsAbout => 'حول CalcMaster';

  @override
  String get paywallTitle => 'افتح CalcMaster Pro';

  @override
  String get paywallSubtitle =>
      'بدون إعلانات، رؤى متقدمة، تحديث فوري لأسعار العملات، ودعم التطوير المستقل.';

  @override
  String get paywallBenefitAdFree => 'تجربة بدون إعلانات';

  @override
  String get paywallBenefitAdvanced => 'رؤى ضريبية ومالية متقدمة';

  @override
  String get paywallBenefitRealtime => 'تحديث فوري لأسعار العملات';

  @override
  String get paywallBenefitSupport => 'دعم بريد إلكتروني ذو أولوية';

  @override
  String get paywallTierMonthly => 'شهري';

  @override
  String get paywallTierAnnual => 'سنوي';

  @override
  String get paywallTierLifetime => 'مدى الحياة';

  @override
  String get paywallBadgeBestValue => 'أفضل قيمة';

  @override
  String get paywallContinue => 'متابعة';

  @override
  String get paywallProcessing => 'جاري المعالجة…';

  @override
  String get paywallRestore => 'استعادة المشتريات';

  @override
  String get paywallTermsFooter =>
      'بالمتابعة، فأنت توافق على شروطنا وسياسة الخصوصية.';

  @override
  String get paywallSubscriptionsDisabled =>
      'الاشتراكات غير مفعّلة في هذا الإصدار.';

  @override
  String get paywallCancelAnytime => 'ألغِ في أي وقت';

  @override
  String get paywallAnnualSavings => 'وفّر 44٪ · الأكثر شعبية';

  @override
  String get paywallLifetimeForever => 'ادفع مرة واحدة، احتفظ بها للأبد';

  @override
  String get regionPickerTitle => 'اختر المنطقة';

  @override
  String get notesAddNote => 'إضافة ملاحظة';

  @override
  String get notesSaveChanges => 'حفظ التغييرات';

  @override
  String get notesSearch => 'البحث في الملاحظات';

  @override
  String get notesEmpty => 'لا توجد ملاحظات بعد. أضف أول واحدة أعلاه.';

  @override
  String get notesDeleteHint => 'تلميح: اضغط مطولاً على الملاحظة للحذف.';

  @override
  String get notesNewTitleHint => 'عنوان الملاحظة الجديدة';

  @override
  String get notesTitleHint => 'العنوان';

  @override
  String get notesBodyHint => 'المحتوى';

  @override
  String actionCopy(String value) {
    return 'تم النسخ: $value';
  }

  @override
  String get actionUseMyLocation => 'استخدم موقعي';

  @override
  String get actionLocating => 'جاري تحديد الموقع…';

  @override
  String get actionPermissionDenied => 'تم رفض إذن الموقع';

  @override
  String get aboutVersion => 'الإصدار';

  @override
  String get aboutBuild => 'البناء';

  @override
  String get aboutMadeWith => 'صُنع بـ';

  @override
  String get aboutBlurb =>
      'يجمع CalcMaster الحاسبات التي يستخدمها الناس فعلاً — تحويلات الوحدات، النسب المئوية، الرياضيات العلمية، الضرائب والمالية، الإلكترونيات، ودفتر الملاحظات — في تطبيق واحد أنيق يحترم خصوصيتك وبطاريتك.';

  @override
  String get aiChatHint => 'اسأل CalcMaster AI...';

  @override
  String get aiChatTitle => 'CalcMaster AI';

  @override
  String get aiChatEmpty =>
      'اسألني أي شيء عن الحسابات أو التحويلات أو المالية.';

  @override
  String get authTwoFactor => 'المصادقة الثنائية';

  @override
  String get authCancel => 'إلغاء';

  @override
  String get authVerify => 'تحقق';

  @override
  String get authOtpHint => '000000';

  @override
  String get privacyAtGlance => 'الخصوصية في لمحة';

  @override
  String get deleteNoteTitle => 'حذف هذه الملاحظة؟';

  @override
  String get deleteNoteCancel => 'إلغاء';

  @override
  String get deleteNoteConfirm => 'حذف';

  @override
  String get labelFilingStatus => 'حالة الإيداع الضريبي';

  @override
  String get labelCompoundFreq => 'تكرار الفائدة المركبة';

  @override
  String get labelInputBase => 'قاعدة الإدخال';

  @override
  String get labelOperator => 'العملية';

  @override
  String get labelPerUnit => 'لكل وحدة';

  @override
  String get labelXofY => 'X% من Y';

  @override
  String get labelXisWhatPctOfY => 'X هو كم % من Y';

  @override
  String get labelPctChangeXtoY => '% التغيير من X إلى Y';
}
