import 'dart:convert';

import 'package:dart_ai_api/ai_service.dart';
import 'package:dart_ai_api/chat_request.dart';
import 'package:dart_ai_api/embed_request.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

void run() async {
  final app = Router();
  final ai = AIService.init();

  app.post('/embed', (Request request) async {
    try {
      final json = await _requestToJson(request);
      ai.embed(EmbedRequest.fromJson(json));
      return Response.ok('embedding saved');
    } catch (err) {
      print(err);
      return Response.internalServerError(body: 'something went wrong');
    }
  });

  app.post('/chat', (Request request) async {
    try {
      final json = await _requestToJson(request);
      final response = await ai.chat(ChatRequest.fromJson(json));
      return Response.ok(response);
    } catch (err) {
      print(err);
      return Response.internalServerError(body: 'something went wrong');
    }
  });

  final server = await io.serve(app, 'localhost', 8080);
  print('Server running on localhost:${server.port}');
}

Future<Map<String, dynamic>> _requestToJson(Request request) async {
  final reqString = await request.readAsString();
  return jsonDecode(reqString);
}
