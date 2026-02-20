import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_model/marketdata.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_model/market.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_charts/select_chart/purchasedsymbols.dart';
import 'package:freebankingapp/freebankingapp/utils/language_utils.dart';

class ChartApi {

  
 Future<Map<String, dynamic>> purchaseMarketStrategy(
    List<String> marketIds, List<String> strategyIds,String selectedTimeFrame) async {
  final prefs = await SharedPreferences.getInstance();
  final String langCode = LanguageUtils.getLanguageCode();
  final url = Uri.parse("https://cgmember.com/api/purchase-market-strategy");  
  final String? userJson = prefs.getString('user');
  final String? accessToken = prefs.getString('access_token');

  if (userJson == null) {
    return {
      'status': 400,
      'message': 'User data not found in SharedPreferences.'
    };
  }

  if (accessToken == null || accessToken.isEmpty) {
    return {
      'status': 401,
      'message': 'Access token is not available'
    };
  }

  final user = jsonDecode(userJson);
  final String? userId = user['data']['id_user'];

  if (userId == null) {
    return {
      'status': 422,
      'message': 'User ID is null'
    };
  }
 
  // Validate request parameters before sending
  if (marketIds.isEmpty || strategyIds.isEmpty) {
    print('❌ purchaseMarketStrategy Validation Error: marketIds or strategyIds is empty');
    return {
      'status': 422,
      'message': 'Please select a market and a strategy.'
    };
  }

  final request = http.MultipartRequest('POST', url);

  final String marketId = marketIds[0];
  final String strategyId = strategyIds[0];

  print('--- purchaseMarketStrategy Request Params ---');
  print('URL: $url');
  print('marketId: $marketId');
  print('strategyId: $strategyId');
  print('id_user: $userId');
  print('timeframe: $selectedTimeFrame');
  print('Authorization: Bearer $accessToken');
  print('-------------------------------------------');

  request.fields.addAll({
    'marketId': marketId,
    'strategyId': strategyId,
    'id_user': userId,
    'timeframe': selectedTimeFrame,
  });

  request.headers.addAll({
    'Authorization': 'Bearer $accessToken',
    'Content-Type': 'multipart/form-data',
  });

  try {
    final streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.bytesToString();

    print('purchaseMarketStrategy Response body: $responseBody');

    final int statusCode = streamedResponse.statusCode;
    String message;

    try {
      final decoded = jsonDecode(responseBody);
      message = decoded['message'] ?? decoded['error'] ?? 'Unknown response';
    } catch (e) {
      message = 'Failed to decode response body: $responseBody';
    }

    return {
      'status': statusCode,
      'message': message,
    };
  } catch (e) {
    print("Error during API call: $e");
    return {
      'status': 500,
      'message': 'Exception occurred: $e',
    };
  }
}


 
Future<Map<String, dynamic>> fetchMarketData() async {
  final String langCode = LanguageUtils.getLanguageCode();
  final response = await http.get(Uri.parse( "https://cgmember.com/api/json-data/?lang=$langCode"));

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body); 
    Map<String, dynamic> marketDataMap = {
      "data": data.map((item) => MarketData.fromJson(item)).toList()
    };
    return marketDataMap; // Now it matches Future<Map<String, dynamic>>
  } else {
    throw Exception('Failed to load market data');
  }
}
  
  Future<List<PurchasedSymbols>> fetchPurchasedMarkets(String userId, {String? lang}) async {
    final String langCode = lang ?? LanguageUtils.getLanguageCode();
    final url = Uri.parse('https://cgmember.com/api/get_purchased_market/$userId?lang=$langCode');
    final response = await http.get(url); 
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List<dynamic> list = jsonData['status'];
      print('** purchased list url is $url ');
      return list.map((e) => PurchasedSymbols.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch purchased markets');
    }
  }



 

 
  static Future<List<Market>> fetchSymbols() async {
    try {
      final String langCode = LanguageUtils.getLanguageCode();
      var url = Uri.parse("https://cgmember.com/api/market?lang=$langCode");
      var response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // Debug log: check structure of API response
        if (jsonData is List) {
          return jsonData.map((item) => Market.fromJson(item)).toList();
        } else {
          throw Exception("Unexpected response format: ${response.body}");
        }
      } else {
        throw Exception("Failed to load market data: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching market data: $e");
    }
  }
}
