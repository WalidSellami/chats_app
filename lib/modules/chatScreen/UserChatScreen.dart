import 'dart:io';
import 'package:chat/models/messageModel/MessageModel.dart';
import 'package:chat/models/userModel/UserModel.dart';
import 'package:chat/shared/adaptive/circularIndicator/CircularIndicator.dart';
import 'package:chat/shared/adaptive/circularIndicator/CircularRingIndicator.dart';
import 'package:chat/shared/components/Components.dart';
import 'package:chat/shared/components/Constants.dart';
import 'package:chat/shared/cubit/appCubit/AppCubit.dart';
import 'package:chat/shared/cubit/appCubit/AppStates.dart';
import 'package:chat/shared/cubit/checkCubit/CheckCubit.dart';
import 'package:chat/shared/cubit/checkCubit/CheckStates.dart';
import 'package:chat/shared/cubit/themeCubit/ThemeCubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';

class UserChatScreen extends StatefulWidget {
  final UserModel user;

  const UserChatScreen({super.key, required this.user});

  @override
  State<UserChatScreen> createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  var messageController = TextEditingController();

  var formKey = GlobalKey<FormState>();

  final focusNode = FocusNode();

  bool isVisible = false;

  final  ScrollController scrollController = ScrollController();

  final GlobalKey globalKey = GlobalKey();


