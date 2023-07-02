class MessageModel {

  String? senderId;
  String? messageText;
  String? messageImage;
  String? receiverId;
  dynamic dateTime;


  MessageModel({
    this.senderId,
    this.messageText,
    this.messageImage,
    this.receiverId,
    this.dateTime
});


  MessageModel.fromJson(Map<String , dynamic> json) {
    senderId = json['sender_id'];
    messageText = json['message_text'];
    messageImage = json['message_image'];
    receiverId = json['receiver_id'];
    dateTime = json['timestamp'];

  }


  Map<String , dynamic> toMap() {

    return {
      'sender_id': senderId,
      'message_text': messageText,
      'message_image': messageImage,
      'receiver_id': receiverId,
      'timestamp': dateTime,

    };

  }



}