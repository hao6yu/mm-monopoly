// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'M&Mプロパティタイクーン';

  @override
  String get propertyTycoon => 'プロパティタイクーン';

  @override
  String get familyEdition => 'ファミリーエディション';

  @override
  String get worldCityEdition => '世界都市エディション';

  @override
  String get chooseNextMove => '次の一手を選ぼう';

  @override
  String get newGame => '新しいゲーム';

  @override
  String get continueGame => '続ける';

  @override
  String get howToPlay => '遊び方';

  @override
  String get settings => '設定';

  @override
  String get shop => 'ショップ';

  @override
  String get howManyPlayers => 'プレイヤーは何人？';

  @override
  String get gameSetupTitle => 'ゲームを作成';

  @override
  String get gameSetupSubtitle => '都市、プレイヤー数、移動スタイルを選びます。';

  @override
  String get playerSetupSubtitle => '各プレイヤーの名前、色、キャラクターを設定します。';

  @override
  String get gameSummary => 'ゲーム概要';

  @override
  String get readyToPlay => '準備完了';

  @override
  String get playerSetup => 'プレイヤー設定';

  @override
  String get chooseBoard => 'ボードを選ぶ';

  @override
  String get numberOfPlayers => 'プレイヤー数';

  @override
  String get numberOfDice => 'サイコロの数';

  @override
  String get players => '人';

  @override
  String get oneDie => 'サイコロ1個';

  @override
  String get twoDice => 'サイコロ2個';

  @override
  String get classicStyle => 'クラシックスタイル';

  @override
  String get standardRules => '標準ルール';

  @override
  String get playersStep => 'プレイヤー';

  @override
  String get setupStep => '設定';

  @override
  String get back => '戻る';

  @override
  String get previous => '前へ';

  @override
  String get next => '次へ';

  @override
  String get startGame => 'ゲーム開始';

  @override
  String playerN(int number) {
    return 'プレイヤー$number';
  }

  @override
  String get you => 'あなた';

  @override
  String get ai => 'コンピューター';

  @override
  String get name => '名前';

  @override
  String get chooseYourAvatar => 'アバターを選ぼう';

  @override
  String get uniqueNameError => '各プレイヤーは異なる名前にしてください';

  @override
  String get allPlayersNeedName => '全プレイヤーに名前が必要です';

  @override
  String get uniqueColorError => '各プレイヤーは異なる色にしてください';

  @override
  String get tutorialRollMove => '振って進もう';

  @override
  String get tutorialRollMoveDesc => 'サイコロをタップして振ろう！\nボードの周りを進もう。';

  @override
  String get tutorialBuyProperties => '物件を購入';

  @override
  String get tutorialBuyPropertiesDesc => '空いている場所に止まった？\n買って自分のものにしよう！';

  @override
  String get tutorialCollectRent => '家賃を徴収';

  @override
  String get tutorialCollectRentDesc => '他のプレイヤーがあなたの物件に止まった？\n家賃を支払ってもらおう！';

  @override
  String get tutorialSpecialSpaces => '特別マス';

  @override
  String get tutorialSpecialSpacesDesc => 'チャンスカード、刑務所、鉄道...\nサプライズがいっぱい！';

  @override
  String get tutorialWinGame => 'ゲームに勝とう！';

  @override
  String get tutorialWinGameDesc => '最後までお金が残った人の勝ち！\n友達を破産させよう！';

  @override
  String get letsPlay => 'さあ遊ぼう！';

  @override
  String get gotIt => 'わかった！';

  @override
  String get startingCash => '初期資金';

  @override
  String get gameOptions => 'ゲームオプション';

  @override
  String get soundAndLanguage => 'サウンドと言語';

  @override
  String get settingsSubtitle => '次のゲームの前にテーブルを調整しましょう';

  @override
  String get playerTrading => 'プレイヤー間取引';

  @override
  String get bankFeatures => '銀行機能';

  @override
  String get propertyAuctions => '物件オークション';

  @override
  String get backgroundMusic => 'BGM';

  @override
  String get gameSounds => '効果音';

  @override
  String get language => '言語';

  @override
  String get buyMeACoffee => 'コーヒーをおごる';

  @override
  String get buyMeACoffeeDesc => 'ご支援はゲームの無料提供とアップデートに役立ちます。一杯のコーヒーがとても嬉しいです！';

  @override
  String get openExternalLink => '外部リンクを開く';

  @override
  String get openBuyMeACoffeeDesc => 'ブラウザでbuymeacoffee.comを開きます。';

  @override
  String get cancel => 'キャンセル';

  @override
  String get open => '開く';

  @override
  String get reset => 'リセット';

  @override
  String get backToMenu => 'メニューに戻る';

  @override
  String get settingsReset => '設定をリセットしました';

  @override
  String get propertyAvailable => 'この物件は購入可能です！';

  @override
  String get price => '価格';

  @override
  String get baseRent => '基本家賃';

  @override
  String get rent => '家賃';

  @override
  String get utilityRentDesc => 'サイコロの目の4倍または10倍';

  @override
  String get yourCash => '所持金';

  @override
  String get notEnoughCash => 'お金が足りません！';

  @override
  String get skip => 'スキップ';

  @override
  String buyForAmount(String amount) {
    return '\$$amountで購入';
  }

  @override
  String get bankruptcy => '破産！';

  @override
  String get payRent => '家賃を支払う';

  @override
  String landedOnProperty(String propertyName) {
    return '$propertyNameに止まりました';
  }

  @override
  String get ownsThisProperty => 'がこの物件を所有しています';

  @override
  String get rentDue => '家賃';

  @override
  String diceRentCalc(int diceRoll, int multiplier, int amount) {
    return 'サイコロ: $diceRoll × $multiplier = \$$amount';
  }

  @override
  String get ownerHasBothUtilities => '（オーナーは公共事業を2つ所有）';

  @override
  String get ownerHasOneUtility => '（オーナーは公共事業を1つ所有）';

  @override
  String ownerHasRailroads(int count, String suffix) {
    return 'オーナーは鉄道を$countつ所有$suffix';
  }

  @override
  String get bankruptMessage => 'お金が足りません！破産しました。';

  @override
  String get acceptBankruptcy => '破産を受け入れる';

  @override
  String payAmount(int amount) {
    return '\$$amountを支払う';
  }

  @override
  String get payTaxToBank => '銀行に税金を支払わなければなりません';

  @override
  String get taxAmount => '税額';

  @override
  String get gameMenu => 'ゲームメニュー';

  @override
  String get backToGame => 'ゲームに戻る';

  @override
  String get saveGame => 'ゲームを保存';

  @override
  String get loadGame => 'ゲームを読み込む';

  @override
  String get loadSavedGame => '保存したゲームを読み込みますか？';

  @override
  String get currentProgressLost => '現在のゲームの進行状況は失われます。';

  @override
  String get restartGame => 'ゲームをやり直す';

  @override
  String get allProgressLost => 'すべての進行状況が失われます。';

  @override
  String get quitToMenu => 'メニューに戻る';

  @override
  String get quitGame => 'ゲームを終了しますか？';

  @override
  String get confirm => '確認';

  @override
  String get inJail => '刑務所に収監中';

  @override
  String get youAreInJail => '刑務所に入っています！';

  @override
  String get bailAmount => '保釈金';

  @override
  String stayInJailTurns(int turns, String suffix) {
    return 'あと$turnsターン$suffix刑務所に残ることもできます。';
  }

  @override
  String get mustPayFine => '出るには罰金を支払わなければなりません！';

  @override
  String get stayInJail => '刑務所に残る';

  @override
  String payBail(int amount) {
    return '\$$amountを支払う';
  }

  @override
  String get buildHotel => 'ホテルを建てよう！';

  @override
  String get buildHouse => '家を建てよう！';

  @override
  String get upgradeCost => 'アップグレード費用';

  @override
  String get currentRent => '現在の家賃';

  @override
  String get newRent => '新しい家賃';

  @override
  String get increase => '増加';

  @override
  String buildForAmount(int amount) {
    return '\$$amountで建設';
  }

  @override
  String get eventGoodNews => '朗報！';

  @override
  String get eventBadNews => '悲報！';

  @override
  String get eventNewsFlash => '速報！';

  @override
  String get eventWildCard => 'ワイルドカード！';

  @override
  String eventLastsRounds(int duration, String suffix) {
    return '$durationラウンド$suffix持続';
  }

  @override
  String get auction => 'オークション';

  @override
  String propertyValue(int amount) {
    return '価値: \$$amount';
  }

  @override
  String get currentBid => '現在の入札額:';

  @override
  String get noBidsYet => 'まだ入札なし';

  @override
  String get leadingBidder => '最高入札者:';

  @override
  String get bidders => '入札者:';

  @override
  String playerTurn(String name) {
    return '$nameのターン';
  }

  @override
  String get notEnoughCashToBid => '入札するお金が足りません';

  @override
  String get pass => 'パス';

  @override
  String bidAmount(int amount) {
    return '\$$amountで入札';
  }

  @override
  String get notEnoughCashShort => 'お金が足りません';

  @override
  String playerWinsAuction(String name) {
    return '$nameが落札しました！';
  }

  @override
  String get noWinnerAuction => '落札者なし - 物件は銀行に戻ります';

  @override
  String finalBid(int amount) {
    return '最終入札額: \$$amount';
  }

  @override
  String get proposeTrade => '取引を提案する';

  @override
  String get tradeWith => '取引相手:';

  @override
  String youOffer(String name) {
    return 'あなたの提供品 ($name)';
  }

  @override
  String get cash => '現金';

  @override
  String get cashLabel => '現金:';

  @override
  String get properties => '物件';

  @override
  String get propertiesLabel => '物件:';

  @override
  String get noPropertiesToOffer => '提供できる物件がありません';

  @override
  String youRequest(String name) {
    return '要求する品 ($nameから)';
  }

  @override
  String get noPropertiesAvailable => '利用可能な物件がありません';

  @override
  String get proposeTradeBtn => '取引を提案';

  @override
  String wantsToTrade(String name) {
    return '$nameが取引を希望しています！';
  }

  @override
  String get youReceive => '受け取るもの:';

  @override
  String get youGive => '渡すもの:';

  @override
  String get nothing => 'なし';

  @override
  String get reject => '拒否';

  @override
  String get accept => '承認';

  @override
  String get propertyManagement => '物件管理';

  @override
  String get mortgage => '抵当に入れる';

  @override
  String get unmortgage => '抵当を解除する';

  @override
  String mortgageCount(int count) {
    return '抵当に入れる ($count)';
  }

  @override
  String unmortgageCount(int count) {
    return '抵当を解除する ($count)';
  }

  @override
  String get noMortgageableProperties =>
      '抵当に入れられる物件がありません。\n家がある物件は先に家を売却してください。';

  @override
  String get noMortgagedProperties => '抵当に入っている物件はありません。';

  @override
  String receiveAmount(int amount) {
    return '受取額: \$$amount';
  }

  @override
  String costAmount(int amount) {
    return '費用: \$$amount';
  }

  @override
  String get pay => '支払う';

  @override
  String get close => '閉じる';

  @override
  String get propertyLocation => '物件の場所';

  @override
  String get startingPoint => 'スタート地点';

  @override
  String get justVisiting => '面会 / 刑務所';

  @override
  String get spinToWin => '回して当てよう！';

  @override
  String get goToJailLabel => '刑務所行き';

  @override
  String get chanceCard => 'チャンス';

  @override
  String get communityChestCard => '共同基金';

  @override
  String get incomeTax => '所得税';

  @override
  String get luxuryTax => '贅沢税';

  @override
  String get didYouKnow => '知ってた？';

  @override
  String get ownAllPropertiesTip => '同じ色グループの物件をすべて所有すると家賃が2倍に！';

  @override
  String get buildHousesEvenlyTip => '物件に均等に家を建てると利益が最大になります。';

  @override
  String hotelsMaxRentTip(int amount) {
    return 'ホテルは最高の家賃を生み出します - 最大\$$amount！';
  }

  @override
  String get railroad1Tip => '鉄道1つ所有: 家賃\$25';

  @override
  String get railroad2Tip => '鉄道2つ所有: 家賃\$50';

  @override
  String get railroad3Tip => '鉄道3つ所有: 家賃\$100';

  @override
  String get railroad4Tip => '鉄道4つ全部所有: 家賃\$200！';

  @override
  String get utility1Tip => '公共事業1つ所有: 家賃 = サイコロの目×4';

  @override
  String get utility2Tip => '公共事業2つ所有: 家賃 = サイコロの目×10！';

  @override
  String get utilitiesProfitableTip => '公共事業はサイコロの目が大きいととても儲かります。';

  @override
  String get chanceHowToPlay => '遊び方';

  @override
  String get chestHowToPlay => '遊び方';

  @override
  String get drawTopCard => 'チャンスの山札から一番上のカードを引く';

  @override
  String get readCardAloud => 'カードを声に出して読む';

  @override
  String get doWhatCardSays => 'カードの指示に従おう！';

  @override
  String get putCardBottom => 'カードを山札の一番下に戻す';

  @override
  String get jailRules => '刑務所ルール';

  @override
  String get goToJailRules => '刑務所行きルール';

  @override
  String get taxRules => '税金ルール';

  @override
  String get drawTopChestCard => '共同基金カードの山札の一番上を引く';

  @override
  String get readToEveryone => '全員に聞こえるように読み上げる';

  @override
  String get followInstructions => 'カードの指示に従う';

  @override
  String get returnCardBottom => 'カードを山札の一番下に戻す';

  @override
  String get justVisitingSafe => '「見学中」なら安全です！';

  @override
  String get inJailYouCan => '刑務所にいる場合は次のことができます:';

  @override
  String get pay50GetOut => '  • \\\$50払って出る';

  @override
  String get rollDoublesThreeTries => '  • ゾロ目を狙う（3回まで）';

  @override
  String get useGetOutCard => '  • 「刑務所から出る」カードを使う';

  @override
  String get goDirectlyToJail => '刑務所へ直行！';

  @override
  String get doNotPassGo => 'GOを通過しない';

  @override
  String get doNotCollect200 => '\\\$200を受け取らない';

  @override
  String get turnEndsImmediately => 'あなたのターンは即終了します';

  @override
  String get mustPayTaxRule => 'この税金は必ず支払う必要があります！';

  @override
  String get payBankAmountShown => '表示された金額を銀行に支払う';

  @override
  String get cantPayMightGoBankrupt => '支払えない場合は破産する可能性があります！';

  @override
  String get collectGoBonus => 'GOに止まるか通過するとお金を受け取れます。';

  @override
  String get passGoEarn => 'GOを通過すると資金繰りが安定します。';

  @override
  String get startTileFunFact => 'GOはモノポリーで最もよく止まるマスです。';

  @override
  String get jailFactOne => 'ここに止まると投獄か見学中のどちらかになります。';

  @override
  String get jailFactTwo => '保釈金を払うか、ゾロ目を狙えます。';

  @override
  String get jailFunFact => '刑務所はゲーム内でも特に戦略性の高いマスです。';

  @override
  String get freeParkingFactOne => 'ルーレットを回して現金、パワーアップ、特別賞品を獲得しよう！';

  @override
  String get freeParkingFactTwo => '毎回必ず報酬がもらえます — ハズレなし！';

  @override
  String get freeParkingFunFact => 'ラッキースピンは一瞬で運命が変わる場所です。';

  @override
  String get goToJailFactOne => 'このマスに止まると駒は刑務所へ直行します。';

  @override
  String get goToJailFactTwo => 'この移動ではGO通過ボーナスはもらえません。';

  @override
  String get goToJailFunFact => '勢いを維持するためにこのマスは避けましょう。';

  @override
  String get chanceFunFact => 'チャンスカードは毎試合に驚きを加えます。';

  @override
  String get communityChestFactOne => 'コミュニティは助け合います！';

  @override
  String get communityChestFactTwo => 'これらのカードはお金がもらえることが多いです。';

  @override
  String get communityChestFactThree => '銀行の手違いで得をすることもあります！';

  @override
  String get communityChestFunFact => '共同基金カードは比較的やさしい内容が多いです。';

  @override
  String get taxFactOne => '税金は誰でも支払う必要があります！';

  @override
  String get taxFactTwo => '税金は公共サービスを支えます。';

  @override
  String get taxFunFact => '税金マスはゲームの流れを一気に変えることがあります。';

  @override
  String aiBuiltOn(String level, String property) {
    return '$propertyに$levelを建設しました！';
  }

  @override
  String get chance => 'チャンス';

  @override
  String get communityChest => '共同基金';

  @override
  String get chanceExcl => 'チャンス！';

  @override
  String get communityChestExcl => '共同基金！';

  @override
  String get tapCardToPick => 'カードをタップして引こう！';

  @override
  String get revealingCard => 'カードを公開中...';

  @override
  String get tapToContinue => 'どこかをタップして続ける';

  @override
  String get chestShort => '基金';

  @override
  String get ok => '確認';

  @override
  String get freeHouseTitle => '無料の家！';

  @override
  String get choosePropertyToBuild => '建設する物件を選んでください';

  @override
  String get noUpgradeableProperties => 'アップグレード可能な物件がありません！';

  @override
  String get buyPropertiesComeBack => '物件を購入してからまた来てください。';

  @override
  String houseN(int level) {
    return '家 $level';
  }

  @override
  String get hotel => 'ホテル';

  @override
  String nextUpgrade(String text) {
    return '次: $text';
  }

  @override
  String get saveForLater => '後で使う';

  @override
  String get build => '建設！';

  @override
  String get teleportTitle => 'テレポート！';

  @override
  String get chooseTileToTeleport => 'テレポート先のマスを選んでください';

  @override
  String get all => 'すべて';

  @override
  String get railroads => '鉄道';

  @override
  String get utilities => '公共事業';

  @override
  String get special => '特別';

  @override
  String get noTilesMatch => '該当するマスがありません';

  @override
  String get teleportBtn => 'テレポート！';

  @override
  String get gameOver => 'ゲームオーバー！';

  @override
  String get winner => '勝者';

  @override
  String get finalStandings => '最終順位';

  @override
  String rankN(int rank) {
    return '$rank位';
  }

  @override
  String get bankrupt => '破産';

  @override
  String get rounds => 'ラウンド';

  @override
  String get finalCash => '最終所持金';

  @override
  String get turns => 'ターン数';

  @override
  String get mainMenu => 'メインメニュー';

  @override
  String get playAgain => 'もう一度遊ぶ';

  @override
  String playerPortfolio(String name) {
    return '$nameのポートフォリオ';
  }

  @override
  String netWorth(int amount) {
    return '純資産: \$$amount';
  }

  @override
  String get position => '位置';

  @override
  String get noPropertiesYet => 'まだ物件がありません';

  @override
  String get startBuyingProperties => '物件を購入して帝国を築こう！';

  @override
  String rentAmount(int amount) {
    return '家賃: \$$amount';
  }

  @override
  String get mortgaged => '抵当中';

  @override
  String get mortgagedLabel => '抵当中';

  @override
  String get railroad => '鉄道';

  @override
  String get utility => '公共事業';

  @override
  String get colorBrown => '茶色';

  @override
  String get colorLightBlue => '水色';

  @override
  String get colorPink => 'ピンク';

  @override
  String get colorOrange => 'オレンジ';

  @override
  String get colorRed => '赤';

  @override
  String get colorYellow => '黄色';

  @override
  String get colorGreen => '緑';

  @override
  String get colorDarkBlue => '紺色';

  @override
  String get noneYet => 'まだなし';

  @override
  String get noProperties => '物件なし';

  @override
  String get yourTurn => 'あなたの番';

  @override
  String tileN(int position) {
    return 'マス $position';
  }

  @override
  String get rolling => '振っています...';

  @override
  String get moving => '移動中...';

  @override
  String get rollDice => 'サイコロを振る';

  @override
  String get tap => 'タップ';

  @override
  String get spin => '回す';

  @override
  String get trade => '取引';

  @override
  String get bank => '銀行';

  @override
  String get use => '使う';

  @override
  String get gameSaved => 'ゲームを保存しました！';

  @override
  String get failedToSave => 'ゲームの保存に失敗しました';

  @override
  String gameLoaded(int round) {
    return 'ゲームを読み込みました！ ラウンド$round';
  }

  @override
  String get failedToLoad => 'ゲームの読み込みに失敗しました';

  @override
  String get noPowerUpCards => 'パワーアップカードがありません！ミニゲームに勝って集めよう。';

  @override
  String get yourPowerUpCards => 'あなたのパワーアップカード';

  @override
  String get noOtherPlayers => '取引できる他のプレイヤーがいません！';

  @override
  String boughtProperty(String name, int price) {
    return '$nameを\$$priceで購入しました！';
  }

  @override
  String paidRentTo(int amount, String name) {
    return '$nameに家賃\$$amountを支払いました';
  }

  @override
  String paidTax(int amount, String taxName) {
    return '\$$amountの$taxNameを支払いました';
  }

  @override
  String get goingToJail => '刑務所行きです！';

  @override
  String get goToJailTitle => '刑務所行き！';

  @override
  String get goToJailMessage => '刑務所行きのマスに止まりました！\nGOを通らず直接刑務所へ行きます。';

  @override
  String wonPrize(String prize) {
    return 'ルーレットを回して$prizeを獲得しました！';
  }

  @override
  String get tradeAccepted => '取引を承認しました！';

  @override
  String get tradeRejected => '取引を拒否しました。';

  @override
  String get tradeCompleted => '取引が完了しました！';

  @override
  String get tradeRejectedShort => '取引拒否。';

  @override
  String get spinPrizeCash50 => '50ドル';

  @override
  String get spinPrizeCash50Desc => '\$50を獲得！';

  @override
  String get spinPrizeCash100 => '100ドル';

  @override
  String get spinPrizeCash100Desc => '\$100を獲得！';

  @override
  String get spinPrizeCash200 => '200ドル';

  @override
  String get spinPrizeCash200Desc => '\$200を獲得！';

  @override
  String get spinPrizeFreeHouse => '無料の家';

  @override
  String get spinPrizeFreeHouseDesc => '好きな物件に無料で家を建てよう！';

  @override
  String get spinPrizeDoubleRent => '家賃2倍';

  @override
  String get spinPrizeDoubleRentDesc => '次に徴収する家賃が2倍に！';

  @override
  String get spinPrizeShield => 'シールド';

  @override
  String get spinPrizeShieldDesc => '次の家賃の支払いを免除！';

  @override
  String get spinPrizeTeleport => 'テレポート';

  @override
  String get spinPrizeTeleportDesc => '好きなマスに移動できます！';

  @override
  String get spinPrizeJackpot => 'ジャックポット！';

  @override
  String get spinPrizeJackpotDesc => '\$500のジャックポットを獲得！';

  @override
  String get luckySpinTitle => 'ラッキースピン！';

  @override
  String playerTurnToSpin(String name) {
    return '$nameのスピンの番です！';
  }

  @override
  String get spinInstructions => '中央をタップしてルーレットを回そう！';

  @override
  String get spinning => '回転中...';

  @override
  String youWonPrize(String name) {
    return '$nameを獲得しました！';
  }

  @override
  String get collectPrize => '賞品を受け取る！';

  @override
  String get orTapToSpin => 'ここをタップして回す';

  @override
  String get goodLuck => '幸運を祈ります！';

  @override
  String get eventMarketBoom => '市場好況！';

  @override
  String get eventMarketBoomDesc => 'すべての物件の価値が3ラウンド間20%アップ！';

  @override
  String get eventTaxHoliday => '免税期間！';

  @override
  String get eventTaxHolidayDesc => 'このラウンドは税金なし！';

  @override
  String get eventGoldRush => 'ゴールドラッシュ！';

  @override
  String get eventGoldRushDesc => '3ラウンド間、GO通過時に\$200ではなく\$300を受け取れます！';

  @override
  String get eventPropertySale => '物件セール！';

  @override
  String get eventPropertySaleDesc => '2ラウンド間、未所有の物件がすべて25%オフ！';

  @override
  String get eventLuckyDay => 'ラッキーデー！';

  @override
  String get eventLuckyDayDesc => '全員に\$50を支給！';

  @override
  String get eventHousingBoom => '住宅ブーム！';

  @override
  String get eventHousingBoomDesc => 'ランダムな物件1つを無料アップグレード！';

  @override
  String get eventRentStrike => '家賃ストライキ！';

  @override
  String get eventRentStrikeDesc => '2ラウンド間、すべての家賃が50%減少。';

  @override
  String get eventMeteorShower => '流星群！';

  @override
  String get eventMeteorShowerDesc => 'ランダムなプレイヤーが\$100を失います！';

  @override
  String get eventCommunityCleanup => '地域清掃活動';

  @override
  String get eventCommunityCleanupDesc => '所有する家1軒につき\$25を支払う。';

  @override
  String get eventStockDividend => '株式配当';

  @override
  String get eventStockDividendDesc => '各プレイヤーは所有物件1つにつき\$10を受け取ります。';

  @override
  String get eventBirthdayParty => '誕生日パーティー！';

  @override
  String get eventBirthdayPartyDesc => '現在のプレイヤーが他の各プレイヤーから\$25を受け取ります！';

  @override
  String get eventBankError => '銀行のミス';

  @override
  String get eventBankErrorDesc => 'ランダムなプレイヤーが\$200を受け取ります！';

  @override
  String get eventMarketCrash => '市場暴落！';

  @override
  String get eventMarketCrashDesc => '物件の価値が乱高下！全員にランダムな影響！';

  @override
  String get powerUpRentReducer => '家賃割引';

  @override
  String get powerUpRentReducerDesc => 'このターンの家賃が50%だけ';

  @override
  String get powerUpSpeedBoost => 'スピードブースト';

  @override
  String get powerUpSpeedBoostDesc => '移動後にもう一度振れる';

  @override
  String get powerUpPropertyScout => '物件スカウト';

  @override
  String get powerUpPropertyScoutDesc => '未所有の物件の価格をすべて確認';

  @override
  String get powerUpRentCollector => '家賃徴収人';

  @override
  String get powerUpRentCollectorDesc => '各プレイヤーから\$50を徴収';

  @override
  String get powerUpPriceFreeze => '価格凍結';

  @override
  String get powerUpPriceFreezeDesc => '次の物件を75%の価格で購入';

  @override
  String get powerUpTeleporter => 'テレポーター';

  @override
  String get powerUpTeleporterDesc => '未所有の物件に移動';

  @override
  String get powerUpShield => 'シールド';

  @override
  String get powerUpShieldDesc => '家賃の支払いを1回ブロック';

  @override
  String get powerUpDoubleDice => 'ダブルダイス';

  @override
  String get powerUpDoubleDiceDesc => 'サイコロ4個で振り、良い2個を選択';

  @override
  String get powerUpMoneyMagnet => 'マネーマグネット';

  @override
  String get powerUpMoneyMagnetDesc => 'GO通過時に\$100追加（3ターン）';

  @override
  String get powerUpMonopolyMaster => 'モノポリーマスター';

  @override
  String get powerUpMonopolyMasterDesc => '所有するすべての物件に無料で家を建設！';

  @override
  String get powerUpRarityCommon => 'コモン';

  @override
  String get powerUpRarityUncommon => 'アンコモン';

  @override
  String get powerUpRarityRare => 'レア';

  @override
  String get powerUpRarityLegendary => 'レジェンダリー';

  @override
  String get winnerTitle => '勝者！';

  @override
  String get gameStats => 'ゲーム統計';

  @override
  String get shopTitle => 'ショップ';

  @override
  String get shopSubtitle => 'テーマ、トークンなどをアンロック！';

  @override
  String get unlocked => 'アンロック済み';

  @override
  String get free => '無料';

  @override
  String get loadingAd => '広告を読み込み中...';

  @override
  String adsProgress(int watched, int required) {
    return '進捗: $watched/$required本の広告を視聴済み！';
  }

  @override
  String purchaseItem(String name) {
    return '$nameを購入しますか？';
  }

  @override
  String unlockFor(String price) {
    return '$priceでアンロック';
  }

  @override
  String buyPrice(String price) {
    return '$priceで購入';
  }

  @override
  String get unlockedExcl => 'アンロック！';

  @override
  String get awesome => 'すごい！';

  @override
  String get watchAdsToUnlock => '広告を見てアンロック';

  @override
  String watchAdsOrPay(int count) {
    return '広告を$count本見るか、課金して即アンロック';
  }

  @override
  String watchAdsCount(int count) {
    return '広告を$count本見てアンロック';
  }

  @override
  String get purchaseToUnlock => '購入してアンロック';

  @override
  String get useThis => 'これを使う';

  @override
  String get owned => '所有済み';

  @override
  String get familyLeaderboard => 'ファミリーリーダーボード';

  @override
  String get rankings => 'ランキング';

  @override
  String get records => '記録';

  @override
  String get achievements => '実績';

  @override
  String get sortBy => '並び替え: ';

  @override
  String get wins => '勝利数';

  @override
  String get winPercent => '勝率';

  @override
  String get earnings => '収益';

  @override
  String get games => 'ゲーム数';

  @override
  String get noPlayersYet => 'プレイヤーがまだいません';

  @override
  String get playToSeeStats => 'ゲームをプレイして統計を見よう！';

  @override
  String get mostWins => '最多勝利';

  @override
  String get highestCash => '最高所持金';

  @override
  String get propertyTycoonRecord => '不動産王';

  @override
  String get longestWinStreak => '最長連勝記録';

  @override
  String get speedChampion => 'スピードチャンピオン';

  @override
  String get luckiestRoller => '最もツイてる人';

  @override
  String inARow(int count) {
    return '$count 連続';
  }

  @override
  String turnsCount(int count) {
    return '$count ターン';
  }

  @override
  String avgValue(String value) {
    return '平均 $value';
  }

  @override
  String get memoryMatchTitle => '神経衰弱';

  @override
  String get pairs => 'ペア';

  @override
  String get timeLabel => '時間';

  @override
  String secondsShort(int seconds) {
    return '$seconds秒';
  }

  @override
  String get greatJob => 'よくできました！';

  @override
  String get timeUp => '時間切れ！';

  @override
  String pairsFound(int found, int total) {
    return '見つけたペア: $found / $total';
  }

  @override
  String scoreAmount(int score) {
    return 'スコア: $score';
  }

  @override
  String get quickTapAmazing => 'すばらしい！';

  @override
  String get quickTapGreat => '最高！';

  @override
  String get quickTapGood => 'いいね';

  @override
  String get quickTapTryAgain => 'もう一度';

  @override
  String get quickTapInstruction => 'コインをタップ！爆弾は避けよう！';

  @override
  String streakCount(int count) {
    return '$count 連続！';
  }

  @override
  String itemSelected(String name) {
    return '$name を選択しました！';
  }

  @override
  String get deletePhotoTitle => '写真を削除しますか？';

  @override
  String get deletePhotoMessage => 'この写真はアバター一覧から削除されます。';

  @override
  String get delete => '削除';

  @override
  String get takePhoto => '写真を撮る';

  @override
  String get choosePhoto => '写真を選ぶ';

  @override
  String get noPhotosYet => 'まだ写真がありません';

  @override
  String get takeSelfieOrPick => '自撮りするかギャラリーから選ぼう！';

  @override
  String get chooseYourAvatarFancy => '✨ アバターを選ぼう ✨';

  @override
  String get avatarCategoryAnimals => '動物';

  @override
  String get avatarCategoryFood => '食べ物';

  @override
  String get avatarCategoryObjects => 'アイテム';

  @override
  String get avatarCategoryCharacters => 'キャラクター';

  @override
  String get avatarCategoryMyPhotos => 'マイ写真';

  @override
  String get select => '選択';

  @override
  String get countryUSA => 'アメリカ合衆国';

  @override
  String get countryUK => 'イギリス';

  @override
  String get countryFrance => 'フランス';

  @override
  String get countryJapan => '日本';

  @override
  String get countryChina => '中国';

  @override
  String get countryMexico => 'メキシコ';

  @override
  String get chooseCity => '都市を選ぶ';

  @override
  String get cityAtlanticCity => 'アトランティックシティ';

  @override
  String get cityNewYork => 'ニューヨーク';

  @override
  String get cityLosAngeles => 'ロサンゼルス';

  @override
  String get cityLondon => 'ロンドン';

  @override
  String get cityEdinburgh => 'エディンバラ';

  @override
  String get cityManchester => 'マンチェスター';

  @override
  String get cityParis => 'パリ';

  @override
  String get cityLyon => 'リヨン';

  @override
  String get cityMarseille => 'マルセイユ';

  @override
  String get cityTokyo => '東京';

  @override
  String get cityOsaka => '大阪';

  @override
  String get cityKyoto => '京都';

  @override
  String get cityBeijing => '北京';

  @override
  String get cityShanghai => '上海';

  @override
  String get cityHongKong => '香港';

  @override
  String get cityMexicoCity => 'メキシコシティ';

  @override
  String get cityGuadalajara => 'グアダラハラ';

  @override
  String get cityCancun => 'カンクン';
}
