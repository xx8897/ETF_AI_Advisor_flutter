import 'dart:convert';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart';

// --- Main Request Handler ---
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final env = DotEnv(includePlatformEnvironment: true)..load(['../.env']);
  final apiKey = env['OPENAI_API_KEY'];
  if (apiKey == null) {
    return Response(statusCode: HttpStatus.internalServerError, body: 'API Key not found');
  }

  final requestBody = await context.request.json() as Map<String, dynamic>;
  
  try {
    final prompt = _buildDynamicPrompt(requestBody);
    final queryText = _buildChromaQuery(requestBody);
    final retrievedDocs = await _queryChromaDB(apiKey, queryText);
    final llmResponse = await _callOpenAI(apiKey, prompt, retrievedDocs);
    final transformedResponse = _transformAiResponse(llmResponse);
    return Response.json(body: transformedResponse);
  } catch (e) {
    print('Error thrown by handler: $e');
    return Response(statusCode: HttpStatus.internalServerError, body: e.toString());
  }
}

// --- Helper Functions ---

String _buildDynamicPrompt(Map<String, dynamic> dna) {
  final riskProfile = dna['risk_profile'] as String;
  final themeWeights = dna['theme_weights'] as Map<String, dynamic>;
  final filters = dna['filters'] as Map<String, dynamic>;
  final portfolioSize = dna['portfolio_size'] as int;

  var prompt = '你是一位專業、謹慎且值得信賴的台灣ETF投資顧問.\n\n';
  prompt += '請為一位「$riskProfile」風險承受度的投資者，設計一個包含 **$portfolioSize** 檔ETF的投資組合。\n\n';
  prompt += '這位投資者的主要投資偏好如下：\n';
  themeWeights.forEach((theme, weight) {
    prompt += '- $theme: $weight%\n';
  });

  if (filters.isNotEmpty) {
    prompt += '\n在選擇ETF時，請務必遵守以下量化篩選條件：\n';
    filters.forEach((key, value) {
      if (key == 'beta_max') prompt += '- Beta值必須低於 $value\n';
      if (key == 'sharpe_min') prompt += '- 夏普值必須高於 $value\n';
    });
  }

  prompt += '\n請根據以下我提供的多檔ETF資料作為你的知識庫，進行分析與推薦。\n';
  prompt += '你的分析報告必須是嚴格的 JSON 格式，根鍵為 "report"，並包含 "overall_analysis" (String) 和 "portfolio" (一個JSON列表 List<Map<String, dynamic>>)。';
  prompt += '在 portfolio 的每個物件中，必須包含 "ETF代號", "ETF名稱", "配置比例"(數字), "理由" 這幾個鍵。';
  return prompt;
}

String _buildChromaQuery(Map<String, dynamic> dna) {
  final riskProfile = dna['risk_profile'] as String;
  final themeWeights = dna['theme_weights'] as Map<String, dynamic>;
  return '為一位 $riskProfile 的投資者，尋找關於 ${themeWeights.keys.join('、')} 的ETF';
}

Future<String> _queryChromaDB(String apiKey, String queryText) async {
  final httpClient = http.Client();
  try {
    final embeddingResponse = await httpClient.post(
      Uri.parse('https://api.openai.com/v1/embeddings'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $apiKey'},
      body: jsonEncode({'model': 'text-embedding-3-small', 'input': queryText}),
    );
    if (embeddingResponse.statusCode != 200) throw Exception('Failed to get embeddings: ${embeddingResponse.body}');
    
    final embeddingJson = jsonDecode(embeddingResponse.body) as Map<String, dynamic>;
    final queryEmbedding = (embeddingJson['data'][0]['embedding'] as List).cast<double>();

    const collectionName = "etf_collection";
    const tenant = "default_tenant";
    const database = "default_database";
    
    final listCollectionsUri = Uri.parse('http://localhost:8000/api/v2/tenants/$tenant/databases/$database/collections');
    final listCollectionsResponse = await httpClient.get(listCollectionsUri);
    if (listCollectionsResponse.statusCode != 200) throw Exception('Failed to list collections: ${listCollectionsResponse.body}');
    
    final collections = jsonDecode(listCollectionsResponse.body) as List;
    final collection = collections.firstWhere((c) => c['name'] == collectionName, orElse: () => null);
    if (collection == null) throw Exception('Collection "$collectionName" not found.');
    final collectionId = collection['id'] as String;

    final queryUri = Uri.parse('http://localhost:8000/api/v2/tenants/$tenant/databases/$database/collections/$collectionId/query');
    final queryResponse = await httpClient.post(
      queryUri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'query_embeddings': [queryEmbedding], 'n_results': 15}),
    );
    if (queryResponse.statusCode != 200) throw Exception('Failed to query collection v2: ${queryResponse.body}');

    final queryJson = jsonDecode(utf8.decode(queryResponse.bodyBytes)) as Map<String, dynamic>;
    final documents = (queryJson['documents'] as List).expand((list) => list).cast<String>().toList();
    
    return documents.join('\n\n---\n\n');
  } finally {
    httpClient.close();
  }
}

Future<String> _callOpenAI(String apiKey, String prompt, String context) async {
  final openAIClient = http.Client();
  try {
    final response = await openAIClient.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $apiKey'},
      body: jsonEncode({
        'model': 'gpt-4o',
        'messages': [
          {'role': 'system', 'content': prompt},
          {'role': 'user', 'content': '這是知識庫:\n$context\n\n請開始分析並回傳JSON報告。'}
        ],
        'response_format': {'type': 'json_object'},
      }),
    );
    if (response.statusCode == 200) {
      final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
      return responseBody['choices'][0]['message']['content'] as String;
    } else {
      throw Exception('Failed to call OpenAI: ${response.body}');
    }
  } finally {
    openAIClient.close();
  }
}

Map<String, dynamic> _transformAiResponse(String rawResponse) {
  final decoded = jsonDecode(rawResponse) as Map<String, dynamic>;
  final report = decoded['report'] as Map<String, dynamic>;
  final portfolioRaw = report['portfolio'];
  var finalPortfolio = <Map<String, dynamic>>[];

  if (portfolioRaw is List) {
    finalPortfolio = portfolioRaw.cast<Map<String, dynamic>> ();
  } else if (portfolioRaw is Map) {
    portfolioRaw.forEach((key, value) {
      if (value is List) {
        finalPortfolio.addAll(value.cast<Map<String, dynamic>> ());
      } else if (value is Map) {
        // Correctly cast the Map before adding
        finalPortfolio.add(Map<String, dynamic>.from(value));
      }
    });
  }

  final sanitizedPortfolio = finalPortfolio.map((etf) {
    return {
      'etf_code': etf['ETF代號']?.toString() ?? 'N/A',
      'etf_name': etf['ETF名稱']?.toString() ?? 'N/A',
      'allocation': (etf['配置比例'] ?? etf['allocation_percentage'] ?? etf['Allocation'] ?? '0').toString().replaceAll('%', ''),
      'reason': etf['理由']?.toString() ?? etf['rationale']?.toString() ?? 'N/A',
    };
  }).toList();

  report['portfolio'] = sanitizedPortfolio;
  return {'report': report};
}