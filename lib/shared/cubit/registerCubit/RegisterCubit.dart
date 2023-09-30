import 'package:chat/models/userModel/UserModel.dart';
import 'package:chat/shared/components/Constants.dart';
import 'package:chat/shared/cubit/registerCubit/RegisterStates.dart';
import 'package:chat/shared/network/local/CacheHelper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterCubit extends Cubit<RegisterStates> {

  RegisterCubit() : super(InitialRegisterState());

  static RegisterCubit get(context) => BlocProvider.of(context);


  void userRegister({
    required String userName,
    required String phone,
    required String email,
    required String password,
}) {

    emit(LoadingRegisterState());

    FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password).then((value) {

        userCreate(userName: userName, phone: phone, email: email, uId: value.user!.uid);

    }).catchError((error) {

      emit(ErrorRegisterState(error));
    });



  }


  void userCreate({
    required String userName,
    required String phone,
    required String email,
    required String uId,
}) async {

    var deviceToken = await getDeviceToken();

    UserModel model = UserModel(
      userName: userName,
      phone: phone,
      email: email,
      uId: uId,
      bio: 'write your bio ...',
      imageProfile: profile,
      imageCover: cover,
      senders: {},
      deviceToken: deviceToken,
    );

    FirebaseFirestore.instance.collection('users').doc(uId).set(model.toMap()).then((value) {

      CacheHelper.saveData(key: 'isGoogleSignIn', value: false).then((value) {
        isGoogleSignIn = false;
      });

      emit(SuccessUserCreateRegisterState(model));

    }).catchError((error) {
      if (kDebugMode) {
        print('${error.toString()} --> in user create');
      }
      emit(ErrorUserCreateRegisterState(error));
    });
  }

}