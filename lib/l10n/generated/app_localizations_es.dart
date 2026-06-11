// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Calculator';

  @override
  String get appTagline => 'Calculadora y conversor mundial';

  @override
  String get tabConvert => 'Convertir';

  @override
  String get tabCalculate => 'Calcular';

  @override
  String get tabFinance => 'Finanzas';

  @override
  String get tabTools => 'Herramientas';

  @override
  String get tabNotes => 'Notas';

  @override
  String get pillUnitConversion => 'Conversión de unidades';

  @override
  String get pillCalculators => 'Calculadoras';

  @override
  String get pillFinanceTools => 'Herramientas financieras';

  @override
  String get pillUtilityTools => 'Herramientas útiles';

  @override
  String get pillSavedNotes => 'Notas guardadas';

  @override
  String get convertHubHeading => 'Convertir';

  @override
  String get convertHubSubheading =>
      'Toca cualquier unidad para convertir al instante';

  @override
  String get calculateHubHeading => 'Calcular';

  @override
  String get calculateHubSubheading =>
      'Estándar · Científica · Porcentaje · Base · Fracción';

  @override
  String get financeHubHeading => 'Finanzas';

  @override
  String get financeHubSubheading =>
      'Impuestos · Propina · Descuento · Interés compuesto · Préstamo · Divisas · Precio unitario';

  @override
  String get toolsHubHeading => 'Herramientas';

  @override
  String get toolsHubSubheading =>
      'GPS · Ley de Ohm · IMC · Diferencia de fechas · Zonas horarias · ADC/DAC · Edad · Relación de aspecto';

  @override
  String get notesHubHeading => 'Notas';

  @override
  String get notesHubSubheading => 'Guarda cálculos, fórmulas y recordatorios';

  @override
  String get categoryDistance => 'Distancia';

  @override
  String get categoryVolume => 'Volumen';

  @override
  String get categoryWeight => 'Peso';

  @override
  String get categoryTemperature => 'Temperatura';

  @override
  String get categorySpeed => 'Velocidad';

  @override
  String get categoryArea => 'Área';

  @override
  String get categoryDataSize => 'Tamaño de datos';

  @override
  String get categoryFuelEconomy => 'Consumo';

  @override
  String get categoryPressure => 'Presión';

  @override
  String get categoryEnergy => 'Energía';

  @override
  String get labelFrom => 'DESDE';

  @override
  String get labelTo => 'HASTA';

  @override
  String get labelAllConversions => 'TODAS LAS CONVERSIONES';

  @override
  String labelUnitsAvailable(int count) {
    return '$count unidades disponibles';
  }

  @override
  String get calcStandard => 'Estándar';

  @override
  String get calcScientific => 'Científica';

  @override
  String get calcPercentage => 'Porcentaje';

  @override
  String get calcBase => 'Base';

  @override
  String get calcFraction => 'Fracción';

  @override
  String get financeTax => 'Impuestos';

  @override
  String get financeTip => 'Propina y dividir';

  @override
  String get financeDiscount => 'Descuento';

  @override
  String get financeCompound => 'Interés compuesto';

  @override
  String get financeEMI => 'Préstamo';

  @override
  String get financeCurrency => 'Divisas';

  @override
  String get financeUnitPrice => 'Precio unitario';

  @override
  String get toolGps => 'Coordenadas GPS';

  @override
  String get toolOhm => 'Ley de Ohm';

  @override
  String get toolBmi => 'IMC';

  @override
  String get toolDateDiff => 'Diferencia de fechas';

  @override
  String get toolTimeZones => 'Zonas horarias';

  @override
  String get toolAdcDac => 'ADC / DAC';

  @override
  String get toolAge => 'Edad';

  @override
  String get toolAspectRatio => 'Relación de aspecto';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsSubscription => 'Suscripción';

  @override
  String get settingsSubscribePro => 'Suscríbete a Pro';

  @override
  String get settingsCalcMasterPro => 'Calculator Pro';

  @override
  String get settingsRestorePurchases => 'Restaurar compras';

  @override
  String get settingsPreferences => 'Preferencias';

  @override
  String get settingsNotifications => 'Notificaciones';

  @override
  String get settingsHelp => 'Ayuda';

  @override
  String get settingsSendFeedback => 'Enviar comentarios';

  @override
  String get settingsPrivacyPolicy => 'Política de privacidad';

  @override
  String get settingsAbout => 'Acerca de Calculator';

  @override
  String get paywallTitle => 'Desbloquea Calculator Pro';

  @override
  String get paywallSubtitle =>
      'Sin anuncios, estadísticas avanzadas, divisas en tiempo real y apoya el desarrollo independiente.';

  @override
  String get paywallBenefitAdFree => 'Sin anuncios';

  @override
  String get paywallBenefitAdvanced => 'Análisis fiscal y financiero avanzado';

  @override
  String get paywallBenefitRealtime => 'Divisas en tiempo real';

  @override
  String get paywallBenefitSupport => 'Soporte prioritario por correo';

  @override
  String get paywallTierMonthly => 'Mensual';

  @override
  String get paywallTierAnnual => 'Anual';

  @override
  String get paywallTierLifetime => 'De por vida';

  @override
  String get paywallBadgeBestValue => 'MEJOR VALOR';

  @override
  String get paywallContinue => 'Continuar';

  @override
  String get paywallProcessing => 'Procesando…';

  @override
  String get paywallRestore => 'Restaurar compras';

  @override
  String get paywallTermsFooter =>
      'Al continuar aceptas nuestros Términos y Política de privacidad.';

  @override
  String get paywallSubscriptionsDisabled =>
      'Las suscripciones aún no están habilitadas en esta versión.';

  @override
  String get paywallCancelAnytime => 'Cancela cuando quieras';

  @override
  String get paywallAnnualSavings => 'Ahorra 44% · más popular';

  @override
  String get paywallLifetimeForever => 'Paga una vez, tuyo para siempre';

  @override
  String get regionPickerTitle => 'Selecciona región';

  @override
  String get notesAddNote => 'Añadir nota';

  @override
  String get notesSaveChanges => 'Guardar cambios';

  @override
  String get notesSearch => 'Buscar notas';

  @override
  String get notesEmpty => 'Aún no hay notas. Añade la primera arriba.';

  @override
  String get notesDeleteHint =>
      'Truco: mantén pulsada una nota para eliminarla.';

  @override
  String get notesNewTitleHint => 'Título de la nueva nota';

  @override
  String get notesTitleHint => 'Título';

  @override
  String get notesBodyHint => 'Contenido';

  @override
  String actionCopy(String value) {
    return 'Copiado: $value';
  }

  @override
  String get actionUseMyLocation => 'Usar mi ubicación';

  @override
  String get actionLocating => 'Localizando…';

  @override
  String get actionPermissionDenied => 'Permiso de ubicación denegado';

  @override
  String get aboutVersion => 'Versión';

  @override
  String get aboutBuild => 'Compilación';

  @override
  String get aboutMadeWith => 'Hecho con';

  @override
  String get aboutBlurb =>
      'Calculator reúne las calculadoras que la gente realmente usa — conversiones de unidades, porcentajes, matemáticas científicas, impuestos y finanzas, electrónica, y un bloc de notas — en una sola aplicación pulida que respeta tu privacidad y tu batería.';

  @override
  String get aiChatHint => 'Pregunta a Calculator AI...';

  @override
  String get aiChatTitle => 'Calculator AI';

  @override
  String get aiChatEmpty =>
      'Pregúntame cualquier cosa sobre cálculos, conversiones o finanzas.';

  @override
  String get authTwoFactor => 'Autenticación de dos factores';

  @override
  String get authCancel => 'Cancelar';

  @override
  String get authVerify => 'Verificar';

  @override
  String get authOtpHint => '000000';

  @override
  String get privacyAtGlance => 'Privacidad en resumen';

  @override
  String get deleteNoteTitle => '¿Eliminar esta nota?';

  @override
  String get deleteNoteCancel => 'Cancelar';

  @override
  String get deleteNoteConfirm => 'Eliminar';

  @override
  String get labelFilingStatus => 'Estado civil fiscal';

  @override
  String get labelCompoundFreq => 'Frecuencia de capitalización';

  @override
  String get labelInputBase => 'Base de entrada';

  @override
  String get labelOperator => 'Operador';

  @override
  String get labelPerUnit => 'Por unidad';

  @override
  String get labelXofY => 'X% de Y';

  @override
  String get labelXisWhatPctOfY => 'X es qué % de Y';

  @override
  String get labelPctChangeXtoY => '% de cambio de X a Y';
}
