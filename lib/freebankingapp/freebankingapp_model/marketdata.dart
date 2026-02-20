import 'dart:convert';

class MarketData {
  final int buffer;
  final int isFirstTick;
  final String symbol;
  final String timeframe;
  final String timestamp;
  final double twbOpen, twbHigh, twbLow, twbClose;
  final double open, high, low, close;
  final int pivotsBuyStrategy1, pivotsSellStrategy1;
  final double opLine, mlpLine;
  final double ktrPlus1, ktrPlus2, ktrPlus3;
  final double ktrMinus1, ktrMinus2, ktfMinus3;
  final double pivot1, pivot2;
  final String pivotColour;
  final double tp1, tp2, tp3;
  final String tp1Colour, tp2Colour, tp3Colour;
  final double wma;
  final int wmaSymbol;
  final double ma200;
  final String gthStart, gthEnd, gth2Start, gth2End;
  final double kcx;
  final String kcxText;
  final double kcxBlinkBar;
  final int kcxBlinkBarCandlesBack;
  final int ksiGreen;
  final double ksiRed;
  final String ksiText;
  final String terminatingCharacter;
  final double kcxBuyStrategy2;
  final double kcxAddStrategy3;
  final int version;
  final int id;
  final String createdAt, updatedAt;

  MarketData({
    required this.buffer,
    required this.isFirstTick,
    required this.symbol,
    required this.timeframe,
    required this.timestamp,
    required this.twbOpen,
    required this.twbHigh,
    required this.twbLow,
    required this.twbClose,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.pivotsBuyStrategy1,
    required this.pivotsSellStrategy1,
    required this.opLine,
    required this.mlpLine,
    required this.ktrPlus1,
    required this.ktrPlus2,
    required this.ktrPlus3,
    required this.ktrMinus1,
    required this.ktrMinus2,
    required this.ktfMinus3,
    required this.pivot1,
    required this.pivot2,
    required this.pivotColour,
    required this.tp1,
    required this.tp2,
    required this.tp3,
    required this.tp1Colour,
    required this.tp2Colour,
    required this.tp3Colour,
    required this.wma,
    required this.wmaSymbol,
    required this.ma200,
    required this.gthStart,
    required this.gthEnd,
    required this.gth2Start,
    required this.gth2End,
    required this.kcx,
    required this.kcxText,
    required this.kcxBlinkBar,
    required this.kcxBlinkBarCandlesBack,
    required this.ksiGreen,
    required this.ksiRed,
    required this.ksiText,
    required this.terminatingCharacter,
    required this.kcxBuyStrategy2,
    required this.kcxAddStrategy3,
    required this.version,
    required this.id,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MarketData.fromJson(Map<String, dynamic> json) {
    return MarketData(
      buffer: json['buffer'],
      isFirstTick: json['is_first_tick'],
      symbol: json['symbol'],
      timeframe: json['timeframe'],
      timestamp: json['timestamp'],
      twbOpen: json['twb_open'].toDouble(),
      twbHigh: json['twb_high'].toDouble(),
      twbLow: json['twb_low'].toDouble(),
      twbClose: json['twb_close'].toDouble(),
      open: json['open'].toDouble(),
      high: json['high'].toDouble(),
      low: json['low'].toDouble(),
      close: json['close'].toDouble(),
      pivotsBuyStrategy1: json['pivots_buy_strategy_1'],
      pivotsSellStrategy1: json['pivots_sell_strategy_1'],
      opLine: json['op_line'].toDouble(),
      mlpLine: json['mlp_line'].toDouble(),
      ktrPlus1: json['ktr_plus_1'].toDouble(),
      ktrPlus2: json['ktr_plus_2'].toDouble(),
      ktrPlus3: json['ktr_plus_3'].toDouble(),
      ktrMinus1: json['ktr_minus_1'].toDouble(),
      ktrMinus2: json['ktr_minus_2'].toDouble(),
      ktfMinus3: json['ktf_minus_3'].toDouble(),
      pivot1: json['pivot_1'].toDouble(),
      pivot2: json['pivot_2'].toDouble(),
      pivotColour: json['pivot_colour'],
      tp1: json['tp1'].toDouble(),
      tp2: json['tp2'].toDouble(),
      tp3: json['tp3'].toDouble(),
      tp1Colour: json['tp1_colour'],
      tp2Colour: json['tp2_colour'],
      tp3Colour: json['tp3_colour'],
      wma: json['wma'].toDouble(),
      wmaSymbol: json['wma_symbol'],
      ma200: json['ma_200'].toDouble(),
      gthStart: json['gth_start'],
      gthEnd: json['gth_end'],
      gth2Start: json['gth2_start'],
      gth2End: json['gth2_end'],
      kcx: json['kcx'].toDouble(),
      kcxText: json['kcx_text'],
      kcxBlinkBar: json['kcx_blink_bar'].toDouble(),
      kcxBlinkBarCandlesBack: json['kcx_blink_bar_candles_back'],
      ksiGreen: json['ksi_green'],
      ksiRed: json['ksi_red'].toDouble(),
      ksiText: json['ksi_text'],
      terminatingCharacter: json['terminating_character'],
      kcxBuyStrategy2: json['kcx_buy_strategy_2'].toDouble(),
      kcxAddStrategy3: json['kcx_add_strategy_3'].toDouble(),
      version: json['__v'],
      id: json['_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  static List<MarketData> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => MarketData.fromJson(json)).toList();
  }
}
