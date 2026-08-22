// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'CalcMaster';

  @override
  String get appTagline => '월드 계산기 & 변환기';

  @override
  String get tabConvert => '변환';

  @override
  String get tabCalculate => '계산';

  @override
  String get tabFinance => '금융';

  @override
  String get tabTools => '도구';

  @override
  String get tabNotes => '메모';

  @override
  String get pillUnitConversion => '단위 변환';

  @override
  String get pillCalculators => '계산기';

  @override
  String get pillFinanceTools => '금융 도구';

  @override
  String get pillUtilityTools => '유틸리티 도구';

  @override
  String get pillSavedNotes => '저장된 메모';

  @override
  String get convertHubHeading => '변환';

  @override
  String get convertHubSubheading => '단위를 탭하여 즉시 변환';

  @override
  String get calculateHubHeading => '계산';

  @override
  String get calculateHubSubheading => '표준 · 공학 · 백분율 · 진수 · 분수';

  @override
  String get financeHubHeading => '금융';

  @override
  String get financeHubSubheading => '세금 · 팁 · 할인 · 복리 · 대출 · 환율 · 단위가격';

  @override
  String get toolsHubHeading => '도구';

  @override
  String get toolsHubSubheading =>
      'GPS · 옴의 법칙 · BMI · 날짜 차이 · 시간대 · ADC/DAC · 나이 · 화면 비율';

  @override
  String get notesHubHeading => '메모';

  @override
  String get notesHubSubheading => '계산, 공식, 알림 저장';

  @override
  String get categoryDistance => '거리';

  @override
  String get categoryVolume => '부피';

  @override
  String get categoryWeight => '무게';

  @override
  String get categoryTemperature => '온도';

  @override
  String get categorySpeed => '속도';

  @override
  String get categoryArea => '면적';

  @override
  String get categoryDataSize => '데이터 크기';

  @override
  String get categoryFuelEconomy => '연비';

  @override
  String get categoryPressure => '압력';

  @override
  String get categoryEnergy => '에너지';

  @override
  String get labelFrom => '에서';

  @override
  String get labelTo => '으로';

  @override
  String get labelAllConversions => '모든 변환';

  @override
  String labelUnitsAvailable(int count) {
    return '$count개 단위 사용 가능';
  }

  @override
  String get calcStandard => '표준';

  @override
  String get calcScientific => '공학';

  @override
  String get calcPercentage => '백분율';

  @override
  String get calcBase => '진수';

  @override
  String get calcFraction => '분수';

  @override
  String get financeTax => '세금';

  @override
  String get financeTip => '팁 & 분할';

  @override
  String get financeDiscount => '할인';

  @override
  String get financeCompound => '복리';

  @override
  String get financeEMI => '대출';

  @override
  String get financeCurrency => '환율';

  @override
  String get financeUnitPrice => '단위가격';

  @override
  String get toolGps => 'GPS 좌표';

  @override
  String get toolOhm => '옴의 법칙';

  @override
  String get toolBmi => 'BMI';

  @override
  String get toolDateDiff => '날짜 차이';

  @override
  String get toolTimeZones => '시간대';

  @override
  String get toolAdcDac => 'ADC / DAC';

  @override
  String get toolAge => '나이';

  @override
  String get toolAspectRatio => '화면 비율';

  @override
  String get toolCalendar => 'Calendar';

  @override
  String get settingsTitle => '설정';

  @override
  String get settingsSubscription => '구독';

  @override
  String get settingsSubscribePro => 'Pro 구독';

  @override
  String get settingsCalcMasterPro => 'CalcMaster Pro';

  @override
  String get settingsRestorePurchases => '구매 복원';

  @override
  String get settingsPreferences => '환경설정';

  @override
  String get settingsNotifications => '알림';

  @override
  String get settingsHelp => '도움말';

  @override
  String get settingsSendFeedback => '피드백 보내기';

  @override
  String get settingsPrivacyPolicy => '개인정보 처리방침';

  @override
  String get settingsAbout => 'CalcMaster 정보';

  @override
  String get paywallTitle => 'CalcMaster Pro 잠금 해제';

  @override
  String get paywallSubtitle => '광고 제거, 고급 인사이트, 실시간 환율, 인디 개발 지원.';

  @override
  String get paywallBenefitAdFree => '광고 없는 경험';

  @override
  String get paywallBenefitAdvanced => '고급 세금 + 금융 인사이트';

  @override
  String get paywallBenefitRealtime => '실시간 환율 새로고침';

  @override
  String get paywallBenefitSupport => '우선 이메일 지원';

  @override
  String get paywallTierMonthly => '월간';

  @override
  String get paywallTierAnnual => '연간';

  @override
  String get paywallTierLifetime => '평생';

  @override
  String get paywallBadgeBestValue => '최고의 가치';

  @override
  String get paywallContinue => '계속';

  @override
  String get paywallProcessing => '처리 중…';

  @override
  String get paywallRestore => '구매 복원';

  @override
  String get paywallTermsFooter => '계속하면 약관 및 개인정보 처리방침에 동의하는 것입니다.';

  @override
  String get paywallSubscriptionsDisabled => '이 빌드에서는 구독이 아직 활성화되지 않았습니다.';

  @override
  String get paywallCancelAnytime => '언제든 취소';

  @override
  String get paywallAnnualSavings => '44% 절약 · 가장 인기';

  @override
  String get paywallLifetimeForever => '한 번 결제, 평생 소유';

  @override
  String get regionPickerTitle => '지역 선택';

  @override
  String get notesAddNote => '메모 추가';

  @override
  String get notesSaveChanges => '변경 사항 저장';

  @override
  String get notesSearch => '메모 검색';

  @override
  String get notesEmpty => '아직 메모가 없습니다. 위에서 첫 메모를 추가하세요.';

  @override
  String get notesDeleteHint => '팁: 메모를 길게 눌러 삭제.';

  @override
  String get notesNewTitleHint => '새 메모 제목';

  @override
  String get notesTitleHint => '제목';

  @override
  String get notesBodyHint => '내용';

  @override
  String actionCopy(String value) {
    return '복사됨: $value';
  }

  @override
  String get actionUseMyLocation => '내 위치 사용';

  @override
  String get actionLocating => '위치 확인 중…';

  @override
  String get actionPermissionDenied => '위치 권한 거부됨';

  @override
  String get aboutVersion => '버전';

  @override
  String get aboutBuild => '빌드';

  @override
  String get aboutMadeWith => '제작';

  @override
  String get aboutBlurb =>
      'CalcMaster는 사람들이 실제로 사용하는 계산기들을 한 앱에 모았습니다 — 단위 변환, 백분율, 공학 계산, 세금 + 금융, 전자공학, 메모장. 개인정보와 배터리를 존중합니다.';

  @override
  String get aiChatHint => 'CalcMaster AI에게 질문...';

  @override
  String get aiChatTitle => 'CalcMaster AI';

  @override
  String get aiChatEmpty => '계산, 변환 또는 재무에 대해 무엇이든 물어보세요.';

  @override
  String get authTwoFactor => '이중 인증';

  @override
  String get authCancel => '취소';

  @override
  String get authVerify => '확인';

  @override
  String get authOtpHint => '000000';

  @override
  String get privacyAtGlance => '개인정보 보호 요약';

  @override
  String get deleteNoteTitle => '이 메모를 삭제하시겠습니까?';

  @override
  String get deleteNoteCancel => '취소';

  @override
  String get deleteNoteConfirm => '삭제';

  @override
  String get labelFilingStatus => '신고 상태';

  @override
  String get labelCompoundFreq => '복리 빈도';

  @override
  String get labelInputBase => '입력 진수';

  @override
  String get labelOperator => '연산자';

  @override
  String get labelPerUnit => '단위당';

  @override
  String get labelXofY => 'Y의 X%';

  @override
  String get labelXisWhatPctOfY => 'X는 Y의 몇 %인가';

  @override
  String get labelPctChangeXtoY => 'X에서 Y로의 % 변화';
}
