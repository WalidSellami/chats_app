
import 'package:bloc/bloc.dart';
import 'package:chat/shared/cubit/appCubit/AppCubit.dart';
import 'package:chat/shared/cubit/checkCubit/CheckStates.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:overlay_support/overlay_support.dart';

class CheckCubit extends Cubit<CheckStates> {

  CheckCubit() : super(InitialCheckState());

  static CheckCubit get(context) => BlocProvider.of(context);


  bool hasInternet = false;
  bool isSplashScreen = true;


  void checkConnection(context) {

    InternetConnectionChecker().onStatusChange.listen((status) {

      final isConnected = status == InternetConnectionStatus.connected;

      hasInternet = isConnected;

      (!isSplashScreen) ? showSimpleNotification(
        (hasInternet) ? const Text(
          'You are connected with internet',
          style: TextStyle(
            fontSize: 17.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ) : const Text(
          'You are not connected with internet',
          style: TextStyle(
            fontSize: 17.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: (hasInternet) ? HexColor('158b96') : Colors.red,
      ) : null;

      if(hasInternet) {
        AppCubit.get(context).getUserProfile();
        AppCubit.get(context).getPosts();
        AppCubit.get(context).getAllUsers();
      }

      emit(SuccessCheckState());
    });


  }


  void changeScreen() {
    isSplashScreen = false;
    emit(SuccessChangeScreenState());
  }


}