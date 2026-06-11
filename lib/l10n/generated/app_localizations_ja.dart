// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Calculator';

  @override
  String get appTagline => 'ワールド計算機 & コンバーター';

  @override
  String get tabConvert => '変換';

  @override
  String get tabCalculate => '計算';

  @override
  String get tabFinance => 'ファイナンス';

  @override
  String get tabTools => 'ツール';

  @override
  String get tabNotes => 'ノート';

  @override
  String get pillUnitConversion => '単位変換';

  @override
  String get pillCalculators => '計算機';

  @override
  String get pillFinanceTools => 'ファイナンスツール';

  @override
  String get pillUtilityTools => 'ユーティリティ';

  @override
  String get pillSavedNotes => '保存したノート';

  @override
  String get convertHubHeading => '変換';

  @override
  String get convertHubSubheading => '任意の単位をタップしてすぐ変換';

  @override
  String get calculateHubHeading => '計算';

  @override
  String get calculateHubSubheading => '標準 · 関数 · パーセント · 基数 · 分数';

  @override
  String get financeHubHeading => 'ファイナンス';

  @override
  String get financeHubSubheading => '税 · チップ · 割引 · 複利 · ローン · 通貨 · 単価';

  @override
  String get toolsHubHeading => 'ツール';

  @override
  String get toolsHubSubheading =>
      'GPS · オームの法則 · BMI · 日付差 · タイムゾーン · ADC/DAC · 年齢 · アスペクト比';

  @override
  String get notesHubHeading => 'ノート';

  @override
  String get notesHubSubheading => '計算、数式、リマインダーを保存';

  @override
  String get categoryDistance => '距離';

  @override
  String get categoryVolume => '体積';

  @override
  String get categoryWeight => '重さ';

  @override
  String get categoryTemperature => '温度';

  @override
  String get categorySpeed => '速度';

  @override
  String get categoryArea => '面積';

  @override
  String get categoryDataSize => 'データサイズ';

  @override
  String get categoryFuelEconomy => '燃費';

  @override
  String get categoryPressure => '圧力';

  @override
  String get categoryEnergy => 'エネルギー';

  @override
  String get labelFrom => 'から';

  @override
  String get labelTo => 'へ';

  @override
  String get labelAllConversions => 'すべての変換';

  @override
  String labelUnitsAvailable(int count) {
    return '$count 単位利用可能';
  }

  @override
  String get calcStandard => '標準';

  @override
  String get calcScientific => '関数';

  @override
  String get calcPercentage => 'パーセント';

  @override
  String get calcBase => '基数';

  @override
  String get calcFraction => '分数';

  @override
  String get financeTax => '税';

  @override
  String get financeTip => 'チップと割り勘';

  @override
  String get financeDiscount => '割引';

  @override
  String get financeCompound => '複利';

  @override
  String get financeEMI => 'ローン';

  @override
  String get financeCurrency => '通貨';

  @override
  String get financeUnitPrice => '単価';

  @override
  String get toolGps => 'GPS 座標';

  @override
  String get toolOhm => 'オームの法則';

  @override
  String get toolBmi => 'BMI';

  @override
  String get toolDateDiff => '日付差';

  @override
  String get toolTimeZones => 'タイムゾーン';

  @override
  String get toolAdcDac => 'ADC / DAC';

  @override
  String get toolAge => '年齢';

  @override
  String get toolAspectRatio => 'アスペクト比';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsSubscription => 'サブスクリプション';

  @override
  String get settingsSubscribePro => 'Pro に登録';

  @override
  String get settingsCalcMasterPro => 'Calculator Pro';

  @override
  String get settingsRestorePurchases => '購入を復元';

  @override
  String get settingsPreferences => '環境設定';

  @override
  String get settingsNotifications => '通知';

  @override
  String get settingsHelp => 'ヘルプ';

  @override
  String get settingsSendFeedback => 'フィードバックを送る';

  @override
  String get settingsPrivacyPolicy => 'プライバシーポリシー';

  @override
  String get settingsAbout => 'Calculator について';

  @override
  String get paywallTitle => 'Calculator Pro を解放';

  @override
  String get paywallSubtitle => '広告非表示、詳細インサイト、リアルタイム為替、開発支援。';

  @override
  String get paywallBenefitAdFree => '広告なし体験';

  @override
  String get paywallBenefitAdvanced => '高度な税務・財務インサイト';

  @override
  String get paywallBenefitRealtime => 'リアルタイム為替更新';

  @override
  String get paywallBenefitSupport => '優先メールサポート';

  @override
  String get paywallTierMonthly => '月額';

  @override
  String get paywallTierAnnual => '年額';

  @override
  String get paywallTierLifetime => '買い切り';

  @override
  String get paywallBadgeBestValue => '最もお得';

  @override
  String get paywallContinue => '続ける';

  @override
  String get paywallProcessing => '処理中…';

  @override
  String get paywallRestore => '購入を復元';

  @override
  String get paywallTermsFooter => '続行することで、利用規約とプライバシーポリシーに同意したものとみなされます。';

  @override
  String get paywallSubscriptionsDisabled => 'このビルドではサブスクリプションがまだ有効になっていません。';

  @override
  String get paywallCancelAnytime => 'いつでも解約可';

  @override
  String get paywallAnnualSavings => '44%お得 · 一番人気';

  @override
  String get paywallLifetimeForever => '1度の支払いで永久利用';

  @override
  String get regionPickerTitle => '地域を選択';

  @override
  String get notesAddNote => 'ノートを追加';

  @override
  String get notesSaveChanges => '変更を保存';

  @override
  String get notesSearch => 'ノートを検索';

  @override
  String get notesEmpty => 'まだノートがありません。上から最初の1件を追加してください。';

  @override
  String get notesDeleteHint => 'ヒント: ノートを長押しで削除。';

  @override
  String get notesNewTitleHint => '新規ノートのタイトル';

  @override
  String get notesTitleHint => 'タイトル';

  @override
  String get notesBodyHint => '本文';

  @override
  String actionCopy(String value) {
    return 'コピーしました: $value';
  }

  @override
  String get actionUseMyLocation => '現在地を使う';

  @override
  String get actionLocating => '位置情報を取得中…';

  @override
  String get actionPermissionDenied => '位置情報の許可が拒否されました';

  @override
  String get aboutVersion => 'バージョン';

  @override
  String get aboutBuild => 'ビルド';

  @override
  String get aboutMadeWith => '制作';

  @override
  String get aboutBlurb =>
      'Calculator は、人々が本当によく使う計算機を1つの洗練されたアプリにまとめました — 単位変換、パーセント、関数計算、税務・ファイナンス、エレクトロニクス、そしてノートパッド。プライバシーとバッテリーを尊重します。';

  @override
  String get aiChatHint => 'Calculator AIに質問...';

  @override
  String get aiChatTitle => 'Calculator AI';

  @override
  String get aiChatEmpty => '計算・変換・財務について何でも聞いてください。';

  @override
  String get authTwoFactor => '二段階認証';

  @override
  String get authCancel => 'キャンセル';

  @override
  String get authVerify => '確認';

  @override
  String get authOtpHint => '000000';

  @override
  String get privacyAtGlance => 'プライバシーの概要';

  @override
  String get deleteNoteTitle => 'このメモを削除しますか？';

  @override
  String get deleteNoteCancel => 'キャンセル';

  @override
  String get deleteNoteConfirm => '削除';

  @override
  String get labelFilingStatus => '申告状況';

  @override
  String get labelCompoundFreq => '複利頻度';

  @override
  String get labelInputBase => '入力基数';

  @override
  String get labelOperator => '演算子';

  @override
  String get labelPerUnit => '単位あたり';

  @override
  String get labelXofY => 'YのX%';

  @override
  String get labelXisWhatPctOfY => 'XはYの何%か';

  @override
  String get labelPctChangeXtoY => 'XからYへの%変化';
}
