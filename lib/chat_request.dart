class ChatRequest {
  final String message;

  ChatRequest(this.message);

  factory ChatRequest.fromJson(Map<String, dynamic> json) =>
      ChatRequest(json['message']);
}
