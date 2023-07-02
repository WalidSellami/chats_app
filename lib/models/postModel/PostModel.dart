class PostModel {

  String? text;
  String? userName;
  String? uId;
  String? imageProfile;
  bool? like;
  String? tagPost;
  String? datePost;
  dynamic timestamp;
  String? imagePost;


  PostModel({
    this.text,
    this.userName,
    this.uId,
    this.imageProfile,
    this.like,
    this.tagPost,
    this.datePost,
    this.timestamp,
    this.imagePost,
});

  PostModel.fromJson(Map<String , dynamic> json) {

    text = json['text'];
    userName = json['user_name'];
    uId = json['uId'];
    imageProfile = json['image_profile'];
    like = json['like'];
    tagPost = json['tag_post'];
    datePost = json['date_time'];
    timestamp = json['timestamp'];
    imagePost = json['image_post'];


  }


  Map<String , dynamic> toMap() {

    return {
      'text': text,
      'user_name': userName,
      'uId': uId,
      'image_profile': imageProfile,
      'like': like,
      'tag_post': tagPost,
      'date_time': datePost,
      'timestamp': timestamp,
      'image_post': imagePost,

    };

  }


}