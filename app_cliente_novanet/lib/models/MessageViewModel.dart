class Message {
  int? id;
  String? text;
  DateTime? date;
  String? fileUrl; // Nueva propiedad para la URL del archivo
  String? fileName; // Nombre original del archivo
  String? contentType; // Tipo de contenido del archivo (ej. "image/jpeg", "application/pdf")
  String? messageType; // "Text", "File"
  String? senderId;
  String? receiverId;

  Message({
    this.id,
    this.text,
    this.date,
    this.fileUrl,
    this.fileName,
    this.contentType,
    this.messageType,
    this.senderId,
    this.receiverId,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      text: json['text'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      fileUrl: json['fileUrl'],
      fileName: json['fileName'],
      contentType: json['contentType'],
      messageType: json['messageType'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'date': date?.toIso8601String(),
      'fileUrl': fileUrl,
      'fileName': fileName,
      'contentType': contentType,
      'messageType': messageType,
      'senderId': senderId,
      'receiverId': receiverId,
    };
  }
}