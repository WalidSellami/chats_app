abstract class AppStates {}

class InitialAppState extends AppStates {}

class ChangeBottomNavAppState extends AppStates {}

class ChangeToPostAppState extends AppStates {}

class SuccessClearAppState extends AppStates {}


// Get User Profile
class LoadingGetUserProfileAppState extends AppStates {}

class SuccessGetUserProfileAppState extends AppStates {}

class ErrorGetUserProfileAppState extends AppStates {
  dynamic error;
  ErrorGetUserProfileAppState(this.error);
}


// Get Image Profile
class SuccessGetImageProfileAppState extends AppStates {}

class ErrorGetImageProfileAppState extends AppStates {}


// Get Image Cover
class SuccessGetImageCoverAppState extends AppStates {}

class ErrorGetImageCoverAppState extends AppStates {}


// Update User Profile
class LoadingUpdateUserProfileAppState extends AppStates {}

class SuccessUpdateUserProfileAppState extends AppStates {}

class ErrorUpdateUserProfileAppState extends AppStates {
  dynamic error;
  ErrorUpdateUserProfileAppState(this.error);
}


// Upload Image Profile
class LoadingUploadImageProfileAppState extends AppStates {}

class SuccessUploadImageProfileAppState extends AppStates {}

class ErrorUploadImageProfileAppState extends AppStates {
  dynamic error;
  ErrorUploadImageProfileAppState(this.error);
}



// Upload Image Cover
class LoadingUploadImageCoverAppState extends AppStates {}

class SuccessUploadImageCoverAppState extends AppStates {}

class ErrorUploadImageCoverAppState extends AppStates {
  dynamic error;
  ErrorUploadImageCoverAppState(this.error);
}

// Clear Images
class SuccessClearImageAppStates extends AppStates {}


// Add Post
class LoadingAddPostAppState extends AppStates {}

class SuccessAddPostAppState extends AppStates {}

class ErrorAddPostAppState extends AppStates {
  dynamic error;
  ErrorAddPostAppState(this.error);
}


// Get Image Post
class SuccessGetImagePostAppState extends AppStates {}

class ErrorGetImagePostAppState extends AppStates {}


// Upload Image Post
class LoadingUploadImagePostAppState extends AppStates {}

class SuccessUploadImagePostAppState extends AppStates {}

class ErrorUploadImagePostAppState extends AppStates {
  dynamic error;
  ErrorUploadImagePostAppState(this.error);
}



// Get Posts
class LoadingGetPostsAppState extends AppStates {}

class SuccessGetPostsAppState extends AppStates {}

class ErrorGetPostsAppState extends AppStates {
  dynamic error;
  ErrorGetPostsAppState(this.error);
}



// Delete Post
class LoadingDeletePostAppState extends AppStates {}

class SuccessDeletePostAppState extends AppStates {}

class ErrorDeletePostAppState extends AppStates {
  dynamic error;
  ErrorDeletePostAppState(this.error);
}



// Get Image Comment
class SuccessGetImageCommentAppState extends AppStates {}

class ErrorGetImageCommentAppState extends AppStates {}



// Add Comment Post
class LoadingAddCommentPostAppState extends AppStates {}

class SuccessAddCommentPostAppState extends AppStates {}

class ErrorAddCommentPostAppState extends AppStates {
  dynamic error;
  ErrorAddCommentPostAppState(this.error);
}



// Upload Image Comment
class LoadingUploadImageCommentAppState extends AppStates {}

class SuccessUploadImageCommentAppState extends AppStates {}

class ErrorUploadImageCommentAppState extends AppStates {
  dynamic error;
  ErrorUploadImageCommentAppState(this.error);
}



// Get Comments
class LoadingGetCommentsAppState extends AppStates {}

class SuccessGetCommentsAppState extends AppStates {}

class ErrorGetCommentsAppState extends AppStates {
  dynamic error;
  ErrorGetCommentsAppState(this.error);
}


// Delete Comment Post
class LoadingDeleteCommentPostAppState extends AppStates {}

class SuccessDeleteCommentPostAppState extends AppStates {}

class ErrorDeleteCommentPostAppState extends AppStates {
  dynamic error;
  ErrorDeleteCommentPostAppState(this.error);
}




// Like Post
class LoadingLikePostAppState extends AppStates {}

class SuccessLikePostAppState extends AppStates {}

class ErrorLikePostAppState extends AppStates {
  dynamic error;
  ErrorLikePostAppState(this.error);
}


// DisLike Post
class LoadingDisLikePostAppState extends AppStates {}

class SuccessDisLikePostAppState extends AppStates {}

class ErrorDisLikePostAppState extends AppStates {
  dynamic error;
  ErrorDisLikePostAppState(this.error);
}


// Get All Users
class LoadingGetAllUsersAppState extends AppStates {}

class SuccessGetAllUsersAppState extends AppStates {}

class ErrorGetAllUsersAppState extends AppStates {
  dynamic error;
  ErrorGetAllUsersAppState(this.error);
}


// Search User
class SuccessSearchUserAppState extends AppStates {}



// Send Message
class LoadingSendMessageAppState extends AppStates {}

class SuccessSendMessageAppState extends AppStates {}

class ErrorSendMessageAppState extends AppStates {
  dynamic error;
  ErrorSendMessageAppState(this.error);
}


// Get Messages
class LoadingGetMessagesAppState extends AppStates {}

class SuccessGetMessagesAppState extends AppStates {}

class ErrorGetMessagesAppState extends AppStates {
  dynamic error;
  ErrorGetMessagesAppState(this.error);
}


// Delete Message
class LoadingDeleteMessageAppState extends AppStates {}

class SuccessDeleteMessageAppState extends AppStates {}

class ErrorDeleteMessageAppState extends AppStates {
  dynamic error;
  ErrorDeleteMessageAppState(this.error);
}



// Get Image Message
class SuccessGetImageMessageAppState extends AppStates {}

class ErrorGetImageMessageAppState extends AppStates {}



// Upload Image Message
class LoadingUploadImageMessageAppState extends AppStates {}

class SuccessUploadImageMessageAppState extends AppStates {}

class ErrorUploadImageMessageAppState extends AppStates {
  dynamic error;
  ErrorUploadImageMessageAppState(this.error);
}


class ErrorDeleteMessageImageAppState extends AppStates {
  dynamic error;
  ErrorDeleteMessageImageAppState(this.error);
}

class ErrorDeleteCommentImageAppState extends AppStates {
  dynamic error;
  ErrorDeleteCommentImageAppState(this.error);
}

class ErrorDeletePostImageAppState extends AppStates {
  dynamic error;
  ErrorDeletePostImageAppState(this.error);
}


// Users Likes
class LoadingGetUsersLikesAppState extends AppStates {}

class SuccessGetUsersLikesAppState extends AppStates {}


class SuccessGetNumberNoticeAppState extends AppStates {}

// Send Notification
class SuccessSendNotificationAppState extends AppStates {}



