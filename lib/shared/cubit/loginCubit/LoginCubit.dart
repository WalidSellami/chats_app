
import 'dart:js_interop';

import 'package:bloc/bloc.dart';
import 'package:chat/models/userModel/UserModel.dart';
import 'package:chat/shared/components/Constants.dart';
import 'package:chat/shared/cubit/loginCubit/LoginStates.dart';
import 'package:chat/shared/network/local/CacheHelper.dart';
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

         CacheHelper.saveData(key: 'isGoogleSignIn', value: false);

        emit(SuccessLoginState(value.user?.uid));

    }).catchError((error) {
      if (kDebugMode) {
        print(error.toString());
      }
      emit(ErrorLoginState(error));
    });

  }


  // You have a google account in firestore
  Future<void> signInWithGoogleAccount() async {
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

      var deviceToken = await getDeviceToken();

      FirebaseFirestore.instance.collection('users').doc(value.user?.uid).update({
        'device_token': deviceToken,
      });

      CacheHelper.saveData(key: 'isGoogleSignIn', value: true);


      emit(SuccessGoogleLoginState(value.user?.uid));

    }).catchError((error) {

      emit(ErrorGoogleLoginState(error));
    });
  }



  // You don't have a google account in firestore (the first login with google)
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

      await FirebaseFirestore.instance.collection('users').doc(value.user!.uid).get().then((v) async {

        CacheHelper.saveData(key: 'isGoogleSignIn', value: true);

        if(v.data() == null) {

          userLoginCreate(
            userName: value.user?.displayName,
            phone: value.user?.phoneNumber,
            email: value.user?.email,
            uId: value.user?.uid,
            imageProfile: value.user?.photoURL,
          );

        } else {

          var deviceToken = await getDeviceToken();

          FirebaseFirestore.instance.collection('users').doc(value.user?.uid).update({
            'device_token': deviceToken,
          });


          emit(SuccessGoogleLoginState(value.user?.uid));

        }


      });


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
      imageProfile: imageProfile ?? profile,
      imageCover: cover,
      senders: {},
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