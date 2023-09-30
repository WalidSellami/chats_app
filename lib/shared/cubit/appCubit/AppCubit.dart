import 'dart:io';
import 'package:chat/models/commentModel/CommentModel.dart';
import 'package:chat/models/messageModel/MessageModel.dart';
import 'package:chat/models/postModel/PostModel.dart';
import 'package:chat/models/userModel/UserModel.dart';
import 'package:chat/modules/chatScreen/ChatScreen.dart';
import 'package:chat/modules/homeScreen/HomeScreen.dart';
import 'package:chat/modules/postScreen/PostScreen.dart';
import 'package:chat/modules/settingsScreen/SettingsScreen.dart';
import 'package:chat/modules/startup/loginScreen/LoginScreen.dart';
import 'package:chat/modules/usersScreen/UsersScreen.dart';
import 'package:chat/shared/components/Components.dart';
import 'package:chat/shared/components/Constants.dart';
import 'package:chat/shared/cubit/appCubit/AppStates.dart';
import 'package:chat/shared/network/local/CacheHelper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(InitialAppState());

  static AppCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;


  List<Widget> screens = [
    const HomeScreen(),
    const ChatScreen(),
    const PostScreen(),
    const UsersScreen(),
    const SettingsScreen(),
  ];

  List<String> titles = [
    'Home' , 'Chats' , '' , 'Users' , 'Settings'
  ];


  void changeBottomNav(int index) {
    if(index == 2) {
      emit(ChangeToPostAppState());
    } else {
      currentIndex = index;
      emit(ChangeBottomNavAppState());
    }
  }


  UserModel? userProfile;

  int numberNotice = 0;

  void getUserProfile() {

    emit(LoadingGetUserProfileAppState());

    FirebaseFirestore.instance.collection('users').doc(uId).snapshots().listen((value) {

      if((value.data() != null) && (value.data()?['uId'] == uId)) {
        userProfile = UserModel.fromJson(value.data()!);
      }


      numberNotice = 0;

      if(((userProfile?.senders)?.length ?? 0) > 0) {

        for(var element in userProfile!.senders!.values) {

          if(element == true) {
            numberNotice++;
          }

        }

      }

      // userProfile?.imageProfile ??= profile;
      // userProfile?.imageCover ??= cover;

      emit(SuccessGetUserProfileAppState());

    });
  }


  var picker = ImagePicker();


  XFile? imageProfile;

  XFile? imageCover;


  Future<void> getImageProfile(ImageSource source , context) async {

    final pickedFile = await picker.pickImage(source: source);

    if(pickedFile != null) {

      imageProfile = pickedFile;
      emit(SuccessGetImageProfileAppState());

    } else {

      showFlutterToast(message: 'No Image selected', state: ToastStates.error, context: context);
      emit(ErrorGetImageProfileAppState());

    }

  }


  Future<void> getImageCover(ImageSource source , context) async {

    final pickedFile = await picker.pickImage(source: source);

    if(pickedFile != null) {

      imageCover = pickedFile;
      emit(SuccessGetImageCoverAppState());

    } else {

      showFlutterToast(message: 'No Image selected', state: ToastStates.error, context: context);
      emit(ErrorGetImageCoverAppState());

    }

  }

  void clearImageProfile() {

    imageProfile = null;
    emit(SuccessClearImageAppStates());

  }

  void clearImageCover() {

    imageCover = null;
    emit(SuccessClearImageAppStates());

  }


  uploadImageProfile({
    required String userName,
    required String bio,
    required String phone,
}) {

    emit(LoadingUploadImageProfileAppState());

    firebase_storage.FirebaseStorage.instance.ref().child('users/$uId/${Uri.file(imageProfile!.path).pathSegments.last}')
        .putFile(File(imageProfile!.path)).then((value) {

       value.ref.getDownloadURL().then((value) {

         updateProfile(userName: userName, bio: bio, phone: phone, imageProfile: value);

       }).catchError((error) {

         if (kDebugMode) {
           print('${error.toString()} --> in upload image profile.');
         }
         emit(ErrorUploadImageProfileAppState(error));
       });
    }).catchError((error) {
      if (kDebugMode) {
        print('${error.toString()} --> in upload image profile in storage.');
      }
      emit(ErrorUploadImageProfileAppState(error));
    });


  }


  uploadImageCover({
    required String userName,
    required String bio,
    required String phone,
  }) {

    emit(LoadingUploadImageCoverAppState());

    firebase_storage.FirebaseStorage.instance.ref().child('users/$uId/${Uri.file(imageCover!.path).pathSegments.last}')
        .putFile(File(imageCover!.path)).then((value) {

      value.ref.getDownloadURL().then((value) {

        updateProfile(userName: userName, bio: bio, phone: phone, imageCover: value);

      }).catchError((error) {

        if (kDebugMode) {
          print('${error.toString()} --> in upload image profile.');
        }
        emit(ErrorUploadImageCoverAppState(error));
      });
    }).catchError((error) {
      if (kDebugMode) {
        print('${error.toString()} --> in upload image profile.');
      }
      emit(ErrorUploadImageCoverAppState(error));
    });


  }




  void updateProfile({
    required String userName,
    required String bio,
    required String phone,
    String? imageCover,
    String? imageProfile,
}) async {

    emit(LoadingUpdateUserProfileAppState());


    var deviceToken = await getDeviceToken();

    UserModel model = UserModel(
      userName: userName,
      bio: bio,
      phone: phone,
      uId: uId ?? userProfile?.uId,
      email: userProfile?.email,
      imageCover: imageCover ?? userProfile?.imageCover,
      imageProfile: imageProfile ?? userProfile?.imageProfile,
      senders: userProfile?.senders ?? {},
      deviceToken: deviceToken,
    );

    FirebaseFirestore.instance.collection('users').doc(uId).update(model.toMap()).then((value) {

      getUserProfile();

    }).catchError((error) {

      emit(ErrorUpdateUserProfileAppState(error));
    });

  }



  List<String> allImagesProfileCover = [];

  void getAllImagesProfileCover() {

    emit(LoadingGetAllImagesProfileCoverAppState());

    firebase_storage.FirebaseStorage.instance.ref().child('users/$uId/').listAll().then((value) {

      allImagesProfileCover = [];

      if(value.items.isNotEmpty) {
        for (var element in value.items) {
          element.getDownloadURL().then((value) {
            allImagesProfileCover.add(value);

            emit(SuccessGetAllImagesProfileCoverAppState());
          }).catchError((error) {
            if (kDebugMode) {
              print('${error
                  .toString()} --> in get image profile (download url).');
            }
            emit(ErrorGetAllImagesProfileCoverAppState(error));
          });
        }
      } else {
        emit(SuccessGetAllImagesProfileCoverAppState());
      }

    }).catchError((error) {

      if (kDebugMode) {
        print('${error.toString()} --> in get all images profile.');
      }
      emit(ErrorGetAllImagesProfileCoverAppState(error));

    });

  }


  void clearImagesProfileCover() {

    allImagesProfileCover = [];
    emit(SuccessClearAppState());

  }


  void deleteImageProfileCover(String image) {

    emit(LoadingDeleteImageProfileCoverAppState());

    String fileName = getFileNameFromUrl(image);

    firebase_storage.FirebaseStorage.instance.ref().child('users/$uId/$fileName').delete().then((value) {

      if(userProfile?.imageProfile == image) {
        FirebaseFirestore.instance.collection('users').doc(uId).update({
          'image_profile': profile,
        });

      } else if(userProfile?.imageCover == image) {
        FirebaseFirestore.instance.collection('users').doc(uId).update({
          'image_cover': cover,
        });

      }

      emit(SuccessDeleteImageProfileCoverAppState());
    }).catchError((error) {

      emit(ErrorDeleteImageProfileCoverAppState(error));
    });


  }

  void changePassword({
    required String oldPassword,
    required String newPassword,
}) async {

    emit(LoadingChangePasswordAppState());

    AuthCredential credential = EmailAuthProvider.credential(
        email: FirebaseAuth.instance.currentUser?.email ?? '',
        password: oldPassword);

    await FirebaseAuth.instance.currentUser?.reauthenticateWithCredential(credential).then((value) async {

      await FirebaseAuth.instance.currentUser?.updatePassword(newPassword);

      emit(SuccessChangePasswordAppState());

    }).catchError((error) {

      if(kDebugMode) {
        print('$error  ---> change password.');
      }

      emit(ErrorChangePasswordAppState(error));
    });

  }



  XFile? imagePost;

  Future<void> getImagePost(ImageSource source , context) async {

    final pickedFile = await picker.pickImage(source: source);

    if(pickedFile != null) {

      imagePost = pickedFile;
      emit(SuccessGetImagePostAppState());

    } else {

      showFlutterToast(message: 'No Image selected', state: ToastStates.error, context: context);
      emit(ErrorGetImagePostAppState());

    }

  }



  void uploadImagePost({
    required String text,
    required String tag,
    required String date,
    required dynamic timestamp,
}) {

    emit(LoadingUploadImagePostAppState());
    firebase_storage.FirebaseStorage.instance.ref().child('posts/${Uri.file(imagePost!.path).pathSegments.last}')
        .putFile(File(imagePost!.path)).then((value) {

       value.ref.getDownloadURL().then((value) {

         addPost(text: text, tag: tag, date: date , imagePost: value , timestamp: timestamp);

       }).catchError((error) {

         emit(ErrorUploadImagePostAppState(error));
       });

    }).catchError((error) {

      emit(ErrorUploadImagePostAppState(error));
    });

  }

  void clearImagePost() {
    imagePost = null;
    emit(SuccessClearImageAppStates());
  }



  void addPost({
    required String text,
    String? tag,
    required String date,
    required dynamic timestamp,
    String? imagePost,
  }) {

    emit(LoadingAddPostAppState());

    PostModel model = PostModel(
      text: text,
      userName: userProfile?.userName,
      uId: uId ?? userProfile?.uId,
      imageProfile: userProfile?.imageProfile,
      tagPost: tag ?? '',
      datePost: date,
      timestamp: timestamp,
      imagePost: imagePost ?? '',
      likes: {},
    );

    FirebaseFirestore.instance.collection('posts').add(model.toMap()).then((value) {

      emit(SuccessAddPostAppState());
    }).catchError((error) {

      if(kDebugMode) {
        print('${error.toString()}  --> in add post.');
      }
      emit(ErrorAddPostAppState(error));
    });



  }



  List<PostModel> posts = [];

  List<String> postsId = [];


  Map<String , dynamic> numberComments = {};

  Map<String , dynamic> numberLikes = {};


  List<String> idFavorites = [];


  void getPosts() {

    emit(LoadingGetPostsAppState());
    FirebaseFirestore.instance.collection('posts').orderBy('timestamp' , descending: true).snapshots().listen((event) {

      posts = [];
      postsId = [];

      // numberComments = {};
      // numberLikes = {};

      for (var elementPost in event.docs) {

        postsId.add(elementPost.id);

        posts.add(PostModel.fromJson(elementPost.data()));


        // Likes
        elementPost.reference.collection('likes').snapshots().listen((eventLike) {

          if(eventLike.docs.isNotEmpty) {

          numberLikes.addAll({elementPost.id: eventLike.docs.length,});

          } else {

            numberLikes.addAll({elementPost.id : 0,});

        }

          emit(SuccessGetPostsAppState());

        });

        // Comments
        elementPost.reference.collection('comments').snapshots().listen((eventComment) {

          if(eventComment.docs.isNotEmpty) {

            numberComments.addAll({elementPost.id : eventComment.docs.length,});

          } else {

            numberComments.addAll({elementPost.id : 0,});

          }

          emit(SuccessGetPostsAppState());

        });

        if((elementPost.data()['uId'] == userProfile?.uId) &&
            ((elementPost.data()['image_profile'] != userProfile?.imageProfile) ||
                (elementPost.data()['user_name'] != userProfile?.userName))) {

          FirebaseFirestore.instance.collection('posts').doc(elementPost.id).update({
            'user_name': userProfile?.userName,
            'image_profile': userProfile?.imageProfile,
          });

        }

      }


      emit(SuccessGetPostsAppState());

    });

  }


  String getFileNameFromUrl(String url) {
    String decodedUrl = Uri.decodeFull(url);
    List<String> pathSegments = Uri.parse(decodedUrl).pathSegments;

    String fileName = pathSegments.last;
    return fileName;
  }


  List<String> commentsId = [];
  List<CommentModel> comments = [];


  void deletePost({
    required String postId,
    String? postImage,
}) {

    emit(LoadingDeletePostAppState());

    if(idFavorites.isNotEmpty || (numberLikes[postId] > 0)) {
      deleteAllLikesForPost(postId: postId);
    }


    if(commentsId.isNotEmpty || (numberComments[postId] > 0)) {
      deleteAllCommentsForPost(postId: postId);
    }

    FirebaseFirestore.instance.collection('posts').doc(postId).delete().then((value) {

      if(postImage != '') {

        String fileName = getFileNameFromUrl(postImage!);

        firebase_storage.FirebaseStorage.instance.ref().child('posts/$fileName').delete().then((value) {

          emit(SuccessClearAppState());
        }).catchError((error) {

          emit(ErrorDeletePostImageAppState(error));
        });
      }

      emit(SuccessDeletePostAppState());
    }).catchError((error) {

      emit(ErrorDeletePostAppState(error));
    });

    }



  void deleteAllLikesForPost({
    required String postId,
  }) {

    emit(LoadingDeleteAllLikesForPostAppState());

    for (var element in idFavorites) {

      FirebaseFirestore.instance.collection('posts').doc(postId).collection('likes').doc(element).delete().then((value) {

        emit(SuccessDeleteAllLikesForPostAppState());

      }).catchError((error) {

        emit(ErrorDeleteAllLikesForPostAppState(error));

      });
    }

  }



  void deleteAllCommentsForPost({
    required String postId,
  }) {

    emit(LoadingDeleteAllCommentsForPostAppState());

    for (var elt in comments) {

      if(elt.imageComment != '') {

        String fileName = getFileNameFromUrl(elt.imageComment!);

        firebase_storage.FirebaseStorage.instance.ref().child('posts/comments/$fileName').delete().then((value) {

          emit(SuccessClearAppState());
        }).catchError((error) {

          emit(ErrorDeleteCommentImageAppState(error));
        });
      }

    }

    for (var element in commentsId) {

      FirebaseFirestore.instance.collection('posts').doc(postId).collection('comments').doc(element).delete().then((value) {

        emit(SuccessDeleteAllCommentsForPostAppState());

      }).catchError((error) {

        emit(ErrorDeleteAllCommentsForPostAppState(error));

      });
    }

  }


  XFile? imageComment;

  Future<void> getImageComment(ImageSource source , context) async {

    final pickedFile = await picker.pickImage(source: source);

    if(pickedFile != null) {

      imageComment = pickedFile;
      emit(SuccessGetImageCommentAppState());

    } else {

      showFlutterToast(message: 'No Image selected', state: ToastStates.error, context: context);
      emit(ErrorGetImageCommentAppState());

    }

  }


  void clearImageComment() {
    imageComment = null;
    emit(SuccessClearImageAppStates());
  }



  void addComment({
    required String postId,
    required String text,
    required String date,
    required dynamic timestamp,
    String? imageComment,
}) {

    emit(LoadingAddCommentPostAppState());

    CommentModel model = CommentModel(
      text: text,
      userName: userProfile?.userName,
      imageProfile: userProfile?.imageProfile,
      dateComment: date,
      imageComment: imageComment ?? '',
      timestamp: timestamp,
    );


    FirebaseFirestore.instance.collection('posts').doc(postId).collection('comments').doc(uId).set(model.toMap()).then((value) {

      emit(SuccessAddCommentPostAppState());
    }).catchError((error) {

      emit(ErrorAddCommentPostAppState(error));
    });


  }



  void uploadImageComment({
    required String postId,
    required String text,
    required String date,
    required dynamic timestamp,
}) {

    emit(LoadingUploadImageCommentAppState());
    firebase_storage.FirebaseStorage.instance.ref().child('posts/comments/${Uri.file(imageComment!.path).pathSegments.last}')
    .putFile(File(imageComment!.path)).then((value) {

      value.ref.getDownloadURL().then((value) {

       addComment(postId: postId, text: text, date: date , timestamp: timestamp, imageComment: value);

      }).catchError((error) {

        emit(ErrorUploadImageCommentAppState(error));
      });

    }).catchError((error) {

      emit(ErrorUploadImageCommentAppState(error));
    });

  }



  void getPostComments({
    required String postId,
}) {

    emit(LoadingGetCommentsAppState());
    FirebaseFirestore.instance.collection('posts').doc(postId).collection('comments').orderBy('timestamp' ,descending: true).snapshots().listen((event) {

      commentsId = [];
      comments = [];

      for(var element in event.docs) {

        commentsId.add(element.id);
        comments.add(CommentModel.fromJson(element.data()));

        if((element.id == uId) &&
            ((element.data()['image_profile'] != userProfile?.imageProfile) ||
                (element.data()['user_name'] != userProfile?.userName))) {

          FirebaseFirestore.instance.collection('posts').doc(postId).collection('comments').doc(uId).update({
            'user_name': userProfile?.userName,
            'image_profile': userProfile?.imageProfile,
          });

        }

      }

      emit(SuccessGetCommentsAppState());

    });


  }



  void deleteComment({
    required String postId,
    required String commentId,
    String? commentImage,
  }) {
    emit(LoadingDeleteCommentPostAppState());
    FirebaseFirestore.instance.collection('posts').doc(postId).collection('comments').doc(commentId).delete().then((value) {

      if(commentImage != '') {

        String fileName = getFileNameFromUrl(commentImage!);

        firebase_storage.FirebaseStorage.instance.ref().child('posts/comments/$fileName').delete().then((value) {

          emit(SuccessClearAppState());
        }).catchError((error) {

          emit(ErrorDeleteCommentImageAppState(error));
        });
      }

      emit(SuccessDeleteCommentPostAppState());
    }).catchError((error) {

      emit(ErrorDeleteCommentPostAppState(error));
    });

  }



  void likePost({
    required String userName,
    required String imageProfile,
    required String imageCover,
    required String email,
    required String phone,
    required String bio,
    required String postId,
}) async {

    emit(LoadingLikePostAppState());

    var deviceToken = await getDeviceToken();

    UserModel model = UserModel(
      userName: userName,
      imageProfile: imageProfile,
      imageCover: imageCover,
      email: email,
      phone: phone,
      bio: bio,
      uId: userProfile?.uId ?? uId,
      deviceToken: userProfile?.deviceToken ?? deviceToken,
      senders: {},
    );

    FirebaseFirestore.instance.collection('posts').doc(postId).collection('likes').doc(uId).set(model.toMap()).then((value) {

      FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'likes.$uId': true,
      });

     getPosts();
    }).catchError((error) {

      emit(ErrorLikePostAppState(error));
    });

  }



  List<UserModel> usersLikes = [];

  void getUsersLikes ({
    required String postId,
}) {

    emit(LoadingGetUsersLikesAppState());
    FirebaseFirestore.instance.collection('posts').doc(postId).collection('likes').orderBy('user_name').snapshots().listen((event) {

      usersLikes = [];

      for(var element in event.docs) {

        idFavorites.add(element.id);
        usersLikes.add(UserModel.fromJson(element.data()));

        if((element.id == uId) &&
            ((element.data()['image_profile'] != userProfile?.imageProfile) ||
                (element.data()['user_name'] != userProfile?.userName))) {

          FirebaseFirestore.instance.collection('posts').doc(postId).collection('likes').doc(uId).update({
            'user_name': userProfile?.userName,
            'image_profile': userProfile?.imageProfile,
          });

        }

      }

      if (kDebugMode) {
        print(idFavorites);
      }

      emit(SuccessGetUsersLikesAppState());
    });

  }


  void dislikePost({
    required String postId,
  }) {

    emit(LoadingDisLikePostAppState());
    FirebaseFirestore.instance.collection('posts').doc(postId).collection('likes').doc(uId).delete().then((value) {

      FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'likes.$uId': false,
      });

      getPosts();
    }).catchError((error) {

      emit(ErrorDisLikePostAppState(error));
    });

  }


  List<UserModel> allUsers = [];

  void getAllUsers() {

    emit(LoadingGetAllUsersAppState());
    FirebaseFirestore.instance.collection('users').snapshots().listen((event) {

      allUsers = [];

      for(var element in event.docs) {

        if(element.data()['uId'] != uId) {

          allUsers.add(UserModel.fromJson(element.data()));

        }

      }

      emit(SuccessGetAllUsersAppState());
    });


  }



  List<UserModel> searchUsers = [];

  void searchUser(String value) {

    searchUsers = allUsers.where((element) =>
      element.userName!.toLowerCase().contains(value.toLowerCase())).toList();

    emit(SuccessSearchUserAppState());

  }


  void clearSearchUser() {

    searchUsers.clear();
    emit(SuccessClearAppState());

  }


  XFile? imageMessage;

  Future<void> getImageMessage(ImageSource source) async {

    final pickedFile = await picker.pickImage(source: source);

    if(pickedFile != null) {

      imageMessage = pickedFile;
      emit(SuccessGetImageMessageAppState());

    } else {

      emit(ErrorGetImageMessageAppState());
    }



  }


  void uploadImageMessage({
    required String senderId,
    required String receiverId,
    String? messageText,
    dynamic dateTime,
}) {

    emit(LoadingUploadImageMessageAppState());
    firebase_storage.FirebaseStorage.instance.ref().child('messages/${Uri.file(imageMessage!.path).pathSegments.last}')
        .putFile(File(imageMessage!.path)).then((value) {

          value.ref.getDownloadURL().then((value) {

            sendMessage(
                senderId: senderId,
                receiverId: receiverId,
                messageText: messageText,
                dateTime: dateTime ,
                messageImage: value);

          }).catchError((error) {

            if (kDebugMode) {
              print('${error.toString()} --> in upload message image.');
            }
            emit(ErrorUploadImageMessageAppState(error));
          });

    }).catchError((error) {

      if (kDebugMode) {
        print('${error.toString()} --> in upload message storage.');
      }
      emit(ErrorUploadImageMessageAppState(error));

    });


  }


  void clearImageMessage() {
    imageMessage = null;
    emit(SuccessClearAppState());
  }


  void sendMessage({
    required String senderId,
    required String receiverId,
    String? messageText,
    String? messageImage,
    dynamic dateTime,
}) {

    emit(LoadingSendMessageAppState());


    MessageModel model = MessageModel(
      senderId: uId,
      receiverId: receiverId,
      messageText: messageText ?? '',
      messageImage: messageImage ?? '',
      dateTime: dateTime,
    );


    FirebaseFirestore.instance.collection('users').doc(uId).collection('chats')
        .doc(receiverId).collection('messages').add(model.toMap()).then((value) {

      FirebaseFirestore.instance.collection('users').doc(uId).update({
         'senders.$receiverId': false,
      });

          emit(SuccessSendMessageAppState());

    }).catchError((error) {

         emit(ErrorSendMessageAppState(error));
    });


      FirebaseFirestore.instance.collection('users').doc(receiverId).collection('chats')
          .doc(uId).collection('messages').add(model.toMap()).then((value) {

        FirebaseFirestore.instance.collection('users').doc(receiverId).update({
          'senders.$uId': true,
        });

        emit(SuccessSendMessageAppState());
      }).catchError((error) {

        emit(ErrorSendMessageAppState(error));
      });



  }



  List<String> messagesId = [];
  List<MessageModel> messages = [];

  List<String> receiverMessagesId = [];



  void getMessages({
    required String receiverId,
}) {

    emit(LoadingGetMessagesAppState());
    FirebaseFirestore.instance.collection('users').doc(uId).collection('chats')
        .doc(receiverId).collection('messages').orderBy('timestamp').snapshots().listen((event) {

      messagesId = [];
      messages = [];


      for(var element in event.docs) {

        messagesId.add(element.id);

        messages.add(MessageModel.fromJson(element.data()));

      }

      emit(SuccessGetMessagesAppState());
    });


    FirebaseFirestore.instance.collection('users').doc(receiverId).collection('chats')
        .doc(uId).collection('messages').orderBy('timestamp').snapshots().listen((event) {

      receiverMessagesId = [];

      for(var element in event.docs) {

        receiverMessagesId.add(element.id);

      }

      emit(SuccessGetReceiverMessagesAppState());
    });


  }


  void clearNotice({
    required String receiverId,
}) {
    FirebaseFirestore.instance.collection('users').doc(uId).update({
     'senders.$receiverId': false,
    });

    numberNotice--;
    emit(SuccessClearAppState());
  }


  void clearMessages() {
    messages.clear();
    emit(SuccessClearAppState());
  }


  void deleteMessage({
    required String receiverId,
    required String messageId,
    required String receiverMessageId,
    String? messageImage,
    bool isUnSend = false,
}) {

    emit(LoadingDeleteMessageAppState());

    FirebaseFirestore.instance.collection('users').doc(uId).collection('chats')
        .doc(receiverId).collection('messages').doc(messageId).delete().then((value) {

          if(isUnSend) {
            FirebaseFirestore.instance.collection('users').doc(receiverId).collection('chats')
                .doc(uId).collection('messages').doc(receiverMessageId).delete().then((value) {
               emit(SuccessClearAppState());
            });
          }

        if(messageImage != '') {

          String fileName = getFileNameFromUrl(messageImage!);

          firebase_storage.FirebaseStorage.instance.ref().child('messages/$fileName').delete().then((value) {

            emit(SuccessClearAppState());

          }).catchError((error) {

            emit(ErrorDeleteMessageImageAppState(error));

          });

        }


      emit(SuccessDeleteMessageAppState());
    }).catchError((error) {

      if (kDebugMode) {
        print('${error.toString()} --> in delete message.');
      }
      emit(ErrorDeleteMessageAppState(error));
    });

  }




  void saveUserAccount({
    required String userName,
    required String email,
    required String imageProfile,
}) async {

    emit(LoadingSaveUserAccountAppState());

    var deviceToken = await getDeviceToken();

    bool isGoogleSignIn = CacheHelper.getData(key: 'isGoogleSignIn');

    FirebaseFirestore.instance.collection('saved').doc(uId).set({
      'user_name': userName,
      'email': email,
      'image_profile': imageProfile,
      'isGoogleSignIn': isGoogleSignIn,
      'device_token': deviceToken,
    }).then((value) {

      emit(SuccessSaveUserAccountAppState());
    }).catchError((error) {
      if (kDebugMode) {
        print('${error.toString()} --> in save user account');
      }
      emit(ErrorSaveUserAccountAppState(error));
    });

  }



  List<String> accountsSavedId = [];
  List<dynamic> accountsSaved = [];

  void getUserAccounts(context) async {

    emit(LoadingGetUserAccountsAppState());

    var deviceToken = await getDeviceToken();

    FirebaseFirestore.instance.collection('saved').snapshots().listen((value) {

      accountsSavedId = [];
      accountsSaved = [];

      for(var element in value.docs) {

        if(element.data()['device_token'] == deviceToken) {

          accountsSavedId.add(element.id);
          accountsSaved.add(element.data());

        }

      }

      if(accountsSaved.isEmpty) {
        CacheHelper.removeData(key: 'isSaved');
        CacheHelper.removeData(key: 'isGoogleSignIn');
        navigateAndNotReturn(context: context, screen: const LoginScreen());
      }

      emit(SuccessGetUserAccountsAppState());
    });


  }


  void deleteUserAccount({
    required String userAccountId,
}) async {

    emit(LoadingDeleteUserAccountAppState());

    FirebaseFirestore.instance.collection('saved').doc(userAccountId).delete().then((value) {

      emit(SuccessDeleteUserAccountAppState());
    }).catchError((error) {

      emit(ErrorDeleteUserAccountAppState(error));
    });


  }





  // Notifications

  Future<void> sendNotification({
    required String title,
    required String body,
    required String token,
}) async {

    const url = 'https://fcm.googleapis.com/fcm/send';

    final data = {
      "data": {
        "title": title,
        "message": body,
        "sound": "default",
        "type": "order",
        "click_action": "FLUTTER_NOTIFICATION_CLICK"
      },
      "to": token,
    };

    Dio dio = Dio();

    dio.options.headers['Content-Type'] = 'application/json';
    dio.options.headers['Authorization'] = 'key=AAAAhpMbiCg:APA91bETZa252Vzu-_hXpBetH73vjJCG7QcaQ5Ig29zeCkWrbHy347zfaIh_NftyYhhR2VIAVZqwmSjh9_gfuXZVAfSh_g9ArJ_IhU61koeBantDB_bYkyK3fh_eFHf4zk77aqLbiykc';

    await dio.post(url , data: data);

    emit(SuccessSendNotificationAppState());

  }



}


