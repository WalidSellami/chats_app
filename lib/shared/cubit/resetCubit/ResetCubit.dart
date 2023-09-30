import 'package:chat/shared/cubit/resetCubit/ResetStates.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ResetCubit extends Cubit<ResetStates> {

  ResetCubit() : super(InitialResetState());

  static ResetCubit get(context) => BlocProvider.of(context);


  void resetPassword({
    required String email,
}) {

    emit(LoadingResetState());

    FirebaseAuth.instance.sendPasswordResetEmail(
        email: email).then((value) {

     emit(SuccessResetState());

    }).catchError((error) {

      emit(ErrorResetState(error));
    });


  }


}