// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'M&M Magnat de l\'Immobilier';

  @override
  String get propertyTycoon => 'MAGNAT IMMOBILIER';

  @override
  String get familyEdition => 'ÉDITION FAMILIALE';

  @override
  String get worldCityEdition => 'ÉDITION VILLES DU MONDE';

  @override
  String get chooseNextMove => 'Choisissez votre prochain coup';

  @override
  String get newGame => 'Nouvelle Partie';

  @override
  String get continueGame => 'Continuer';

  @override
  String get howToPlay => 'Comment Jouer';

  @override
  String get settings => 'Paramètres';

  @override
  String get shop => 'Boutique';

  @override
  String get howManyPlayers => 'Combien de Joueurs ?';

  @override
  String get gameSetupTitle => 'Créez votre partie';

  @override
  String get gameSetupSubtitle =>
      'Choisissez une ville, le nombre de joueurs et le style de déplacement.';

  @override
  String get playerSetupSubtitle =>
      'Donnez à chaque joueur un nom, une couleur et un personnage.';

  @override
  String get gameSummary => 'Résumé de la partie';

  @override
  String get readyToPlay => 'Prêt à jouer';

  @override
  String get playerSetup => 'Configuration des Joueurs';

  @override
  String get chooseBoard => 'Choisir un plateau';

  @override
  String get numberOfPlayers => 'Nombre de Joueurs';

  @override
  String get numberOfDice => 'Nombre de Dés';

  @override
  String get players => 'joueurs';

  @override
  String get oneDie => 'Un Dé';

  @override
  String get twoDice => 'Deux Dés';

  @override
  String get classicStyle => 'Style classique';

  @override
  String get standardRules => 'Règles standard';

  @override
  String get playersStep => 'Joueurs';

  @override
  String get setupStep => 'Configuration';

  @override
  String get back => 'Retour';

  @override
  String get previous => 'Précédent';

  @override
  String get next => 'Suivant';

  @override
  String get startGame => 'Commencer la Partie';

  @override
  String playerN(int number) {
    return 'Joueur $number';
  }

  @override
  String get you => 'Vous';

  @override
  String get ai => 'IA';

  @override
  String get name => 'Nom';

  @override
  String get chooseYourAvatar => 'Choisissez Votre Avatar';

  @override
  String get uniqueNameError => 'Chaque joueur doit avoir un nom unique';

  @override
  String get allPlayersNeedName => 'Tous les joueurs doivent avoir un nom';

  @override
  String get uniqueColorError => 'Chaque joueur doit avoir une couleur unique';

  @override
  String get tutorialRollMove => 'Lancez et Déplacez';

  @override
  String get tutorialRollMoveDesc =>
      'Appuyez sur les dés pour lancer !\nDéplacez-vous autour du plateau.';

  @override
  String get tutorialBuyProperties => 'Achetez des Propriétés';

  @override
  String get tutorialBuyPropertiesDesc =>
      'Vous tombez sur une case libre ?\nAchetez-la et possédez-la !';

  @override
  String get tutorialCollectRent => 'Collectez le Loyer';

  @override
  String get tutorialCollectRentDesc =>
      'D\'autres tombent sur votre propriété ?\nIls VOUS paient !';

  @override
  String get tutorialSpecialSpaces => 'Cases Spéciales';

  @override
  String get tutorialSpecialSpacesDesc =>
      'Cartes chance, prison, gares...\nDes surprises partout !';

  @override
  String get tutorialWinGame => 'Gagnez la Partie !';

  @override
  String get tutorialWinGameDesc =>
      'Le dernier joueur avec de l\'argent gagne !\nMettez vos amis en faillite !';

  @override
  String get letsPlay => 'Jouons !';

  @override
  String get gotIt => 'Compris !';

  @override
  String get startingCash => 'Argent de Départ';

  @override
  String get gameOptions => 'Options de Jeu';

  @override
  String get soundAndLanguage => 'Son et Langue';

  @override
  String get settingsSubtitle =>
      'Préparez votre table avant la prochaine partie';

  @override
  String get playerTrading => 'Échanges entre Joueurs';

  @override
  String get bankFeatures => 'Fonctions Bancaires';

  @override
  String get propertyAuctions => 'Ventes aux Enchères';

  @override
  String get backgroundMusic => 'Musique de Fond';

  @override
  String get gameSounds => 'Sons du Jeu';

  @override
  String get language => 'Langue';

  @override
  String get buyMeACoffee => 'Offrez-moi un café';

  @override
  String get buyMeACoffeeDesc =>
      'Votre soutien aide à garder le jeu gratuit et à jour. Chaque café compte beaucoup !';

  @override
  String get openExternalLink => 'Ouvrir un Lien Externe';

  @override
  String get openBuyMeACoffeeDesc =>
      'Ceci ouvrira buymeacoffee.com dans votre navigateur.';

  @override
  String get cancel => 'Annuler';

  @override
  String get open => 'Ouvrir';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get backToMenu => 'Retour au Menu';

  @override
  String get settingsReset => 'Paramètres réinitialisés';

  @override
  String get propertyAvailable => 'Cette propriété est disponible !';

  @override
  String get price => 'Prix';

  @override
  String get baseRent => 'Loyer de Base';

  @override
  String get rent => 'Loyer';

  @override
  String get utilityRentDesc => '4x ou 10x le lancer de dés';

  @override
  String get yourCash => 'Votre Argent';

  @override
  String get notEnoughCash => 'Pas assez d\'argent !';

  @override
  String get skip => 'Passer';

  @override
  String buyForAmount(String amount) {
    return 'Acheter \$$amount';
  }

  @override
  String get bankruptcy => 'FAILLITE !';

  @override
  String get payRent => 'Payer le Loyer';

  @override
  String landedOnProperty(String propertyName) {
    return 'Vous êtes tombé sur $propertyName';
  }

  @override
  String get ownsThisProperty => 'possède cette propriété';

  @override
  String get rentDue => 'Loyer Dû';

  @override
  String diceRentCalc(int diceRoll, int multiplier, int amount) {
    return 'Dés : $diceRoll × $multiplier = \$$amount';
  }

  @override
  String get ownerHasBothUtilities =>
      '(Le propriétaire possède les deux services)';

  @override
  String get ownerHasOneUtility => '(Le propriétaire possède 1 service)';

  @override
  String ownerHasRailroads(int count, String suffix) {
    return 'Le propriétaire possède $count gare$suffix';
  }

  @override
  String get bankruptMessage =>
      'Vous n\'avez pas assez d\'argent ! Vous êtes en faillite.';

  @override
  String get acceptBankruptcy => 'Accepter la Faillite';

  @override
  String payAmount(int amount) {
    return 'Payer \$$amount';
  }

  @override
  String get payTaxToBank => 'Vous devez payer un impôt à la banque';

  @override
  String get taxAmount => 'Montant de l\'Impôt';

  @override
  String get gameMenu => 'Menu du Jeu';

  @override
  String get backToGame => 'Retour au Jeu';

  @override
  String get saveGame => 'Sauvegarder la Partie';

  @override
  String get loadGame => 'Charger une Partie';

  @override
  String get loadSavedGame => 'Charger une Partie Sauvegardée ?';

  @override
  String get currentProgressLost => 'La progression actuelle sera perdue.';

  @override
  String get restartGame => 'Recommencer la Partie';

  @override
  String get allProgressLost => 'Toute la progression sera perdue.';

  @override
  String get quitToMenu => 'Quitter vers le Menu';

  @override
  String get quitGame => 'Quitter la Partie ?';

  @override
  String get confirm => 'Confirmer';

  @override
  String get inJail => 'EN PRISON';

  @override
  String get youAreInJail => 'Vous êtes en prison !';

  @override
  String get bailAmount => 'Montant de la Caution';

  @override
  String stayInJailTurns(int turns, String suffix) {
    return 'Ou restez en prison pendant encore $turns tour$suffix.';
  }

  @override
  String get mustPayFine => 'Vous devez payer l\'amende pour sortir !';

  @override
  String get stayInJail => 'Rester en Prison';

  @override
  String payBail(int amount) {
    return 'Payer \$$amount';
  }

  @override
  String get buildHotel => 'Construire un Hôtel !';

  @override
  String get buildHouse => 'Construire une Maison !';

  @override
  String get upgradeCost => 'Coût d\'Amélioration';

  @override
  String get currentRent => 'Loyer Actuel';

  @override
  String get newRent => 'Nouveau Loyer';

  @override
  String get increase => 'Augmentation';

  @override
  String buildForAmount(int amount) {
    return 'Construire \$$amount';
  }

  @override
  String get eventGoodNews => 'Bonne Nouvelle !';

  @override
  String get eventBadNews => 'Mauvaise Nouvelle !';

  @override
  String get eventNewsFlash => 'Flash Info !';

  @override
  String get eventWildCard => 'Joker !';

  @override
  String eventLastsRounds(int duration, String suffix) {
    return 'Dure $duration tour$suffix';
  }

  @override
  String get auction => 'ENCHÈRES';

  @override
  String propertyValue(int amount) {
    return 'Valeur : \$$amount';
  }

  @override
  String get currentBid => 'Offre Actuelle :';

  @override
  String get noBidsYet => 'Aucune offre';

  @override
  String get leadingBidder => 'Meilleur Enchérisseur :';

  @override
  String get bidders => 'Enchérisseurs :';

  @override
  String playerTurn(String name) {
    return 'Tour de $name';
  }

  @override
  String get notEnoughCashToBid => 'Pas assez d\'argent pour enchérir';

  @override
  String get pass => 'Passer';

  @override
  String bidAmount(int amount) {
    return 'Enchérir \$$amount';
  }

  @override
  String get notEnoughCashShort => 'Pas assez d\'argent';

  @override
  String playerWinsAuction(String name) {
    return '$name remporte l\'enchère !';
  }

  @override
  String get noWinnerAuction =>
      'Pas de gagnant - la propriété retourne à la banque';

  @override
  String finalBid(int amount) {
    return 'Enchère finale : \$$amount';
  }

  @override
  String get proposeTrade => 'Proposer un Échange';

  @override
  String get tradeWith => 'Échanger avec :';

  @override
  String youOffer(String name) {
    return 'Vous Offrez ($name)';
  }

  @override
  String get cash => 'Argent';

  @override
  String get cashLabel => 'Argent :';

  @override
  String get properties => 'Propriétés';

  @override
  String get propertiesLabel => 'Propriétés :';

  @override
  String get noPropertiesToOffer => 'Aucune propriété à offrir';

  @override
  String youRequest(String name) {
    return 'Vous Demandez (à $name)';
  }

  @override
  String get noPropertiesAvailable => 'Aucune propriété disponible';

  @override
  String get proposeTradeBtn => 'Proposer l\'Échange';

  @override
  String wantsToTrade(String name) {
    return '$name veut échanger !';
  }

  @override
  String get youReceive => 'Vous Recevez :';

  @override
  String get youGive => 'Vous Donnez :';

  @override
  String get nothing => 'Rien';

  @override
  String get reject => 'Refuser';

  @override
  String get accept => 'Accepter';

  @override
  String get propertyManagement => 'Gestion des Propriétés';

  @override
  String get mortgage => 'Hypothéquer';

  @override
  String get unmortgage => 'Lever l\'Hypothèque';

  @override
  String mortgageCount(int count) {
    return 'Hypothéquer ($count)';
  }

  @override
  String unmortgageCount(int count) {
    return 'Lever l\'Hypothèque ($count)';
  }

  @override
  String get noMortgageableProperties =>
      'Aucune propriété disponible à hypothéquer.\nLes propriétés avec des maisons doivent d\'abord vendre les maisons.';

  @override
  String get noMortgagedProperties => 'Aucune propriété hypothéquée.';

  @override
  String receiveAmount(int amount) {
    return 'Recevoir : \$$amount';
  }

  @override
  String costAmount(int amount) {
    return 'Coût : \$$amount';
  }

  @override
  String get pay => 'Payer';

  @override
  String get close => 'Fermer';

  @override
  String get propertyLocation => 'Emplacement de la Propriété';

  @override
  String get startingPoint => 'Point de Départ';

  @override
  String get justVisiting => 'Simple Visite / En Prison';

  @override
  String get spinToWin => 'Tournez pour Gagner !';

  @override
  String get goToJailLabel => 'Allez en Prison';

  @override
  String get chanceCard => 'Chance';

  @override
  String get communityChestCard => 'Caisse';

  @override
  String get incomeTax => 'Impôt sur le Revenu';

  @override
  String get luxuryTax => 'Taxe de Luxe';

  @override
  String get didYouKnow => 'Le Saviez-Vous ?';

  @override
  String get ownAllPropertiesTip =>
      'Possédez toutes les propriétés d\'un même groupe de couleur pour doubler le loyer !';

  @override
  String get buildHousesEvenlyTip =>
      'Construisez des maisons uniformément sur vos propriétés pour un profit maximum.';

  @override
  String hotelsMaxRentTip(int amount) {
    return 'Les hôtels génèrent le loyer le plus élevé - jusqu\'à \$$amount !';
  }

  @override
  String get railroad1Tip => '1 gare : loyer de 25 \$';

  @override
  String get railroad2Tip => '2 gares : loyer de 50 \$';

  @override
  String get railroad3Tip => '3 gares : loyer de 100 \$';

  @override
  String get railroad4Tip => '4 gares : loyer de 200 \$ !';

  @override
  String get utility1Tip => '1 service : Loyer = 4× le lancer de dés';

  @override
  String get utility2Tip => '2 services : Loyer = 10× le lancer de dés !';

  @override
  String get utilitiesProfitableTip =>
      'Les services peuvent être très rentables avec des lancers de dés élevés.';

  @override
  String get chanceHowToPlay => 'Comment Jouer';

  @override
  String get chestHowToPlay => 'Comment Jouer';

  @override
  String get drawTopCard => 'Piochez la carte du dessus de la pile Chance';

  @override
  String get readCardAloud => 'Lisez la carte à voix haute';

  @override
  String get doWhatCardSays => 'Faites ce que la carte dit !';

  @override
  String get putCardBottom => 'Remettez la carte au bas de la pile';

  @override
  String get jailRules => 'Règles de la Prison';

  @override
  String get goToJailRules => 'Règles d\'Envoi en Prison';

  @override
  String get taxRules => 'Règles Fiscales';

  @override
  String get drawTopChestCard => 'Pioche la carte du dessus de la caisse';

  @override
  String get readToEveryone => 'Lis-la à voix haute pour tout le monde';

  @override
  String get followInstructions => 'Suis les instructions de la carte';

  @override
  String get returnCardBottom => 'Remets la carte au bas du paquet';

  @override
  String get justVisitingSafe =>
      'Si tu es « Simple visite » - tu es en sécurité !';

  @override
  String get inJailYouCan => 'Si tu es EN prison, tu peux :';

  @override
  String get pay50GetOut => '  • Payer \\\$50 pour sortir';

  @override
  String get rollDoublesThreeTries =>
      '  • Tenter de faire un double (3 essais)';

  @override
  String get useGetOutCard =>
      '  • Utiliser une carte « Sortie de prison gratuite »';

  @override
  String get goDirectlyToJail => 'Va directement en prison !';

  @override
  String get doNotPassGo => 'NE passe PAS par DÉPART';

  @override
  String get doNotCollect200 => 'NE collecte PAS \\\$200';

  @override
  String get turnEndsImmediately => 'Ton tour se termine immédiatement';

  @override
  String get mustPayTaxRule => 'Tu DOIS payer cette taxe !';

  @override
  String get payBankAmountShown => 'Paye à la banque le montant indiqué';

  @override
  String get cantPayMightGoBankrupt =>
      'Si tu ne peux pas payer, tu risques la faillite !';

  @override
  String get collectGoBonus =>
      'Collecte de l\'argent en arrivant sur DÉPART ou en le dépassant.';

  @override
  String get passGoEarn =>
      'Passer par DÉPART maintient un bon flux de trésorerie.';

  @override
  String get startTileFunFact =>
      'DÉPART est la case la plus visitée du Monopoly.';

  @override
  String get jailFactOne =>
      'Tomber ici peut signifier prison ou simple visite.';

  @override
  String get jailFactTwo => 'Tu peux payer une caution ou tenter un double.';

  @override
  String get jailFunFact =>
      'La prison est l\'une des cases les plus stratégiques du jeu.';

  @override
  String get freeParkingFactOne =>
      'Tournez la roue pour gagner de l\'argent, des bonus ou des prix spéciaux !';

  @override
  String get freeParkingFactTwo =>
      'Chaque tour garantit une récompense — jamais de mauvais résultat !';

  @override
  String get freeParkingFunFact =>
      'La Roue de la Chance peut retourner la situation en un instant.';

  @override
  String get goToJailFactOne =>
      'Cette case envoie ton pion directement en prison.';

  @override
  String get goToJailFactTwo =>
      'Tu ne touches pas l\'argent de DÉPART sur ce déplacement.';

  @override
  String get goToJailFunFact => 'Évite cette case pour garder ton élan.';

  @override
  String get chanceFunFact =>
      'Les cartes Chance ajoutent des surprises à chaque partie.';

  @override
  String get communityChestFactOne => 'La communauté s\'entraide !';

  @override
  String get communityChestFactTwo =>
      'Ces cartes te donnent souvent de l\'argent.';

  @override
  String get communityChestFactThree =>
      'Une erreur de banque en ta faveur peut arriver !';

  @override
  String get communityChestFunFact =>
      'Les cartes Caisse de Communauté sont souvent favorables.';

  @override
  String get taxFactOne => 'Tout le monde doit payer des taxes !';

  @override
  String get taxFactTwo => 'Les taxes financent les services publics.';

  @override
  String get taxFunFact =>
      'Les cases Taxe peuvent vite changer le rythme de la partie.';

  @override
  String aiBuiltOn(String level, String property) {
    return 'A construit un $level sur $property !';
  }

  @override
  String get chance => 'Hasard';

  @override
  String get communityChest => 'CAISSE';

  @override
  String get chanceExcl => 'CHANCE !';

  @override
  String get communityChestExcl => 'CAISSE !';

  @override
  String get tapCardToPick => 'Appuyez sur une carte pour la choisir !';

  @override
  String get revealingCard => 'Révélation de votre carte...';

  @override
  String get tapToContinue => 'Appuyez n\'importe où pour continuer';

  @override
  String get chestShort => 'CAISSE';

  @override
  String get ok => 'D\'accord';

  @override
  String get freeHouseTitle => 'MAISON GRATUITE !';

  @override
  String get choosePropertyToBuild =>
      'Choisissez une propriété pour construire';

  @override
  String get noUpgradeableProperties =>
      'Aucune propriété disponible à améliorer !';

  @override
  String get buyPropertiesComeBack =>
      'Achetez des propriétés et revenez plus tard.';

  @override
  String houseN(int level) {
    return 'Maison $level';
  }

  @override
  String get hotel => 'Hôtel';

  @override
  String nextUpgrade(String text) {
    return 'Suivant : $text';
  }

  @override
  String get saveForLater => 'Garder pour Plus Tard';

  @override
  String get build => 'Construire !';

  @override
  String get teleportTitle => 'TÉLÉPORTATION !';

  @override
  String get chooseTileToTeleport => 'Choisissez une case pour vous téléporter';

  @override
  String get all => 'Tout';

  @override
  String get railroads => 'Gares';

  @override
  String get utilities => 'Services';

  @override
  String get special => 'Spécial';

  @override
  String get noTilesMatch => 'Aucune case ne correspond à ce filtre';

  @override
  String get teleportBtn => 'Téléporter !';

  @override
  String get gameOver => 'FIN DE PARTIE !';

  @override
  String get winner => 'Gagnant';

  @override
  String get finalStandings => 'Classement Final';

  @override
  String rankN(int rank) {
    return 'N°$rank';
  }

  @override
  String get bankrupt => 'EN FAILLITE';

  @override
  String get rounds => 'Tours';

  @override
  String get finalCash => 'Argent Final';

  @override
  String get turns => 'Tours';

  @override
  String get mainMenu => 'Menu Principal';

  @override
  String get playAgain => 'Rejouer';

  @override
  String playerPortfolio(String name) {
    return 'Portefeuille de $name';
  }

  @override
  String netWorth(int amount) {
    return 'Valeur Nette : \$$amount';
  }

  @override
  String get position => 'Emplacement';

  @override
  String get noPropertiesYet => 'Pas Encore de Propriétés';

  @override
  String get startBuyingProperties =>
      'Commencez à acheter des propriétés pour bâtir votre empire !';

  @override
  String rentAmount(int amount) {
    return 'Loyer : \$$amount';
  }

  @override
  String get mortgaged => 'HYPOTHÉQUÉE';

  @override
  String get mortgagedLabel => 'Hypothéquée';

  @override
  String get railroad => 'Gare';

  @override
  String get utility => 'Service';

  @override
  String get colorBrown => 'Marron';

  @override
  String get colorLightBlue => 'Bleu Clair';

  @override
  String get colorPink => 'Rose';

  @override
  String get colorOrange => 'Couleur orange';

  @override
  String get colorRed => 'Rouge';

  @override
  String get colorYellow => 'Jaune';

  @override
  String get colorGreen => 'Vert';

  @override
  String get colorDarkBlue => 'Bleu Foncé';

  @override
  String get noneYet => 'Aucun pour le moment';

  @override
  String get noProperties => 'Aucune propriété';

  @override
  String get yourTurn => 'À TOI DE JOUER';

  @override
  String tileN(int position) {
    return 'Case $position';
  }

  @override
  String get rolling => 'LANCER...';

  @override
  String get moving => 'DÉPLACEMENT...';

  @override
  String get rollDice => 'LANCER LES DÉS';

  @override
  String get tap => 'APPUYER';

  @override
  String get spin => 'TOURNER';

  @override
  String get trade => 'Échanger';

  @override
  String get bank => 'Banque';

  @override
  String get use => 'UTILISER';

  @override
  String get gameSaved => 'Partie sauvegardée avec succès !';

  @override
  String get failedToSave => 'Échec de la sauvegarde';

  @override
  String gameLoaded(int round) {
    return 'Partie chargée ! Tour $round';
  }

  @override
  String get failedToLoad => 'Échec du chargement';

  @override
  String get noPowerUpCards =>
      'Pas de cartes bonus ! Gagnez des mini-jeux pour en collecter.';

  @override
  String get yourPowerUpCards => 'Vos Cartes Bonus';

  @override
  String get noOtherPlayers => 'Aucun autre joueur avec qui échanger !';

  @override
  String boughtProperty(String name, int price) {
    return '$name acheté pour \$$price !';
  }

  @override
  String paidRentTo(int amount, String name) {
    return '\$$amount de loyer payé à $name';
  }

  @override
  String paidTax(int amount, String taxName) {
    return '\$$amount de $taxName payé';
  }

  @override
  String get goingToJail => 'Direction la prison !';

  @override
  String get goToJailTitle => 'Allez en Prison !';

  @override
  String get goToJailMessage =>
      'Vous êtes tombé sur Allez en Prison !\nAllez directement en prison, ne passez pas par la case Départ.';

  @override
  String wonPrize(String prize) {
    return 'A tourné la roue et gagné $prize !';
  }

  @override
  String get tradeAccepted => 'Échange accepté !';

  @override
  String get tradeRejected => 'Échange refusé.';

  @override
  String get tradeCompleted => 'Échange effectué !';

  @override
  String get tradeRejectedShort => 'Échange refusé.';

  @override
  String get spinPrizeCash50 => '50 \$';

  @override
  String get spinPrizeCash50Desc => 'Gagnez 50 \$ !';

  @override
  String get spinPrizeCash100 => '100 \$';

  @override
  String get spinPrizeCash100Desc => 'Gagnez 100 \$ !';

  @override
  String get spinPrizeCash200 => '200 \$';

  @override
  String get spinPrizeCash200Desc => 'Gagnez 200 \$ !';

  @override
  String get spinPrizeFreeHouse => 'Maison Gratuite';

  @override
  String get spinPrizeFreeHouseDesc =>
      'Construisez une maison gratuite sur n\'importe quelle propriété !';

  @override
  String get spinPrizeDoubleRent => 'Loyer x2';

  @override
  String get spinPrizeDoubleRentDesc =>
      'Le prochain loyer que vous collectez est doublé !';

  @override
  String get spinPrizeShield => 'Bouclier';

  @override
  String get spinPrizeShieldDesc => 'Évitez votre prochain paiement de loyer !';

  @override
  String get spinPrizeTeleport => 'Téléportation';

  @override
  String get spinPrizeTeleportDesc =>
      'Déplacez-vous vers la case de votre choix !';

  @override
  String get spinPrizeJackpot => 'JACKPOT !';

  @override
  String get spinPrizeJackpotDesc => 'Gagnez le jackpot de 500 \$ !';

  @override
  String get luckySpinTitle => 'ROUE DE LA CHANCE !';

  @override
  String playerTurnToSpin(String name) {
    return 'C\'est au tour de $name de tourner !';
  }

  @override
  String get spinInstructions => 'Appuyez au centre pour tourner la roue !';

  @override
  String get spinning => 'La roue tourne...';

  @override
  String youWonPrize(String name) {
    return 'Vous avez gagné $name !';
  }

  @override
  String get collectPrize => 'Récupérer le Prix !';

  @override
  String get orTapToSpin => 'Ou appuyez ici pour tourner';

  @override
  String get goodLuck => 'Bonne chance !';

  @override
  String get eventMarketBoom => 'Boom Immobilier !';

  @override
  String get eventMarketBoomDesc =>
      'Toutes les propriétés valent 20 % de plus pendant 3 tours !';

  @override
  String get eventTaxHoliday => 'Vacances Fiscales !';

  @override
  String get eventTaxHolidayDesc => 'Pas d\'impôts ce tour-ci !';

  @override
  String get eventGoldRush => 'Ruée vers l\'Or !';

  @override
  String get eventGoldRushDesc =>
      'Collectez 300 \$ au lieu de 200 \$ en passant par la case Départ pendant 3 tours !';

  @override
  String get eventPropertySale => 'Soldes Immobilières !';

  @override
  String get eventPropertySaleDesc =>
      'Toutes les propriétés sans propriétaire sont à -25 % pendant 2 tours !';

  @override
  String get eventLuckyDay => 'Jour de Chance !';

  @override
  String get eventLuckyDayDesc => 'Tout le monde reçoit 50 \$ !';

  @override
  String get eventHousingBoom => 'Boom du Logement !';

  @override
  String get eventHousingBoomDesc =>
      'Amélioration gratuite sur une propriété aléatoire !';

  @override
  String get eventRentStrike => 'Grève des Loyers !';

  @override
  String get eventRentStrikeDesc =>
      'Tous les loyers sont réduits de 50 % pendant 2 tours.';

  @override
  String get eventMeteorShower => 'Pluie de Météorites !';

  @override
  String get eventMeteorShowerDesc => 'Un joueur au hasard perd 100 \$ !';

  @override
  String get eventCommunityCleanup => 'Nettoyage Communautaire';

  @override
  String get eventCommunityCleanupDesc =>
      'Payez 25 \$ pour chaque maison que vous possédez.';

  @override
  String get eventStockDividend => 'Dividende Boursier';

  @override
  String get eventStockDividendDesc =>
      'Chaque joueur reçoit 10 \$ par propriété possédée.';

  @override
  String get eventBirthdayParty => 'Fête d\'Anniversaire !';

  @override
  String get eventBirthdayPartyDesc =>
      'Le joueur actuel collecte 25 \$ de chaque autre joueur !';

  @override
  String get eventBankError => 'Erreur Bancaire';

  @override
  String get eventBankErrorDesc => 'Un joueur au hasard reçoit 200 \$ !';

  @override
  String get eventMarketCrash => 'Krach Boursier !';

  @override
  String get eventMarketCrashDesc =>
      'Les valeurs immobilières fluctuent follement ! Effets aléatoires pour tout le monde !';

  @override
  String get powerUpRentReducer => 'Réducteur de Loyer';

  @override
  String get powerUpRentReducerDesc => 'Ne payez que 50 % du loyer ce tour-ci';

  @override
  String get powerUpSpeedBoost => 'Boost de Vitesse';

  @override
  String get powerUpSpeedBoostDesc =>
      'Relancez les dés après votre déplacement';

  @override
  String get powerUpPropertyScout => 'Éclaireur Immobilier';

  @override
  String get powerUpPropertyScoutDesc =>
      'Voir les prix de toutes les propriétés disponibles';

  @override
  String get powerUpRentCollector => 'Collecteur de Loyers';

  @override
  String get powerUpRentCollectorDesc => 'Collectez 50 \$ de chaque joueur';

  @override
  String get powerUpPriceFreeze => 'Gel des Prix';

  @override
  String get powerUpPriceFreezeDesc =>
      'Achetez la prochaine propriété à 75 % du prix';

  @override
  String get powerUpTeleporter => 'Téléporteur';

  @override
  String get powerUpTeleporterDesc =>
      'Déplacez-vous vers n\'importe quelle propriété disponible';

  @override
  String get powerUpShield => 'Bouclier';

  @override
  String get powerUpShieldDesc => 'Bloquez un paiement de loyer';

  @override
  String get powerUpDoubleDice => 'Double Dés';

  @override
  String get powerUpDoubleDiceDesc => 'Lancez 4 dés, gardez les 2 meilleurs';

  @override
  String get powerUpMoneyMagnet => 'Aimant à Argent';

  @override
  String get powerUpMoneyMagnetDesc =>
      '100 \$ supplémentaires en passant par Départ (3 tours)';

  @override
  String get powerUpMonopolyMaster => 'Maître du Monopole';

  @override
  String get powerUpMonopolyMasterDesc =>
      'Maison gratuite sur toutes vos propriétés !';

  @override
  String get powerUpRarityCommon => 'Commun';

  @override
  String get powerUpRarityUncommon => 'Peu Commun';

  @override
  String get powerUpRarityRare => 'Peu commun';

  @override
  String get powerUpRarityLegendary => 'Légendaire';

  @override
  String get winnerTitle => 'GAGNANT !';

  @override
  String get gameStats => 'Statistiques de la Partie';

  @override
  String get shopTitle => 'Boutique';

  @override
  String get shopSubtitle => 'Débloquez des thèmes, jetons et plus !';

  @override
  String get unlocked => 'Débloqué';

  @override
  String get free => 'Gratuit';

  @override
  String get loadingAd => 'Chargement de la pub...';

  @override
  String adsProgress(int watched, int required) {
    return 'Progression : $watched/$required pubs visionnées !';
  }

  @override
  String purchaseItem(String name) {
    return 'Acheter $name ?';
  }

  @override
  String unlockFor(String price) {
    return 'Débloquer pour $price';
  }

  @override
  String buyPrice(String price) {
    return 'Acheter $price';
  }

  @override
  String get unlockedExcl => 'DÉBLOQUÉ !';

  @override
  String get awesome => 'Génial !';

  @override
  String get watchAdsToUnlock => 'Regardez des pubs pour débloquer';

  @override
  String watchAdsOrPay(int count) {
    return 'Regardez $count pubs ou payez pour débloquer instantanément';
  }

  @override
  String watchAdsCount(int count) {
    return 'Regardez $count pubs pour débloquer';
  }

  @override
  String get purchaseToUnlock => 'Acheter pour débloquer';

  @override
  String get useThis => 'Utiliser';

  @override
  String get owned => 'Possédé';

  @override
  String get familyLeaderboard => 'Classement Familial';

  @override
  String get rankings => 'Classements';

  @override
  String get records => 'Historique';

  @override
  String get achievements => 'Succès';

  @override
  String get sortBy => 'Trier par : ';

  @override
  String get wins => 'Victoires';

  @override
  String get winPercent => '% Victoires';

  @override
  String get earnings => 'Gains';

  @override
  String get games => 'Parties';

  @override
  String get noPlayersYet => 'Pas encore de joueurs';

  @override
  String get playToSeeStats =>
      'Jouez quelques parties pour voir les statistiques !';

  @override
  String get mostWins => 'Plus de Victoires';

  @override
  String get highestCash => 'Plus Gros Capital';

  @override
  String get propertyTycoonRecord => 'Magnat Immobilier';

  @override
  String get longestWinStreak => 'Plus Longue Série de Victoires';

  @override
  String get speedChampion => 'Champion de Vitesse';

  @override
  String get luckiestRoller => 'Lanceur le Plus Chanceux';

  @override
  String inARow(int count) {
    return '$count d\'affilée';
  }

  @override
  String turnsCount(int count) {
    return '$count tours';
  }

  @override
  String avgValue(String value) {
    return '$value de moy.';
  }

  @override
  String get memoryMatchTitle => 'Jeu de mémoire';

  @override
  String get pairs => 'Paires';

  @override
  String get timeLabel => 'Temps';

  @override
  String secondsShort(int seconds) {
    return '$seconds sec';
  }

  @override
  String get greatJob => 'Beau travail !';

  @override
  String get timeUp => 'Temps écoulé !';

  @override
  String pairsFound(int found, int total) {
    return 'Paires trouvées : $found / $total';
  }

  @override
  String scoreAmount(int score) {
    return 'Score : $score';
  }

  @override
  String get quickTapAmazing => 'INCROYABLE !';

  @override
  String get quickTapGreat => 'Super !';

  @override
  String get quickTapGood => 'Bien';

  @override
  String get quickTapTryAgain => 'Réessayez';

  @override
  String get quickTapInstruction => 'Touchez les pièces ! Évitez les bombes !';

  @override
  String streakCount(int count) {
    return 'Série de $count !';
  }

  @override
  String itemSelected(String name) {
    return '$name sélectionné !';
  }

  @override
  String get deletePhotoTitle => 'Supprimer la photo ?';

  @override
  String get deletePhotoMessage => 'Cette photo sera supprimée de vos avatars.';

  @override
  String get delete => 'Supprimer';

  @override
  String get takePhoto => 'Prendre une photo';

  @override
  String get choosePhoto => 'Choisir une photo';

  @override
  String get noPhotosYet => 'Pas encore de photos';

  @override
  String get takeSelfieOrPick =>
      'Prenez un selfie ou choisissez dans la galerie !';

  @override
  String get chooseYourAvatarFancy => '✨ Choisissez votre avatar ✨';

  @override
  String get avatarCategoryAnimals => 'Animaux';

  @override
  String get avatarCategoryFood => 'Nourriture';

  @override
  String get avatarCategoryObjects => 'Objets';

  @override
  String get avatarCategoryCharacters => 'Personnages';

  @override
  String get avatarCategoryMyPhotos => 'Mes photos';

  @override
  String get select => 'Sélectionner';

  @override
  String get countryUSA => 'États-Unis';

  @override
  String get countryUK => 'Royaume-Uni';

  @override
  String get countryFrance => 'République française';

  @override
  String get countryJapan => 'Japon';

  @override
  String get countryChina => 'Chine';

  @override
  String get countryMexico => 'Mexique';

  @override
  String get chooseCity => 'Choisir la Ville';

  @override
  String get cityAtlanticCity => 'Atlantic City';

  @override
  String get cityNewYork => 'New York';

  @override
  String get cityLosAngeles => 'Los Angeles';

  @override
  String get cityLondon => 'Londres';

  @override
  String get cityEdinburgh => 'Édimbourg';

  @override
  String get cityManchester => 'Manchester';

  @override
  String get cityParis => 'Paris';

  @override
  String get cityLyon => 'Lyon';

  @override
  String get cityMarseille => 'Marseille';

  @override
  String get cityTokyo => 'Tokyo';

  @override
  String get cityOsaka => 'Osaka';

  @override
  String get cityKyoto => 'Kyoto';

  @override
  String get cityBeijing => 'Pékin';

  @override
  String get cityShanghai => 'Shanghai';

  @override
  String get cityHongKong => 'Hong Kong';

  @override
  String get cityMexicoCity => 'Mexico';

  @override
  String get cityGuadalajara => 'Guadalajara';

  @override
  String get cityCancun => 'Cancún';
}
