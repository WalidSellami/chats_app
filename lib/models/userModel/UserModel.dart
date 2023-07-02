class UserModel {
  String? userName;
  String? phone;
  String? email;
  String? uId;
  String? bio;
  String? imageCover;
  String? imageProfile;
  String? deviceToken;

  UserModel({
    this.userName,
    this.phone,
    this.email,
    this.uId,
    this.bio,
    this.imageCover,
    this.imageProfile,
    this.deviceToken,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
        userName = json['user_name'];
        phone = json['phone'];
        email = json['email'];
        uId = json['uId'];
        bio = json['bio'];
        imageCover = json['image_cover'];
        imageProfile = json['image_profile'];
        deviceToken = json['device_token'];
      }

  Map<String, dynamic> toMap() {
    return {
      'user_name': userName,
      'phone': phone,
      'email': email,
      'uId': uId,
      'bio': bio,
      'image_cover': imageCover,
      'image_profile': imageProfile,
      'device_token' : deviceToken,
    };
  }
}
