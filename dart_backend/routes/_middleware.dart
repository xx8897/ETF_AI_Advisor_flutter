import 'package:dart_frog/dart_frog.dart';

Handler middleware(Handler handler) {
  return (context) async {
    // Handle preflight requests.
    if (context.request.method == HttpMethod.options) {
      return Response(headers: _corsHeaders);
    }

    // Execute the request handler.
    final response = await handler(context);

    // Add CORS headers to the response.
    return response.copyWith(headers: _corsHeaders);
  };
}

const _corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Origin, Content-Type, X-Auth-Token',
};
