import 'package:chat/models/userModel/UserModel.dart';

abstract class LoginStates {}

class InitialLoginState extends LoginStates {}

class LoadingLoginState extends LoginStates {}

class SuccessLoginState extends LoginStates {
  final dynamic uId;
  SuccessLoginState(this.uId);
}

class ErrorLoginState extends LoginStates {
  dynamic error;
  ErrorLoginState(this.error);
}


// Google Account Login
class LoadingGoogleLoginState extends LoginStates {}

class SuccessGoogleLoginState extends LoginStates {
  final dynamic uId;
  SuccessGoogleLoginState(this.uId);
}

class ErrorGoogleLoginState extends LoginStates {
  dynamic error;
  ErrorGoogleLoginState(this.error);
}


class SuccessUserLoginCreateLoginState extends LoginStates {
  final UserModel model;
  SuccessUserLoginCreateLoginState(this.model);
}

class ErrorUserLoginCreateLoginState extends LoginStates {
  dynamic error;
  ErrorUserLoginCreateLoginState(this.error);
}