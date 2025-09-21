import 'dart:convert';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';

// In a real-world scenario, this data would be loaded from a database or a more robust
// data source. For this prototype, we'll read it from the JSON file on each request.
Future<Map<String, dynamic>> _loadEtfData() async {
  final file = File('../etf_dynamic_data.json');
  if (await file.exists()) {
    final content = await file.readAsString();
    return jsonDecode(content) as Map<String, dynamic>;
  }
  return {};
}

Future<Response> onRequest(RequestContext context, String etfCode) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final allData = await _loadEtfData();
  final etfDetails = allData[etfCode];

  if (etfDetails == null) {
    return Response(
      statusCode: HttpStatus.notFound,
      body: 'ETF with code "$etfCode" not found.',
    );
  }

  return Response.json(body: etfDetails);
}
