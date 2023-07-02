abstract class ResetStates {}

class InitialResetState extends ResetStates {}

class LoadingResetState extends ResetStates {}

class SuccessResetState extends ResetStates {}

class ErrorResetState extends ResetStates {

  dynamic error;
  ErrorResetState(this.error);

}