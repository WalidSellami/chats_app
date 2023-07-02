class CommentModel {

  String? text;
  String? userName;
  String? imageProfile;
  String? dateComment;
  dynamic timestamp;
  String? imageComment;


  CommentModel({
    this.text,
    this.userName,
    this.imageProfile,
    this.dateComment,
    this.timestamp,
    this.imageComment,
  });

  CommentModel.fromJson(Map<String , dynamic> json) {

    text = json['text'];
    userName = json['user_name'];
    imageProfile = json['image_profile'];
    dateComment = json['date_time'];
    timestamp = json['timestamp'];
    imageComment = json['image_comment'];


  }


  Map<String , dynamic> toMap() {

    return {
      'text': text,
      'user_name': userName,
      'image_profile': imageProfile,
      'date_time': dateComment,
      'timestamp': timestamp,
      'image_comment': imageComment,

    };

  }


}