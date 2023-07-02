
import 'package:bloc/bloc.dart';
import 'package:chat/models/userModel/UserModel.dart';
import 'package:chat/shared/components/Constants.dart';
import 'package:chat/shared/cubit/loginCubit/LoginStates.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginCubit extends Cubit<LoginStates> {

  LoginCubit() : super(InitialLoginState());


  static LoginCubit get(context) => BlocProvider.of(context);


  void userLogin({
    required String email,
    required String password,
}) {

    emit(LoadingLoginState());

    FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password).then((value) async {

         var deviceToken = await getDeviceToken();

         FirebaseFirestore.instance.collection('users').doc(value.user?.uid).update({
           'device_token': deviceToken,
         });

        emit(SuccessLoginState(value.user?.uid));

    }).catchError((error) {
      if (kDebugMode) {
        print(error.toString());
      }
      emit(ErrorLoginState(error));
    });

  }



  Future<void> signInWithGoogle() async {
    emit(LoadingGoogleLoginState());
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    FirebaseAuth.instance.signInWithCredential(credential).then((value) async {


      userLoginCreate(
          userName: value.user?.displayName,
          phone: value.user?.phoneNumber,
          email: value.user?.email,
          uId: value.user?.uid,
          imageProfile: value.user?.photoURL,
      );

      var deviceToken = await getDeviceToken();

      FirebaseFirestore.instance.collection('users').doc(value.user?.uid).update({
        'device_token': deviceToken,
      });

      // emit(SuccessGoogleLoginState(value.user?.uid));

    }).catchError((error) {

      emit(ErrorGoogleLoginState(error));
    });
  }


  void userLoginCreate({
    required String? userName,
    required String? phone,
    required String? email,
    required String? uId,
    String? imageProfile,
  }) async {

    var deviceToken = await getDeviceToken();

    UserModel model = UserModel(
      userName: userName,
      phone: phone ?? '',
      email: email,
      uId: uId,
      bio: 'write your bio ...',
      imageProfile: imageProfile ??
          'https://t4.ftcdn.net/jpg/00/64/67/63/360_F_64676383_LdbmhiNM6Ypzb3FM4PPuFP9rHe7ri8Ju.webp',
      imageCover: 'https://img.freepik.com/free-photo/abstract-textured-backgound_1258-30555.jpg',
      deviceToken: deviceToken,
    );

    FirebaseFirestore.instance.collection('users').doc(uId)
        .set(model.toMap())
        .then((value) {
      emit(SuccessUserLoginCreateLoginState(model));
    }).catchError((error) {
      if (kDebugMode) {
        print('${error.toString()} --> in user login create');
      }
      emit(ErrorUserLoginCreateLoginState(error));
    });
  }
}