  void scrollBottom() {
    if(scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeIn,
      );
    }
  }


  @override
  void dispose() {
    scrollController.dispose();
    messageController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      if (CheckCubit.get(context).hasInternet) {
        AppCubit.get(context)
            .getMessages(receiverId: widget.user.uId.toString());
      }
      return BlocConsumer<CheckCubit, CheckStates>(
        listener: (context, state) {},
        builder: (context, state) {
          var checkCubit = CheckCubit.get(context);

          return BlocConsumer<AppCubit, AppStates>(
            listener: (context, state) {
              if (state is SuccessSendMessageAppState) {
                setState(() {
                  isVisible = false;
                });
                setState(() {
                  messageController.text = '';
                });
                if (AppCubit.get(context).imageMessage != null) {
                  Navigator.pop(context);
                  AppCubit.get(context).clearImageMessage();
                }
              }


              if(state is SuccessGetMessagesAppState) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  scrollBottom();
                });
                AppCubit.get(context).clearNotice(receiverId: widget.user.uId.toString());
              }


              if (state is SuccessGetImageMessageAppState) {
                setState(() {
                  isVisible = true;
                });
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  scrollBottom();
                });
              }

            },
            builder: (context, state) {
              var cubit = AppCubit.get(context);
              var messages = cubit.messages;
              var messageId = cubit.messagesId;
              var receiverMessageId = cubit.receiverMessagesId;

              return WillPopScope(
                onWillPop: () async {
                  cubit.clearMessages();
                  focusNode.unfocus();
                  return true;
                },
                child: Scaffold(
                  appBar: defaultAppBar(
                    onPress: () {
                      cubit.clearMessages();
                      Navigator.pop(context);
                      focusNode.unfocus();
                    },
                    text: '${widget.user.userName}',
                  ),
                  body: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        Expanded(
                          child: (checkCubit.hasInternet)
                              ? ConditionalBuilder(
                                  condition: messages.isNotEmpty,
                                  builder: (context) => Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ListView.separated(
                                        controller: scrollController,
                                        itemBuilder: (context, index) {
                                          if (messages[index].senderId == uId) {
                                            if (messages[index].messageImage != '') {
                                              return buildItemUserSenderMessageWithImage(
                                                  messages[index],
                                                  messageId[index],
                                                  receiverMessageId[index],
                                                  index);
                                            } else {
                                              return buildItemUserSenderMessage(
                                                  messages[index],
                                                  messageId[index],
                                                  receiverMessageId[index],
                                                  index);
                                            }
                                          } else {
                                            if (messages[index].messageImage != '') {
                                              return buildItemUserReceiverMessageWithImage(
                                                  messages[index],
                                                  messageId[index],
                                                  receiverMessageId[index],
                                                  index);
                                            } else {
                                              return buildItemUserReceiverMessage(
                                                  messages[index],
                                                  messageId[index],
                                                  receiverMessageId[index],
                                              );
                                            }
                                          }
                                        },
                                        separatorBuilder: (context, index) =>
                                            const SizedBox(
                                              height: 20.0,
                                            ),
                                        itemCount: messages.length),
                                  ),
                                  fallback: (context) => (state
                                          is LoadingGetMessagesAppState)
                                      ? Center(
                                          child: CircularIndicator(os: getOs()))
                                      : const Center(
                                          child: Text(
                                            'There is no messages',
                                            style: TextStyle(
                                              fontSize: 17.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                )
                              : const Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'No Internet',
                                        style: TextStyle(
                                          fontSize: 19.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 8.0,
                                      ),
                                      Icon(EvaIcons.wifiOffOutline),
                                    ],
                                  ),
                                ),
                        ),
                        if (cubit.imageMessage != null)
                          const SizedBox(
                            height: 25.0,
                          ),
                        if (cubit.imageMessage != null)
                          SizedBox(
                            width: 180.0,
                            height: 220.0,
                            child: Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: GestureDetector(
                                    onTap: () {
                                      showImage(context, 'image', '',
                                          imageUpload: cubit.imageMessage);
                                    },
                                    child: Hero(
                                      tag: 'image',
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8.0,
                                          ),
                                          border: Border.all(
                                            width: 0.0,
                                            color:
                                                ThemeCubit.get(context).isDark
                                                    ? Colors.white
                                                    : Colors.grey.shade900,
                                          ),
                                        ),
                                        clipBehavior:
                                            Clip.antiAliasWithSaveLayer,
                                        child: Image.file(
                                          File(cubit.imageMessage!.path),
                                          width: 160.0,
                                          height: 160.0,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                CircleAvatar(
                                  radius: 20.0,
                                  backgroundColor:
                                      ThemeCubit.get(context).isDark
                                          ? Colors.grey.shade700
                                          : Colors.grey.shade300,
                                  child: IconButton(
                                    onPressed: () {
                                      if (messageController.text == '') {
                                        setState(() {
                                          isVisible = false;
                                        });
                                      }
                                      cubit.clearImageMessage();
                                    },
                                    icon: Icon(
                                      Icons.close_rounded,
                                      color: ThemeCubit.get(context).isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        Material(
                          elevation: 15.0,
                          color: ThemeCubit.get(context).isDark
                              ? HexColor('171717')
                              : Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                if (cubit.imageMessage == null)
                                  InkWell(
                                    borderRadius: BorderRadius.circular(
                                      8.0,
                                    ),
                                    onTap: () {
                                      focusNode.unfocus();
                                      if (checkCubit.hasInternet) {
                                        showModalBottomSheet(
                                            context: context,
                                            builder: (BuildContext context) {
                                              HapticFeedback.vibrate();
                                              return SafeArea(
                                                child: Material(
                                                  color:
                                                      ThemeCubit.get(context).isDark
                                                          ? HexColor('171717')
                                                          : Colors.white,
                                                  child: Wrap(
                                                    children: <Widget>[
                                                      ListTile(
                                                        leading: const Icon(
                                                            Icons.camera_alt),
                                                        title: const Text(
                                                            'Take a new photo'),
                                                        onTap: () async {
                                                          cubit.getImageMessage(
                                                              ImageSource.camera);
                                                          Navigator.pop(context);
                                                        },
                                                      ),
                                                      ListTile(
                                                        leading: const Icon(
                                                            Icons.photo_library),
                                                        title: const Text(
                                                            'Choose from gallery'),
                                                        onTap: () async {
                                                          cubit.getImageMessage(
                                                              ImageSource.gallery);
                                                          Navigator.pop(context);
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            });
                                      } else {
                                        showFlutterToast(
                                            message: 'No Internet Connection',
                                            state: ToastStates.error,
                                            context: context);
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Icon(
                                        Icons.camera_alt_rounded,
                                        size: 28.0,
                                        color:
                                            Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                const SizedBox(
                                  width: 8.0,
                                ),
                                Expanded(
                                  child: TextFormField(
                                    controller: messageController,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null,
                                    focusNode: focusNode,
                                    decoration: InputDecoration(
                                      hintText: 'Write a message ...',
                                      constraints: const BoxConstraints(
                                        maxHeight: 120.0,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          30.0,
                                        ),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      if ((value.isNotEmpty) && (value.trim().isNotEmpty)) {
                                        setState(() {
                                          isVisible = true;
                                        });
                                      } else {
                                        setState(() {
                                          isVisible = false;
                                        });
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  width: 8.0,
                                ),
                                Visibility(
                                  visible: isVisible,
                                  child: ConditionalBuilder(
                                    condition: state is! LoadingSendMessageAppState,
                                    builder: (context) => InkWell(
                                      borderRadius: BorderRadius.circular(
                                        8.0,
                                      ),
                                      onTap: () async {
                                        if (checkCubit.hasInternet) {
                                          if (formKey.currentState!.validate()) {
                                            if (cubit.imageMessage == null) {

                                                cubit.sendMessage(
                                                    senderId: uId,
                                                    receiverId:
                                                    widget.user.uId.toString(),
                                                    messageText:
                                                    messageController.text,
                                                    dateTime: Timestamp.now());

                                                cubit.sendNotification(
                                                    title:
                                                    (cubit.userProfile?.userName)
                                                        .toString(),
                                                    body: messageController.text,
                                                    token: widget.user.deviceToken
                                                        .toString());

                                            } else {

                                              showLoading(context);

                                              cubit.uploadImageMessage(
                                                  senderId: uId,
                                                  receiverId:
                                                      widget.user.uId.toString(),
                                                  messageText:
                                                      messageController.text,
                                                  dateTime: Timestamp.now());

                                              await Future.delayed(const Duration(milliseconds: 800)).then((value) async {
                                                await cubit.sendNotification(
                                                    title:
                                                    (cubit.userProfile?.userName)
                                                        .toString(),
                                                    body: (messageController
                                                        .text.isEmpty)
                                                        ? 'Sent a photo'
                                                        : messageController.text,
                                                    token: widget.user.deviceToken
                                                        .toString());
                                              });

                                            }
                                          }
                                        } else {
                                          showFlutterToast(
                                              message: 'No Internet Connection',
                                              state: ToastStates.error,
                                              context: context);
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Icon(
                                          Icons.send_rounded,
                                          size: 28.0,
                                          color:
                                              Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                    fallback: (context) =>
                                        CircularRingIndicator(os: getOs()),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    });
  }

  Widget buildItemUserSenderMessage(MessageModel model, messageId, receiverMessageId, index) =>
      Align(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onLongPress: () {
            if(CheckCubit.get(context).hasInternet) {
              showRemoveOptions(model.receiverId, messageId, receiverMessageId, model.messageImage);
            } else {
              showFlutterToast(message: 'No Internet Connection', state: ToastStates.error, context: context);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(
              8.0,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(
                  14.0,
                ),
                topRight: Radius.circular(
                  14.0,
                ),
                bottomLeft: Radius.circular(
                  14.0,
                ),
              ),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 240.0,
              ),
              child: Text(
                '${model.messageText}',
                style: const TextStyle(fontSize: 15.0, color: Colors.white),
              ),
            ),
          ),
        ),
      );

  Widget buildItemUserSenderMessageWithImage(
          MessageModel model, messageId, receiverMessageId, index) =>
      GestureDetector(
        onLongPress: () {
          if(CheckCubit.get(context).hasInternet) {
            showRemoveOptions(model.receiverId, messageId, receiverMessageId, model.messageImage);
          } else {
            showFlutterToast(message: 'No Internet Connection', state: ToastStates.error, context: context);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {
                showFullImageAndSave(context, globalKey, index.toString(), model.messageImage);
              },
              child: Hero(
                tag: index.toString(),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(
                        14.0,
                      ),
                      topRight: Radius.circular(
                        14.0,
                      ),
                      bottomLeft: Radius.circular(
                        14.0,
                      ),
                    ),
                    border: Border.all(
                      width: 0.4,
                      color: ThemeCubit.get(context).isDark
                          ? Colors.white
                          : Colors.grey.shade900,
                    ),
                  ),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Image.network(
                    '${model.messageImage}',
                    width: 160.0,
                    height: 160.0,
                    fit: BoxFit.cover,
                    frameBuilder:
                        (context, child, frame, wasSynchronouslyLoaded) {
                      return child;
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      } else {
                        return Container(
                          width: 160.0,
                          height: 160.0,
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 0.2,
                              color: ThemeCubit.get(context).isDark
                                  ? Colors.white
                                  : Colors.grey.shade900,
                            ),
                          ),
                          child:
                              Center(child: CircularRingIndicator(os: getOs())),
                        );
                      }
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 160.0,
                        height: 160.0,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 0.4,
                            color: ThemeCubit.get(context).isDark
                                ? Colors.white
                                : Colors.grey.shade900,
                          ),
                        ),
                        child: const Center(
                            child: Text(
                          'Failed to load',
                          style: TextStyle(
                            fontSize: 13.0,
                          ),
                        )),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 2.0,
            ),
            if (model.messageText != '')
              Container(
                padding: const EdgeInsets.all(
                  8.0,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(
                      14.0,
                    ),
                    topRight: Radius.circular(
                      14.0,
                    ),
                    bottomLeft: Radius.circular(
                      14.0,
                    ),
                  ),
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 240.0,
                  ),
                  child: Text(
                    '${model.messageText}',
                    style: const TextStyle(fontSize: 15.0, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      );

  Widget buildItemUserReceiverMessage(MessageModel model, messageId, receiverMessageId) => Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onLongPress: () {
            if(CheckCubit.get(context).hasInternet) {
              showRemoveOptions(model.receiverId, messageId, receiverMessageId, model.messageImage);
            } else {
              showFlutterToast(message: 'No Internet Connection', state: ToastStates.error, context: context);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(
              8.0,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade700,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(
                  14.0,
                ),
                topRight: Radius.circular(
                  14.0,
                ),
                bottomRight: Radius.circular(
                  14.0,
                ),
              ),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 240.0,
              ),
              child: Text(
                '${model.messageText}',
                style: const TextStyle(fontSize: 15.0, color: Colors.white),
              ),
            ),
          ),
        ),
      );

  Widget buildItemUserReceiverMessageWithImage(
          MessageModel model, messageId, receiverMessageId, index) =>
      GestureDetector(
        onLongPress: () {
          if(CheckCubit.get(context).hasInternet) {
            showRemoveOptions(model.receiverId, messageId, receiverMessageId, model.messageImage);
          } else {
            showFlutterToast(message: 'No Internet Connection', state: ToastStates.error, context: context);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                showFullImageAndSave(context, globalKey , index.toString(), model.messageImage);
              },
              child: Hero(
                tag: index.toString(),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(
                        14.0,
                      ),
                      topRight: Radius.circular(
                        14.0,
                      ),
                      bottomRight: Radius.circular(
                        14.0,
                      ),
                    ),
                    border: Border.all(
                      width: 0.4,
                      color: ThemeCubit.get(context).isDark
                          ? Colors.white
                          : Colors.grey.shade900,
                    ),
                  ),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Image.network(
                    '${model.messageImage}',
                    width: 160.0,
                    height: 160.0,
                    fit: BoxFit.cover,
                    frameBuilder:
                        (context, child, frame, wasSynchronouslyLoaded) {
                      return child;
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      } else {
                        return Container(
                          width: 160,
                          height: 160.0,
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 0.4,
                              color: ThemeCubit.get(context).isDark
                                  ? Colors.white
                                  : Colors.grey.shade900,
                            ),
                          ),
                          child:
                              Center(child: CircularRingIndicator(os: getOs())),
                        );
                      }
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 160.0,
                        height: 160.0,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 0.6,
                            color: ThemeCubit.get(context).isDark
                                ? Colors.white
                                : Colors.grey.shade900,
                          ),
                        ),
                        child: const Center(
                            child: Text(
                          'Failed to load',
                          style: TextStyle(
                            fontSize: 13.0,
                          ),
                        )),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 2.0,
            ),
            if (model.messageText != '')
              Container(
                padding: const EdgeInsets.all(
                  8.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade700,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(
                      14.0,
                    ),
                    topRight: Radius.circular(
                      14.0,
                    ),
                    bottomRight: Radius.circular(
                      14.0,
                    ),
                  ),
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 240.0,
                  ),
                  child: Text(
                    '${model.messageText}',
                    style: const TextStyle(fontSize: 15.0, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      );



  dynamic showRemoveOptions(receiverId, messageId, receiverMessageId, messageImage) {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          HapticFeedback.vibrate();
          focusNode.unfocus();
          return SafeArea(
            child: Material(
              color:
              ThemeCubit.get(context).isDark
                  ? HexColor('171717')
                  : Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      'Who do you want to remove this message for ?',
                      style: TextStyle(
                        fontSize: 12.0,
                      ),
                    ),
                    const SizedBox(
                      height: 4.0,
                    ),
                    ListTile(
                      leading: const Icon(
                          Icons.delete_rounded),
                      title: const Text(
                          'UnSend'),
                      onTap: () async {
                        AppCubit.get(context).deleteMessage(
                            receiverId: receiverId,
                            messageId: messageId,
                            receiverMessageId: receiverMessageId,
                            messageImage: messageImage,
                            isUnSend: true,
                        );
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                          Icons.delete_rounded),
                      title: const Text(
                          'Remove for you'),
                      onTap: () async {
                        AppCubit.get(context).deleteMessage(
                            receiverId: receiverId,
                            messageId: messageId,
                            receiverMessageId: receiverMessageId,
                            messageImage: messageImage,
                        );
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

}
