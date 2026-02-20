
class MarketData {
  late int buffer;
  late bool isFirstTick;
  late String symbol;
  late String timeframe;
  late DateTime timestamp;
  late double twbOpen, twbHigh, twbLow, twbClose;
  late double open, high, low, close;
  late String pivotsSellStrategy1, kcxSymbol;
  late double pivotsBuyStrategy1; 
  late double opLine, mlpLine, ktrPlus1, ktrPlus2, ktrPlus3;
  late double ktrMinus1, ktrMinus2, ktfMinus3, pivot1, pivot2;
  late String pivotColour;
  late double tp1, tp2, tp3;
  late String tp1Colour, tp2Colour, tp3Colour;
  late double wma, ma200, kcx, kcxBlinkBar;
  late String kcxText, ksiText;
  late int kcxBlinkBarCandlesBack;
  late double ksiGreen, ksiRed;
  late String terminatingCharacter;
  late double kcxBuyStrategy2, kcxAddStrategy3; // Changed to double for signal detection

  MarketData.fromList(List<dynamic> data) {
    buffer = int.parse(data[0].toString());
    isFirstTick = int.tryParse(data[1].toString()) == 1;
    symbol = data[2].toString();
    timeframe = data[3].toString();
    timestamp = DateTime.parse(data[4].toString().replaceAll('.', '-') + ":00");

    twbOpen = double.parse(data[5].toString());
    twbHigh = double.parse(data[6].toString());
    twbLow = double.parse(data[7].toString());
    twbClose = double.parse(data[8].toString());
    
    open = double.parse(data[9].toString());
    high = double.parse(data[10].toString());
    low = double.parse(data[11].toString());
    close = double.parse(data[12].toString());

    pivotsBuyStrategy1 = double.parse(data[13].toString()); 
    pivotsSellStrategy1 = data[14].toString();
    kcxSymbol = data[15].toString();

    opLine = double.parse(data[16].toString());
    mlpLine = double.parse(data[17].toString()); // Index 17
    ktrPlus1 = double.parse(data[18].toString()); // Index 18
    ktrPlus2 = double.parse(data[19].toString()); // Index 19
    ktrPlus3 = double.parse(data[20].toString()); // Index 20
    ktrMinus1 = double.parse(data[21].toString()); // Index 21
    ktrMinus2 = double.parse(data[22].toString()); // Index 22
    ktfMinus3 = double.parse(data[23].toString()); // Index 23
    pivot1 = double.parse(data[24].toString());    // Index 24
    pivot2 = double.parse(data[25].toString());    // Index 25

    pivotColour = data[26].toString();
    tp1 = double.parse(data[27].toString());
    tp1Colour = data[28].toString();
    tp2 = double.parse(data[29].toString());
    tp2Colour = data[30].toString();
    tp3 = double.parse(data[31].toString());
    tp3Colour = data[32].toString();

    wma = double.parse(data[33].toString());
    ma200 = double.parse(data[35].toString());

    kcx = double.parse(data[40].toString());
    kcxText = data[41].toString();
    kcxBlinkBar = double.parse(data[42].toString());
    kcxBlinkBarCandlesBack = int.parse(data[43].toString());

    ksiGreen = double.parse(data[44].toString());
    ksiRed = double.parse(data[45].toString());
    ksiText = data[46].toString();

    terminatingCharacter = data[47].toString();

    // Mapping 48 and 49 as doubles for signal logic
    kcxBuyStrategy2 = double.tryParse(data[48].toString()) ?? 0.0;
    kcxAddStrategy3 = double.tryParse(data[49].toString()) ?? 0.0;
  }
  
  double get change => open != 0 ? ((close - open) / open) * 100 : 0;
}
