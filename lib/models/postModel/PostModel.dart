class PostModel {

  String? text;
  String? userName;
  String? uId;
  String? imageProfile;
  String? tagPost;
  String? datePost;
  dynamic timestamp;
  String? imagePost;
  Map<String , dynamic>? likes;


  PostModel({
    this.text,
    this.userName,
    this.uId,
    this.imageProfile,
    this.tagPost,
    this.datePost,
    this.timestamp,
    this.imagePost,
    this.likes,
});

  PostModel.fromJson(Map<String , dynamic> json) {

    text = json['text'];
    userName = json['user_name'];
    uId = json['uId'];
    imageProfile = json['image_profile'];
    tagPost = json['tag_post'];
    datePost = json['date_time'];
    timestamp = json['timestamp'];
    imagePost = json['image_post'];
    likes = json['likes'];


  }


  Map<String , dynamic> toMap() {

    return {
      'text': text,
      'user_name': userName,
      'uId': uId,
      'image_profile': imageProfile,
      'tag_post': tagPost,
      'date_time': datePost,
      'timestamp': timestamp,
      'image_post': imagePost,
      'likes': likes,

    };

  }


}