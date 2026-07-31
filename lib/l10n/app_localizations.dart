import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
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
/// import 'l10n/app_localizations.dart';
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
    Locale('fr'),
    Locale('ja'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'M&M Property Tycoon'**
  String get appTitle;

  /// No description provided for @propertyTycoon.
  ///
  /// In en, this message translates to:
  /// **'PROPERTY TYCOON'**
  String get propertyTycoon;

  /// No description provided for @familyEdition.
  ///
  /// In en, this message translates to:
  /// **'FAMILY EDITION'**
  String get familyEdition;

  /// No description provided for @worldCityEdition.
  ///
  /// In en, this message translates to:
  /// **'WORLD CITY EDITION'**
  String get worldCityEdition;

  /// No description provided for @chooseNextMove.
  ///
  /// In en, this message translates to:
  /// **'Choose your next move'**
  String get chooseNextMove;

  /// No description provided for @newGame.
  ///
  /// In en, this message translates to:
  /// **'New Game'**
  String get newGame;

  /// No description provided for @continueGame.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueGame;

  /// No description provided for @howToPlay.
  ///
  /// In en, this message translates to:
  /// **'How to Play'**
  String get howToPlay;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @shop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shop;

  /// No description provided for @howManyPlayers.
  ///
  /// In en, this message translates to:
  /// **'How Many Players?'**
  String get howManyPlayers;

  /// No description provided for @gameSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Your Game'**
  String get gameSetupTitle;

  /// No description provided for @gameSetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a city, game size, and movement style.'**
  String get gameSetupSubtitle;

  /// No description provided for @playerSetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Give every player a name, color, and character.'**
  String get playerSetupSubtitle;

  /// No description provided for @gameSummary.
  ///
  /// In en, this message translates to:
  /// **'Game Summary'**
  String get gameSummary;

  /// No description provided for @readyToPlay.
  ///
  /// In en, this message translates to:
  /// **'Ready to play'**
  String get readyToPlay;

  /// No description provided for @playerSetup.
  ///
  /// In en, this message translates to:
  /// **'Player Setup'**
  String get playerSetup;

  /// No description provided for @chooseBoard.
  ///
  /// In en, this message translates to:
  /// **'Choose Board'**
  String get chooseBoard;

  /// No description provided for @numberOfPlayers.
  ///
  /// In en, this message translates to:
  /// **'Number of Players'**
  String get numberOfPlayers;

  /// No description provided for @numberOfDice.
  ///
  /// In en, this message translates to:
  /// **'Number of Dice'**
  String get numberOfDice;

  /// No description provided for @players.
  ///
  /// In en, this message translates to:
  /// **'players'**
  String get players;

  /// No description provided for @oneDie.
  ///
  /// In en, this message translates to:
  /// **'One Die'**
  String get oneDie;

  /// No description provided for @twoDice.
  ///
  /// In en, this message translates to:
  /// **'Two Dice'**
  String get twoDice;

  /// No description provided for @classicStyle.
  ///
  /// In en, this message translates to:
  /// **'Classic style'**
  String get classicStyle;

  /// No description provided for @standardRules.
  ///
  /// In en, this message translates to:
  /// **'Standard rules'**
  String get standardRules;

  /// No description provided for @playersStep.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get playersStep;

  /// No description provided for @setupStep.
  ///
  /// In en, this message translates to:
  /// **'Setup'**
  String get setupStep;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @startGame.
  ///
  /// In en, this message translates to:
  /// **'Start Game'**
  String get startGame;

  /// No description provided for @playerN.
  ///
  /// In en, this message translates to:
  /// **'Player {number}'**
  String playerN(int number);

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @ai.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get ai;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @chooseYourAvatar.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Avatar'**
  String get chooseYourAvatar;

  /// No description provided for @uniqueNameError.
  ///
  /// In en, this message translates to:
  /// **'Each player must have a unique name'**
  String get uniqueNameError;

  /// No description provided for @allPlayersNeedName.
  ///
  /// In en, this message translates to:
  /// **'All players must have a name'**
  String get allPlayersNeedName;

  /// No description provided for @uniqueColorError.
  ///
  /// In en, this message translates to:
  /// **'Each player must have a unique color'**
  String get uniqueColorError;

  /// No description provided for @tutorialRollMove.
  ///
  /// In en, this message translates to:
  /// **'Roll & Move'**
  String get tutorialRollMove;

  /// No description provided for @tutorialRollMoveDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap the dice to roll!\nMove around the board.'**
  String get tutorialRollMoveDesc;

  /// No description provided for @tutorialBuyProperties.
  ///
  /// In en, this message translates to:
  /// **'Buy Properties'**
  String get tutorialBuyProperties;

  /// No description provided for @tutorialBuyPropertiesDesc.
  ///
  /// In en, this message translates to:
  /// **'Land on an empty spot?\nBuy it and own it!'**
  String get tutorialBuyPropertiesDesc;

  /// No description provided for @tutorialCollectRent.
  ///
  /// In en, this message translates to:
  /// **'Collect Rent'**
  String get tutorialCollectRent;

  /// No description provided for @tutorialCollectRentDesc.
  ///
  /// In en, this message translates to:
  /// **'Others land on your property?\nThey pay YOU!'**
  String get tutorialCollectRentDesc;

  /// No description provided for @tutorialSpecialSpaces.
  ///
  /// In en, this message translates to:
  /// **'Special Spaces'**
  String get tutorialSpecialSpaces;

  /// No description provided for @tutorialSpecialSpacesDesc.
  ///
  /// In en, this message translates to:
  /// **'Chance cards, jail, trains...\nSurprises everywhere!'**
  String get tutorialSpecialSpacesDesc;

  /// No description provided for @tutorialWinGame.
  ///
  /// In en, this message translates to:
  /// **'Win the Game!'**
  String get tutorialWinGame;

  /// No description provided for @tutorialWinGameDesc.
  ///
  /// In en, this message translates to:
  /// **'Last player with money wins!\nBankrupt your friends!'**
  String get tutorialWinGameDesc;

  /// No description provided for @letsPlay.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Play!'**
  String get letsPlay;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it!'**
  String get gotIt;

  /// No description provided for @startingCash.
  ///
  /// In en, this message translates to:
  /// **'Starting Cash'**
  String get startingCash;

  /// No description provided for @gameOptions.
  ///
  /// In en, this message translates to:
  /// **'Game Options'**
  String get gameOptions;

  /// No description provided for @soundAndLanguage.
  ///
  /// In en, this message translates to:
  /// **'Sound & Language'**
  String get soundAndLanguage;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tune your table before the next game'**
  String get settingsSubtitle;

  /// No description provided for @playerTrading.
  ///
  /// In en, this message translates to:
  /// **'Player Trading'**
  String get playerTrading;

  /// No description provided for @bankFeatures.
  ///
  /// In en, this message translates to:
  /// **'Bank Features'**
  String get bankFeatures;

  /// No description provided for @propertyAuctions.
  ///
  /// In en, this message translates to:
  /// **'Property Auctions'**
  String get propertyAuctions;

  /// No description provided for @backgroundMusic.
  ///
  /// In en, this message translates to:
  /// **'Background Music'**
  String get backgroundMusic;

  /// No description provided for @gameSounds.
  ///
  /// In en, this message translates to:
  /// **'Game Sounds'**
  String get gameSounds;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @buyMeACoffee.
  ///
  /// In en, this message translates to:
  /// **'Buy me a coffee'**
  String get buyMeACoffee;

  /// No description provided for @buyMeACoffeeDesc.
  ///
  /// In en, this message translates to:
  /// **'Your support helps keep the game free and updated. Every coffee means a lot!'**
  String get buyMeACoffeeDesc;

  /// No description provided for @openExternalLink.
  ///
  /// In en, this message translates to:
  /// **'Open External Link'**
  String get openExternalLink;

  /// No description provided for @openBuyMeACoffeeDesc.
  ///
  /// In en, this message translates to:
  /// **'This will open buymeacoffee.com in your browser.'**
  String get openBuyMeACoffeeDesc;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @backToMenu.
  ///
  /// In en, this message translates to:
  /// **'Back to Menu'**
  String get backToMenu;

  /// No description provided for @settingsReset.
  ///
  /// In en, this message translates to:
  /// **'Settings reset'**
  String get settingsReset;

  /// No description provided for @propertyAvailable.
  ///
  /// In en, this message translates to:
  /// **'This property is available!'**
  String get propertyAvailable;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @baseRent.
  ///
  /// In en, this message translates to:
  /// **'Base Rent'**
  String get baseRent;

  /// No description provided for @rent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get rent;

  /// No description provided for @utilityRentDesc.
  ///
  /// In en, this message translates to:
  /// **'4x or 10x dice roll'**
  String get utilityRentDesc;

  /// No description provided for @yourCash.
  ///
  /// In en, this message translates to:
  /// **'Your Cash'**
  String get yourCash;

  /// No description provided for @notEnoughCash.
  ///
  /// In en, this message translates to:
  /// **'Not enough cash!'**
  String get notEnoughCash;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @buyForAmount.
  ///
  /// In en, this message translates to:
  /// **'Buy \${amount}'**
  String buyForAmount(String amount);

  /// No description provided for @bankruptcy.
  ///
  /// In en, this message translates to:
  /// **'BANKRUPTCY!'**
  String get bankruptcy;

  /// No description provided for @payRent.
  ///
  /// In en, this message translates to:
  /// **'Pay Rent'**
  String get payRent;

  /// No description provided for @landedOnProperty.
  ///
  /// In en, this message translates to:
  /// **'You landed on {propertyName}'**
  String landedOnProperty(String propertyName);

  /// No description provided for @ownsThisProperty.
  ///
  /// In en, this message translates to:
  /// **'owns this property'**
  String get ownsThisProperty;

  /// No description provided for @rentDue.
  ///
  /// In en, this message translates to:
  /// **'Rent Due'**
  String get rentDue;

  /// No description provided for @diceRentCalc.
  ///
  /// In en, this message translates to:
  /// **'Dice: {diceRoll} × {multiplier} = \${amount}'**
  String diceRentCalc(int diceRoll, int multiplier, int amount);

  /// No description provided for @ownerHasBothUtilities.
  ///
  /// In en, this message translates to:
  /// **'(Owner has both utilities)'**
  String get ownerHasBothUtilities;

  /// No description provided for @ownerHasOneUtility.
  ///
  /// In en, this message translates to:
  /// **'(Owner has 1 utility)'**
  String get ownerHasOneUtility;

  /// No description provided for @ownerHasRailroads.
  ///
  /// In en, this message translates to:
  /// **'Owner has {count} railroad{suffix}'**
  String ownerHasRailroads(int count, String suffix);

  /// No description provided for @bankruptMessage.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have enough cash! You are bankrupt.'**
  String get bankruptMessage;

  /// No description provided for @acceptBankruptcy.
  ///
  /// In en, this message translates to:
  /// **'Accept Bankruptcy'**
  String get acceptBankruptcy;

  /// No description provided for @payAmount.
  ///
  /// In en, this message translates to:
  /// **'Pay \${amount}'**
  String payAmount(int amount);

  /// No description provided for @payTaxToBank.
  ///
  /// In en, this message translates to:
  /// **'You must pay tax to the bank'**
  String get payTaxToBank;

  /// No description provided for @taxAmount.
  ///
  /// In en, this message translates to:
  /// **'Tax Amount'**
  String get taxAmount;

  /// No description provided for @gameMenu.
  ///
  /// In en, this message translates to:
  /// **'Game Menu'**
  String get gameMenu;

  /// No description provided for @backToGame.
  ///
  /// In en, this message translates to:
  /// **'Back to Game'**
  String get backToGame;

  /// No description provided for @saveGame.
  ///
  /// In en, this message translates to:
  /// **'Save Game'**
  String get saveGame;

  /// No description provided for @loadGame.
  ///
  /// In en, this message translates to:
  /// **'Load Game'**
  String get loadGame;

  /// No description provided for @loadSavedGame.
  ///
  /// In en, this message translates to:
  /// **'Load Saved Game?'**
  String get loadSavedGame;

  /// No description provided for @currentProgressLost.
  ///
  /// In en, this message translates to:
  /// **'Current game progress will be lost.'**
  String get currentProgressLost;

  /// No description provided for @restartGame.
  ///
  /// In en, this message translates to:
  /// **'Restart Game'**
  String get restartGame;

  /// No description provided for @allProgressLost.
  ///
  /// In en, this message translates to:
  /// **'All progress will be lost.'**
  String get allProgressLost;

  /// No description provided for @quitToMenu.
  ///
  /// In en, this message translates to:
  /// **'Quit to Menu'**
  String get quitToMenu;

  /// No description provided for @quitGame.
  ///
  /// In en, this message translates to:
  /// **'Quit Game?'**
  String get quitGame;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @inJail.
  ///
  /// In en, this message translates to:
  /// **'IN JAIL'**
  String get inJail;

  /// No description provided for @youAreInJail.
  ///
  /// In en, this message translates to:
  /// **'You are in jail!'**
  String get youAreInJail;

  /// No description provided for @bailAmount.
  ///
  /// In en, this message translates to:
  /// **'Bail Amount'**
  String get bailAmount;

  /// No description provided for @stayInJailTurns.
  ///
  /// In en, this message translates to:
  /// **'Or stay in jail for {turns} more turn{suffix}.'**
  String stayInJailTurns(int turns, String suffix);

  /// No description provided for @mustPayFine.
  ///
  /// In en, this message translates to:
  /// **'You must pay the fine to get out!'**
  String get mustPayFine;

  /// No description provided for @stayInJail.
  ///
  /// In en, this message translates to:
  /// **'Stay in Jail'**
  String get stayInJail;

  /// No description provided for @payBail.
  ///
  /// In en, this message translates to:
  /// **'Pay \${amount}'**
  String payBail(int amount);

  /// No description provided for @buildHotel.
  ///
  /// In en, this message translates to:
  /// **'Build a Hotel!'**
  String get buildHotel;

  /// No description provided for @buildHouse.
  ///
  /// In en, this message translates to:
  /// **'Build a House!'**
  String get buildHouse;

  /// No description provided for @upgradeCost.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Cost'**
  String get upgradeCost;

  /// No description provided for @currentRent.
  ///
  /// In en, this message translates to:
  /// **'Current Rent'**
  String get currentRent;

  /// No description provided for @newRent.
  ///
  /// In en, this message translates to:
  /// **'New Rent'**
  String get newRent;

  /// No description provided for @increase.
  ///
  /// In en, this message translates to:
  /// **'Increase'**
  String get increase;

  /// No description provided for @buildForAmount.
  ///
  /// In en, this message translates to:
  /// **'Build \${amount}'**
  String buildForAmount(int amount);

  /// No description provided for @eventGoodNews.
  ///
  /// In en, this message translates to:
  /// **'Good News!'**
  String get eventGoodNews;

  /// No description provided for @eventBadNews.
  ///
  /// In en, this message translates to:
  /// **'Bad News!'**
  String get eventBadNews;

  /// No description provided for @eventNewsFlash.
  ///
  /// In en, this message translates to:
  /// **'News Flash!'**
  String get eventNewsFlash;

  /// No description provided for @eventWildCard.
  ///
  /// In en, this message translates to:
  /// **'Wild Card!'**
  String get eventWildCard;

  /// No description provided for @eventLastsRounds.
  ///
  /// In en, this message translates to:
  /// **'Lasts {duration} round{suffix}'**
  String eventLastsRounds(int duration, String suffix);

  /// No description provided for @auction.
  ///
  /// In en, this message translates to:
  /// **'AUCTION'**
  String get auction;

  /// No description provided for @propertyValue.
  ///
  /// In en, this message translates to:
  /// **'Value: \${amount}'**
  String propertyValue(int amount);

  /// No description provided for @currentBid.
  ///
  /// In en, this message translates to:
  /// **'Current Bid:'**
  String get currentBid;

  /// No description provided for @noBidsYet.
  ///
  /// In en, this message translates to:
  /// **'No bids yet'**
  String get noBidsYet;

  /// No description provided for @leadingBidder.
  ///
  /// In en, this message translates to:
  /// **'Leading Bidder:'**
  String get leadingBidder;

  /// No description provided for @bidders.
  ///
  /// In en, this message translates to:
  /// **'Bidders:'**
  String get bidders;

  /// No description provided for @playerTurn.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s Turn'**
  String playerTurn(String name);

  /// No description provided for @notEnoughCashToBid.
  ///
  /// In en, this message translates to:
  /// **'Not enough cash to bid'**
  String get notEnoughCashToBid;

  /// No description provided for @pass.
  ///
  /// In en, this message translates to:
  /// **'Pass'**
  String get pass;

  /// No description provided for @bidAmount.
  ///
  /// In en, this message translates to:
  /// **'Bid \${amount}'**
  String bidAmount(int amount);

  /// No description provided for @notEnoughCashShort.
  ///
  /// In en, this message translates to:
  /// **'Not enough cash'**
  String get notEnoughCashShort;

  /// No description provided for @playerWinsAuction.
  ///
  /// In en, this message translates to:
  /// **'{name} wins the auction!'**
  String playerWinsAuction(String name);

  /// No description provided for @noWinnerAuction.
  ///
  /// In en, this message translates to:
  /// **'No winner - property returns to bank'**
  String get noWinnerAuction;

  /// No description provided for @finalBid.
  ///
  /// In en, this message translates to:
  /// **'Final bid: \${amount}'**
  String finalBid(int amount);

  /// No description provided for @proposeTrade.
  ///
  /// In en, this message translates to:
  /// **'Propose a Trade'**
  String get proposeTrade;

  /// No description provided for @tradeWith.
  ///
  /// In en, this message translates to:
  /// **'Trade with:'**
  String get tradeWith;

  /// No description provided for @youOffer.
  ///
  /// In en, this message translates to:
  /// **'You Offer ({name})'**
  String youOffer(String name);

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @cashLabel.
  ///
  /// In en, this message translates to:
  /// **'Cash:'**
  String get cashLabel;

  /// No description provided for @properties.
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get properties;

  /// No description provided for @propertiesLabel.
  ///
  /// In en, this message translates to:
  /// **'Properties:'**
  String get propertiesLabel;

  /// No description provided for @noPropertiesToOffer.
  ///
  /// In en, this message translates to:
  /// **'No properties to offer'**
  String get noPropertiesToOffer;

  /// No description provided for @youRequest.
  ///
  /// In en, this message translates to:
  /// **'You Request (from {name})'**
  String youRequest(String name);

  /// No description provided for @noPropertiesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No properties available'**
  String get noPropertiesAvailable;

  /// No description provided for @proposeTradeBtn.
  ///
  /// In en, this message translates to:
  /// **'Propose Trade'**
  String get proposeTradeBtn;

  /// No description provided for @wantsToTrade.
  ///
  /// In en, this message translates to:
  /// **'{name} wants to trade!'**
  String wantsToTrade(String name);

  /// No description provided for @youReceive.
  ///
  /// In en, this message translates to:
  /// **'You Receive:'**
  String get youReceive;

  /// No description provided for @youGive.
  ///
  /// In en, this message translates to:
  /// **'You Give:'**
  String get youGive;

  /// No description provided for @nothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing'**
  String get nothing;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @propertyManagement.
  ///
  /// In en, this message translates to:
  /// **'Property Management'**
  String get propertyManagement;

  /// No description provided for @mortgage.
  ///
  /// In en, this message translates to:
  /// **'Mortgage'**
  String get mortgage;

  /// No description provided for @unmortgage.
  ///
  /// In en, this message translates to:
  /// **'Unmortgage'**
  String get unmortgage;

  /// No description provided for @mortgageCount.
  ///
  /// In en, this message translates to:
  /// **'Mortgage ({count})'**
  String mortgageCount(int count);

  /// No description provided for @unmortgageCount.
  ///
  /// In en, this message translates to:
  /// **'Unmortgage ({count})'**
  String unmortgageCount(int count);

  /// No description provided for @noMortgageableProperties.
  ///
  /// In en, this message translates to:
  /// **'No properties available to mortgage.\nProperties with houses must sell houses first.'**
  String get noMortgageableProperties;

  /// No description provided for @noMortgagedProperties.
  ///
  /// In en, this message translates to:
  /// **'No mortgaged properties.'**
  String get noMortgagedProperties;

  /// No description provided for @receiveAmount.
  ///
  /// In en, this message translates to:
  /// **'Receive: \${amount}'**
  String receiveAmount(int amount);

  /// No description provided for @costAmount.
  ///
  /// In en, this message translates to:
  /// **'Cost: \${amount}'**
  String costAmount(int amount);

  /// No description provided for @pay.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get pay;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @propertyLocation.
  ///
  /// In en, this message translates to:
  /// **'Property Location'**
  String get propertyLocation;

  /// No description provided for @startingPoint.
  ///
  /// In en, this message translates to:
  /// **'Starting Point'**
  String get startingPoint;

  /// No description provided for @justVisiting.
  ///
  /// In en, this message translates to:
  /// **'Just Visiting / In Jail'**
  String get justVisiting;

  /// No description provided for @spinToWin.
  ///
  /// In en, this message translates to:
  /// **'Spin to Win!'**
  String get spinToWin;

  /// No description provided for @goToJailLabel.
  ///
  /// In en, this message translates to:
  /// **'Go To Jail'**
  String get goToJailLabel;

  /// No description provided for @chanceCard.
  ///
  /// In en, this message translates to:
  /// **'Chance'**
  String get chanceCard;

  /// No description provided for @communityChestCard.
  ///
  /// In en, this message translates to:
  /// **'Comm Chest'**
  String get communityChestCard;

  /// No description provided for @incomeTax.
  ///
  /// In en, this message translates to:
  /// **'Income Tax'**
  String get incomeTax;

  /// No description provided for @luxuryTax.
  ///
  /// In en, this message translates to:
  /// **'Luxury Tax'**
  String get luxuryTax;

  /// No description provided for @didYouKnow.
  ///
  /// In en, this message translates to:
  /// **'Did You Know?'**
  String get didYouKnow;

  /// No description provided for @ownAllPropertiesTip.
  ///
  /// In en, this message translates to:
  /// **'Own all properties in a color group to charge double rent!'**
  String get ownAllPropertiesTip;

  /// No description provided for @buildHousesEvenlyTip.
  ///
  /// In en, this message translates to:
  /// **'Build houses evenly across your properties for maximum profit.'**
  String get buildHousesEvenlyTip;

  /// No description provided for @hotelsMaxRentTip.
  ///
  /// In en, this message translates to:
  /// **'Hotels generate the highest rent - up to \${amount}!'**
  String hotelsMaxRentTip(int amount);

  /// No description provided for @railroad1Tip.
  ///
  /// In en, this message translates to:
  /// **'Own 1 railroad: \$25 rent'**
  String get railroad1Tip;

  /// No description provided for @railroad2Tip.
  ///
  /// In en, this message translates to:
  /// **'Own 2 railroads: \$50 rent'**
  String get railroad2Tip;

  /// No description provided for @railroad3Tip.
  ///
  /// In en, this message translates to:
  /// **'Own 3 railroads: \$100 rent'**
  String get railroad3Tip;

  /// No description provided for @railroad4Tip.
  ///
  /// In en, this message translates to:
  /// **'Own all 4 railroads: \$200 rent!'**
  String get railroad4Tip;

  /// No description provided for @utility1Tip.
  ///
  /// In en, this message translates to:
  /// **'Own 1 utility: Rent = 4× dice roll'**
  String get utility1Tip;

  /// No description provided for @utility2Tip.
  ///
  /// In en, this message translates to:
  /// **'Own both utilities: Rent = 10× dice roll!'**
  String get utility2Tip;

  /// No description provided for @utilitiesProfitableTip.
  ///
  /// In en, this message translates to:
  /// **'Utilities can be very profitable with high dice rolls.'**
  String get utilitiesProfitableTip;

  /// No description provided for @chanceHowToPlay.
  ///
  /// In en, this message translates to:
  /// **'How to Play'**
  String get chanceHowToPlay;

  /// No description provided for @chestHowToPlay.
  ///
  /// In en, this message translates to:
  /// **'How to Play'**
  String get chestHowToPlay;

  /// No description provided for @drawTopCard.
  ///
  /// In en, this message translates to:
  /// **'Draw the top card from the Chance pile'**
  String get drawTopCard;

  /// No description provided for @readCardAloud.
  ///
  /// In en, this message translates to:
  /// **'Read the card out loud'**
  String get readCardAloud;

  /// No description provided for @doWhatCardSays.
  ///
  /// In en, this message translates to:
  /// **'Do what the card says!'**
  String get doWhatCardSays;

  /// No description provided for @putCardBottom.
  ///
  /// In en, this message translates to:
  /// **'Put the card at the bottom of the pile'**
  String get putCardBottom;

  /// No description provided for @jailRules.
  ///
  /// In en, this message translates to:
  /// **'Jail Rules'**
  String get jailRules;

  /// No description provided for @goToJailRules.
  ///
  /// In en, this message translates to:
  /// **'Go To Jail Rules'**
  String get goToJailRules;

  /// No description provided for @taxRules.
  ///
  /// In en, this message translates to:
  /// **'Tax Rules'**
  String get taxRules;

  /// No description provided for @drawTopChestCard.
  ///
  /// In en, this message translates to:
  /// **'Draw the top card from the chest'**
  String get drawTopChestCard;

  /// No description provided for @readToEveryone.
  ///
  /// In en, this message translates to:
  /// **'Read it out loud to everyone'**
  String get readToEveryone;

  /// No description provided for @followInstructions.
  ///
  /// In en, this message translates to:
  /// **'Follow the instructions on the card'**
  String get followInstructions;

  /// No description provided for @returnCardBottom.
  ///
  /// In en, this message translates to:
  /// **'Return the card to the bottom'**
  String get returnCardBottom;

  /// No description provided for @justVisitingSafe.
  ///
  /// In en, this message translates to:
  /// **'If you\'re \"Just Visiting\" - you\'re safe!'**
  String get justVisitingSafe;

  /// No description provided for @inJailYouCan.
  ///
  /// In en, this message translates to:
  /// **'If you\'re IN jail, you can:'**
  String get inJailYouCan;

  /// No description provided for @pay50GetOut.
  ///
  /// In en, this message translates to:
  /// **'  • Pay \$50 to get out'**
  String get pay50GetOut;

  /// No description provided for @rollDoublesThreeTries.
  ///
  /// In en, this message translates to:
  /// **'  • Try to roll doubles (3 tries)'**
  String get rollDoublesThreeTries;

  /// No description provided for @useGetOutCard.
  ///
  /// In en, this message translates to:
  /// **'  • Use a \"Get Out of Jail Free\" card'**
  String get useGetOutCard;

  /// No description provided for @goDirectlyToJail.
  ///
  /// In en, this message translates to:
  /// **'Go directly to Jail!'**
  String get goDirectlyToJail;

  /// No description provided for @doNotPassGo.
  ///
  /// In en, this message translates to:
  /// **'Do NOT pass GO'**
  String get doNotPassGo;

  /// No description provided for @doNotCollect200.
  ///
  /// In en, this message translates to:
  /// **'Do NOT collect \$200'**
  String get doNotCollect200;

  /// No description provided for @turnEndsImmediately.
  ///
  /// In en, this message translates to:
  /// **'Your turn ends immediately'**
  String get turnEndsImmediately;

  /// No description provided for @mustPayTaxRule.
  ///
  /// In en, this message translates to:
  /// **'You MUST pay this tax!'**
  String get mustPayTaxRule;

  /// No description provided for @payBankAmountShown.
  ///
  /// In en, this message translates to:
  /// **'Pay the bank the amount shown'**
  String get payBankAmountShown;

  /// No description provided for @cantPayMightGoBankrupt.
  ///
  /// In en, this message translates to:
  /// **'If you can\'t pay, you might go bankrupt!'**
  String get cantPayMightGoBankrupt;

  /// No description provided for @collectGoBonus.
  ///
  /// In en, this message translates to:
  /// **'Collect money when you land on or pass GO.'**
  String get collectGoBonus;

  /// No description provided for @passGoEarn.
  ///
  /// In en, this message translates to:
  /// **'Passing GO keeps your cash flow healthy.'**
  String get passGoEarn;

  /// No description provided for @startTileFunFact.
  ///
  /// In en, this message translates to:
  /// **'GO is the most visited tile in Monopoly.'**
  String get startTileFunFact;

  /// No description provided for @jailFactOne.
  ///
  /// In en, this message translates to:
  /// **'Landing here can mean jail time or just visiting.'**
  String get jailFactOne;

  /// No description provided for @jailFactTwo.
  ///
  /// In en, this message translates to:
  /// **'You can pay bail or try to roll doubles.'**
  String get jailFactTwo;

  /// No description provided for @jailFunFact.
  ///
  /// In en, this message translates to:
  /// **'Jail is one of the most strategic spaces in the game.'**
  String get jailFunFact;

  /// No description provided for @freeParkingFactOne.
  ///
  /// In en, this message translates to:
  /// **'Spin the wheel to win cash, power-ups, or special prizes!'**
  String get freeParkingFactOne;

  /// No description provided for @freeParkingFactTwo.
  ///
  /// In en, this message translates to:
  /// **'Every spin guarantees a reward — no bad outcomes!'**
  String get freeParkingFactTwo;

  /// No description provided for @freeParkingFunFact.
  ///
  /// In en, this message translates to:
  /// **'Lucky Spin is where fortunes can change in an instant.'**
  String get freeParkingFunFact;

  /// No description provided for @goToJailFactOne.
  ///
  /// In en, this message translates to:
  /// **'This sends your token directly to Jail.'**
  String get goToJailFactOne;

  /// No description provided for @goToJailFactTwo.
  ///
  /// In en, this message translates to:
  /// **'You do not collect GO money on this move.'**
  String get goToJailFactTwo;

  /// No description provided for @goToJailFunFact.
  ///
  /// In en, this message translates to:
  /// **'Avoid this tile to keep your momentum.'**
  String get goToJailFunFact;

  /// No description provided for @chanceFunFact.
  ///
  /// In en, this message translates to:
  /// **'Chance cards add surprise to every match.'**
  String get chanceFunFact;

  /// No description provided for @communityChestFactOne.
  ///
  /// In en, this message translates to:
  /// **'The community helps each other!'**
  String get communityChestFactOne;

  /// No description provided for @communityChestFactTwo.
  ///
  /// In en, this message translates to:
  /// **'These cards often give you money.'**
  String get communityChestFactTwo;

  /// No description provided for @communityChestFactThree.
  ///
  /// In en, this message translates to:
  /// **'Bank error in your favor can happen!'**
  String get communityChestFactThree;

  /// No description provided for @communityChestFunFact.
  ///
  /// In en, this message translates to:
  /// **'Community Chest cards are often friendly.'**
  String get communityChestFunFact;

  /// No description provided for @taxFactOne.
  ///
  /// In en, this message translates to:
  /// **'Everyone has to pay taxes!'**
  String get taxFactOne;

  /// No description provided for @taxFactTwo.
  ///
  /// In en, this message translates to:
  /// **'Taxes help support public services.'**
  String get taxFactTwo;

  /// No description provided for @taxFunFact.
  ///
  /// In en, this message translates to:
  /// **'Tax spaces can quickly change game momentum.'**
  String get taxFunFact;

  /// No description provided for @aiBuiltOn.
  ///
  /// In en, this message translates to:
  /// **'Built a {level} on {property}!'**
  String aiBuiltOn(String level, String property);

  /// No description provided for @chance.
  ///
  /// In en, this message translates to:
  /// **'CHANCE'**
  String get chance;

  /// No description provided for @communityChest.
  ///
  /// In en, this message translates to:
  /// **'COMM CHEST'**
  String get communityChest;

  /// No description provided for @chanceExcl.
  ///
  /// In en, this message translates to:
  /// **'CHANCE!'**
  String get chanceExcl;

  /// No description provided for @communityChestExcl.
  ///
  /// In en, this message translates to:
  /// **'COMM CHEST!'**
  String get communityChestExcl;

  /// No description provided for @tapCardToPick.
  ///
  /// In en, this message translates to:
  /// **'Tap a card to pick it!'**
  String get tapCardToPick;

  /// No description provided for @revealingCard.
  ///
  /// In en, this message translates to:
  /// **'Revealing your card...'**
  String get revealingCard;

  /// No description provided for @tapToContinue.
  ///
  /// In en, this message translates to:
  /// **'Tap anywhere to continue'**
  String get tapToContinue;

  /// No description provided for @chestShort.
  ///
  /// In en, this message translates to:
  /// **'COMM CHEST'**
  String get chestShort;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @freeHouseTitle.
  ///
  /// In en, this message translates to:
  /// **'FREE HOUSE!'**
  String get freeHouseTitle;

  /// No description provided for @choosePropertyToBuild.
  ///
  /// In en, this message translates to:
  /// **'Choose a property to build on'**
  String get choosePropertyToBuild;

  /// No description provided for @noUpgradeableProperties.
  ///
  /// In en, this message translates to:
  /// **'No properties available to upgrade!'**
  String get noUpgradeableProperties;

  /// No description provided for @buyPropertiesComeBack.
  ///
  /// In en, this message translates to:
  /// **'Buy properties and come back later.'**
  String get buyPropertiesComeBack;

  /// No description provided for @houseN.
  ///
  /// In en, this message translates to:
  /// **'House {level}'**
  String houseN(int level);

  /// No description provided for @hotel.
  ///
  /// In en, this message translates to:
  /// **'Hotel'**
  String get hotel;

  /// No description provided for @nextUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Next: {text}'**
  String nextUpgrade(String text);

  /// No description provided for @saveForLater.
  ///
  /// In en, this message translates to:
  /// **'Save for Later'**
  String get saveForLater;

  /// No description provided for @build.
  ///
  /// In en, this message translates to:
  /// **'Build!'**
  String get build;

  /// No description provided for @teleportTitle.
  ///
  /// In en, this message translates to:
  /// **'TELEPORT!'**
  String get teleportTitle;

  /// No description provided for @chooseTileToTeleport.
  ///
  /// In en, this message translates to:
  /// **'Choose any tile to teleport to'**
  String get chooseTileToTeleport;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @railroads.
  ///
  /// In en, this message translates to:
  /// **'Railroads'**
  String get railroads;

  /// No description provided for @utilities.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get utilities;

  /// No description provided for @special.
  ///
  /// In en, this message translates to:
  /// **'Special'**
  String get special;

  /// No description provided for @noTilesMatch.
  ///
  /// In en, this message translates to:
  /// **'No tiles match this filter'**
  String get noTilesMatch;

  /// No description provided for @teleportBtn.
  ///
  /// In en, this message translates to:
  /// **'Teleport!'**
  String get teleportBtn;

  /// No description provided for @gameOver.
  ///
  /// In en, this message translates to:
  /// **'GAME OVER!'**
  String get gameOver;

  /// No description provided for @winner.
  ///
  /// In en, this message translates to:
  /// **'Winner'**
  String get winner;

  /// No description provided for @finalStandings.
  ///
  /// In en, this message translates to:
  /// **'Final Standings'**
  String get finalStandings;

  /// No description provided for @rankN.
  ///
  /// In en, this message translates to:
  /// **'#{rank}'**
  String rankN(int rank);

  /// No description provided for @bankrupt.
  ///
  /// In en, this message translates to:
  /// **'BANKRUPT'**
  String get bankrupt;

  /// No description provided for @rounds.
  ///
  /// In en, this message translates to:
  /// **'Rounds'**
  String get rounds;

  /// No description provided for @finalCash.
  ///
  /// In en, this message translates to:
  /// **'Final Cash'**
  String get finalCash;

  /// No description provided for @turns.
  ///
  /// In en, this message translates to:
  /// **'Turns'**
  String get turns;

  /// No description provided for @mainMenu.
  ///
  /// In en, this message translates to:
  /// **'Main Menu'**
  String get mainMenu;

  /// No description provided for @playAgain.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get playAgain;

  /// No description provided for @playerPortfolio.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s Portfolio'**
  String playerPortfolio(String name);

  /// No description provided for @netWorth.
  ///
  /// In en, this message translates to:
  /// **'Net Worth: \${amount}'**
  String netWorth(int amount);

  /// No description provided for @position.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get position;

  /// No description provided for @noPropertiesYet.
  ///
  /// In en, this message translates to:
  /// **'No Properties Yet'**
  String get noPropertiesYet;

  /// No description provided for @startBuyingProperties.
  ///
  /// In en, this message translates to:
  /// **'Start buying properties to build your empire!'**
  String get startBuyingProperties;

  /// No description provided for @rentAmount.
  ///
  /// In en, this message translates to:
  /// **'Rent: \${amount}'**
  String rentAmount(int amount);

  /// No description provided for @mortgaged.
  ///
  /// In en, this message translates to:
  /// **'MORTGAGED'**
  String get mortgaged;

  /// No description provided for @mortgagedLabel.
  ///
  /// In en, this message translates to:
  /// **'Mortgaged'**
  String get mortgagedLabel;

  /// No description provided for @railroad.
  ///
  /// In en, this message translates to:
  /// **'Railroad'**
  String get railroad;

  /// No description provided for @utility.
  ///
  /// In en, this message translates to:
  /// **'Utility'**
  String get utility;

  /// No description provided for @colorBrown.
  ///
  /// In en, this message translates to:
  /// **'Brown'**
  String get colorBrown;

  /// No description provided for @colorLightBlue.
  ///
  /// In en, this message translates to:
  /// **'Light Blue'**
  String get colorLightBlue;

  /// No description provided for @colorPink.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get colorPink;

  /// No description provided for @colorOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get colorOrange;

  /// No description provided for @colorRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get colorRed;

  /// No description provided for @colorYellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get colorYellow;

  /// No description provided for @colorGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get colorGreen;

  /// No description provided for @colorDarkBlue.
  ///
  /// In en, this message translates to:
  /// **'Dark Blue'**
  String get colorDarkBlue;

  /// No description provided for @noneYet.
  ///
  /// In en, this message translates to:
  /// **'None yet'**
  String get noneYet;

  /// No description provided for @noProperties.
  ///
  /// In en, this message translates to:
  /// **'No properties'**
  String get noProperties;

  /// No description provided for @yourTurn.
  ///
  /// In en, this message translates to:
  /// **'YOUR TURN'**
  String get yourTurn;

  /// No description provided for @tileN.
  ///
  /// In en, this message translates to:
  /// **'Tile {position}'**
  String tileN(int position);

  /// No description provided for @rolling.
  ///
  /// In en, this message translates to:
  /// **'ROLLING...'**
  String get rolling;

  /// No description provided for @moving.
  ///
  /// In en, this message translates to:
  /// **'MOVING...'**
  String get moving;

  /// No description provided for @rollDice.
  ///
  /// In en, this message translates to:
  /// **'ROLL DICE'**
  String get rollDice;

  /// No description provided for @tap.
  ///
  /// In en, this message translates to:
  /// **'TAP'**
  String get tap;

  /// No description provided for @spin.
  ///
  /// In en, this message translates to:
  /// **'SPIN'**
  String get spin;

  /// No description provided for @trade.
  ///
  /// In en, this message translates to:
  /// **'Trade'**
  String get trade;

  /// No description provided for @bank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get bank;

  /// No description provided for @use.
  ///
  /// In en, this message translates to:
  /// **'USE'**
  String get use;

  /// No description provided for @gameSaved.
  ///
  /// In en, this message translates to:
  /// **'Game saved successfully!'**
  String get gameSaved;

  /// No description provided for @failedToSave.
  ///
  /// In en, this message translates to:
  /// **'Failed to save game'**
  String get failedToSave;

  /// No description provided for @gameLoaded.
  ///
  /// In en, this message translates to:
  /// **'Game loaded! Round {round}'**
  String gameLoaded(int round);

  /// No description provided for @failedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load game'**
  String get failedToLoad;

  /// No description provided for @noPowerUpCards.
  ///
  /// In en, this message translates to:
  /// **'No power-up cards! Win mini-games to collect them.'**
  String get noPowerUpCards;

  /// No description provided for @yourPowerUpCards.
  ///
  /// In en, this message translates to:
  /// **'Your Power-Up Cards'**
  String get yourPowerUpCards;

  /// No description provided for @noOtherPlayers.
  ///
  /// In en, this message translates to:
  /// **'No other players to trade with!'**
  String get noOtherPlayers;

  /// No description provided for @boughtProperty.
  ///
  /// In en, this message translates to:
  /// **'Bought {name} for \${price}!'**
  String boughtProperty(String name, int price);

  /// No description provided for @paidRentTo.
  ///
  /// In en, this message translates to:
  /// **'Paid \${amount} rent to {name}'**
  String paidRentTo(int amount, String name);

  /// No description provided for @paidTax.
  ///
  /// In en, this message translates to:
  /// **'Paid \${amount} {taxName}'**
  String paidTax(int amount, String taxName);

  /// No description provided for @goingToJail.
  ///
  /// In en, this message translates to:
  /// **'Going to jail!'**
  String get goingToJail;

  /// No description provided for @goToJailTitle.
  ///
  /// In en, this message translates to:
  /// **'Go to Jail!'**
  String get goToJailTitle;

  /// No description provided for @goToJailMessage.
  ///
  /// In en, this message translates to:
  /// **'You landed on Go to Jail!\nGo directly to jail, do not pass GO.'**
  String get goToJailMessage;

  /// No description provided for @wonPrize.
  ///
  /// In en, this message translates to:
  /// **'Spun the wheel and won {prize}!'**
  String wonPrize(String prize);

  /// No description provided for @tradeAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted the trade!'**
  String get tradeAccepted;

  /// No description provided for @tradeRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected the trade.'**
  String get tradeRejected;

  /// No description provided for @tradeCompleted.
  ///
  /// In en, this message translates to:
  /// **'Trade completed!'**
  String get tradeCompleted;

  /// No description provided for @tradeRejectedShort.
  ///
  /// In en, this message translates to:
  /// **'Trade rejected.'**
  String get tradeRejectedShort;

  /// No description provided for @spinPrizeCash50.
  ///
  /// In en, this message translates to:
  /// **'\$50'**
  String get spinPrizeCash50;

  /// No description provided for @spinPrizeCash50Desc.
  ///
  /// In en, this message translates to:
  /// **'Win \$50!'**
  String get spinPrizeCash50Desc;

  /// No description provided for @spinPrizeCash100.
  ///
  /// In en, this message translates to:
  /// **'\$100'**
  String get spinPrizeCash100;

  /// No description provided for @spinPrizeCash100Desc.
  ///
  /// In en, this message translates to:
  /// **'Win \$100!'**
  String get spinPrizeCash100Desc;

  /// No description provided for @spinPrizeCash200.
  ///
  /// In en, this message translates to:
  /// **'\$200'**
  String get spinPrizeCash200;

  /// No description provided for @spinPrizeCash200Desc.
  ///
  /// In en, this message translates to:
  /// **'Win \$200!'**
  String get spinPrizeCash200Desc;

  /// No description provided for @spinPrizeFreeHouse.
  ///
  /// In en, this message translates to:
  /// **'Free House'**
  String get spinPrizeFreeHouse;

  /// No description provided for @spinPrizeFreeHouseDesc.
  ///
  /// In en, this message translates to:
  /// **'Build a free house on any property!'**
  String get spinPrizeFreeHouseDesc;

  /// No description provided for @spinPrizeDoubleRent.
  ///
  /// In en, this message translates to:
  /// **'2x Rent'**
  String get spinPrizeDoubleRent;

  /// No description provided for @spinPrizeDoubleRentDesc.
  ///
  /// In en, this message translates to:
  /// **'Next rent you collect is doubled!'**
  String get spinPrizeDoubleRentDesc;

  /// No description provided for @spinPrizeShield.
  ///
  /// In en, this message translates to:
  /// **'Shield'**
  String get spinPrizeShield;

  /// No description provided for @spinPrizeShieldDesc.
  ///
  /// In en, this message translates to:
  /// **'Skip your next rent payment!'**
  String get spinPrizeShieldDesc;

  /// No description provided for @spinPrizeTeleport.
  ///
  /// In en, this message translates to:
  /// **'Teleport'**
  String get spinPrizeTeleport;

  /// No description provided for @spinPrizeTeleportDesc.
  ///
  /// In en, this message translates to:
  /// **'Move to any tile of your choice!'**
  String get spinPrizeTeleportDesc;

  /// No description provided for @spinPrizeJackpot.
  ///
  /// In en, this message translates to:
  /// **'JACKPOT!'**
  String get spinPrizeJackpot;

  /// No description provided for @spinPrizeJackpotDesc.
  ///
  /// In en, this message translates to:
  /// **'Win \$500 jackpot!'**
  String get spinPrizeJackpotDesc;

  /// No description provided for @luckySpinTitle.
  ///
  /// In en, this message translates to:
  /// **'LUCKY SPIN!'**
  String get luckySpinTitle;

  /// No description provided for @playerTurnToSpin.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s turn to spin!'**
  String playerTurnToSpin(String name);

  /// No description provided for @spinInstructions.
  ///
  /// In en, this message translates to:
  /// **'Tap the center to spin the wheel!'**
  String get spinInstructions;

  /// No description provided for @spinning.
  ///
  /// In en, this message translates to:
  /// **'Spinning...'**
  String get spinning;

  /// No description provided for @youWonPrize.
  ///
  /// In en, this message translates to:
  /// **'You won {name}!'**
  String youWonPrize(String name);

  /// No description provided for @collectPrize.
  ///
  /// In en, this message translates to:
  /// **'Collect Prize!'**
  String get collectPrize;

  /// No description provided for @orTapToSpin.
  ///
  /// In en, this message translates to:
  /// **'Or tap here to spin'**
  String get orTapToSpin;

  /// No description provided for @goodLuck.
  ///
  /// In en, this message translates to:
  /// **'Good luck!'**
  String get goodLuck;

  /// No description provided for @eventMarketBoom.
  ///
  /// In en, this message translates to:
  /// **'Market Boom!'**
  String get eventMarketBoom;

  /// No description provided for @eventMarketBoomDesc.
  ///
  /// In en, this message translates to:
  /// **'All properties are worth 20% more for 3 rounds!'**
  String get eventMarketBoomDesc;

  /// No description provided for @eventTaxHoliday.
  ///
  /// In en, this message translates to:
  /// **'Tax Holiday!'**
  String get eventTaxHoliday;

  /// No description provided for @eventTaxHolidayDesc.
  ///
  /// In en, this message translates to:
  /// **'No taxes this round!'**
  String get eventTaxHolidayDesc;

  /// No description provided for @eventGoldRush.
  ///
  /// In en, this message translates to:
  /// **'Gold Rush!'**
  String get eventGoldRush;

  /// No description provided for @eventGoldRushDesc.
  ///
  /// In en, this message translates to:
  /// **'Collect \$300 instead of \$200 when passing GO for 3 rounds!'**
  String get eventGoldRushDesc;

  /// No description provided for @eventPropertySale.
  ///
  /// In en, this message translates to:
  /// **'Property Sale!'**
  String get eventPropertySale;

  /// No description provided for @eventPropertySaleDesc.
  ///
  /// In en, this message translates to:
  /// **'All unowned properties are 25% off for 2 rounds!'**
  String get eventPropertySaleDesc;

  /// No description provided for @eventLuckyDay.
  ///
  /// In en, this message translates to:
  /// **'Lucky Day!'**
  String get eventLuckyDay;

  /// No description provided for @eventLuckyDayDesc.
  ///
  /// In en, this message translates to:
  /// **'Everyone receives \$50!'**
  String get eventLuckyDayDesc;

  /// No description provided for @eventHousingBoom.
  ///
  /// In en, this message translates to:
  /// **'Housing Boom!'**
  String get eventHousingBoom;

  /// No description provided for @eventHousingBoomDesc.
  ///
  /// In en, this message translates to:
  /// **'Free upgrade on one random property!'**
  String get eventHousingBoomDesc;

  /// No description provided for @eventRentStrike.
  ///
  /// In en, this message translates to:
  /// **'Rent Strike!'**
  String get eventRentStrike;

  /// No description provided for @eventRentStrikeDesc.
  ///
  /// In en, this message translates to:
  /// **'All rents are reduced by 50% for 2 rounds.'**
  String get eventRentStrikeDesc;

  /// No description provided for @eventMeteorShower.
  ///
  /// In en, this message translates to:
  /// **'Meteor Shower!'**
  String get eventMeteorShower;

  /// No description provided for @eventMeteorShowerDesc.
  ///
  /// In en, this message translates to:
  /// **'A random player loses \$100!'**
  String get eventMeteorShowerDesc;

  /// No description provided for @eventCommunityCleanup.
  ///
  /// In en, this message translates to:
  /// **'Community Clean-up'**
  String get eventCommunityCleanup;

  /// No description provided for @eventCommunityCleanupDesc.
  ///
  /// In en, this message translates to:
  /// **'Pay \$25 for each house you own.'**
  String get eventCommunityCleanupDesc;

  /// No description provided for @eventStockDividend.
  ///
  /// In en, this message translates to:
  /// **'Stock Dividend'**
  String get eventStockDividend;

  /// No description provided for @eventStockDividendDesc.
  ///
  /// In en, this message translates to:
  /// **'Each player receives \$10 per property owned.'**
  String get eventStockDividendDesc;

  /// No description provided for @eventBirthdayParty.
  ///
  /// In en, this message translates to:
  /// **'Birthday Party!'**
  String get eventBirthdayParty;

  /// No description provided for @eventBirthdayPartyDesc.
  ///
  /// In en, this message translates to:
  /// **'Current player collects \$25 from each other player!'**
  String get eventBirthdayPartyDesc;

  /// No description provided for @eventBankError.
  ///
  /// In en, this message translates to:
  /// **'Bank Error'**
  String get eventBankError;

  /// No description provided for @eventBankErrorDesc.
  ///
  /// In en, this message translates to:
  /// **'A random player receives \$200!'**
  String get eventBankErrorDesc;

  /// No description provided for @eventMarketCrash.
  ///
  /// In en, this message translates to:
  /// **'Market Crash!'**
  String get eventMarketCrash;

  /// No description provided for @eventMarketCrashDesc.
  ///
  /// In en, this message translates to:
  /// **'Property values fluctuate wildly! Random effects for everyone!'**
  String get eventMarketCrashDesc;

  /// No description provided for @powerUpRentReducer.
  ///
  /// In en, this message translates to:
  /// **'Rent Reducer'**
  String get powerUpRentReducer;

  /// No description provided for @powerUpRentReducerDesc.
  ///
  /// In en, this message translates to:
  /// **'Pay only 50% rent this turn'**
  String get powerUpRentReducerDesc;

  /// No description provided for @powerUpSpeedBoost.
  ///
  /// In en, this message translates to:
  /// **'Speed Boost'**
  String get powerUpSpeedBoost;

  /// No description provided for @powerUpSpeedBoostDesc.
  ///
  /// In en, this message translates to:
  /// **'Roll again after moving'**
  String get powerUpSpeedBoostDesc;

  /// No description provided for @powerUpPropertyScout.
  ///
  /// In en, this message translates to:
  /// **'Property Scout'**
  String get powerUpPropertyScout;

  /// No description provided for @powerUpPropertyScoutDesc.
  ///
  /// In en, this message translates to:
  /// **'See all unowned property prices'**
  String get powerUpPropertyScoutDesc;

  /// No description provided for @powerUpRentCollector.
  ///
  /// In en, this message translates to:
  /// **'Rent Collector'**
  String get powerUpRentCollector;

  /// No description provided for @powerUpRentCollectorDesc.
  ///
  /// In en, this message translates to:
  /// **'Collect \$50 from each player'**
  String get powerUpRentCollectorDesc;

  /// No description provided for @powerUpPriceFreeze.
  ///
  /// In en, this message translates to:
  /// **'Price Freeze'**
  String get powerUpPriceFreeze;

  /// No description provided for @powerUpPriceFreezeDesc.
  ///
  /// In en, this message translates to:
  /// **'Buy next property at 75% price'**
  String get powerUpPriceFreezeDesc;

  /// No description provided for @powerUpTeleporter.
  ///
  /// In en, this message translates to:
  /// **'Teleporter'**
  String get powerUpTeleporter;

  /// No description provided for @powerUpTeleporterDesc.
  ///
  /// In en, this message translates to:
  /// **'Move to any unowned property'**
  String get powerUpTeleporterDesc;

  /// No description provided for @powerUpShield.
  ///
  /// In en, this message translates to:
  /// **'Shield'**
  String get powerUpShield;

  /// No description provided for @powerUpShieldDesc.
  ///
  /// In en, this message translates to:
  /// **'Block one rent payment'**
  String get powerUpShieldDesc;

  /// No description provided for @powerUpDoubleDice.
  ///
  /// In en, this message translates to:
  /// **'Double Dice'**
  String get powerUpDoubleDice;

  /// No description provided for @powerUpDoubleDiceDesc.
  ///
  /// In en, this message translates to:
  /// **'Roll with 4 dice, pick best 2'**
  String get powerUpDoubleDiceDesc;

  /// No description provided for @powerUpMoneyMagnet.
  ///
  /// In en, this message translates to:
  /// **'Money Magnet'**
  String get powerUpMoneyMagnet;

  /// No description provided for @powerUpMoneyMagnetDesc.
  ///
  /// In en, this message translates to:
  /// **'Extra \$100 when passing GO (3 turns)'**
  String get powerUpMoneyMagnetDesc;

  /// No description provided for @powerUpMonopolyMaster.
  ///
  /// In en, this message translates to:
  /// **'Monopoly Master'**
  String get powerUpMonopolyMaster;

  /// No description provided for @powerUpMonopolyMasterDesc.
  ///
  /// In en, this message translates to:
  /// **'Free house on all owned properties!'**
  String get powerUpMonopolyMasterDesc;

  /// No description provided for @powerUpRarityCommon.
  ///
  /// In en, this message translates to:
  /// **'Common'**
  String get powerUpRarityCommon;

  /// No description provided for @powerUpRarityUncommon.
  ///
  /// In en, this message translates to:
  /// **'Uncommon'**
  String get powerUpRarityUncommon;

  /// No description provided for @powerUpRarityRare.
  ///
  /// In en, this message translates to:
  /// **'Rare'**
  String get powerUpRarityRare;

  /// No description provided for @powerUpRarityLegendary.
  ///
  /// In en, this message translates to:
  /// **'Legendary'**
  String get powerUpRarityLegendary;

  /// No description provided for @winnerTitle.
  ///
  /// In en, this message translates to:
  /// **'WINNER!'**
  String get winnerTitle;

  /// No description provided for @gameStats.
  ///
  /// In en, this message translates to:
  /// **'Game Stats'**
  String get gameStats;

  /// No description provided for @shopTitle.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shopTitle;

  /// No description provided for @shopSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock themes, tokens & more!'**
  String get shopSubtitle;

  /// No description provided for @unlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get unlocked;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @loadingAd.
  ///
  /// In en, this message translates to:
  /// **'Loading ad...'**
  String get loadingAd;

  /// No description provided for @adsProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress: {watched}/{required} ads watched!'**
  String adsProgress(int watched, int required);

  /// No description provided for @purchaseItem.
  ///
  /// In en, this message translates to:
  /// **'Purchase {name}?'**
  String purchaseItem(String name);

  /// No description provided for @unlockFor.
  ///
  /// In en, this message translates to:
  /// **'Unlock for {price}'**
  String unlockFor(String price);

  /// No description provided for @buyPrice.
  ///
  /// In en, this message translates to:
  /// **'Buy {price}'**
  String buyPrice(String price);

  /// No description provided for @unlockedExcl.
  ///
  /// In en, this message translates to:
  /// **'UNLOCKED!'**
  String get unlockedExcl;

  /// No description provided for @awesome.
  ///
  /// In en, this message translates to:
  /// **'Awesome!'**
  String get awesome;

  /// No description provided for @watchAdsToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Watch ads to unlock'**
  String get watchAdsToUnlock;

  /// No description provided for @watchAdsOrPay.
  ///
  /// In en, this message translates to:
  /// **'Watch {count} ads or pay to unlock instantly'**
  String watchAdsOrPay(int count);

  /// No description provided for @watchAdsCount.
  ///
  /// In en, this message translates to:
  /// **'Watch {count} ads to unlock'**
  String watchAdsCount(int count);

  /// No description provided for @purchaseToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Purchase to unlock'**
  String get purchaseToUnlock;

  /// No description provided for @useThis.
  ///
  /// In en, this message translates to:
  /// **'Use This'**
  String get useThis;

  /// No description provided for @owned.
  ///
  /// In en, this message translates to:
  /// **'Owned'**
  String get owned;

  /// No description provided for @familyLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Family Leaderboard'**
  String get familyLeaderboard;

  /// No description provided for @rankings.
  ///
  /// In en, this message translates to:
  /// **'Rankings'**
  String get rankings;

  /// No description provided for @records.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get records;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by: '**
  String get sortBy;

  /// No description provided for @wins.
  ///
  /// In en, this message translates to:
  /// **'Wins'**
  String get wins;

  /// No description provided for @winPercent.
  ///
  /// In en, this message translates to:
  /// **'Win %'**
  String get winPercent;

  /// No description provided for @earnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earnings;

  /// No description provided for @games.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get games;

  /// No description provided for @noPlayersYet.
  ///
  /// In en, this message translates to:
  /// **'No players yet'**
  String get noPlayersYet;

  /// No description provided for @playToSeeStats.
  ///
  /// In en, this message translates to:
  /// **'Play some games to see stats!'**
  String get playToSeeStats;

  /// No description provided for @mostWins.
  ///
  /// In en, this message translates to:
  /// **'Most Wins'**
  String get mostWins;

  /// No description provided for @highestCash.
  ///
  /// In en, this message translates to:
  /// **'Highest Cash'**
  String get highestCash;

  /// No description provided for @propertyTycoonRecord.
  ///
  /// In en, this message translates to:
  /// **'Property Tycoon'**
  String get propertyTycoonRecord;

  /// No description provided for @longestWinStreak.
  ///
  /// In en, this message translates to:
  /// **'Longest Win Streak'**
  String get longestWinStreak;

  /// No description provided for @speedChampion.
  ///
  /// In en, this message translates to:
  /// **'Speed Champion'**
  String get speedChampion;

  /// No description provided for @luckiestRoller.
  ///
  /// In en, this message translates to:
  /// **'Luckiest Roller'**
  String get luckiestRoller;

  /// No description provided for @inARow.
  ///
  /// In en, this message translates to:
  /// **'{count} in a row'**
  String inARow(int count);

  /// No description provided for @turnsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} turns'**
  String turnsCount(int count);

  /// No description provided for @avgValue.
  ///
  /// In en, this message translates to:
  /// **'{value} avg'**
  String avgValue(String value);

  /// No description provided for @memoryMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Memory Match'**
  String get memoryMatchTitle;

  /// No description provided for @pairs.
  ///
  /// In en, this message translates to:
  /// **'Pairs'**
  String get pairs;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;

  /// No description provided for @secondsShort.
  ///
  /// In en, this message translates to:
  /// **'{seconds} s'**
  String secondsShort(int seconds);

  /// No description provided for @greatJob.
  ///
  /// In en, this message translates to:
  /// **'Great Job!'**
  String get greatJob;

  /// No description provided for @timeUp.
  ///
  /// In en, this message translates to:
  /// **'Time\'s Up!'**
  String get timeUp;

  /// No description provided for @pairsFound.
  ///
  /// In en, this message translates to:
  /// **'Pairs Found: {found} / {total}'**
  String pairsFound(int found, int total);

  /// No description provided for @scoreAmount.
  ///
  /// In en, this message translates to:
  /// **'Score: {score}'**
  String scoreAmount(int score);

  /// No description provided for @quickTapAmazing.
  ///
  /// In en, this message translates to:
  /// **'AMAZING!'**
  String get quickTapAmazing;

  /// No description provided for @quickTapGreat.
  ///
  /// In en, this message translates to:
  /// **'Great!'**
  String get quickTapGreat;

  /// No description provided for @quickTapGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get quickTapGood;

  /// No description provided for @quickTapTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get quickTapTryAgain;

  /// No description provided for @quickTapInstruction.
  ///
  /// In en, this message translates to:
  /// **'Tap the coins! Avoid bombs!'**
  String get quickTapInstruction;

  /// No description provided for @streakCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Streak!'**
  String streakCount(int count);

  /// No description provided for @itemSelected.
  ///
  /// In en, this message translates to:
  /// **'{name} selected!'**
  String itemSelected(String name);

  /// No description provided for @deletePhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Photo?'**
  String get deletePhotoTitle;

  /// No description provided for @deletePhotoMessage.
  ///
  /// In en, this message translates to:
  /// **'This photo will be removed from your avatars.'**
  String get deletePhotoMessage;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @choosePhoto.
  ///
  /// In en, this message translates to:
  /// **'Choose Photo'**
  String get choosePhoto;

  /// No description provided for @noPhotosYet.
  ///
  /// In en, this message translates to:
  /// **'No photos yet'**
  String get noPhotosYet;

  /// No description provided for @takeSelfieOrPick.
  ///
  /// In en, this message translates to:
  /// **'Take a selfie or pick from gallery!'**
  String get takeSelfieOrPick;

  /// No description provided for @chooseYourAvatarFancy.
  ///
  /// In en, this message translates to:
  /// **'✨ Choose Your Avatar ✨'**
  String get chooseYourAvatarFancy;

  /// No description provided for @avatarCategoryAnimals.
  ///
  /// In en, this message translates to:
  /// **'Animals'**
  String get avatarCategoryAnimals;

  /// No description provided for @avatarCategoryFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get avatarCategoryFood;

  /// No description provided for @avatarCategoryObjects.
  ///
  /// In en, this message translates to:
  /// **'Objects'**
  String get avatarCategoryObjects;

  /// No description provided for @avatarCategoryCharacters.
  ///
  /// In en, this message translates to:
  /// **'Characters'**
  String get avatarCategoryCharacters;

  /// No description provided for @avatarCategoryMyPhotos.
  ///
  /// In en, this message translates to:
  /// **'My Photos'**
  String get avatarCategoryMyPhotos;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @countryUSA.
  ///
  /// In en, this message translates to:
  /// **'United States'**
  String get countryUSA;

  /// No description provided for @countryUK.
  ///
  /// In en, this message translates to:
  /// **'United Kingdom'**
  String get countryUK;

  /// No description provided for @countryFrance.
  ///
  /// In en, this message translates to:
  /// **'France'**
  String get countryFrance;

  /// No description provided for @countryJapan.
  ///
  /// In en, this message translates to:
  /// **'Japan'**
  String get countryJapan;

  /// No description provided for @countryChina.
  ///
  /// In en, this message translates to:
  /// **'China'**
  String get countryChina;

  /// No description provided for @countryMexico.
  ///
  /// In en, this message translates to:
  /// **'Mexico'**
  String get countryMexico;

  /// No description provided for @chooseCity.
  ///
  /// In en, this message translates to:
  /// **'Choose City'**
  String get chooseCity;

  /// No description provided for @cityAtlanticCity.
  ///
  /// In en, this message translates to:
  /// **'Atlantic City'**
  String get cityAtlanticCity;

  /// No description provided for @cityNewYork.
  ///
  /// In en, this message translates to:
  /// **'New York City'**
  String get cityNewYork;

  /// No description provided for @cityLosAngeles.
  ///
  /// In en, this message translates to:
  /// **'Los Angeles'**
  String get cityLosAngeles;

  /// No description provided for @cityLondon.
  ///
  /// In en, this message translates to:
  /// **'London'**
  String get cityLondon;

  /// No description provided for @cityEdinburgh.
  ///
  /// In en, this message translates to:
  /// **'Edinburgh'**
  String get cityEdinburgh;

  /// No description provided for @cityManchester.
  ///
  /// In en, this message translates to:
  /// **'Manchester'**
  String get cityManchester;

  /// No description provided for @cityParis.
  ///
  /// In en, this message translates to:
  /// **'Paris'**
  String get cityParis;

  /// No description provided for @cityLyon.
  ///
  /// In en, this message translates to:
  /// **'Lyon'**
  String get cityLyon;

  /// No description provided for @cityMarseille.
  ///
  /// In en, this message translates to:
  /// **'Marseille'**
  String get cityMarseille;

  /// No description provided for @cityTokyo.
  ///
  /// In en, this message translates to:
  /// **'Tokyo'**
  String get cityTokyo;

  /// No description provided for @cityOsaka.
  ///
  /// In en, this message translates to:
  /// **'Osaka'**
  String get cityOsaka;

  /// No description provided for @cityKyoto.
  ///
  /// In en, this message translates to:
  /// **'Kyoto'**
  String get cityKyoto;

  /// No description provided for @cityBeijing.
  ///
  /// In en, this message translates to:
  /// **'Beijing'**
  String get cityBeijing;

  /// No description provided for @cityShanghai.
  ///
  /// In en, this message translates to:
  /// **'Shanghai'**
  String get cityShanghai;

  /// No description provided for @cityHongKong.
  ///
  /// In en, this message translates to:
  /// **'Hong Kong'**
  String get cityHongKong;

  /// No description provided for @cityMexicoCity.
  ///
  /// In en, this message translates to:
  /// **'Mexico City'**
  String get cityMexicoCity;

  /// No description provided for @cityGuadalajara.
  ///
  /// In en, this message translates to:
  /// **'Guadalajara'**
  String get cityGuadalajara;

  /// No description provided for @cityCancun.
  ///
  /// In en, this message translates to:
  /// **'Cancún'**
  String get cityCancun;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr', 'ja', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
