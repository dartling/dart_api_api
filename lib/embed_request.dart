class EmbedRequest {
  final String title;
  final String body;

  EmbedRequest(this.title, this.body);

  factory EmbedRequest.fromJson(Map<String, dynamic> json) =>
      EmbedRequest(json['title'], json['body']);
}
