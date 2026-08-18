// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'CalcMaster';

  @override
  String get appTagline => 'Мировой калькулятор и конвертер';

  @override
  String get tabConvert => 'Конвертер';

  @override
  String get tabCalculate => 'Калькулятор';

  @override
  String get tabFinance => 'Финансы';

  @override
  String get tabTools => 'Инструменты';

  @override
  String get tabNotes => 'Заметки';

  @override
  String get pillUnitConversion => 'Конверсия единиц';

  @override
  String get pillCalculators => 'Калькуляторы';

  @override
  String get pillFinanceTools => 'Финансовые инструменты';

  @override
  String get pillUtilityTools => 'Утилиты';

  @override
  String get pillSavedNotes => 'Сохранённые заметки';

  @override
  String get convertHubHeading => 'Конвертер';

  @override
  String get convertHubSubheading =>
      'Нажмите на единицу для мгновенной конверсии';

  @override
  String get calculateHubHeading => 'Калькулятор';

  @override
  String get calculateHubSubheading =>
      'Стандартный · Научный · Процент · Системы счисления · Дробь';

  @override
  String get financeHubHeading => 'Финансы';

  @override
  String get financeHubSubheading =>
      'Налог · Чаевые · Скидка · Сложный процент · Кредит · Валюта · Цена за единицу';

  @override
  String get toolsHubHeading => 'Инструменты';

  @override
  String get toolsHubSubheading =>
      'GPS · Закон Ома · ИМТ · Разница дат · Часовые пояса · АЦП/ЦАП · Возраст · Соотношение сторон';

  @override
  String get notesHubHeading => 'Заметки';

  @override
  String get notesHubSubheading => 'Сохраняйте расчёты, формулы и напоминания';

  @override
  String get categoryDistance => 'Расстояние';

  @override
  String get categoryVolume => 'Объём';

  @override
  String get categoryWeight => 'Вес';

  @override
  String get categoryTemperature => 'Температура';

  @override
  String get categorySpeed => 'Скорость';

  @override
  String get categoryArea => 'Площадь';

  @override
  String get categoryDataSize => 'Объём данных';

  @override
  String get categoryFuelEconomy => 'Расход топлива';

  @override
  String get categoryPressure => 'Давление';

  @override
  String get categoryEnergy => 'Энергия';

  @override
  String get labelFrom => 'ИЗ';

  @override
  String get labelTo => 'В';

  @override
  String get labelAllConversions => 'ВСЕ КОНВЕРСИИ';

  @override
  String labelUnitsAvailable(int count) {
    return '$count единиц доступно';
  }

  @override
  String get calcStandard => 'Стандартный';

  @override
  String get calcScientific => 'Научный';

  @override
  String get calcPercentage => 'Процент';

  @override
  String get calcBase => 'Системы';

  @override
  String get calcFraction => 'Дробь';

  @override
  String get financeTax => 'Налог';

  @override
  String get financeTip => 'Чаевые и счёт';

  @override
  String get financeDiscount => 'Скидка';

  @override
  String get financeCompound => 'Сложный процент';

  @override
  String get financeEMI => 'Кредит';

  @override
  String get financeCurrency => 'Валюта';

  @override
  String get financeUnitPrice => 'Цена за единицу';

  @override
  String get toolGps => 'GPS координаты';

  @override
  String get toolOhm => 'Закон Ома';

  @override
  String get toolBmi => 'ИМТ';

  @override
  String get toolDateDiff => 'Разница дат';

  @override
  String get toolTimeZones => 'Часовые пояса';

  @override
  String get toolAdcDac => 'АЦП / ЦАП';

  @override
  String get toolAge => 'Возраст';

  @override
  String get toolAspectRatio => 'Соотношение сторон';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsSubscription => 'Подписка';

  @override
  String get settingsSubscribePro => 'Подписаться на Pro';

  @override
  String get settingsCalcMasterPro => 'CalcMaster Pro';

  @override
  String get settingsRestorePurchases => 'Восстановить покупки';

  @override
  String get settingsPreferences => 'Параметры';

  @override
  String get settingsNotifications => 'Уведомления';

  @override
  String get settingsHelp => 'Помощь';

  @override
  String get settingsSendFeedback => 'Отправить отзыв';

  @override
  String get settingsPrivacyPolicy => 'Политика конфиденциальности';

  @override
  String get settingsAbout => 'О CalcMaster';

  @override
  String get paywallTitle => 'Откройте CalcMaster Pro';

  @override
  String get paywallSubtitle =>
      'Без рекламы, расширенная аналитика, актуальные курсы валют и поддержка независимой разработки.';

  @override
  String get paywallBenefitAdFree => 'Без рекламы';

  @override
  String get paywallBenefitAdvanced =>
      'Расширенный налоговый и финансовый анализ';

  @override
  String get paywallBenefitRealtime => 'Курсы валют в реальном времени';

  @override
  String get paywallBenefitSupport => 'Приоритетная поддержка';

  @override
  String get paywallTierMonthly => 'Ежемесячно';

  @override
  String get paywallTierAnnual => 'Ежегодно';

  @override
  String get paywallTierLifetime => 'Навсегда';

  @override
  String get paywallBadgeBestValue => 'ЛУЧШИЙ ВЫБОР';

  @override
  String get paywallContinue => 'Продолжить';

  @override
  String get paywallProcessing => 'Обработка…';

  @override
  String get paywallRestore => 'Восстановить покупки';

  @override
  String get paywallTermsFooter =>
      'Продолжая, вы соглашаетесь с нашими Условиями и Политикой конфиденциальности.';

  @override
  String get paywallTermsOfUse => 'Условия использования';

  @override
  String get paywallSubscriptionsDisabled =>
      'Подписки ещё не включены в этой сборке.';

  @override
  String get paywallCancelAnytime => 'Отмена в любое время';

  @override
  String get paywallAnnualSavings => 'Экономия 44% · самый популярный';

  @override
  String get paywallLifetimeForever => 'Заплатите один раз, владейте навсегда';

  @override
  String get regionPickerTitle => 'Выберите регион';

  @override
  String get notesAddNote => 'Добавить заметку';

  @override
  String get notesSaveChanges => 'Сохранить изменения';

  @override
  String get notesSearch => 'Поиск заметок';

  @override
  String get notesEmpty => 'Заметок пока нет. Добавьте первую выше.';

  @override
  String get notesDeleteHint => 'Совет: удерживайте заметку для удаления.';

  @override
  String get notesNewTitleHint => 'Заголовок новой заметки';

  @override
  String get notesTitleHint => 'Заголовок';

  @override
  String get notesBodyHint => 'Содержание';

  @override
  String actionCopy(String value) {
    return 'Скопировано: $value';
  }

  @override
  String get actionUseMyLocation => 'Использовать моё местоположение';

  @override
  String get actionLocating => 'Определение…';

  @override
  String get actionPermissionDenied => 'Доступ к местоположению запрещён';

  @override
  String get aboutVersion => 'Версия';

  @override
  String get aboutBuild => 'Сборка';

  @override
  String get aboutMadeWith => 'Сделано с';

  @override
  String get aboutBlurb =>
      'CalcMaster объединяет калькуляторы, которыми люди реально пользуются — конверсии единиц, проценты, научная математика, налоги и финансы, электроника, блокнот — в одном изящном приложении, уважающем вашу приватность и батарею.';

  @override
  String get aiChatHint => 'Спросите CalcMaster AI...';

  @override
  String get aiChatTitle => 'CalcMaster AI';

  @override
  String get aiChatEmpty =>
      'Спросите меня о вычислениях, конвертации или финансах.';

  @override
  String get authTwoFactor => 'Двухфакторная аутентификация';

  @override
  String get authCancel => 'Отмена';

  @override
  String get authVerify => 'Подтвердить';

  @override
  String get authOtpHint => '000000';

  @override
  String get privacyAtGlance => 'Конфиденциальность вкратце';

  @override
  String get deleteNoteTitle => 'Удалить эту заметку?';

  @override
  String get deleteNoteCancel => 'Отмена';

  @override
  String get deleteNoteConfirm => 'Удалить';

  @override
  String get labelFilingStatus => 'Статус подачи';

  @override
  String get labelCompoundFreq => 'Частота начисления';

  @override
  String get labelInputBase => 'Система счисления';

  @override
  String get labelOperator => 'Оператор';

  @override
  String get labelPerUnit => 'За единицу';

  @override
  String get labelXofY => 'X% от Y';

  @override
  String get labelXisWhatPctOfY => 'X — какой % от Y';

  @override
  String get labelPctChangeXtoY => '% изменения от X до Y';
}
