class Message {
  final String? senderId;
  final String? receiverId;
  final String? text;
  final String? base64Content; // Nuevo campo para imágenes en Base64
  final String? messageType;   // "Text" o "Image"
  final DateTime? date;

  Message({
    this.senderId,
    this.receiverId,
    this.text,
    this.base64Content,
    this.messageType,
    this.date,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      senderId: json['senderId'] as String?,
      receiverId: json['receiverId'] as String?,
      text: json['text'] as String?,
      base64Content: json['base64Content'] as String?,
      messageType: json['messageType'] as String?,
      date: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now().toUtc(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'base64Content': base64Content,
      'messageType': messageType,
      'timestamp': date?.toIso8601String(),
    };
  }
}