# Manual HTTP Implementation for ChromaDB v2 API (Full Snapshot)

This document contains the definitive, correct, and final version of all code modifications required to interact with the ChromaDB v2 API using the `http` package.

**Author**: Dart Backend Engineer
**Date**: 2025-09-21

---

## 1. `pubspec.yaml` (Dependencies)

The `chromadb` package must be **removed** from the dependencies.

```yaml
dependencies:
  dart_frog: ^1.1.0
  http: ^1.2.1
  dotenv: ^4.2.0
```

---

## 2. `recommend.dart` (Full File Content)

The entire file should be replaced with the following code.

### 2.1. Imports

The `chromadb` import must be **removed**.

```dart
import 'dart:convert';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart';
```

### 2.2. `_onPost` Function Implementation

This version includes the multi-step process of fetching the collection UUID before querying.

```dart
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
  const promptTemplate = "YOUR_PROMPT_HERE"; // Placeholder for brevity
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
```
