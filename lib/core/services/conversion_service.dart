import 'dart:async';
import 'dart:convert';

import 'package:coingecko_api/coingecko_api.dart';
import 'package:coingecko_api/coingecko_result.dart';
import 'package:coingecko_api/data/coin.dart';
import 'package:coingecko_api/data/coin_market_data.dart';
import 'package:coingecko_api/data/market_data.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class ConversionService {
  final String _conversionsBox = "conversions";

  static Map<String, double> conversions = <String, double>{};

  ConversionService();

  ConversionService._();

  static final ConversionService _instance = ConversionService._();

  static Future<void>? updateFuture;

  factory ConversionService.getInstance() => _instance;

  Future<void> loadConversionData() async {
    Box box = await Hive.openBox(_conversionsBox);
    box.keys.toList().forEach((element) {
      conversions[element] = box.get(element);
    });
  }

  Future<Map<String, double>> _fetchBsConversions() async {
    final url = Uri.parse('https://api.alcambio.app/graphql');
    final headers = {
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      "operationName": "getCountryConversions",
      "variables": {"countryCode": "VE"},
      "query":
          "query getCountryConversions(\$countryCode: String!) {\n  getCountryConversions(payload: {countryCode: \$countryCode}) {\n    _id\n    baseCurrency {\n      code\n      decimalDigits\n      name\n      rounding\n      symbol\n      symbolNative\n      __typename\n    }\n    country {\n      code\n      dial_code\n      flag\n      name\n      __typename\n    }\n    conversionRates {\n      baseValue\n      official\n      principal\n      rateCurrency {\n        code\n        decimalDigits\n        name\n        rounding\n        symbol\n        symbolNative\n        __typename\n      }\n      rateValue\n      type\n      __typename\n    }\n    dateBcvFees\n    dateParalelo\n    dateBcv\n    createdAt\n    __typename\n  }\n}"
    });
    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode != 200) return <String, double>{};

    final responseBytes = response.bodyBytes;
    final json = jsonDecode(utf8.decode(responseBytes));
    final conversionRates =
        json['data']['getCountryConversions']['conversionRates'];

    return {
      'parallel': 1 / conversionRates[0]['baseValue'],
      'bcv': 1 / conversionRates[1]['baseValue']
    };
  }

  Future<Map<String, double>> _fetchCryptoConversions() async {
    CoinGeckoApi coinGeckoApi = CoinGeckoApi();
    CoinGeckoResult<Coin?> result =
        await coinGeckoApi.coins.getCoinData(id: 'tether');
    if (result.isError || result.data == null) return <String, double>{};
    Coin coin = result.data!;
    CoinMarketData? coinMarketData = coin.marketData;
    if (coinMarketData == null) return <String, double>{};

    List<MarketData> marketData = coinMarketData.dataByCurrency;
    return {
      'usdt': marketData
          .firstWhere((element) => element.coinId == 'usd')
          .currentPrice!
    };
  }

  Future<void> updateConversions() async {
    try {
      Map<String, double> fetchedConversions = {
        ...(await _fetchBsConversions()),
        ...(await _fetchCryptoConversions())
      };
      final Box box = await Hive.openBox(_conversionsBox);
      fetchedConversions.forEach((key, value) {
        box.put(key, value);
        conversions[key] = value;
      });
    } catch (e) {
      print("COULDN'T FETCH CONVERSIONS FROM THE INTERNET");
    }
  }

  double usdToCurrency(double amount, String currency) {
    if (currency == 'usd') {
      return amount;
    }
    if (currency == 'bs') {
      currency = 'bcv';
    }
    if (!conversions.containsKey(currency)) return 0;

    double conversionRate = conversions[currency]!;
    return amount / conversionRate;
  }

  double currencyToUsd(double amount, String currency) {
    if (currency == 'bs') {
      currency = 'bcv';
    }
    return amount * (conversions[currency] ?? 0);
  }

  double fetchRate(String currency) {
    return 1 / (conversions[currency] ?? 0);
  }

  bool hasLoadedRates() {
    return conversions.isNotEmpty;
  }
}
