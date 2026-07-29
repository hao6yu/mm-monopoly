// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'M&M Magnate Inmobiliario';

  @override
  String get propertyTycoon => 'MAGNATE INMOBILIARIO';

  @override
  String get familyEdition => 'EDICIÓN FAMILIAR';

  @override
  String get worldCityEdition => 'EDICIÓN CIUDADES DEL MUNDO';

  @override
  String get chooseNextMove => 'Elige tu próximo movimiento';

  @override
  String get newGame => 'Nueva Partida';

  @override
  String get continueGame => 'Continuar';

  @override
  String get howToPlay => 'Cómo Jugar';

  @override
  String get settings => 'Ajustes';

  @override
  String get shop => 'Tienda';

  @override
  String get howManyPlayers => '¿Cuántos Jugadores?';

  @override
  String get playerSetup => 'Configuración de Jugadores';

  @override
  String get chooseBoard => 'Elige Tablero';

  @override
  String get numberOfPlayers => 'Número de Jugadores';

  @override
  String get numberOfDice => 'Número de Dados';

  @override
  String get players => 'jugadores';

  @override
  String get oneDie => 'Un Dado';

  @override
  String get twoDice => 'Dos Dados';

  @override
  String get classicStyle => 'Estilo clásico';

  @override
  String get standardRules => 'Reglas estándar';

  @override
  String get playersStep => 'Jugadores';

  @override
  String get setupStep => 'Configuración';

  @override
  String get back => 'Atrás';

  @override
  String get previous => 'Anterior';

  @override
  String get next => 'Siguiente';

  @override
  String get startGame => 'Iniciar Partida';

  @override
  String playerN(int number) {
    return 'Jugador $number';
  }

  @override
  String get you => 'Tú';

  @override
  String get ai => 'IA';

  @override
  String get name => 'Nombre';

  @override
  String get chooseYourAvatar => 'Elige Tu Avatar';

  @override
  String get uniqueNameError => 'Cada jugador debe tener un nombre único';

  @override
  String get allPlayersNeedName => 'Todos los jugadores deben tener un nombre';

  @override
  String get uniqueColorError => 'Cada jugador debe tener un color único';

  @override
  String get tutorialRollMove => 'Lanza y Mueve';

  @override
  String get tutorialRollMoveDesc =>
      '¡Toca los dados para lanzar!\nMuévete por el tablero.';

  @override
  String get tutorialBuyProperties => 'Compra Propiedades';

  @override
  String get tutorialBuyPropertiesDesc =>
      '¿Caíste en una casilla libre?\n¡Cómprala y hazla tuya!';

  @override
  String get tutorialCollectRent => 'Cobra Alquiler';

  @override
  String get tutorialCollectRentDesc =>
      '¿Otros caen en tu propiedad?\n¡Te pagan A TI!';

  @override
  String get tutorialSpecialSpaces => 'Casillas Especiales';

  @override
  String get tutorialSpecialSpacesDesc =>
      'Cartas de suerte, cárcel, trenes...\n¡Sorpresas por todas partes!';

  @override
  String get tutorialWinGame => '¡Gana la Partida!';

  @override
  String get tutorialWinGameDesc =>
      '¡El último con dinero gana!\n¡Deja en bancarrota a tus amigos!';

  @override
  String get letsPlay => '¡A Jugar!';

  @override
  String get gotIt => '¡Entendido!';

  @override
  String get startingCash => 'Dinero Inicial';

  @override
  String get playerTrading => 'Intercambio entre Jugadores';

  @override
  String get bankFeatures => 'Funciones del Banco';

  @override
  String get propertyAuctions => 'Subastas de Propiedades';

  @override
  String get backgroundMusic => 'Música de Fondo';

  @override
  String get gameSounds => 'Sonidos del Juego';

  @override
  String get language => 'Idioma';

  @override
  String get buyMeACoffee => 'Invítame un café';

  @override
  String get buyMeACoffeeDesc =>
      'Tu apoyo ayuda a mantener el juego gratis y actualizado. ¡Cada café cuenta mucho!';

  @override
  String get openExternalLink => 'Abrir Enlace Externo';

  @override
  String get openBuyMeACoffeeDesc =>
      'Esto abrirá buymeacoffee.com en tu navegador.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get open => 'Abrir';

  @override
  String get reset => 'Restablecer';

  @override
  String get backToMenu => 'Volver al Menú';

  @override
  String get settingsReset => 'Ajustes restablecidos';

  @override
  String get propertyAvailable => '¡Esta propiedad está disponible!';

  @override
  String get price => 'Precio';

  @override
  String get baseRent => 'Alquiler Base';

  @override
  String get rent => 'Alquiler';

  @override
  String get utilityRentDesc => '4x o 10x la tirada de dados';

  @override
  String get yourCash => 'Tu Dinero';

  @override
  String get notEnoughCash => '¡No tienes suficiente dinero!';

  @override
  String get skip => 'Pasar';

  @override
  String buyForAmount(String amount) {
    return 'Comprar \$$amount';
  }

  @override
  String get bankruptcy => '¡BANCARROTA!';

  @override
  String get payRent => 'Pagar Alquiler';

  @override
  String landedOnProperty(String propertyName) {
    return 'Caíste en $propertyName';
  }

  @override
  String get ownsThisProperty => 'es dueño de esta propiedad';

  @override
  String get rentDue => 'Alquiler a Pagar';

  @override
  String diceRentCalc(int diceRoll, int multiplier, int amount) {
    return 'Dados: $diceRoll × $multiplier = \$$amount';
  }

  @override
  String get ownerHasBothUtilities => '(El dueño tiene ambos servicios)';

  @override
  String get ownerHasOneUtility => '(El dueño tiene 1 servicio)';

  @override
  String ownerHasRailroads(int count, String suffix) {
    return 'El dueño tiene $count ferrocarril$suffix';
  }

  @override
  String get bankruptMessage =>
      '¡No tienes suficiente dinero! Estás en bancarrota.';

  @override
  String get acceptBankruptcy => 'Aceptar Bancarrota';

  @override
  String payAmount(int amount) {
    return 'Pagar \$$amount';
  }

  @override
  String get payTaxToBank => 'Debes pagar impuestos al banco';

  @override
  String get taxAmount => 'Monto del Impuesto';

  @override
  String get gameMenu => 'Menú del Juego';

  @override
  String get backToGame => 'Volver al Juego';

  @override
  String get saveGame => 'Guardar Partida';

  @override
  String get loadGame => 'Cargar Partida';

  @override
  String get loadSavedGame => '¿Cargar Partida Guardada?';

  @override
  String get currentProgressLost => 'Se perderá el progreso actual.';

  @override
  String get restartGame => 'Reiniciar Partida';

  @override
  String get allProgressLost => 'Se perderá todo el progreso.';

  @override
  String get quitToMenu => 'Salir al Menú';

  @override
  String get quitGame => '¿Salir del Juego?';

  @override
  String get confirm => 'Confirmar';

  @override
  String get inJail => 'EN LA CÁRCEL';

  @override
  String get youAreInJail => '¡Estás en la cárcel!';

  @override
  String get bailAmount => 'Monto de la Fianza';

  @override
  String stayInJailTurns(int turns, String suffix) {
    return 'O quédate en la cárcel por $turns turno$suffix más.';
  }

  @override
  String get mustPayFine => '¡Debes pagar la multa para salir!';

  @override
  String get stayInJail => 'Quedarse en la Cárcel';

  @override
  String payBail(int amount) {
    return 'Pagar \$$amount';
  }

  @override
  String get buildHotel => '¡Construye un Hotel!';

  @override
  String get buildHouse => '¡Construye una Casa!';

  @override
  String get upgradeCost => 'Costo de Mejora';

  @override
  String get currentRent => 'Alquiler Actual';

  @override
  String get newRent => 'Nuevo Alquiler';

  @override
  String get increase => 'Aumento';

  @override
  String buildForAmount(int amount) {
    return 'Construir \$$amount';
  }

  @override
  String get eventGoodNews => '¡Buenas Noticias!';

  @override
  String get eventBadNews => '¡Malas Noticias!';

  @override
  String get eventNewsFlash => '¡Noticia de Última Hora!';

  @override
  String get eventWildCard => '¡Comodín!';

  @override
  String eventLastsRounds(int duration, String suffix) {
    return 'Dura $duration ronda$suffix';
  }

  @override
  String get auction => 'SUBASTA';

  @override
  String propertyValue(int amount) {
    return 'Valor: \$$amount';
  }

  @override
  String get currentBid => 'Oferta Actual:';

  @override
  String get noBidsYet => 'Sin ofertas aún';

  @override
  String get leadingBidder => 'Mejor Postor:';

  @override
  String get bidders => 'Postores:';

  @override
  String playerTurn(String name) {
    return 'Turno de $name';
  }

  @override
  String get notEnoughCashToBid => 'No tienes suficiente dinero para ofertar';

  @override
  String get pass => 'Pasar';

  @override
  String bidAmount(int amount) {
    return 'Ofertar \$$amount';
  }

  @override
  String get notEnoughCashShort => 'Dinero insuficiente';

  @override
  String playerWinsAuction(String name) {
    return '¡$name gana la subasta!';
  }

  @override
  String get noWinnerAuction => 'Sin ganador - la propiedad vuelve al banco';

  @override
  String finalBid(int amount) {
    return 'Oferta final: \$$amount';
  }

  @override
  String get proposeTrade => 'Proponer un Intercambio';

  @override
  String get tradeWith => 'Intercambiar con:';

  @override
  String youOffer(String name) {
    return 'Tú Ofreces ($name)';
  }

  @override
  String get cash => 'Dinero';

  @override
  String get cashLabel => 'Dinero:';

  @override
  String get properties => 'Propiedades';

  @override
  String get propertiesLabel => 'Propiedades:';

  @override
  String get noPropertiesToOffer => 'No tienes propiedades para ofrecer';

  @override
  String youRequest(String name) {
    return 'Tú Pides (de $name)';
  }

  @override
  String get noPropertiesAvailable => 'No hay propiedades disponibles';

  @override
  String get proposeTradeBtn => 'Proponer Intercambio';

  @override
  String wantsToTrade(String name) {
    return '¡$name quiere intercambiar!';
  }

  @override
  String get youReceive => 'Tú Recibes:';

  @override
  String get youGive => 'Tú Das:';

  @override
  String get nothing => 'Nada';

  @override
  String get reject => 'Rechazar';

  @override
  String get accept => 'Aceptar';

  @override
  String get propertyManagement => 'Gestión de Propiedades';

  @override
  String get mortgage => 'Hipotecar';

  @override
  String get unmortgage => 'Deshipotecar';

  @override
  String mortgageCount(int count) {
    return 'Hipotecar ($count)';
  }

  @override
  String unmortgageCount(int count) {
    return 'Deshipotecar ($count)';
  }

  @override
  String get noMortgageableProperties =>
      'No hay propiedades disponibles para hipotecar.\nLas propiedades con casas deben vender las casas primero.';

  @override
  String get noMortgagedProperties => 'No hay propiedades hipotecadas.';

  @override
  String receiveAmount(int amount) {
    return 'Recibir: \$$amount';
  }

  @override
  String costAmount(int amount) {
    return 'Costo: \$$amount';
  }

  @override
  String get pay => 'Pagar';

  @override
  String get close => 'Cerrar';

  @override
  String get propertyLocation => 'Ubicación de la Propiedad';

  @override
  String get startingPoint => 'Punto de Partida';

  @override
  String get justVisiting => 'De Visita / En la Cárcel';

  @override
  String get spinToWin => '¡Gira para Ganar!';

  @override
  String get goToJailLabel => 'Ve a la Cárcel';

  @override
  String get chanceCard => 'Suerte';

  @override
  String get communityChestCard => 'Arca Comunal';

  @override
  String get incomeTax => 'Impuesto sobre la Renta';

  @override
  String get luxuryTax => 'Impuesto de Lujo';

  @override
  String get didYouKnow => '¿Sabías Que?';

  @override
  String get ownAllPropertiesTip =>
      '¡Sé dueño de todas las propiedades de un grupo de color para cobrar el doble de alquiler!';

  @override
  String get buildHousesEvenlyTip =>
      'Construye casas de forma pareja en tus propiedades para máxima ganancia.';

  @override
  String hotelsMaxRentTip(int amount) {
    return '¡Los hoteles generan el alquiler más alto - hasta \$$amount!';
  }

  @override
  String get railroad1Tip => 'Tener 1 ferrocarril: \$25 de alquiler';

  @override
  String get railroad2Tip => 'Tener 2 ferrocarriles: \$50 de alquiler';

  @override
  String get railroad3Tip => 'Tener 3 ferrocarriles: \$100 de alquiler';

  @override
  String get railroad4Tip => '¡Tener los 4 ferrocarriles: \$200 de alquiler!';

  @override
  String get utility1Tip => 'Tener 1 servicio: Alquiler = 4× tirada de dados';

  @override
  String get utility2Tip =>
      '¡Tener ambos servicios: Alquiler = 10× tirada de dados!';

  @override
  String get utilitiesProfitableTip =>
      'Los servicios pueden ser muy rentables con tiradas altas de dados.';

  @override
  String get chanceHowToPlay => 'Cómo Jugar';

  @override
  String get chestHowToPlay => 'Cómo Jugar';

  @override
  String get drawTopCard => 'Toma la carta de arriba del montón de Suerte';

  @override
  String get readCardAloud => 'Lee la carta en voz alta';

  @override
  String get doWhatCardSays => '¡Haz lo que dice la carta!';

  @override
  String get putCardBottom => 'Pon la carta al fondo del montón';

  @override
  String get jailRules => 'Reglas de la Cárcel';

  @override
  String get goToJailRules => 'Reglas de Ir a la Cárcel';

  @override
  String get taxRules => 'Reglas de Impuestos';

  @override
  String get drawTopChestCard => 'Toma la carta superior del cofre';

  @override
  String get readToEveryone => 'Léela en voz alta para todos';

  @override
  String get followInstructions => 'Sigue las instrucciones de la carta';

  @override
  String get returnCardBottom => 'Devuelve la carta al fondo del mazo';

  @override
  String get justVisitingSafe => 'Si solo estás de visita, ¡estás a salvo!';

  @override
  String get inJailYouCan => 'Si estás EN la cárcel, puedes:';

  @override
  String get pay50GetOut => '  • Paga \\\$50 para salir';

  @override
  String get rollDoublesThreeTries => '  • Intenta sacar dobles (3 intentos)';

  @override
  String get useGetOutCard =>
      '  • Usa una carta de \"Salir de la cárcel gratis\"';

  @override
  String get goDirectlyToJail => '¡Ve directamente a la cárcel!';

  @override
  String get doNotPassGo => 'NO pases por SALIDA';

  @override
  String get doNotCollect200 => 'NO cobres \\\$200';

  @override
  String get turnEndsImmediately => 'Tu turno termina inmediatamente';

  @override
  String get mustPayTaxRule => '¡DEBES pagar este impuesto!';

  @override
  String get payBankAmountShown => 'Paga al banco la cantidad indicada';

  @override
  String get cantPayMightGoBankrupt => 'Si no puedes pagar, ¡podrías quebrar!';

  @override
  String get collectGoBonus => 'Cobra dinero al caer o pasar por SALIDA.';

  @override
  String get passGoEarn =>
      'Pasar por SALIDA mantiene saludable tu flujo de efectivo.';

  @override
  String get startTileFunFact =>
      'SALIDA es la casilla más visitada de Monopoly.';

  @override
  String get jailFactOne => 'Caer aquí puede significar cárcel o solo visita.';

  @override
  String get jailFactTwo => 'Puedes pagar fianza o intentar sacar dobles.';

  @override
  String get jailFunFact =>
      'La cárcel es una de las casillas más estratégicas del juego.';

  @override
  String get freeParkingFactOne =>
      '¡Gira la ruleta para ganar dinero, potenciadores o premios especiales!';

  @override
  String get freeParkingFactTwo =>
      'Cada giro garantiza una recompensa — ¡sin malos resultados!';

  @override
  String get freeParkingFunFact =>
      'El Giro de la Suerte es donde las fortunas pueden cambiar al instante.';

  @override
  String get goToJailFactOne =>
      'Esta casilla envía tu ficha directamente a la cárcel.';

  @override
  String get goToJailFactTwo =>
      'No cobras dinero de SALIDA en este movimiento.';

  @override
  String get goToJailFunFact => 'Evita esta casilla para mantener tu impulso.';

  @override
  String get chanceFunFact =>
      'Las cartas de Suerte añaden sorpresas a cada partida.';

  @override
  String get communityChestFactOne => '¡La comunidad se ayuda entre sí!';

  @override
  String get communityChestFactTwo => 'Estas cartas suelen darte dinero.';

  @override
  String get communityChestFactThree =>
      '¡Puede ocurrir un error bancario a tu favor!';

  @override
  String get communityChestFunFact =>
      'Las cartas de Cofre de Comunidad suelen ser amistosas.';

  @override
  String get taxFactOne => '¡Todos tienen que pagar impuestos!';

  @override
  String get taxFactTwo =>
      'Los impuestos ayudan a financiar servicios públicos.';

  @override
  String get taxFunFact =>
      'Las casillas de impuestos pueden cambiar el ritmo de la partida.';

  @override
  String aiBuiltOn(String level, String property) {
    return '¡Construyó un $level en $property!';
  }

  @override
  String get chance => 'SUERTE';

  @override
  String get communityChest => 'ARCA COMUNAL';

  @override
  String get chanceExcl => '¡SUERTE!';

  @override
  String get communityChestExcl => '¡ARCA COMUNAL!';

  @override
  String get tapCardToPick => '¡Toca una carta para elegirla!';

  @override
  String get revealingCard => 'Revelando tu carta...';

  @override
  String get tapToContinue => 'Toca en cualquier lugar para continuar';

  @override
  String get chestShort => 'ARCA';

  @override
  String get ok => 'Aceptar';

  @override
  String get freeHouseTitle => '¡CASA GRATIS!';

  @override
  String get choosePropertyToBuild => 'Elige una propiedad para construir';

  @override
  String get noUpgradeableProperties =>
      '¡No hay propiedades disponibles para mejorar!';

  @override
  String get buyPropertiesComeBack => 'Compra propiedades y vuelve después.';

  @override
  String houseN(int level) {
    return 'Casa $level';
  }

  @override
  String get hotel => 'Hotel de lujo';

  @override
  String nextUpgrade(String text) {
    return 'Siguiente: $text';
  }

  @override
  String get saveForLater => 'Guardar para Después';

  @override
  String get build => '¡Construir!';

  @override
  String get teleportTitle => '¡TELETRANSPORTE!';

  @override
  String get chooseTileToTeleport =>
      'Elige cualquier casilla para teletransportarte';

  @override
  String get all => 'Todas';

  @override
  String get railroads => 'Ferrocarriles';

  @override
  String get utilities => 'Servicios';

  @override
  String get special => 'Especiales';

  @override
  String get noTilesMatch => 'Ninguna casilla coincide con este filtro';

  @override
  String get teleportBtn => '¡Teletransportar!';

  @override
  String get gameOver => '¡FIN DEL JUEGO!';

  @override
  String get winner => 'Ganador';

  @override
  String get finalStandings => 'Clasificación Final';

  @override
  String rankN(int rank) {
    return 'N.º $rank';
  }

  @override
  String get bankrupt => 'EN BANCARROTA';

  @override
  String get rounds => 'Rondas';

  @override
  String get finalCash => 'Dinero Final';

  @override
  String get turns => 'Turnos';

  @override
  String get mainMenu => 'Menú Principal';

  @override
  String get playAgain => 'Jugar de Nuevo';

  @override
  String playerPortfolio(String name) {
    return 'Portafolio de $name';
  }

  @override
  String netWorth(int amount) {
    return 'Patrimonio: \$$amount';
  }

  @override
  String get position => 'Posición';

  @override
  String get noPropertiesYet => 'Sin Propiedades Aún';

  @override
  String get startBuyingProperties =>
      '¡Empieza a comprar propiedades para construir tu imperio!';

  @override
  String rentAmount(int amount) {
    return 'Alquiler: \$$amount';
  }

  @override
  String get mortgaged => 'HIPOTECADA';

  @override
  String get mortgagedLabel => 'Hipotecada';

  @override
  String get railroad => 'Ferrocarril';

  @override
  String get utility => 'Servicio';

  @override
  String get colorBrown => 'Marrón';

  @override
  String get colorLightBlue => 'Celeste';

  @override
  String get colorPink => 'Rosa';

  @override
  String get colorOrange => 'Naranja';

  @override
  String get colorRed => 'Rojo';

  @override
  String get colorYellow => 'Amarillo';

  @override
  String get colorGreen => 'Verde';

  @override
  String get colorDarkBlue => 'Azul Oscuro';

  @override
  String get noneYet => 'Ninguno aún';

  @override
  String get noProperties => 'Sin propiedades';

  @override
  String get yourTurn => 'TU TURNO';

  @override
  String tileN(int position) {
    return 'Casilla $position';
  }

  @override
  String get rolling => 'LANZANDO...';

  @override
  String get moving => 'MOVIENDO...';

  @override
  String get rollDice => 'LANZAR DADOS';

  @override
  String get tap => 'TOCA';

  @override
  String get spin => 'GIRA';

  @override
  String get trade => 'Intercambio';

  @override
  String get bank => 'Banco';

  @override
  String get use => 'USAR';

  @override
  String get gameSaved => '¡Partida guardada con éxito!';

  @override
  String get failedToSave => 'Error al guardar la partida';

  @override
  String gameLoaded(int round) {
    return '¡Partida cargada! Ronda $round';
  }

  @override
  String get failedToLoad => 'Error al cargar la partida';

  @override
  String get noPowerUpCards =>
      '¡Sin cartas de poder! Gana minijuegos para conseguirlas.';

  @override
  String get yourPowerUpCards => 'Tus Cartas de Poder';

  @override
  String get noOtherPlayers =>
      '¡No hay otros jugadores con quién intercambiar!';

  @override
  String boughtProperty(String name, int price) {
    return '¡Compraste $name por \$$price!';
  }

  @override
  String paidRentTo(int amount, String name) {
    return 'Pagaste \$$amount de alquiler a $name';
  }

  @override
  String paidTax(int amount, String taxName) {
    return 'Pagaste \$$amount de $taxName';
  }

  @override
  String get goingToJail => '¡Vas a la cárcel!';

  @override
  String get goToJailTitle => '¡Ve a la Cárcel!';

  @override
  String get goToJailMessage =>
      '¡Caíste en Ve a la Cárcel!\nVe directo a la cárcel, no pases por la Salida.';

  @override
  String wonPrize(String prize) {
    return '¡Giraste la ruleta y ganaste $prize!';
  }

  @override
  String get tradeAccepted => '¡Intercambio aceptado!';

  @override
  String get tradeRejected => 'Intercambio rechazado.';

  @override
  String get tradeCompleted => '¡Intercambio completado!';

  @override
  String get tradeRejectedShort => 'Intercambio rechazado.';

  @override
  String get spinPrizeCash50 => '\$50 efectivo';

  @override
  String get spinPrizeCash50Desc => '¡Gana \$50!';

  @override
  String get spinPrizeCash100 => '\$100 efectivo';

  @override
  String get spinPrizeCash100Desc => '¡Gana \$100!';

  @override
  String get spinPrizeCash200 => '\$200 efectivo';

  @override
  String get spinPrizeCash200Desc => '¡Gana \$200!';

  @override
  String get spinPrizeFreeHouse => 'Casa Gratis';

  @override
  String get spinPrizeFreeHouseDesc =>
      '¡Construye una casa gratis en cualquier propiedad!';

  @override
  String get spinPrizeDoubleRent => '2x Alquiler';

  @override
  String get spinPrizeDoubleRentDesc =>
      '¡El próximo alquiler que cobres se duplica!';

  @override
  String get spinPrizeShield => 'Escudo';

  @override
  String get spinPrizeShieldDesc => '¡Sáltate tu próximo pago de alquiler!';

  @override
  String get spinPrizeTeleport => 'Teletransporte';

  @override
  String get spinPrizeTeleportDesc =>
      '¡Muévete a cualquier casilla que elijas!';

  @override
  String get spinPrizeJackpot => '¡PREMIO MAYOR!';

  @override
  String get spinPrizeJackpotDesc => '¡Gana el premio mayor de \$500!';

  @override
  String get luckySpinTitle => '¡GIRO DE LA SUERTE!';

  @override
  String playerTurnToSpin(String name) {
    return '¡Turno de $name para girar!';
  }

  @override
  String get spinInstructions => '¡Toca el centro para girar la ruleta!';

  @override
  String get spinning => 'Girando...';

  @override
  String youWonPrize(String name) {
    return '¡Ganaste $name!';
  }

  @override
  String get collectPrize => '¡Recoger Premio!';

  @override
  String get orTapToSpin => 'O toca aquí para girar';

  @override
  String get goodLuck => '¡Buena suerte!';

  @override
  String get eventMarketBoom => '¡Auge del Mercado!';

  @override
  String get eventMarketBoomDesc =>
      '¡Todas las propiedades valen 20% más por 3 rondas!';

  @override
  String get eventTaxHoliday => '¡Vacaciones Fiscales!';

  @override
  String get eventTaxHolidayDesc => '¡Sin impuestos esta ronda!';

  @override
  String get eventGoldRush => '¡Fiebre del Oro!';

  @override
  String get eventGoldRushDesc =>
      '¡Cobra \$300 en vez de \$200 al pasar por la Salida durante 3 rondas!';

  @override
  String get eventPropertySale => '¡Rebajas de Propiedades!';

  @override
  String get eventPropertySaleDesc =>
      '¡Todas las propiedades sin dueño tienen 25% de descuento por 2 rondas!';

  @override
  String get eventLuckyDay => '¡Día de Suerte!';

  @override
  String get eventLuckyDayDesc => '¡Todos reciben \$50!';

  @override
  String get eventHousingBoom => '¡Boom Inmobiliario!';

  @override
  String get eventHousingBoomDesc => '¡Mejora gratis en una propiedad al azar!';

  @override
  String get eventRentStrike => '¡Huelga de Alquileres!';

  @override
  String get eventRentStrikeDesc =>
      'Todos los alquileres se reducen un 50% por 2 rondas.';

  @override
  String get eventMeteorShower => '¡Lluvia de Meteoritos!';

  @override
  String get eventMeteorShowerDesc => '¡Un jugador al azar pierde \$100!';

  @override
  String get eventCommunityCleanup => 'Limpieza Comunitaria';

  @override
  String get eventCommunityCleanupDesc => 'Paga \$25 por cada casa que tengas.';

  @override
  String get eventStockDividend => 'Dividendo de Acciones';

  @override
  String get eventStockDividendDesc =>
      'Cada jugador recibe \$10 por propiedad que posea.';

  @override
  String get eventBirthdayParty => '¡Fiesta de Cumpleaños!';

  @override
  String get eventBirthdayPartyDesc =>
      '¡El jugador actual cobra \$25 de cada otro jugador!';

  @override
  String get eventBankError => 'Error del Banco';

  @override
  String get eventBankErrorDesc => '¡Un jugador al azar recibe \$200!';

  @override
  String get eventMarketCrash => '¡Caída del Mercado!';

  @override
  String get eventMarketCrashDesc =>
      '¡Los valores de las propiedades fluctúan como locos! ¡Efectos al azar para todos!';

  @override
  String get powerUpRentReducer => 'Reductor de Alquiler';

  @override
  String get powerUpRentReducerDesc =>
      'Paga solo el 50% del alquiler este turno';

  @override
  String get powerUpSpeedBoost => 'Turbo de Velocidad';

  @override
  String get powerUpSpeedBoostDesc => 'Lanza de nuevo después de moverte';

  @override
  String get powerUpPropertyScout => 'Explorador de Propiedades';

  @override
  String get powerUpPropertyScoutDesc =>
      'Ve los precios de todas las propiedades sin dueño';

  @override
  String get powerUpRentCollector => 'Cobrador de Alquileres';

  @override
  String get powerUpRentCollectorDesc => 'Cobra \$50 de cada jugador';

  @override
  String get powerUpPriceFreeze => 'Congelación de Precios';

  @override
  String get powerUpPriceFreezeDesc =>
      'Compra la próxima propiedad al 75% del precio';

  @override
  String get powerUpTeleporter => 'Teletransportador';

  @override
  String get powerUpTeleporterDesc => 'Muévete a cualquier propiedad sin dueño';

  @override
  String get powerUpShield => 'Escudo';

  @override
  String get powerUpShieldDesc => 'Bloquea un pago de alquiler';

  @override
  String get powerUpDoubleDice => 'Dados Dobles';

  @override
  String get powerUpDoubleDiceDesc => 'Lanza con 4 dados, elige los 2 mejores';

  @override
  String get powerUpMoneyMagnet => 'Imán de Dinero';

  @override
  String get powerUpMoneyMagnetDesc =>
      '\$100 extra al pasar por la Salida (3 turnos)';

  @override
  String get powerUpMonopolyMaster => 'Maestro del Monopolio';

  @override
  String get powerUpMonopolyMasterDesc =>
      '¡Casa gratis en todas tus propiedades!';

  @override
  String get powerUpRarityCommon => 'Común';

  @override
  String get powerUpRarityUncommon => 'Poco Común';

  @override
  String get powerUpRarityRare => 'Rara';

  @override
  String get powerUpRarityLegendary => 'Legendaria';

  @override
  String get winnerTitle => '¡GANADOR!';

  @override
  String get gameStats => 'Estadísticas del Juego';

  @override
  String get shopTitle => 'Tienda';

  @override
  String get shopSubtitle => '¡Desbloquea temas, fichas y más!';

  @override
  String get unlocked => 'Desbloqueado';

  @override
  String get free => 'Gratis';

  @override
  String get loadingAd => 'Cargando anuncio...';

  @override
  String adsProgress(int watched, int required) {
    return 'Progreso: ¡$watched/$required anuncios vistos!';
  }

  @override
  String purchaseItem(String name) {
    return '¿Comprar $name?';
  }

  @override
  String unlockFor(String price) {
    return 'Desbloquear por $price';
  }

  @override
  String buyPrice(String price) {
    return 'Comprar $price';
  }

  @override
  String get unlockedExcl => '¡DESBLOQUEADO!';

  @override
  String get awesome => '¡Genial!';

  @override
  String get watchAdsToUnlock => 'Mira anuncios para desbloquear';

  @override
  String watchAdsOrPay(int count) {
    return 'Mira $count anuncios o paga para desbloquear al instante';
  }

  @override
  String watchAdsCount(int count) {
    return 'Mira $count anuncios para desbloquear';
  }

  @override
  String get purchaseToUnlock => 'Compra para desbloquear';

  @override
  String get useThis => 'Usar Este';

  @override
  String get owned => 'Adquirido';

  @override
  String get familyLeaderboard => 'Tabla de Clasificación Familiar';

  @override
  String get rankings => 'Clasificaciones';

  @override
  String get records => 'Récords';

  @override
  String get achievements => 'Logros';

  @override
  String get sortBy => 'Ordenar por: ';

  @override
  String get wins => 'Victorias';

  @override
  String get winPercent => '% Victorias';

  @override
  String get earnings => 'Ganancias';

  @override
  String get games => 'Partidas';

  @override
  String get noPlayersYet => 'Sin jugadores aún';

  @override
  String get playToSeeStats =>
      '¡Juega algunas partidas para ver las estadísticas!';

  @override
  String get mostWins => 'Más Victorias';

  @override
  String get highestCash => 'Mayor Dinero';

  @override
  String get propertyTycoonRecord => 'Magnate Inmobiliario';

  @override
  String get longestWinStreak => 'Mejor Racha de Victorias';

  @override
  String get speedChampion => 'Campeón de Velocidad';

  @override
  String get luckiestRoller => 'El Más Suertudo';

  @override
  String inARow(int count) {
    return '$count seguidos';
  }

  @override
  String turnsCount(int count) {
    return '$count turnos';
  }

  @override
  String avgValue(String value) {
    return '$value de prom.';
  }

  @override
  String get memoryMatchTitle => 'Juego de memoria';

  @override
  String get pairs => 'Parejas';

  @override
  String get timeLabel => 'Tiempo';

  @override
  String secondsShort(int seconds) {
    return '$seconds seg';
  }

  @override
  String get greatJob => '¡Gran trabajo!';

  @override
  String get timeUp => '¡Se acabó el tiempo!';

  @override
  String pairsFound(int found, int total) {
    return 'Parejas encontradas: $found / $total';
  }

  @override
  String scoreAmount(int score) {
    return 'Puntuación: $score';
  }

  @override
  String get quickTapAmazing => '¡INCREÍBLE!';

  @override
  String get quickTapGreat => '¡Genial!';

  @override
  String get quickTapGood => 'Bien';

  @override
  String get quickTapTryAgain => 'Inténtalo de nuevo';

  @override
  String get quickTapInstruction => '¡Toca las monedas! ¡Evita las bombas!';

  @override
  String streakCount(int count) {
    return '¡Racha de $count!';
  }

  @override
  String itemSelected(String name) {
    return '¡$name seleccionado!';
  }

  @override
  String get deletePhotoTitle => '¿Eliminar foto?';

  @override
  String get deletePhotoMessage => 'Esta foto se eliminará de tus avatares.';

  @override
  String get delete => 'Eliminar';

  @override
  String get takePhoto => 'Tomar foto';

  @override
  String get choosePhoto => 'Elegir foto';

  @override
  String get noPhotosYet => 'Aún no hay fotos';

  @override
  String get takeSelfieOrPick => '¡Hazte una selfie o elige de la galería!';

  @override
  String get chooseYourAvatarFancy => '✨ Elige tu avatar ✨';

  @override
  String get avatarCategoryAnimals => 'Animales';

  @override
  String get avatarCategoryFood => 'Comida';

  @override
  String get avatarCategoryObjects => 'Objetos';

  @override
  String get avatarCategoryCharacters => 'Personajes';

  @override
  String get avatarCategoryMyPhotos => 'Mis fotos';

  @override
  String get select => 'Seleccionar';

  @override
  String get countryUSA => 'Estados Unidos';

  @override
  String get countryUK => 'Reino Unido';

  @override
  String get countryFrance => 'Francia';

  @override
  String get countryJapan => 'Japón';

  @override
  String get countryChina => 'República Popular China';

  @override
  String get countryMexico => 'México';

  @override
  String get chooseCity => 'Elige Ciudad';

  @override
  String get cityAtlanticCity => 'Atlantic City';

  @override
  String get cityNewYork => 'Nueva York';

  @override
  String get cityLosAngeles => 'Los Ángeles';

  @override
  String get cityLondon => 'Londres';

  @override
  String get cityEdinburgh => 'Edimburgo';

  @override
  String get cityManchester => 'Mánchester';

  @override
  String get cityParis => 'París';

  @override
  String get cityLyon => 'Lyon';

  @override
  String get cityMarseille => 'Marsella';

  @override
  String get cityTokyo => 'Tokio';

  @override
  String get cityOsaka => 'Osaka';

  @override
  String get cityKyoto => 'Kioto';

  @override
  String get cityBeijing => 'Pekín';

  @override
  String get cityShanghai => 'Shanghái';

  @override
  String get cityHongKong => 'Hong Kong';

  @override
  String get cityMexicoCity => 'Ciudad de México';

  @override
  String get cityGuadalajara => 'Guadalajara';

  @override
  String get cityCancun => 'Cancún';
}
