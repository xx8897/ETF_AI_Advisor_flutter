import 'dart:io';
import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:excel/excel.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  // 1. Parse the incoming request body
  final requestBody = await context.request.json() as Map<String, dynamic>;
  final portfolio = (requestBody['portfolio'] as List).cast<Map<String, dynamic>>();
  print('[Debug] Received portfolio: $portfolio');

  // 2. Load and parse the Excel data
  final filePath = '../scripts/data/etf.xlsx';
  final bytes = await File(filePath).readAsBytes();
  final excel = Excel.decodeBytes(bytes);
  final sheet = excel.tables[excel.tables.keys.first]!;

  // 3. Create a map for quick lookup of holdings
  final holdingsMap = <String, String>{};
  for (var i = 1; i < sheet.rows.length; i++) {
    final row = sheet.rows[i];
    final etfCode = row[0]?.value.toString().split('.').first ?? '';
    final holdingsStr = row[19]?.value.toString() ?? ''; // '主要持股/持債' is at index 19
    if (etfCode.isNotEmpty) {
      holdingsMap[etfCode] = holdingsStr;
    }
  }
  print('[Debug] Holdings map created with ${holdingsMap.length} entries.');

  // 4. Calculate weighted holdings
  final aggregatedHoldings = <String, double>{};

  for (final etf in portfolio) {
    final etfCodeWithSuffix = etf['etf_code'] as String;
    final etfCode = etfCodeWithSuffix.split('.').first; // Remove .TW suffix
    final allocation = (etf['allocation'] as num).toDouble() / 100.0;
    final holdingsStr = holdingsMap[etfCode];
    print('[Debug] Processing $etfCode with allocation $allocation');

    if (holdingsStr != null) {
      final holdings = _parseHoldings(holdingsStr);
      print('[Debug] Parsed ${holdings.length} holdings for $etfCode');
      for (final holding in holdings) {
        final name = holding['name'] as String;
        final weight = (holding['weight'] as num).toDouble();
        aggregatedHoldings[name] = (aggregatedHoldings[name] ?? 0.0) + (weight * allocation);
      }
    }
  }

  // 5. Sort and format the final list
  final sortedHoldings = aggregatedHoldings.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  
  final result = sortedHoldings.map((entry) {
    return {'name': entry.key, 'weight': double.parse(entry.value.toStringAsFixed(2))};
  }).toList();
  
  print('[Debug] Final aggregated result: $result');

  return Response.json(body: {'portfolio_holdings': result});
}

// Final, robust parser for holdings string, identical to the frontend version
List<Map<String, dynamic>> _parseHoldings(String dataStr) {
  if (!dataStr.contains('%')) return [{'name': dataStr, 'weight': 100.0}];
  
  final items = <Map<String, dynamic>>[];
  // This RegExp is more robust and captures various naming conventions.
  final regex = RegExp(r'([\s\S]+?)\((\d+\.\d+)%\)');
  final matches = regex.allMatches(dataStr);
  
  for (final match in matches) {
    try {
      // Group 1 is the name, which might have leading/trailing whitespace or commas
      final name = match.group(1)!.trim().replaceAll(RegExp(r'^,\s*'), '');
      items.add({
        'name': name,
        'weight': double.parse(match.group(2)!)
      });
    } catch (e) {/* ignore */}
  }
  return items;
}
