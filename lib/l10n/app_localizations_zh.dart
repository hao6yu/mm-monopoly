// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'M&M 地产大亨';

  @override
  String get propertyTycoon => '地产大亨';

  @override
  String get familyEdition => '家庭版';

  @override
  String get worldCityEdition => '世界城市版';

  @override
  String get chooseNextMove => '选择你的下一步';

  @override
  String get newGame => '新游戏';

  @override
  String get continueGame => '继续';

  @override
  String get howToPlay => '游戏规则';

  @override
  String get settings => '设置';

  @override
  String get shop => '商店';

  @override
  String get howManyPlayers => '几位玩家？';

  @override
  String get gameSetupTitle => '创建你的游戏';

  @override
  String get gameSetupSubtitle => '选择城市、玩家人数和移动方式。';

  @override
  String get playerSetupSubtitle => '为每位玩家设置名字、颜色和角色。';

  @override
  String get gameSummary => '游戏概要';

  @override
  String get readyToPlay => '准备开始';

  @override
  String get playerSetup => '玩家设置';

  @override
  String get chooseBoard => '选择棋盘';

  @override
  String get numberOfPlayers => '玩家人数';

  @override
  String get numberOfDice => '骰子数量';

  @override
  String get players => '位玩家';

  @override
  String get oneDie => '一颗骰子';

  @override
  String get twoDice => '两颗骰子';

  @override
  String get classicStyle => '经典模式';

  @override
  String get standardRules => '标准规则';

  @override
  String get playersStep => '玩家';

  @override
  String get setupStep => '设置';

  @override
  String get back => '返回';

  @override
  String get previous => '上一步';

  @override
  String get next => '下一步';

  @override
  String get startGame => '开始游戏';

  @override
  String playerN(int number) {
    return '玩家 $number';
  }

  @override
  String get you => '你';

  @override
  String get ai => '电脑';

  @override
  String get name => '名字';

  @override
  String get chooseYourAvatar => '选择你的头像';

  @override
  String get uniqueNameError => '每位玩家必须有不同的名字';

  @override
  String get allPlayersNeedName => '所有玩家都必须有名字';

  @override
  String get uniqueColorError => '每位玩家必须选择不同的颜色';

  @override
  String get tutorialRollMove => '掷骰前进';

  @override
  String get tutorialRollMoveDesc => '点击骰子来掷骰！\n在棋盘上移动。';

  @override
  String get tutorialBuyProperties => '购买地产';

  @override
  String get tutorialBuyPropertiesDesc => '停在空地上？\n买下来，拥有它！';

  @override
  String get tutorialCollectRent => '收取租金';

  @override
  String get tutorialCollectRentDesc => '别人停在你的地产上？\n他们要付给你租金！';

  @override
  String get tutorialSpecialSpaces => '特殊格子';

  @override
  String get tutorialSpecialSpacesDesc => '机会卡、监狱、火车站……\n到处都是惊喜！';

  @override
  String get tutorialWinGame => '赢得游戏！';

  @override
  String get tutorialWinGameDesc => '最后有钱的玩家获胜！\n让你的朋友们破产吧！';

  @override
  String get letsPlay => '开始游戏！';

  @override
  String get gotIt => '知道了！';

  @override
  String get startingCash => '初始资金';

  @override
  String get gameOptions => '游戏选项';

  @override
  String get soundAndLanguage => '声音与语言';

  @override
  String get settingsSubtitle => '在下一场游戏前调整你的桌面';

  @override
  String get playerTrading => '玩家交易';

  @override
  String get bankFeatures => '银行功能';

  @override
  String get propertyAuctions => '地产拍卖';

  @override
  String get backgroundMusic => '背景音乐';

  @override
  String get gameSounds => '游戏音效';

  @override
  String get language => '语言';

  @override
  String get buyMeACoffee => '请我喝杯咖啡';

  @override
  String get buyMeACoffeeDesc => '你的支持帮助游戏保持免费和持续更新。每一杯咖啡都意义非凡！';

  @override
  String get openExternalLink => '打开外部链接';

  @override
  String get openBuyMeACoffeeDesc => '这将在浏览器中打开 buymeacoffee.com。';

  @override
  String get cancel => '取消';

  @override
  String get open => '打开';

  @override
  String get reset => '重置';

  @override
  String get backToMenu => '返回菜单';

  @override
  String get settingsReset => '设置已重置';

  @override
  String get propertyAvailable => '这块地产可以购买！';

  @override
  String get price => '价格';

  @override
  String get baseRent => '基础租金';

  @override
  String get rent => '租金';

  @override
  String get utilityRentDesc => '骰子点数的4倍或10倍';

  @override
  String get yourCash => '你的现金';

  @override
  String get notEnoughCash => '现金不足！';

  @override
  String get skip => '跳过';

  @override
  String buyForAmount(String amount) {
    return '购买 \$$amount';
  }

  @override
  String get bankruptcy => '破产！';

  @override
  String get payRent => '支付租金';

  @override
  String landedOnProperty(String propertyName) {
    return '你停在了 $propertyName';
  }

  @override
  String get ownsThisProperty => '拥有这块地产';

  @override
  String get rentDue => '应付租金';

  @override
  String diceRentCalc(int diceRoll, int multiplier, int amount) {
    return '骰子：$diceRoll × $multiplier = \$$amount';
  }

  @override
  String get ownerHasBothUtilities => '（房主拥有两项公用事业）';

  @override
  String get ownerHasOneUtility => '（房主拥有1项公用事业）';

  @override
  String ownerHasRailroads(int count, String suffix) {
    return '房主拥有 $count 条铁路$suffix';
  }

  @override
  String get bankruptMessage => '你的现金不够了！你破产了。';

  @override
  String get acceptBankruptcy => '接受破产';

  @override
  String payAmount(int amount) {
    return '支付 \$$amount';
  }

  @override
  String get payTaxToBank => '你必须向银行缴税';

  @override
  String get taxAmount => '税额';

  @override
  String get gameMenu => '游戏菜单';

  @override
  String get backToGame => '返回游戏';

  @override
  String get saveGame => '保存游戏';

  @override
  String get loadGame => '读取游戏';

  @override
  String get loadSavedGame => '读取存档？';

  @override
  String get currentProgressLost => '当前游戏进度将会丢失。';

  @override
  String get restartGame => '重新开始';

  @override
  String get allProgressLost => '所有进度将会丢失。';

  @override
  String get quitToMenu => '退出到菜单';

  @override
  String get quitGame => '退出游戏？';

  @override
  String get confirm => '确认';

  @override
  String get inJail => '在监狱中';

  @override
  String get youAreInJail => '你被关进了监狱！';

  @override
  String get bailAmount => '保释金';

  @override
  String stayInJailTurns(int turns, String suffix) {
    return '或者继续待在监狱 $turns 回合$suffix。';
  }

  @override
  String get mustPayFine => '你必须缴纳罚款才能出狱！';

  @override
  String get stayInJail => '待在监狱';

  @override
  String payBail(int amount) {
    return '缴纳 \$$amount';
  }

  @override
  String get buildHotel => '建造酒店！';

  @override
  String get buildHouse => '建造房屋！';

  @override
  String get upgradeCost => '升级费用';

  @override
  String get currentRent => '当前租金';

  @override
  String get newRent => '新租金';

  @override
  String get increase => '涨幅';

  @override
  String buildForAmount(int amount) {
    return '建造 \$$amount';
  }

  @override
  String get eventGoodNews => '好消息！';

  @override
  String get eventBadNews => '坏消息！';

  @override
  String get eventNewsFlash => '最新快讯！';

  @override
  String get eventWildCard => '百搭卡！';

  @override
  String eventLastsRounds(int duration, String suffix) {
    return '持续 $duration 回合$suffix';
  }

  @override
  String get auction => '拍卖';

  @override
  String propertyValue(int amount) {
    return '价值：\$$amount';
  }

  @override
  String get currentBid => '当前出价：';

  @override
  String get noBidsYet => '暂无出价';

  @override
  String get leadingBidder => '最高出价者：';

  @override
  String get bidders => '竞拍者：';

  @override
  String playerTurn(String name) {
    return '$name 的回合';
  }

  @override
  String get notEnoughCashToBid => '现金不足，无法出价';

  @override
  String get pass => '跳过';

  @override
  String bidAmount(int amount) {
    return '出价 \$$amount';
  }

  @override
  String get notEnoughCashShort => '现金不足';

  @override
  String playerWinsAuction(String name) {
    return '$name 赢得了拍卖！';
  }

  @override
  String get noWinnerAuction => '无人中标——地产归还银行';

  @override
  String finalBid(int amount) {
    return '最终出价：\$$amount';
  }

  @override
  String get proposeTrade => '发起交易';

  @override
  String get tradeWith => '交易对象：';

  @override
  String youOffer(String name) {
    return '你的报价（$name）';
  }

  @override
  String get cash => '现金';

  @override
  String get cashLabel => '现金：';

  @override
  String get properties => '地产';

  @override
  String get propertiesLabel => '地产：';

  @override
  String get noPropertiesToOffer => '没有可交易的地产';

  @override
  String youRequest(String name) {
    return '你的请求（来自 $name）';
  }

  @override
  String get noPropertiesAvailable => '没有可用的地产';

  @override
  String get proposeTradeBtn => '发起交易';

  @override
  String wantsToTrade(String name) {
    return '$name 想和你交易！';
  }

  @override
  String get youReceive => '你将获得：';

  @override
  String get youGive => '你将给出：';

  @override
  String get nothing => '无';

  @override
  String get reject => '拒绝';

  @override
  String get accept => '接受';

  @override
  String get propertyManagement => '地产管理';

  @override
  String get mortgage => '抵押';

  @override
  String get unmortgage => '赎回';

  @override
  String mortgageCount(int count) {
    return '抵押（$count）';
  }

  @override
  String unmortgageCount(int count) {
    return '赎回（$count）';
  }

  @override
  String get noMortgageableProperties => '没有可抵押的地产。\n有房屋的地产需要先卖掉房屋。';

  @override
  String get noMortgagedProperties => '没有已抵押的地产。';

  @override
  String receiveAmount(int amount) {
    return '获得：\$$amount';
  }

  @override
  String costAmount(int amount) {
    return '费用：\$$amount';
  }

  @override
  String get pay => '支付';

  @override
  String get close => '关闭';

  @override
  String get propertyLocation => '地产位置';

  @override
  String get startingPoint => '起点';

  @override
  String get justVisiting => '路过探望 / 在监狱中';

  @override
  String get spinToWin => '转盘赢大奖！';

  @override
  String get goToJailLabel => '进入监狱';

  @override
  String get chanceCard => '机会';

  @override
  String get communityChestCard => '公益金';

  @override
  String get incomeTax => '所得税';

  @override
  String get luxuryTax => '奢侈税';

  @override
  String get didYouKnow => '你知道吗？';

  @override
  String get ownAllPropertiesTip => '拥有同一颜色组的所有地产可以收取双倍租金！';

  @override
  String get buildHousesEvenlyTip => '在你的地产上均匀建造房屋，利润最大化。';

  @override
  String hotelsMaxRentTip(int amount) {
    return '酒店能收取最高租金——高达 \$$amount！';
  }

  @override
  String get railroad1Tip => '拥有1条铁路：租金 \$25';

  @override
  String get railroad2Tip => '拥有2条铁路：租金 \$50';

  @override
  String get railroad3Tip => '拥有3条铁路：租金 \$100';

  @override
  String get railroad4Tip => '拥有全部4条铁路：租金 \$200！';

  @override
  String get utility1Tip => '拥有1项公用事业：租金 = 骰子点数 × 4';

  @override
  String get utility2Tip => '拥有2项公用事业：租金 = 骰子点数 × 10！';

  @override
  String get utilitiesProfitableTip => '骰子点数高的时候，公用事业非常赚钱哦。';

  @override
  String get chanceHowToPlay => '玩法说明';

  @override
  String get chestHowToPlay => '玩法说明';

  @override
  String get drawTopCard => '从机会卡牌堆顶部抽一张卡';

  @override
  String get readCardAloud => '大声读出卡片内容';

  @override
  String get doWhatCardSays => '按照卡片上说的做！';

  @override
  String get putCardBottom => '把卡片放到牌堆底部';

  @override
  String get jailRules => '监狱规则';

  @override
  String get goToJailRules => '入狱规则';

  @override
  String get taxRules => '税收规则';

  @override
  String get drawTopChestCard => '从宝箱牌堆顶部抽一张牌';

  @override
  String get readToEveryone => '大声读给所有人听';

  @override
  String get followInstructions => '按照卡牌上的说明执行';

  @override
  String get returnCardBottom => '把卡牌放回牌堆底部';

  @override
  String get justVisitingSafe => '如果你只是“路过探望”，就是安全的！';

  @override
  String get inJailYouCan => '如果你在监狱中，你可以：';

  @override
  String get pay50GetOut => '  • 支付 \$50 离开监狱';

  @override
  String get rollDoublesThreeTries => '  • 尝试掷出双骰（3 次机会）';

  @override
  String get useGetOutCard => '  • 使用“免费出狱卡”';

  @override
  String get goDirectlyToJail => '直接进入监狱！';

  @override
  String get doNotPassGo => '不要经过起点';

  @override
  String get doNotCollect200 => '不要领取 \$200';

  @override
  String get turnEndsImmediately => '你的回合立即结束';

  @override
  String get mustPayTaxRule => '你必须支付这笔税款！';

  @override
  String get payBankAmountShown => '向银行支付显示的金额';

  @override
  String get cantPayMightGoBankrupt => '如果你无法支付，可能会破产！';

  @override
  String get collectGoBonus => '当你停在或经过起点时可获得金钱。';

  @override
  String get passGoEarn => '经过起点是保持现金流的关键。';

  @override
  String get startTileFunFact => '起点是大富翁中经过次数最多的格子之一。';

  @override
  String get jailFactOne => '落在这里可能是入狱，也可能只是探监。';

  @override
  String get jailFactTwo => '你可以交保释金，或尝试掷出双骰。';

  @override
  String get jailFunFact => '监狱是游戏里最讲策略的格子之一。';

  @override
  String get freeParkingFactOne => '转动转盘赢取现金、增益卡或特别奖品！';

  @override
  String get freeParkingFactTwo => '每次转动都保证有奖励——绝无空手而归！';

  @override
  String get freeParkingFunFact => '幸运转盘是命运瞬间逆转的地方。';

  @override
  String get goToJailFactOne => '落在这里会直接把你送进监狱。';

  @override
  String get goToJailFactTwo => '这次移动不能领取起点奖励。';

  @override
  String get goToJailFunFact => '尽量避开这个格子可以保持节奏。';

  @override
  String get chanceFunFact => '机会卡会让每局都充满惊喜。';

  @override
  String get communityChestFactOne => '公益宝箱体现了社区互助精神！';

  @override
  String get communityChestFactTwo => '这些卡通常会给你带来收益。';

  @override
  String get communityChestFactThree => '“银行出错，利于你”也可能出现！';

  @override
  String get communityChestFunFact => '公益宝箱卡通常比较友好。';

  @override
  String get taxFactOne => '每个人都需要纳税！';

  @override
  String get taxFactTwo => '税收用于支持公共服务。';

  @override
  String get taxFunFact => '税务格经常会改变整局节奏。';

  @override
  String aiBuiltOn(String level, String property) {
    return '在 $property 上建造了$level！';
  }

  @override
  String get chance => '机会';

  @override
  String get communityChest => '公益金';

  @override
  String get chanceExcl => '机会！';

  @override
  String get communityChestExcl => '公益金！';

  @override
  String get tapCardToPick => '点击一张卡片来抽取！';

  @override
  String get revealingCard => '正在揭晓你的卡片……';

  @override
  String get tapToContinue => '点击任意位置继续';

  @override
  String get chestShort => '公益金';

  @override
  String get ok => '好的';

  @override
  String get freeHouseTitle => '免费房屋！';

  @override
  String get choosePropertyToBuild => '选择一块地产来建造';

  @override
  String get noUpgradeableProperties => '没有可以升级的地产！';

  @override
  String get buyPropertiesComeBack => '先去购买地产，稍后再来。';

  @override
  String houseN(int level) {
    return '房屋 $level';
  }

  @override
  String get hotel => '酒店';

  @override
  String nextUpgrade(String text) {
    return '下一级：$text';
  }

  @override
  String get saveForLater => '留着以后用';

  @override
  String get build => '建造！';

  @override
  String get teleportTitle => '传送！';

  @override
  String get chooseTileToTeleport => '选择任意格子进行传送';

  @override
  String get all => '全部';

  @override
  String get railroads => '铁路';

  @override
  String get utilities => '公用事业';

  @override
  String get special => '特殊';

  @override
  String get noTilesMatch => '没有匹配的格子';

  @override
  String get teleportBtn => '传送！';

  @override
  String get gameOver => '游戏结束！';

  @override
  String get winner => '赢家';

  @override
  String get finalStandings => '最终排名';

  @override
  String rankN(int rank) {
    return '第$rank名';
  }

  @override
  String get bankrupt => '破产';

  @override
  String get rounds => '回合数';

  @override
  String get finalCash => '最终现金';

  @override
  String get turns => '回合';

  @override
  String get mainMenu => '主菜单';

  @override
  String get playAgain => '再玩一局';

  @override
  String playerPortfolio(String name) {
    return '$name 的资产';
  }

  @override
  String netWorth(int amount) {
    return '净资产：\$$amount';
  }

  @override
  String get position => '位置';

  @override
  String get noPropertiesYet => '还没有地产';

  @override
  String get startBuyingProperties => '开始购买地产，建立你的帝国吧！';

  @override
  String rentAmount(int amount) {
    return '租金：\$$amount';
  }

  @override
  String get mortgaged => '已抵押';

  @override
  String get mortgagedLabel => '已抵押';

  @override
  String get railroad => '铁路';

  @override
  String get utility => '公用事业';

  @override
  String get colorBrown => '棕色';

  @override
  String get colorLightBlue => '浅蓝色';

  @override
  String get colorPink => '粉色';

  @override
  String get colorOrange => '橙色';

  @override
  String get colorRed => '红色';

  @override
  String get colorYellow => '黄色';

  @override
  String get colorGreen => '绿色';

  @override
  String get colorDarkBlue => '深蓝色';

  @override
  String get noneYet => '暂无';

  @override
  String get noProperties => '没有地产';

  @override
  String get yourTurn => '轮到你了';

  @override
  String tileN(int position) {
    return '格子 $position';
  }

  @override
  String get rolling => '掷骰中……';

  @override
  String get moving => '移动中……';

  @override
  String get rollDice => '掷骰子';

  @override
  String get tap => '点击';

  @override
  String get spin => '转动';

  @override
  String get trade => '交易';

  @override
  String get bank => '银行';

  @override
  String get use => '使用';

  @override
  String get gameSaved => '游戏保存成功！';

  @override
  String get failedToSave => '保存游戏失败';

  @override
  String gameLoaded(int round) {
    return '游戏已读取！第 $round 回合';
  }

  @override
  String get failedToLoad => '读取游戏失败';

  @override
  String get noPowerUpCards => '没有增益卡！赢得小游戏来收集它们。';

  @override
  String get yourPowerUpCards => '你的增益卡';

  @override
  String get noOtherPlayers => '没有其他玩家可以交易！';

  @override
  String boughtProperty(String name, int price) {
    return '以 \$$price 购买了 $name！';
  }

  @override
  String paidRentTo(int amount, String name) {
    return '向 $name 支付了 \$$amount 租金';
  }

  @override
  String paidTax(int amount, String taxName) {
    return '缴纳了 \$$amount $taxName';
  }

  @override
  String get goingToJail => '要去监狱了！';

  @override
  String get goToJailTitle => '进入监狱！';

  @override
  String get goToJailMessage => '你停在了“进入监狱”格！\n直接进入监狱，不经过“起点”。';

  @override
  String wonPrize(String prize) {
    return '转动了转盘，赢得了 $prize！';
  }

  @override
  String get tradeAccepted => '交易已接受！';

  @override
  String get tradeRejected => '交易被拒绝了。';

  @override
  String get tradeCompleted => '交易完成！';

  @override
  String get tradeRejectedShort => '交易被拒绝。';

  @override
  String get spinPrizeCash50 => '50美元';

  @override
  String get spinPrizeCash50Desc => '赢得 \$50！';

  @override
  String get spinPrizeCash100 => '100美元';

  @override
  String get spinPrizeCash100Desc => '赢得 \$100！';

  @override
  String get spinPrizeCash200 => '200美元';

  @override
  String get spinPrizeCash200Desc => '赢得 \$200！';

  @override
  String get spinPrizeFreeHouse => '免费房屋';

  @override
  String get spinPrizeFreeHouseDesc => '在任意地产上免费建造一栋房屋！';

  @override
  String get spinPrizeDoubleRent => '双倍租金';

  @override
  String get spinPrizeDoubleRentDesc => '你下一次收取的租金翻倍！';

  @override
  String get spinPrizeShield => '护盾';

  @override
  String get spinPrizeShieldDesc => '免除下一次租金支付！';

  @override
  String get spinPrizeTeleport => '传送';

  @override
  String get spinPrizeTeleportDesc => '移动到你选择的任意格子！';

  @override
  String get spinPrizeJackpot => '大奖！';

  @override
  String get spinPrizeJackpotDesc => '赢得 \$500 大奖！';

  @override
  String get luckySpinTitle => '幸运转盘！';

  @override
  String playerTurnToSpin(String name) {
    return '轮到 $name 转动转盘！';
  }

  @override
  String get spinInstructions => '点击中心来转动转盘！';

  @override
  String get spinning => '转动中……';

  @override
  String youWonPrize(String name) {
    return '你赢得了 $name！';
  }

  @override
  String get collectPrize => '领取奖品！';

  @override
  String get orTapToSpin => '或者点击这里转动';

  @override
  String get goodLuck => '祝你好运！';

  @override
  String get eventMarketBoom => '市场繁荣！';

  @override
  String get eventMarketBoomDesc => '所有地产价值上涨20%，持续3回合！';

  @override
  String get eventTaxHoliday => '免税假期！';

  @override
  String get eventTaxHolidayDesc => '本回合免收所有税费！';

  @override
  String get eventGoldRush => '淘金热！';

  @override
  String get eventGoldRushDesc => '经过“起点”时可领取 \$300 而不是 \$200，持续3回合！';

  @override
  String get eventPropertySale => '地产大甩卖！';

  @override
  String get eventPropertySaleDesc => '所有无主地产打75折，持续2回合！';

  @override
  String get eventLuckyDay => '幸运日！';

  @override
  String get eventLuckyDayDesc => '每位玩家获得 \$50！';

  @override
  String get eventHousingBoom => '房产热潮！';

  @override
  String get eventHousingBoomDesc => '随机一块地产免费升级！';

  @override
  String get eventRentStrike => '租金罢工！';

  @override
  String get eventRentStrikeDesc => '所有租金减半，持续2回合。';

  @override
  String get eventMeteorShower => '流星雨！';

  @override
  String get eventMeteorShowerDesc => '随机一位玩家损失 \$100！';

  @override
  String get eventCommunityCleanup => '社区大扫除';

  @override
  String get eventCommunityCleanupDesc => '你拥有的每栋房屋需支付 \$25。';

  @override
  String get eventStockDividend => '股息分红';

  @override
  String get eventStockDividendDesc => '每位玩家按拥有的地产数量获得每块 \$10。';

  @override
  String get eventBirthdayParty => '生日派对！';

  @override
  String get eventBirthdayPartyDesc => '当前玩家从每位其他玩家处收取 \$25！';

  @override
  String get eventBankError => '银行出错';

  @override
  String get eventBankErrorDesc => '随机一位玩家获得 \$200！';

  @override
  String get eventMarketCrash => '股市崩盘！';

  @override
  String get eventMarketCrashDesc => '地产价值剧烈波动！所有人都会受到随机影响！';

  @override
  String get powerUpRentReducer => '租金减免';

  @override
  String get powerUpRentReducerDesc => '本回合只需支付50%的租金';

  @override
  String get powerUpSpeedBoost => '加速冲刺';

  @override
  String get powerUpSpeedBoostDesc => '移动后可以再掷一次骰子';

  @override
  String get powerUpPropertyScout => '地产侦察';

  @override
  String get powerUpPropertyScoutDesc => '查看所有无主地产的价格';

  @override
  String get powerUpRentCollector => '租金收割机';

  @override
  String get powerUpRentCollectorDesc => '从每位玩家处收取 \$50';

  @override
  String get powerUpPriceFreeze => '价格冻结';

  @override
  String get powerUpPriceFreezeDesc => '以75折购买下一块地产';

  @override
  String get powerUpTeleporter => '传送器';

  @override
  String get powerUpTeleporterDesc => '移动到任意无主地产';

  @override
  String get powerUpShield => '护盾';

  @override
  String get powerUpShieldDesc => '免除一次租金支付';

  @override
  String get powerUpDoubleDice => '双倍骰子';

  @override
  String get powerUpDoubleDiceDesc => '掷4颗骰子，选最好的2颗';

  @override
  String get powerUpMoneyMagnet => '金钱磁铁';

  @override
  String get powerUpMoneyMagnetDesc => '经过“起点”时额外获得 \$100（持续3回合）';

  @override
  String get powerUpMonopolyMaster => '垄断大师';

  @override
  String get powerUpMonopolyMasterDesc => '在所有已拥有的地产上免费建造房屋！';

  @override
  String get powerUpRarityCommon => '普通';

  @override
  String get powerUpRarityUncommon => '稀有';

  @override
  String get powerUpRarityRare => '珍贵';

  @override
  String get powerUpRarityLegendary => '传说';

  @override
  String get winnerTitle => '赢家！';

  @override
  String get gameStats => '游戏统计';

  @override
  String get shopTitle => '商店';

  @override
  String get shopSubtitle => '解锁主题、棋子和更多！';

  @override
  String get unlocked => '已解锁';

  @override
  String get free => '免费';

  @override
  String get loadingAd => '加载广告中……';

  @override
  String adsProgress(int watched, int required) {
    return '进度：已观看 $watched/$required 个广告！';
  }

  @override
  String purchaseItem(String name) {
    return '购买 $name？';
  }

  @override
  String unlockFor(String price) {
    return '花费 $price 解锁';
  }

  @override
  String buyPrice(String price) {
    return '购买 $price';
  }

  @override
  String get unlockedExcl => '已解锁！';

  @override
  String get awesome => '太棒了！';

  @override
  String get watchAdsToUnlock => '观看广告来解锁';

  @override
  String watchAdsOrPay(int count) {
    return '观看 $count 个广告或付费立即解锁';
  }

  @override
  String watchAdsCount(int count) {
    return '观看 $count 个广告来解锁';
  }

  @override
  String get purchaseToUnlock => '付费解锁';

  @override
  String get useThis => '使用此项';

  @override
  String get owned => '已拥有';

  @override
  String get familyLeaderboard => '家庭排行榜';

  @override
  String get rankings => '排名';

  @override
  String get records => '记录';

  @override
  String get achievements => '成就';

  @override
  String get sortBy => '排序：';

  @override
  String get wins => '胜场';

  @override
  String get winPercent => '胜率';

  @override
  String get earnings => '收益';

  @override
  String get games => '场次';

  @override
  String get noPlayersYet => '还没有玩家';

  @override
  String get playToSeeStats => '玩几局游戏来查看统计吧！';

  @override
  String get mostWins => '最多胜场';

  @override
  String get highestCash => '最高现金';

  @override
  String get propertyTycoonRecord => '地产大亨';

  @override
  String get longestWinStreak => '最长连胜';

  @override
  String get speedChampion => '速度冠军';

  @override
  String get luckiestRoller => '最幸运掷骰';

  @override
  String inARow(int count) {
    return '连续 $count 次';
  }

  @override
  String turnsCount(int count) {
    return '$count 回合';
  }

  @override
  String avgValue(String value) {
    return '平均 $value';
  }

  @override
  String get memoryMatchTitle => '记忆配对';

  @override
  String get pairs => '配对数';

  @override
  String get timeLabel => '时间';

  @override
  String secondsShort(int seconds) {
    return '$seconds秒';
  }

  @override
  String get greatJob => '做得好！';

  @override
  String get timeUp => '时间到！';

  @override
  String pairsFound(int found, int total) {
    return '已找到配对：$found / $total';
  }

  @override
  String scoreAmount(int score) {
    return '得分：$score';
  }

  @override
  String get quickTapAmazing => '太棒了！';

  @override
  String get quickTapGreat => '很棒！';

  @override
  String get quickTapGood => '不错';

  @override
  String get quickTapTryAgain => '再试一次';

  @override
  String get quickTapInstruction => '点击金币！避开炸弹！';

  @override
  String streakCount(int count) {
    return '连击 $count 次！';
  }

  @override
  String itemSelected(String name) {
    return '已选择 $name！';
  }

  @override
  String get deletePhotoTitle => '删除照片？';

  @override
  String get deletePhotoMessage => '这张照片将从你的头像中移除。';

  @override
  String get delete => '删除';

  @override
  String get takePhoto => '拍照';

  @override
  String get choosePhoto => '选择照片';

  @override
  String get noPhotosYet => '还没有照片';

  @override
  String get takeSelfieOrPick => '拍一张自拍或从相册选择！';

  @override
  String get chooseYourAvatarFancy => '✨ 选择你的头像 ✨';

  @override
  String get avatarCategoryAnimals => '动物';

  @override
  String get avatarCategoryFood => '食物';

  @override
  String get avatarCategoryObjects => '物品';

  @override
  String get avatarCategoryCharacters => '角色';

  @override
  String get avatarCategoryMyPhotos => '我的照片';

  @override
  String get select => '选择';

  @override
  String get countryUSA => '美国';

  @override
  String get countryUK => '英国';

  @override
  String get countryFrance => '法国';

  @override
  String get countryJapan => '日本';

  @override
  String get countryChina => '中国';

  @override
  String get countryMexico => '墨西哥';

  @override
  String get chooseCity => '选择城市';

  @override
  String get cityAtlanticCity => '大西洋城';

  @override
  String get cityNewYork => '纽约';

  @override
  String get cityLosAngeles => '洛杉矶';

  @override
  String get cityLondon => '伦敦';

  @override
  String get cityEdinburgh => '爱丁堡';

  @override
  String get cityManchester => '曼彻斯特';

  @override
  String get cityParis => '巴黎';

  @override
  String get cityLyon => '里昂';

  @override
  String get cityMarseille => '马赛';

  @override
  String get cityTokyo => '东京';

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
  String get cityMexicoCity => '墨西哥城';

  @override
  String get cityGuadalajara => '瓜达拉哈拉';

  @override
  String get cityCancun => '坎昆';
}
