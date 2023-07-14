import 'dart:io';

import 'package:bloc/bloc.dart';
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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(InitialAppState());

  static AppCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;

  // List<SalomonBottomBarItem> items = [
  //   SalomonBottomBarItem(
  //     icon: const Icon(EvaIcons.homeOutline, size: 26.0,),
  //     title: const Text(''),
  //     activeIcon: const Icon(EvaIcons.home , size: 28.0,),
  //   ),
  //
  //   SalomonBottomBarItem(
  //     icon: const Icon(EvaIcons.messageCircleOutline, size: 26.0,),
  //     title: const Text(''),
  //     activeIcon:  const Icon(EvaIcons.messageCircle , size: 28.0,),
  //   ),
  //
  //   SalomonBottomBarItem(
  //     icon: const Icon(Icons.add_circle_rounded, size: 35.0,),
  //     title: const Text(''),
  //   ),
  //
  //   SalomonBottomBarItem(
  //     icon: const Icon(EvaIcons.peopleOutline, size: 26.0,),
  //     title: const Text(''),
  //     activeIcon: const Icon(EvaIcons.people, size: 28.0,)
  //   ),
  //
  //   SalomonBottomBarItem(
  //     icon: const Icon(EvaIcons.settingsOutline, size: 26.0,),
  //     title: const Text(''),
  //     activeIcon: const Icon(EvaIcons.settings, size: 28.0,),
  //   ),
  //
  // ];

  List<Widget> screens = [
    const HomeScreen(),
    const ChatScreen(),
    const PostScreen(),
    const UsersScreen(),
    const SettingsScreen(),
  ];

  List<String> titles = [
    'Home' , 'Chat' , '' , 'Users' , 'Settings'
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

      userProfile = UserModel.fromJson(value.data()!);

      numberNotice = 0;

      if((userProfile?.senders)!.isNotEmpty) {

        for(var element in userProfile!.senders!.values) {

          if(element == true) {
            numberNotice++;
          }

        }

      }

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

    firebase_storage.FirebaseStorage.instance.ref().child('users/${Uri.file(imageProfile!.path).pathSegments.last}')
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

    firebase_storage.FirebaseStorage.instance.ref().child('users/${Uri.file(imageCover!.path).pathSegments.last}')
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
      deviceToken: deviceToken,
    );

    FirebaseFirestore.instance.collection('users').doc(uId).update(model.toMap()).then((value) {

      getUserProfile();

      if(imageProfile != null) {
        clearImageProfile();
      } else if(imageCover != null) {
        clearImageCover();
      }

    }).catchError((error) {

      emit(ErrorUpdateUserProfileAppState(error));
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
      like: false,
      tagPost: tag ?? '',
      datePost: date,
      timestamp: timestamp,
      imagePost: imagePost ?? '',
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


        });

        // Comments
        elementPost.reference.collection('comments').snapshots().listen((eventComment) {

          if(eventComment.docs.isNotEmpty) {

            numberComments.addAll({elementPost.id : eventComment.docs.length,});

          } else {

            numberComments.addAll({elementPost.id : 0,});

          }

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



  void deletePost({
    required String postId,
    String? postImage,
}) {
    emit(LoadingDeletePostAppState());
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

       addComment(postId: postId, text: text, date: date , timestamp: timestamp);

      }).catchError((error) {

        emit(ErrorUploadImageCommentAppState(error));
      });

    }).catchError((error) {

      emit(ErrorUploadImageCommentAppState(error));
    });

  }



  List<String> commentsId = [];
  List<CommentModel> comments = [];


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
}) {

    emit(LoadingLikePostAppState());

    UserModel model = UserModel(
      userName: userName,
      imageProfile: imageProfile,
      imageCover: imageCover,
      email: email,
      phone: phone,
      bio: bio,
    );

    FirebaseFirestore.instance.collection('posts').doc(postId).collection('likes').doc(uId).set(model.toMap()).then((value) {

      FirebaseFirestore.instance.collection('posts').doc(postId).update({'like': true});

      emit(SuccessLikePostAppState());
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

      emit(SuccessGetUsersLikesAppState());
    });

  }


  void dislikePost({
    required String postId,
  }) {

    emit(LoadingDisLikePostAppState());
    FirebaseFirestore.instance.collection('posts').doc(postId).collection('likes').doc(uId).delete().then((value) {

      FirebaseFirestore.instance.collection('posts').doc(postId).update({'like': false});

      emit(SuccessDisLikePostAppState());
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

    searchUsers = [];
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
         'senders' : {
           receiverId: false,
         },
      });

          emit(SuccessSendMessageAppState());
    }).catchError((error) {

         emit(ErrorSendMessageAppState(error));
    });


    FirebaseFirestore.instance.collection('users').doc(receiverId).collection('chats')
        .doc(uId).collection('messages').add(model.toMap()).then((value) {

      FirebaseFirestore.instance.collection('users').doc(receiverId).update({
        'senders' : {
          uId: true,
        },
      });

      emit(SuccessSendMessageAppState());
    }).catchError((error) {

      emit(ErrorSendMessageAppState(error));
    });


  }



  List<String> messagesId = [];
  List<MessageModel> messages = [];

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

      FirebaseFirestore.instance.collection('users').doc(uId).update({
        'senders' : {
          receiverId: false,
        },
      });

      numberNotice--;

      emit(SuccessGetMessagesAppState());
    });


  }


  void clearMessages() {
    messages = [];
    emit(SuccessClearAppState());
  }


  void deleteMessage({
    required String receiverId,
    required String messageId,
    String? messageImage,
}) {

    emit(LoadingDeleteMessageAppState());
    FirebaseFirestore.instance.collection('users').doc(uId).collection('chats')
        .doc(receiverId).collection('messages').doc(messageId).delete().then((value) {

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

    // var token = await FirebaseMessaging.instance.getToken();

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


