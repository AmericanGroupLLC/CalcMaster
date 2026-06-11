// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Calculator';

  @override
  String get appTagline => 'Calculatrice et convertisseur mondial';

  @override
  String get tabConvert => 'Convertir';

  @override
  String get tabCalculate => 'Calculer';

  @override
  String get tabFinance => 'Finance';

  @override
  String get tabTools => 'Outils';

  @override
  String get tabNotes => 'Notes';

  @override
  String get pillUnitConversion => 'Conversion d\'unités';

  @override
  String get pillCalculators => 'Calculatrices';

  @override
  String get pillFinanceTools => 'Outils financiers';

  @override
  String get pillUtilityTools => 'Outils utilitaires';

  @override
  String get pillSavedNotes => 'Notes enregistrées';

  @override
  String get convertHubHeading => 'Convertir';

  @override
  String get convertHubSubheading =>
      'Touchez n\'importe quelle unité pour convertir instantanément';

  @override
  String get calculateHubHeading => 'Calculer';

  @override
  String get calculateHubSubheading =>
      'Standard · Scientifique · Pourcentage · Base · Fraction';

  @override
  String get financeHubHeading => 'Finance';

  @override
  String get financeHubSubheading =>
      'Impôt · Pourboire · Remise · Intérêts composés · Prêt · Devise · Prix unitaire';

  @override
  String get toolsHubHeading => 'Outils';

  @override
  String get toolsHubSubheading =>
      'GPS · Loi d\'Ohm · IMC · Différence de date · Fuseaux horaires · ADC/DAC · Âge · Format d\'image';

  @override
  String get notesHubHeading => 'Notes';

  @override
  String get notesHubSubheading => 'Enregistrez calculs, formules et rappels';

  @override
  String get categoryDistance => 'Distance';

  @override
  String get categoryVolume => 'Volume';

  @override
  String get categoryWeight => 'Poids';

  @override
  String get categoryTemperature => 'Température';

  @override
  String get categorySpeed => 'Vitesse';

  @override
  String get categoryArea => 'Surface';

  @override
  String get categoryDataSize => 'Taille de données';

  @override
  String get categoryFuelEconomy => 'Consommation';

  @override
  String get categoryPressure => 'Pression';

  @override
  String get categoryEnergy => 'Énergie';

  @override
  String get labelFrom => 'DE';

  @override
  String get labelTo => 'VERS';

  @override
  String get labelAllConversions => 'TOUTES LES CONVERSIONS';

  @override
  String labelUnitsAvailable(int count) {
    return '$count unités disponibles';
  }

  @override
  String get calcStandard => 'Standard';

  @override
  String get calcScientific => 'Scientifique';

  @override
  String get calcPercentage => 'Pourcentage';

  @override
  String get calcBase => 'Base';

  @override
  String get calcFraction => 'Fraction';

  @override
  String get financeTax => 'Impôt';

  @override
  String get financeTip => 'Pourboire & partage';

  @override
  String get financeDiscount => 'Remise';

  @override
  String get financeCompound => 'Intérêts composés';

  @override
  String get financeEMI => 'Prêt / EMI';

  @override
  String get financeCurrency => 'Devise';

  @override
  String get financeUnitPrice => 'Prix unitaire';

  @override
  String get toolGps => 'Coordonnées GPS';

  @override
  String get toolOhm => 'Loi d\'Ohm';

  @override
  String get toolBmi => 'IMC';

  @override
  String get toolDateDiff => 'Différence de date';

  @override
  String get toolTimeZones => 'Fuseaux horaires';

  @override
  String get toolAdcDac => 'ADC / DAC';

  @override
  String get toolAge => 'Âge';

  @override
  String get toolAspectRatio => 'Format d\'image';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsSubscription => 'Abonnement';

  @override
  String get settingsSubscribePro => 'S\'abonner à Pro';

  @override
  String get settingsCalcMasterPro => 'Calculator Pro';

  @override
  String get settingsRestorePurchases => 'Restaurer les achats';

  @override
  String get settingsPreferences => 'Préférences';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsHelp => 'Aide';

  @override
  String get settingsSendFeedback => 'Envoyer un commentaire';

  @override
  String get settingsPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get settingsAbout => 'À propos de Calculator';

  @override
  String get paywallTitle => 'Débloquez Calculator Pro';

  @override
  String get paywallSubtitle =>
      'Sans publicité, statistiques avancées, taux de change en temps réel, et soutien au développement indépendant.';

  @override
  String get paywallBenefitAdFree => 'Expérience sans publicité';

  @override
  String get paywallBenefitAdvanced =>
      'Statistiques fiscales et financières avancées';

  @override
  String get paywallBenefitRealtime => 'Devises en temps réel';

  @override
  String get paywallBenefitSupport => 'Support email prioritaire';

  @override
  String get paywallTierMonthly => 'Mensuel';

  @override
  String get paywallTierAnnual => 'Annuel';

  @override
  String get paywallTierLifetime => 'À vie';

  @override
  String get paywallBadgeBestValue => 'MEILLEURE VALEUR';

  @override
  String get paywallContinue => 'Continuer';

  @override
  String get paywallProcessing => 'Traitement…';

  @override
  String get paywallRestore => 'Restaurer les achats';

  @override
  String get paywallTermsFooter =>
      'En continuant, vous acceptez nos Conditions et notre Politique de confidentialité.';

  @override
  String get paywallSubscriptionsDisabled =>
      'Les abonnements ne sont pas encore activés dans cette version.';

  @override
  String get paywallCancelAnytime => 'Annulez à tout moment';

  @override
  String get paywallAnnualSavings => 'Économisez 44% · le plus populaire';

  @override
  String get paywallLifetimeForever => 'Payez une fois, à vous pour toujours';

  @override
  String get regionPickerTitle => 'Sélectionner la région';

  @override
  String get notesAddNote => 'Ajouter une note';

  @override
  String get notesSaveChanges => 'Enregistrer';

  @override
  String get notesSearch => 'Rechercher des notes';

  @override
  String get notesEmpty => 'Aucune note. Ajoutez la première ci-dessus.';

  @override
  String get notesDeleteHint => 'Astuce : appuyez longuement pour supprimer.';

  @override
  String get notesNewTitleHint => 'Titre de la nouvelle note';

  @override
  String get notesTitleHint => 'Titre';

  @override
  String get notesBodyHint => 'Contenu';

  @override
  String actionCopy(String value) {
    return 'Copié : $value';
  }

  @override
  String get actionUseMyLocation => 'Utiliser ma position';

  @override
  String get actionLocating => 'Localisation…';

  @override
  String get actionPermissionDenied => 'Permission de localisation refusée';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutBuild => 'Build';

  @override
  String get aboutMadeWith => 'Conçu avec';

  @override
  String get aboutBlurb =>
      'Calculator regroupe les calculatrices que les gens utilisent vraiment — conversions d\'unités, pourcentages, mathématiques scientifiques, impôts et finance, électronique, et un bloc-notes — dans une seule application soignée qui respecte votre vie privée et votre batterie.';

  @override
  String get aiChatHint => 'Demandez à Calculator AI...';

  @override
  String get aiChatTitle => 'Calculator AI';

  @override
  String get aiChatEmpty =>
      'Posez-moi des questions sur les calculs, conversions ou finances.';

  @override
  String get authTwoFactor => 'Authentification à deux facteurs';

  @override
  String get authCancel => 'Annuler';

  @override
  String get authVerify => 'Vérifier';

  @override
  String get authOtpHint => '000000';

  @override
  String get privacyAtGlance => 'Confidentialité en un coup d\'œil';

  @override
  String get deleteNoteTitle => 'Supprimer cette note ?';

  @override
  String get deleteNoteCancel => 'Annuler';

  @override
  String get deleteNoteConfirm => 'Supprimer';

  @override
  String get labelFilingStatus => 'Situation fiscale';

  @override
  String get labelCompoundFreq => 'Fréquence de capitalisation';

  @override
  String get labelInputBase => 'Base d\'entrée';

  @override
  String get labelOperator => 'Opérateur';

  @override
  String get labelPerUnit => 'Par unité';

  @override
  String get labelXofY => 'X% de Y';

  @override
  String get labelXisWhatPctOfY => 'X est quel % de Y';

  @override
  String get labelPctChangeXtoY => '% de variation de X à Y';
}
