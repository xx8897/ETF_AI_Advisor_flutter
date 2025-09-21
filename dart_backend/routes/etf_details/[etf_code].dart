import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:excel/excel.dart';

Future<Response> onRequest(RequestContext context, String etfCode) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  // Define the path to the Excel file, relative to the dart_backend directory
  final filePath = '../scripts/data/etf.xlsx';
  final file = File(filePath);

  if (!await file.exists()) {
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: 'Data file not found.',
    );
  }

  // Read the file and decode it using the excel package
  final bytes = await file.readAsBytes();
  final excel = Excel.decodeBytes(bytes);

  // Assume the data is in the first sheet
  final sheetName = excel.tables.keys.first;
  final sheet = excel.tables[sheetName];

  if (sheet == null) {
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: 'Could not find the required sheet in the data file.',
    );
  }

  // Find the row that matches the requested etfCode
  // We assume the first row is the header row
  final headerRow = sheet.rows.first;
  Map<String, dynamic>? etfDetails;

  // Start from the second row to iterate through data
  for (var i = 1; i < sheet.rows.length; i++) {
    final row = sheet.rows[i];
    // Assuming the ETF code is in the first column (index 0)
    final codeCell = row[0];
    if (codeCell != null && codeCell.value.toString().startsWith(etfCode)) {
      etfDetails = {};
      // Map header to row data
      for (var j = 0; j < headerRow.length; j++) {
        final header = headerRow[j]?.value.toString() ?? 'column_$j';
        final cell = row[j];
        // Handle different data types from Excel cells
        etfDetails[header] = cell?.value;
      }
      break; // Found the matching ETF, exit the loop
    }
  }

  if (etfDetails == null) {
    return Response(
      statusCode: HttpStatus.notFound,
      body: 'ETF with code "$etfCode" not found.',
    );
  }

  // Convert CellValue objects to a JSON encodable format (String)
  final encodableEtfDetails = etfDetails.map((key, cellValue) {
    // The .toString() method on CellValue and its subtypes provides a 
    // reasonable string representation for JSON encoding.
    return MapEntry(key, cellValue?.toString());
  });

  return Response.json(body: encodableEtfDetails);
}