import 'package:chat/models/userModel/UserModel.dart';

abstract class RegisterStates {}

class InitialRegisterState extends RegisterStates {}

class LoadingRegisterState extends RegisterStates {}

class ErrorRegisterState extends RegisterStates {
  dynamic error;
  ErrorRegisterState(this.error);
}

class SuccessUserCreateRegisterState extends RegisterStates {
  final UserModel userModel;
  SuccessUserCreateRegisterState(this.userModel);
}

class ErrorUserCreateRegisterState extends RegisterStates {
  dynamic error;
  ErrorUserCreateRegisterState(this.error);
}