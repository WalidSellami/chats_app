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



// Verify Email
class LoadingVerifyEmailRegisterState extends RegisterStates {}

class SuccessVerifyEmailRegisterState extends RegisterStates {}

class ErrorVerifyEmailRegisterState extends RegisterStates {
  dynamic error;
  ErrorVerifyEmailRegisterState(this.error);
}



// Auto Verified Email
class LoadingAutoVerifiedEmailRegisterState extends RegisterStates {}

class SuccessAutoVerifiedEmailRegisterState extends RegisterStates {}


// Delete User
class LoadingDeleteUserRegisterState extends RegisterStates {}

class SuccessDeleteUserRegisterState extends RegisterStates {}

class ErrorDeleteUserRegisterState extends RegisterStates {
  dynamic error;
  ErrorDeleteUserRegisterState(this.error);
}