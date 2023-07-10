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

  late ScrollController scrollController;

  GlobalKey globalKey = GlobalKey();


  void scrollBottom() {
    if(scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // FocusScope.of(context).requestFocus(focusNode);
      scrollBottom();
    });
  }


  @override
  void dispose() {
    scrollController.dispose();
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
                if (AppCubit.get(context).imageMessage != null) {
                  Navigator.pop(context);
                  AppCubit.get(context).clearImageMessage();
                }
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  scrollBottom();
                });
                setState(() {
                  isVisible = false;
                });
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

              return Scaffold(
                appBar: defaultAppBar(
                  onPress: () {
                    // cubit.clearMessages();
                    Navigator.pop(context);
                  },
                  text: '${widget.user.userName}',
                ),
                body: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        Expanded(
                          child: (checkCubit.hasInternet)
                              ? ConditionalBuilder(
                                  condition: messages.isNotEmpty,
                                  builder: (context) => ListView.separated(
                                      controller: scrollController,
                                      itemBuilder: (context, index) {
                                        if (messages[index].senderId == uId) {
                                          if (messages[index].messageImage != '') {
                                            return buildItemUserSenderMessageWithImage(
                                                messages[index],
                                                messageId[index],
                                                index);
                                          } else {
                                            return buildItemUserSenderMessage(
                                                messages[index],
                                                messageId[index],
                                                index);
                                          }
                                        } else {
                                          if (messages[index].messageImage !=
                                              '') {
                                            return buildItemUserReceiverMessageWithImage(
                                                messages[index],
                                                messageId[index],
                                                index);
                                          } else {
                                            return buildItemUserReceiverMessage(
                                                messages[index],
                                                messageId[index]);
                                          }
                                        }
                                      },
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(
                                            height: 20.0,
                                          ),
                                      itemCount: messages.length),
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
                                          width: 150.0,
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
                        Row(
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
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxHeight: 120.0,
                                ),
                                child: TextFormField(
                                  controller: messageController,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  focusNode: focusNode,
                                  decoration: InputDecoration(
                                    hintText: 'Write a message ...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        30.0,
                                      ),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    if (value.isNotEmpty) {
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
                                  onTap: () {
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

                                          cubit.sendNotification(
                                              title:
                                                  (cubit.userProfile?.userName)
                                                      .toString(),
                                              body: (messageController
                                                      .text.isEmpty)
                                                  ? 'Sent a photo'
                                                  : messageController.text,
                                              token: widget.user.deviceToken
                                                  .toString());
                                        }

                                        setState(() {
                                          messageController.text = '';
                                        });
                                      }
                                    } else {
                                      showFlutterToast(
                                          message: 'No Internet Connection',
                                          state: ToastStates.error,
                                          context: context);
                                    }
                                    focusNode.unfocus();
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

  Widget buildItemUserSenderMessage(MessageModel model, messageId, index) =>
      Align(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onLongPress: () {
            showAlert(context, messageId, model.messageImage);
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
                maxWidth: 200.0,
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
          MessageModel model, messageId, index) =>
      GestureDetector(
        onLongPress: () {
          showAlert(context, messageId, model.messageImage);
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
                    width: 120.0,
                    height: 150.0,
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
                          width: 120,
                          height: 150.0,
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
                        width: 120.0,
                        height: 150.0,
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
                    maxWidth: 200.0,
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

  Widget buildItemUserReceiverMessage(MessageModel model, messageId) => Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onLongPress: () {
            showAlert(context, messageId, model.messageImage);
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
                maxWidth: 200.0,
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
          MessageModel model, messageId, index) =>
      GestureDetector(
        onLongPress: () {
          showAlert(context, messageId, model.messageImage);
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
                    width: 120.0,
                    height: 150.0,
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
                          width: 120,
                          height: 150.0,
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
                        width: 120.0,
                        height: 150.0,
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
                    maxWidth: 200.0,
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

  dynamic showAlert(BuildContext context, messageId, messageImage) {
    return showDialog(
      context: context,
      builder: (context) {
        HapticFeedback.vibrate(); // Vibrate the phone
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              14.0,
            ),
          ),
          title: const Text(
            'Do you want to remove this message ?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'No',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                AppCubit.get(context).deleteMessage(
                    receiverId: widget.user.uId.toString(),
                    messageId: messageId,
                    messageImage: messageImage);
                Navigator.pop(context);
              },
              child: Text(
                'Yes',
                style: TextStyle(
                  color: HexColor('f9325f'),
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
