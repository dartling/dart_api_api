import 'package:dart_ai_api/chat_request.dart';
import 'package:dart_ai_api/embed_request.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:supabase/supabase.dart';

class AIService {
  static const _openAiKey = "SECRET";
  static const _supabaseUrl = "http://localhost:54321";
  static const _supabaseKey = "SECRET";

  final OpenAI openAi;
  final SupabaseClient supabase;

  factory AIService.init() {
    OpenAI.apiKey = _openAiKey;
    final supabase = SupabaseClient(_supabaseUrl, _supabaseKey);
    return AIService(OpenAI.instance, supabase);
  }

  AIService(this.openAi, this.supabase);

  void embed(EmbedRequest request) async {
    final response = await openAi.embedding.create(
      model: "text-embedding-ada-002",
      input: request.body,
    );
    final embedding = response.data.first.embeddings;
    await supabase.from("documents").insert({
      "title": request.title,
      "body": request.body,
      "embedding": embedding,
    });
  }

  Future<String> chat(ChatRequest request) async {
    // create an embedding of the message to perform similarity search
    final embeddingResponse = await openAi.embedding.create(
      model: "text-embedding-ada-002",
      input: request.message,
    );
    final embedding = embeddingResponse.data.first.embeddings;

    // retrieve up to 5 most similar documents to include in chat system prompt
    final results = await supabase.rpc('match_documents', params: {
      'query_embedding': embedding,
      'match_threshold': 0.8,
      'match_count': 5,
    });

    // combine document content together
    var context = '';
    for (var document in results) {
      document as Map<String, dynamic>;
      final content = document['body'] as String;
      context += '$content\n---\n';
    }

    final prompt = """
      You are a helpful AI assistant.
      Given the following sections, answer any user questions by
      using only that information.
      If you are unsure and the answer is not explicitly written in
      the sections below, say "Sorry, I can't help you with that."

      Context sections:
      $context
    """;

    final chatResponse =
        await openAi.chat.create(model: 'gpt-3.5-turbo', messages: [
      OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.system, content: prompt),
      OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.user, content: request.message),
    ]);
    return chatResponse.choices.first.message.content;
  }
}
