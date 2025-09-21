import 'dart:convert';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart';

Future<Response> onRequest(RequestContext reqContext) async {
  switch (reqContext.request.method) {
    case HttpMethod.post:
      return _onPost(reqContext);
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _onPost(RequestContext reqContext) async {
  // 1. Parse request body
  final json = await reqContext.request.json() as Map<String, dynamic>;
  final themes = (json['themes'] as List).cast<String>();

  if (themes.isEmpty) {
    return Response(statusCode: HttpStatus.badRequest, body: 'Missing "themes"');
  }

  // 2. Load environment variables
  final env = DotEnv(includePlatformEnvironment: true)..load(['../.env']);
  final apiKey = env['OPENAI_API_KEY'];
  if (apiKey == null) {
    return Response(statusCode: HttpStatus.internalServerError, body: 'API Key not found');
  }

  // 3. Get query embedding from OpenAI
  final openAIClient = http.Client();
  final query = "尋找關於 '${themes.join('、')}' 的高股息或科技類ETF";
  final embeddingResponse = await openAIClient.post(
    Uri.parse('https://api.openai.com/v1/embeddings'),
    headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $apiKey'},
    body: jsonEncode({'model': 'text-embedding-3-small', 'input': query}),
  );
  openAIClient.close();

  if (embeddingResponse.statusCode != 200) {
    return Response(statusCode: HttpStatus.internalServerError, body: 'Failed to get embeddings');
  }
  
  final embeddingJson = jsonDecode(embeddingResponse.body) as Map<String, dynamic>;
  final queryEmbedding = (embeddingJson['data'][0]['embedding'] as List).cast<double>();

  // 4. Get Collection UUID from ChromaDB by name
  final getCollectionClient = http.Client();
  final getCollectionResponse = await getCollectionClient.get(
    Uri.parse('http://localhost:8000/api/v2/tenants/default_tenant/databases/default_database/collections/etf_collection'),
  );
  getCollectionClient.close();

  if (getCollectionResponse.statusCode != 200) {
    return Response(statusCode: HttpStatus.internalServerError, body: 'Failed to get collection details');
  }
  final collectionJson = jsonDecode(getCollectionResponse.body) as Map<String, dynamic>;
  final collectionId = collectionJson['id'] as String;

  // 5. Query ChromaDB using the embedding and UUID
  final queryClient = http.Client();
  final queryResponse = await queryClient.post(
    Uri.parse('http://localhost:8000/api/v2/tenants/default_tenant/databases/default_database/collections/$collectionId/query'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'query_embeddings': [queryEmbedding], 'n_results': 10}),
  );
  queryClient.close();

  if (queryResponse.statusCode != 200) {
    return Response(statusCode: HttpStatus.internalServerError, body: 'Failed to query collection');
  }

  final queryJson = jsonDecode(utf8.decode(queryResponse.bodyBytes)) as Map<String, dynamic>;
  final documents = (queryJson['documents'] as List).expand((list) => list).cast<String>().toList();
  final context = documents.join('\n\n---\n\n');

  // 6. Generate report with OpenAI
  const promptTemplate = """
你是一位專業、謹慎且值得信賴的ETF投資顧問。
使用者的投資偏好是: {themes}
根據以下我提供的多檔ETF資料作為你的知識庫:
---
{context}
---
請為使用者從上述資料中，挑選出 2-3 檔最符合其投資偏好的ETF，並提供一份完整的投資組合建議。
你的分析報告必須包含以下內容：
1.  **整體分析 (overall_analysis)**: 對於為何推薦這個組合的整體說明。
2.  **投資組合 (portfolio)**: 一個包含推薦的ETF的列表。每個ETF項目應包含:
    - `etf_code`: ETF 代號
    - `etf_name`: ETF 名稱
    - `allocation`: 建議的資金配置百分比 (例如 40)
    - `reason`: 推薦此檔ETF的簡短原因
你的回覆必須是嚴格的 JSON 格式，根鍵應為 "report"。
請確保 portfolio 中所有 ETF 的 allocation 總和為 100。
""";
  final prompt = promptTemplate
      .replaceFirst('{themes}', themes.join('、'))
      .replaceFirst('{context}', context);

  final completionClient = http.Client();
  final completionResponse = await completionClient.post(
    Uri.parse('https://api.openai.com/v1/chat/completions'),
    headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $apiKey'},
    body: jsonEncode({
      'model': 'gpt-4o',
      'messages': [{'role': 'user', 'content': prompt}],
      'response_format': {'type': 'json_object'},
    }),
  );
  completionClient.close();

  if (completionResponse.statusCode != 200) {
    return Response(statusCode: HttpStatus.internalServerError, body: 'Failed to get completion');
  }

  // 7. Parse and return the final report
  final completionJson = jsonDecode(utf8.decode(completionResponse.bodyBytes)) as Map<String, dynamic>;
  final reportContent = completionJson['choices'][0]['message']['content'] as String;
  final reportData = jsonDecode(reportContent);

  return Response.json(body: reportData);
}
