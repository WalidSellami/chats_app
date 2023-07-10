
import 'package:bloc/bloc.dart';
import 'package:chat/models/userModel/UserModel.dart';
import 'package:chat/shared/components/Constants.dart';
import 'package:chat/shared/cubit/registerCubit/RegisterStates.dart';
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
      imageProfile: 'https://t4.ftcdn.net/jpg/00/64/67/63/360_F_64676383_LdbmhiNM6Ypzb3FM4PPuFP9rHe7ri8Ju.webp',
      imageCover: 'https://img.freepik.com/free-photo/abstract-textured-backgound_1258-30555.jpg',
      senders: {},
      deviceToken: deviceToken,
    );

    FirebaseFirestore.instance.collection('users').doc(uId).set(model.toMap()).then((value) {

      emit(SuccessUserCreateRegisterState(model));

    }).catchError((error) {
      if (kDebugMode) {
        print('${error.toString()} --> in user create');
      }
      emit(ErrorUserCreateRegisterState(error));
    });


  }


}