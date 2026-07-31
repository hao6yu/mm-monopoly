// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'M&M Property Tycoon';

  @override
  String get propertyTycoon => 'PROPERTY TYCOON';

  @override
  String get familyEdition => 'FAMILY EDITION';

  @override
  String get worldCityEdition => 'WORLD CITY EDITION';

  @override
  String get chooseNextMove => 'Choose your next move';

  @override
  String get newGame => 'New Game';

  @override
  String get continueGame => 'Continue';

  @override
  String get howToPlay => 'How to Play';

  @override
  String get settings => 'Settings';

  @override
  String get shop => 'Shop';

  @override
  String get howManyPlayers => 'How Many Players?';

  @override
  String get gameSetupTitle => 'Create Your Game';

  @override
  String get gameSetupSubtitle =>
      'Choose a city, game size, and movement style.';

  @override
  String get playerSetupSubtitle =>
      'Give every player a name, color, and character.';

  @override
  String get gameSummary => 'Game Summary';

  @override
  String get readyToPlay => 'Ready to play';

  @override
  String get playerSetup => 'Player Setup';

  @override
  String get chooseBoard => 'Choose Board';

  @override
  String get numberOfPlayers => 'Number of Players';

  @override
  String get numberOfDice => 'Number of Dice';

  @override
  String get players => 'players';

  @override
  String get oneDie => 'One Die';

  @override
  String get twoDice => 'Two Dice';

  @override
  String get classicStyle => 'Classic style';

  @override
  String get standardRules => 'Standard rules';

  @override
  String get playersStep => 'Players';

  @override
  String get setupStep => 'Setup';

  @override
  String get back => 'Back';

  @override
  String get previous => 'Previous';

  @override
  String get next => 'Next';

  @override
  String get startGame => 'Start Game';

  @override
  String playerN(int number) {
    return 'Player $number';
  }

  @override
  String get you => 'You';

  @override
  String get ai => 'AI';

  @override
  String get name => 'Name';

  @override
  String get chooseYourAvatar => 'Choose Your Avatar';

  @override
  String get uniqueNameError => 'Each player must have a unique name';

  @override
  String get allPlayersNeedName => 'All players must have a name';

  @override
  String get uniqueColorError => 'Each player must have a unique color';

  @override
  String get tutorialRollMove => 'Roll & Move';

  @override
  String get tutorialRollMoveDesc =>
      'Tap the dice to roll!\nMove around the board.';

  @override
  String get tutorialBuyProperties => 'Buy Properties';

  @override
  String get tutorialBuyPropertiesDesc =>
      'Land on an empty spot?\nBuy it and own it!';

  @override
  String get tutorialCollectRent => 'Collect Rent';

  @override
  String get tutorialCollectRentDesc =>
      'Others land on your property?\nThey pay YOU!';

  @override
  String get tutorialSpecialSpaces => 'Special Spaces';

  @override
  String get tutorialSpecialSpacesDesc =>
      'Chance cards, jail, trains...\nSurprises everywhere!';

  @override
  String get tutorialWinGame => 'Win the Game!';

  @override
  String get tutorialWinGameDesc =>
      'Last player with money wins!\nBankrupt your friends!';

  @override
  String get letsPlay => 'Let\'s Play!';

  @override
  String get gotIt => 'Got it!';

  @override
  String get startingCash => 'Starting Cash';

  @override
  String get gameOptions => 'Game Options';

  @override
  String get soundAndLanguage => 'Sound & Language';

  @override
  String get settingsSubtitle => 'Tune your table before the next game';

  @override
  String get playerTrading => 'Player Trading';

  @override
  String get bankFeatures => 'Bank Features';

  @override
  String get propertyAuctions => 'Property Auctions';

  @override
  String get backgroundMusic => 'Background Music';

  @override
  String get gameSounds => 'Game Sounds';

  @override
  String get language => 'Language';

  @override
  String get buyMeACoffee => 'Buy me a coffee';

  @override
  String get buyMeACoffeeDesc =>
      'Your support helps keep the game free and updated. Every coffee means a lot!';

  @override
  String get openExternalLink => 'Open External Link';

  @override
  String get openBuyMeACoffeeDesc =>
      'This will open buymeacoffee.com in your browser.';

  @override
  String get cancel => 'Cancel';

  @override
  String get open => 'Open';

  @override
  String get reset => 'Reset';

  @override
  String get backToMenu => 'Back to Menu';

  @override
  String get settingsReset => 'Settings reset';

  @override
  String get propertyAvailable => 'This property is available!';

  @override
  String get price => 'Price';

  @override
  String get baseRent => 'Base Rent';

  @override
  String get rent => 'Rent';

  @override
  String get utilityRentDesc => '4x or 10x dice roll';

  @override
  String get yourCash => 'Your Cash';

  @override
  String get notEnoughCash => 'Not enough cash!';

  @override
  String get skip => 'Skip';

  @override
  String buyForAmount(String amount) {
    return 'Buy \$$amount';
  }

  @override
  String get bankruptcy => 'BANKRUPTCY!';

  @override
  String get payRent => 'Pay Rent';

  @override
  String landedOnProperty(String propertyName) {
    return 'You landed on $propertyName';
  }

  @override
  String get ownsThisProperty => 'owns this property';

  @override
  String get rentDue => 'Rent Due';

  @override
  String diceRentCalc(int diceRoll, int multiplier, int amount) {
    return 'Dice: $diceRoll × $multiplier = \$$amount';
  }

  @override
  String get ownerHasBothUtilities => '(Owner has both utilities)';

  @override
  String get ownerHasOneUtility => '(Owner has 1 utility)';

  @override
  String ownerHasRailroads(int count, String suffix) {
    return 'Owner has $count railroad$suffix';
  }

  @override
  String get bankruptMessage =>
      'You don\'t have enough cash! You are bankrupt.';

  @override
  String get acceptBankruptcy => 'Accept Bankruptcy';

  @override
  String payAmount(int amount) {
    return 'Pay \$$amount';
  }

  @override
  String get payTaxToBank => 'You must pay tax to the bank';

  @override
  String get taxAmount => 'Tax Amount';

  @override
  String get gameMenu => 'Game Menu';

  @override
  String get backToGame => 'Back to Game';

  @override
  String get saveGame => 'Save Game';

  @override
  String get loadGame => 'Load Game';

  @override
  String get loadSavedGame => 'Load Saved Game?';

  @override
  String get currentProgressLost => 'Current game progress will be lost.';

  @override
  String get restartGame => 'Restart Game';

  @override
  String get allProgressLost => 'All progress will be lost.';

  @override
  String get quitToMenu => 'Quit to Menu';

  @override
  String get quitGame => 'Quit Game?';

  @override
  String get confirm => 'Confirm';

  @override
  String get inJail => 'IN JAIL';

  @override
  String get youAreInJail => 'You are in jail!';

  @override
  String get bailAmount => 'Bail Amount';

  @override
  String stayInJailTurns(int turns, String suffix) {
    return 'Or stay in jail for $turns more turn$suffix.';
  }

  @override
  String get mustPayFine => 'You must pay the fine to get out!';

  @override
  String get stayInJail => 'Stay in Jail';

  @override
  String payBail(int amount) {
    return 'Pay \$$amount';
  }

  @override
  String get buildHotel => 'Build a Hotel!';

  @override
  String get buildHouse => 'Build a House!';

  @override
  String get upgradeCost => 'Upgrade Cost';

  @override
  String get currentRent => 'Current Rent';

  @override
  String get newRent => 'New Rent';

  @override
  String get increase => 'Increase';

  @override
  String buildForAmount(int amount) {
    return 'Build \$$amount';
  }

  @override
  String get eventGoodNews => 'Good News!';

  @override
  String get eventBadNews => 'Bad News!';

  @override
  String get eventNewsFlash => 'News Flash!';

  @override
  String get eventWildCard => 'Wild Card!';

  @override
  String eventLastsRounds(int duration, String suffix) {
    return 'Lasts $duration round$suffix';
  }

  @override
  String get auction => 'AUCTION';

  @override
  String propertyValue(int amount) {
    return 'Value: \$$amount';
  }

  @override
  String get currentBid => 'Current Bid:';

  @override
  String get noBidsYet => 'No bids yet';

  @override
  String get leadingBidder => 'Leading Bidder:';

  @override
  String get bidders => 'Bidders:';

  @override
  String playerTurn(String name) {
    return '$name\'s Turn';
  }

  @override
  String get notEnoughCashToBid => 'Not enough cash to bid';

  @override
  String get pass => 'Pass';

  @override
  String bidAmount(int amount) {
    return 'Bid \$$amount';
  }

  @override
  String get notEnoughCashShort => 'Not enough cash';

  @override
  String playerWinsAuction(String name) {
    return '$name wins the auction!';
  }

  @override
  String get noWinnerAuction => 'No winner - property returns to bank';

  @override
  String finalBid(int amount) {
    return 'Final bid: \$$amount';
  }

  @override
  String get proposeTrade => 'Propose a Trade';

  @override
  String get tradeWith => 'Trade with:';

  @override
  String youOffer(String name) {
    return 'You Offer ($name)';
  }

  @override
  String get cash => 'Cash';

  @override
  String get cashLabel => 'Cash:';

  @override
  String get properties => 'Properties';

  @override
  String get propertiesLabel => 'Properties:';

  @override
  String get noPropertiesToOffer => 'No properties to offer';

  @override
  String youRequest(String name) {
    return 'You Request (from $name)';
  }

  @override
  String get noPropertiesAvailable => 'No properties available';

  @override
  String get proposeTradeBtn => 'Propose Trade';

  @override
  String wantsToTrade(String name) {
    return '$name wants to trade!';
  }

  @override
  String get youReceive => 'You Receive:';

  @override
  String get youGive => 'You Give:';

  @override
  String get nothing => 'Nothing';

  @override
  String get reject => 'Reject';

  @override
  String get accept => 'Accept';

  @override
  String get propertyManagement => 'Property Management';

  @override
  String get mortgage => 'Mortgage';

  @override
  String get unmortgage => 'Unmortgage';

  @override
  String mortgageCount(int count) {
    return 'Mortgage ($count)';
  }

  @override
  String unmortgageCount(int count) {
    return 'Unmortgage ($count)';
  }

  @override
  String get noMortgageableProperties =>
      'No properties available to mortgage.\nProperties with houses must sell houses first.';

  @override
  String get noMortgagedProperties => 'No mortgaged properties.';

  @override
  String receiveAmount(int amount) {
    return 'Receive: \$$amount';
  }

  @override
  String costAmount(int amount) {
    return 'Cost: \$$amount';
  }

  @override
  String get pay => 'Pay';

  @override
  String get close => 'Close';

  @override
  String get propertyLocation => 'Property Location';

  @override
  String get startingPoint => 'Starting Point';

  @override
  String get justVisiting => 'Just Visiting / In Jail';

  @override
  String get spinToWin => 'Spin to Win!';

  @override
  String get goToJailLabel => 'Go To Jail';

  @override
  String get chanceCard => 'Chance';

  @override
  String get communityChestCard => 'Comm Chest';

  @override
  String get incomeTax => 'Income Tax';

  @override
  String get luxuryTax => 'Luxury Tax';

  @override
  String get didYouKnow => 'Did You Know?';

  @override
  String get ownAllPropertiesTip =>
      'Own all properties in a color group to charge double rent!';

  @override
  String get buildHousesEvenlyTip =>
      'Build houses evenly across your properties for maximum profit.';

  @override
  String hotelsMaxRentTip(int amount) {
    return 'Hotels generate the highest rent - up to \$$amount!';
  }

  @override
  String get railroad1Tip => 'Own 1 railroad: \$25 rent';

  @override
  String get railroad2Tip => 'Own 2 railroads: \$50 rent';

  @override
  String get railroad3Tip => 'Own 3 railroads: \$100 rent';

  @override
  String get railroad4Tip => 'Own all 4 railroads: \$200 rent!';

  @override
  String get utility1Tip => 'Own 1 utility: Rent = 4× dice roll';

  @override
  String get utility2Tip => 'Own both utilities: Rent = 10× dice roll!';

  @override
  String get utilitiesProfitableTip =>
      'Utilities can be very profitable with high dice rolls.';

  @override
  String get chanceHowToPlay => 'How to Play';

  @override
  String get chestHowToPlay => 'How to Play';

  @override
  String get drawTopCard => 'Draw the top card from the Chance pile';

  @override
  String get readCardAloud => 'Read the card out loud';

  @override
  String get doWhatCardSays => 'Do what the card says!';

  @override
  String get putCardBottom => 'Put the card at the bottom of the pile';

  @override
  String get jailRules => 'Jail Rules';

  @override
  String get goToJailRules => 'Go To Jail Rules';

  @override
  String get taxRules => 'Tax Rules';

  @override
  String get drawTopChestCard => 'Draw the top card from the chest';

  @override
  String get readToEveryone => 'Read it out loud to everyone';

  @override
  String get followInstructions => 'Follow the instructions on the card';

  @override
  String get returnCardBottom => 'Return the card to the bottom';

  @override
  String get justVisitingSafe => 'If you\'re \"Just Visiting\" - you\'re safe!';

  @override
  String get inJailYouCan => 'If you\'re IN jail, you can:';

  @override
  String get pay50GetOut => '  • Pay \$50 to get out';

  @override
  String get rollDoublesThreeTries => '  • Try to roll doubles (3 tries)';

  @override
  String get useGetOutCard => '  • Use a \"Get Out of Jail Free\" card';

  @override
  String get goDirectlyToJail => 'Go directly to Jail!';

  @override
  String get doNotPassGo => 'Do NOT pass GO';

  @override
  String get doNotCollect200 => 'Do NOT collect \$200';

  @override
  String get turnEndsImmediately => 'Your turn ends immediately';

  @override
  String get mustPayTaxRule => 'You MUST pay this tax!';

  @override
  String get payBankAmountShown => 'Pay the bank the amount shown';

  @override
  String get cantPayMightGoBankrupt =>
      'If you can\'t pay, you might go bankrupt!';

  @override
  String get collectGoBonus => 'Collect money when you land on or pass GO.';

  @override
  String get passGoEarn => 'Passing GO keeps your cash flow healthy.';

  @override
  String get startTileFunFact => 'GO is the most visited tile in Monopoly.';

  @override
  String get jailFactOne => 'Landing here can mean jail time or just visiting.';

  @override
  String get jailFactTwo => 'You can pay bail or try to roll doubles.';

  @override
  String get jailFunFact =>
      'Jail is one of the most strategic spaces in the game.';

  @override
  String get freeParkingFactOne =>
      'Spin the wheel to win cash, power-ups, or special prizes!';

  @override
  String get freeParkingFactTwo =>
      'Every spin guarantees a reward — no bad outcomes!';

  @override
  String get freeParkingFunFact =>
      'Lucky Spin is where fortunes can change in an instant.';

  @override
  String get goToJailFactOne => 'This sends your token directly to Jail.';

  @override
  String get goToJailFactTwo => 'You do not collect GO money on this move.';

  @override
  String get goToJailFunFact => 'Avoid this tile to keep your momentum.';

  @override
  String get chanceFunFact => 'Chance cards add surprise to every match.';

  @override
  String get communityChestFactOne => 'The community helps each other!';

  @override
  String get communityChestFactTwo => 'These cards often give you money.';

  @override
  String get communityChestFactThree => 'Bank error in your favor can happen!';

  @override
  String get communityChestFunFact =>
      'Community Chest cards are often friendly.';

  @override
  String get taxFactOne => 'Everyone has to pay taxes!';

  @override
  String get taxFactTwo => 'Taxes help support public services.';

  @override
  String get taxFunFact => 'Tax spaces can quickly change game momentum.';

  @override
  String aiBuiltOn(String level, String property) {
    return 'Built a $level on $property!';
  }

  @override
  String get chance => 'CHANCE';

  @override
  String get communityChest => 'COMM CHEST';

  @override
  String get chanceExcl => 'CHANCE!';

  @override
  String get communityChestExcl => 'COMM CHEST!';

  @override
  String get tapCardToPick => 'Tap a card to pick it!';

  @override
  String get revealingCard => 'Revealing your card...';

  @override
  String get tapToContinue => 'Tap anywhere to continue';

  @override
  String get chestShort => 'COMM CHEST';

  @override
  String get ok => 'OK';

  @override
  String get freeHouseTitle => 'FREE HOUSE!';

  @override
  String get choosePropertyToBuild => 'Choose a property to build on';

  @override
  String get noUpgradeableProperties => 'No properties available to upgrade!';

  @override
  String get buyPropertiesComeBack => 'Buy properties and come back later.';

  @override
  String houseN(int level) {
    return 'House $level';
  }

  @override
  String get hotel => 'Hotel';

  @override
  String nextUpgrade(String text) {
    return 'Next: $text';
  }

  @override
  String get saveForLater => 'Save for Later';

  @override
  String get build => 'Build!';

  @override
  String get teleportTitle => 'TELEPORT!';

  @override
  String get chooseTileToTeleport => 'Choose any tile to teleport to';

  @override
  String get all => 'All';

  @override
  String get railroads => 'Railroads';

  @override
  String get utilities => 'Utilities';

  @override
  String get special => 'Special';

  @override
  String get noTilesMatch => 'No tiles match this filter';

  @override
  String get teleportBtn => 'Teleport!';

  @override
  String get gameOver => 'GAME OVER!';

  @override
  String get winner => 'Winner';

  @override
  String get finalStandings => 'Final Standings';

  @override
  String rankN(int rank) {
    return '#$rank';
  }

  @override
  String get bankrupt => 'BANKRUPT';

  @override
  String get rounds => 'Rounds';

  @override
  String get finalCash => 'Final Cash';

  @override
  String get turns => 'Turns';

  @override
  String get mainMenu => 'Main Menu';

  @override
  String get playAgain => 'Play Again';

  @override
  String playerPortfolio(String name) {
    return '$name\'s Portfolio';
  }

  @override
  String netWorth(int amount) {
    return 'Net Worth: \$$amount';
  }

  @override
  String get position => 'Position';

  @override
  String get noPropertiesYet => 'No Properties Yet';

  @override
  String get startBuyingProperties =>
      'Start buying properties to build your empire!';

  @override
  String rentAmount(int amount) {
    return 'Rent: \$$amount';
  }

  @override
  String get mortgaged => 'MORTGAGED';

  @override
  String get mortgagedLabel => 'Mortgaged';

  @override
  String get railroad => 'Railroad';

  @override
  String get utility => 'Utility';

  @override
  String get colorBrown => 'Brown';

  @override
  String get colorLightBlue => 'Light Blue';

  @override
  String get colorPink => 'Pink';

  @override
  String get colorOrange => 'Orange';

  @override
  String get colorRed => 'Red';

  @override
  String get colorYellow => 'Yellow';

  @override
  String get colorGreen => 'Green';

  @override
  String get colorDarkBlue => 'Dark Blue';

  @override
  String get noneYet => 'None yet';

  @override
  String get noProperties => 'No properties';

  @override
  String get yourTurn => 'YOUR TURN';

  @override
  String tileN(int position) {
    return 'Tile $position';
  }

  @override
  String get rolling => 'ROLLING...';

  @override
  String get moving => 'MOVING...';

  @override
  String get rollDice => 'ROLL DICE';

  @override
  String get tap => 'TAP';

  @override
  String get spin => 'SPIN';

  @override
  String get trade => 'Trade';

  @override
  String get bank => 'Bank';

  @override
  String get use => 'USE';

  @override
  String get gameSaved => 'Game saved successfully!';

  @override
  String get failedToSave => 'Failed to save game';

  @override
  String gameLoaded(int round) {
    return 'Game loaded! Round $round';
  }

  @override
  String get failedToLoad => 'Failed to load game';

  @override
  String get noPowerUpCards =>
      'No power-up cards! Win mini-games to collect them.';

  @override
  String get yourPowerUpCards => 'Your Power-Up Cards';

  @override
  String get noOtherPlayers => 'No other players to trade with!';

  @override
  String boughtProperty(String name, int price) {
    return 'Bought $name for \$$price!';
  }

  @override
  String paidRentTo(int amount, String name) {
    return 'Paid \$$amount rent to $name';
  }

  @override
  String paidTax(int amount, String taxName) {
    return 'Paid \$$amount $taxName';
  }

  @override
  String get goingToJail => 'Going to jail!';

  @override
  String get goToJailTitle => 'Go to Jail!';

  @override
  String get goToJailMessage =>
      'You landed on Go to Jail!\nGo directly to jail, do not pass GO.';

  @override
  String wonPrize(String prize) {
    return 'Spun the wheel and won $prize!';
  }

  @override
  String get tradeAccepted => 'Accepted the trade!';

  @override
  String get tradeRejected => 'Rejected the trade.';

  @override
  String get tradeCompleted => 'Trade completed!';

  @override
  String get tradeRejectedShort => 'Trade rejected.';

  @override
  String get spinPrizeCash50 => '\$50';

  @override
  String get spinPrizeCash50Desc => 'Win \$50!';

  @override
  String get spinPrizeCash100 => '\$100';

  @override
  String get spinPrizeCash100Desc => 'Win \$100!';

  @override
  String get spinPrizeCash200 => '\$200';

  @override
  String get spinPrizeCash200Desc => 'Win \$200!';

  @override
  String get spinPrizeFreeHouse => 'Free House';

  @override
  String get spinPrizeFreeHouseDesc => 'Build a free house on any property!';

  @override
  String get spinPrizeDoubleRent => '2x Rent';

  @override
  String get spinPrizeDoubleRentDesc => 'Next rent you collect is doubled!';

  @override
  String get spinPrizeShield => 'Shield';

  @override
  String get spinPrizeShieldDesc => 'Skip your next rent payment!';

  @override
  String get spinPrizeTeleport => 'Teleport';

  @override
  String get spinPrizeTeleportDesc => 'Move to any tile of your choice!';

  @override
  String get spinPrizeJackpot => 'JACKPOT!';

  @override
  String get spinPrizeJackpotDesc => 'Win \$500 jackpot!';

  @override
  String get luckySpinTitle => 'LUCKY SPIN!';

  @override
  String playerTurnToSpin(String name) {
    return '$name\'s turn to spin!';
  }

  @override
  String get spinInstructions => 'Tap the center to spin the wheel!';

  @override
  String get spinning => 'Spinning...';

  @override
  String youWonPrize(String name) {
    return 'You won $name!';
  }

  @override
  String get collectPrize => 'Collect Prize!';

  @override
  String get orTapToSpin => 'Or tap here to spin';

  @override
  String get goodLuck => 'Good luck!';

  @override
  String get eventMarketBoom => 'Market Boom!';

  @override
  String get eventMarketBoomDesc =>
      'All properties are worth 20% more for 3 rounds!';

  @override
  String get eventTaxHoliday => 'Tax Holiday!';

  @override
  String get eventTaxHolidayDesc => 'No taxes this round!';

  @override
  String get eventGoldRush => 'Gold Rush!';

  @override
  String get eventGoldRushDesc =>
      'Collect \$300 instead of \$200 when passing GO for 3 rounds!';

  @override
  String get eventPropertySale => 'Property Sale!';

  @override
  String get eventPropertySaleDesc =>
      'All unowned properties are 25% off for 2 rounds!';

  @override
  String get eventLuckyDay => 'Lucky Day!';

  @override
  String get eventLuckyDayDesc => 'Everyone receives \$50!';

  @override
  String get eventHousingBoom => 'Housing Boom!';

  @override
  String get eventHousingBoomDesc => 'Free upgrade on one random property!';

  @override
  String get eventRentStrike => 'Rent Strike!';

  @override
  String get eventRentStrikeDesc =>
      'All rents are reduced by 50% for 2 rounds.';

  @override
  String get eventMeteorShower => 'Meteor Shower!';

  @override
  String get eventMeteorShowerDesc => 'A random player loses \$100!';

  @override
  String get eventCommunityCleanup => 'Community Clean-up';

  @override
  String get eventCommunityCleanupDesc => 'Pay \$25 for each house you own.';

  @override
  String get eventStockDividend => 'Stock Dividend';

  @override
  String get eventStockDividendDesc =>
      'Each player receives \$10 per property owned.';

  @override
  String get eventBirthdayParty => 'Birthday Party!';

  @override
  String get eventBirthdayPartyDesc =>
      'Current player collects \$25 from each other player!';

  @override
  String get eventBankError => 'Bank Error';

  @override
  String get eventBankErrorDesc => 'A random player receives \$200!';

  @override
  String get eventMarketCrash => 'Market Crash!';

  @override
  String get eventMarketCrashDesc =>
      'Property values fluctuate wildly! Random effects for everyone!';

  @override
  String get powerUpRentReducer => 'Rent Reducer';

  @override
  String get powerUpRentReducerDesc => 'Pay only 50% rent this turn';

  @override
  String get powerUpSpeedBoost => 'Speed Boost';

  @override
  String get powerUpSpeedBoostDesc => 'Roll again after moving';

  @override
  String get powerUpPropertyScout => 'Property Scout';

  @override
  String get powerUpPropertyScoutDesc => 'See all unowned property prices';

  @override
  String get powerUpRentCollector => 'Rent Collector';

  @override
  String get powerUpRentCollectorDesc => 'Collect \$50 from each player';

  @override
  String get powerUpPriceFreeze => 'Price Freeze';

  @override
  String get powerUpPriceFreezeDesc => 'Buy next property at 75% price';

  @override
  String get powerUpTeleporter => 'Teleporter';

  @override
  String get powerUpTeleporterDesc => 'Move to any unowned property';

  @override
  String get powerUpShield => 'Shield';

  @override
  String get powerUpShieldDesc => 'Block one rent payment';

  @override
  String get powerUpDoubleDice => 'Double Dice';

  @override
  String get powerUpDoubleDiceDesc => 'Roll with 4 dice, pick best 2';

  @override
  String get powerUpMoneyMagnet => 'Money Magnet';

  @override
  String get powerUpMoneyMagnetDesc => 'Extra \$100 when passing GO (3 turns)';

  @override
  String get powerUpMonopolyMaster => 'Monopoly Master';

  @override
  String get powerUpMonopolyMasterDesc => 'Free house on all owned properties!';

  @override
  String get powerUpRarityCommon => 'Common';

  @override
  String get powerUpRarityUncommon => 'Uncommon';

  @override
  String get powerUpRarityRare => 'Rare';

  @override
  String get powerUpRarityLegendary => 'Legendary';

  @override
  String get winnerTitle => 'WINNER!';

  @override
  String get gameStats => 'Game Stats';

  @override
  String get shopTitle => 'Shop';

  @override
  String get shopSubtitle => 'Unlock themes, tokens & more!';

  @override
  String get unlocked => 'Unlocked';

  @override
  String get free => 'Free';

  @override
  String get loadingAd => 'Loading ad...';

  @override
  String adsProgress(int watched, int required) {
    return 'Progress: $watched/$required ads watched!';
  }

  @override
  String purchaseItem(String name) {
    return 'Purchase $name?';
  }

  @override
  String unlockFor(String price) {
    return 'Unlock for $price';
  }

  @override
  String buyPrice(String price) {
    return 'Buy $price';
  }

  @override
  String get unlockedExcl => 'UNLOCKED!';

  @override
  String get awesome => 'Awesome!';

  @override
  String get watchAdsToUnlock => 'Watch ads to unlock';

  @override
  String watchAdsOrPay(int count) {
    return 'Watch $count ads or pay to unlock instantly';
  }

  @override
  String watchAdsCount(int count) {
    return 'Watch $count ads to unlock';
  }

  @override
  String get purchaseToUnlock => 'Purchase to unlock';

  @override
  String get useThis => 'Use This';

  @override
  String get owned => 'Owned';

  @override
  String get familyLeaderboard => 'Family Leaderboard';

  @override
  String get rankings => 'Rankings';

  @override
  String get records => 'Records';

  @override
  String get achievements => 'Achievements';

  @override
  String get sortBy => 'Sort by: ';

  @override
  String get wins => 'Wins';

  @override
  String get winPercent => 'Win %';

  @override
  String get earnings => 'Earnings';

  @override
  String get games => 'Games';

  @override
  String get noPlayersYet => 'No players yet';

  @override
  String get playToSeeStats => 'Play some games to see stats!';

  @override
  String get mostWins => 'Most Wins';

  @override
  String get highestCash => 'Highest Cash';

  @override
  String get propertyTycoonRecord => 'Property Tycoon';

  @override
  String get longestWinStreak => 'Longest Win Streak';

  @override
  String get speedChampion => 'Speed Champion';

  @override
  String get luckiestRoller => 'Luckiest Roller';

  @override
  String inARow(int count) {
    return '$count in a row';
  }

  @override
  String turnsCount(int count) {
    return '$count turns';
  }

  @override
  String avgValue(String value) {
    return '$value avg';
  }

  @override
  String get memoryMatchTitle => 'Memory Match';

  @override
  String get pairs => 'Pairs';

  @override
  String get timeLabel => 'Time';

  @override
  String secondsShort(int seconds) {
    return '$seconds s';
  }

  @override
  String get greatJob => 'Great Job!';

  @override
  String get timeUp => 'Time\'s Up!';

  @override
  String pairsFound(int found, int total) {
    return 'Pairs Found: $found / $total';
  }

  @override
  String scoreAmount(int score) {
    return 'Score: $score';
  }

  @override
  String get quickTapAmazing => 'AMAZING!';

  @override
  String get quickTapGreat => 'Great!';

  @override
  String get quickTapGood => 'Good';

  @override
  String get quickTapTryAgain => 'Try Again';

  @override
  String get quickTapInstruction => 'Tap the coins! Avoid bombs!';

  @override
  String streakCount(int count) {
    return '$count Streak!';
  }

  @override
  String itemSelected(String name) {
    return '$name selected!';
  }

  @override
  String get deletePhotoTitle => 'Delete Photo?';

  @override
  String get deletePhotoMessage =>
      'This photo will be removed from your avatars.';

  @override
  String get delete => 'Delete';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get choosePhoto => 'Choose Photo';

  @override
  String get noPhotosYet => 'No photos yet';

  @override
  String get takeSelfieOrPick => 'Take a selfie or pick from gallery!';

  @override
  String get chooseYourAvatarFancy => '✨ Choose Your Avatar ✨';

  @override
  String get avatarCategoryAnimals => 'Animals';

  @override
  String get avatarCategoryFood => 'Food';

  @override
  String get avatarCategoryObjects => 'Objects';

  @override
  String get avatarCategoryCharacters => 'Characters';

  @override
  String get avatarCategoryMyPhotos => 'My Photos';

  @override
  String get select => 'Select';

  @override
  String get countryUSA => 'United States';

  @override
  String get countryUK => 'United Kingdom';

  @override
  String get countryFrance => 'France';

  @override
  String get countryJapan => 'Japan';

  @override
  String get countryChina => 'China';

  @override
  String get countryMexico => 'Mexico';

  @override
  String get chooseCity => 'Choose City';

  @override
  String get cityAtlanticCity => 'Atlantic City';

  @override
  String get cityNewYork => 'New York City';

  @override
  String get cityLosAngeles => 'Los Angeles';

  @override
  String get cityLondon => 'London';

  @override
  String get cityEdinburgh => 'Edinburgh';

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
  String get cityBeijing => 'Beijing';

  @override
  String get cityShanghai => 'Shanghai';

  @override
  String get cityHongKong => 'Hong Kong';

  @override
  String get cityMexicoCity => 'Mexico City';

  @override
  String get cityGuadalajara => 'Guadalajara';

  @override
  String get cityCancun => 'Cancún';
}
