import 'dart:io';

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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class PostCommentScreen extends StatefulWidget {
  final String postId;

  const PostCommentScreen({super.key, required this.postId});

  @override
  State<PostCommentScreen> createState() => _PostCommentScreenState();
}

class _PostCommentScreenState extends State<PostCommentScreen> {
  var textController = TextEditingController();

  final focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    textController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isOut = MediaQuery.of(context).viewInsets.bottom == 0;
    return BlocConsumer<CheckCubit , CheckStates>(
      listener: (context , state) {},
      builder: (context , state) {

        var checkCubit = CheckCubit.get(context);

        return BlocConsumer<AppCubit, AppStates>(
          listener: (context, state) {
            if (state is LoadingUploadImageCommentAppState) {
              showLoading(context);
            }

            if (state is SuccessAddCommentPostAppState) {
              showFlutterToast(
                  message: 'Done with success',
                  state: ToastStates.success,
                  context: context);

              if (AppCubit.get(context).imageComment == null) {
                Navigator.pop(context);
              } else {
                Navigator.pop(context);
                Navigator.pop(context);
                AppCubit.get(context).clearImageComment();
              }
            }

            if (state is ErrorAddCommentPostAppState) {
              showFlutterToast(
                  message: '${state.error}',
                  state: ToastStates.error,
                  context: context);
            }
          },
          builder: (context, state) {
            var cubit = AppCubit.get(context);
            var userProfile = cubit.userProfile;

            return Scaffold(
              appBar: defaultAppBar(
                onPress: () {
                  Navigator.pop(context);
                },
                text: 'Write Comment',
                actions: [
                  if ((textController.text != '') || (cubit.imageComment != null))
                    ConditionalBuilder(
                      condition: state is! LoadingAddCommentPostAppState,
                      builder: (context) => IconButton(
                        onPressed: () {
                          focusNode.unfocus();
                          if(checkCubit.hasInternet) {
                            if (cubit.imageComment == null) {
                              cubit.addComment(
                                  postId: widget.postId,
                                  text: textController.text,
                                  date: DateFormat('dd MMM yyyy \'at\' HH:mm')
                                      .format(DateTime.now()),
                                  timestamp: Timestamp.now(),
                              );
                            } else {
                              cubit.uploadImageComment(
                                  postId: widget.postId,
                                  text: textController.text,
                                  date: DateFormat('dd MMM yyyy \'at\' HH:mm')
                                      .format(DateTime.now()),
                                  timestamp: Timestamp.now(),
                              );
                            }
                          }
                        },
                        icon: Icon(
                          Icons.send_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      fallback: (context) => Padding(
                        padding: const EdgeInsets.only(
                          right: 10.0,
                        ),
                        child: CircularRingIndicator(os: getOs()),
                      ),
                    ),
                ],
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24.0,
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            backgroundImage:
                            NetworkImage('${userProfile?.imageProfile}'),
                          ),
                          const SizedBox(
                            width: 20.0,
                          ),
                          Text(
                            '${userProfile?.userName}',
                            style: const TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 12.0,
                      ),
                      TextFormField(
                        controller: textController,
                        maxLines: 8,
                        focusNode: focusNode,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          hintText: 'Write something ...',
                          suffixIcon: textController.text.isNotEmpty
                              ? CircleAvatar(
                            radius: 20.0,
                            backgroundColor:
                            Theme.of(context).colorScheme.primary,
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  textController.text = '';
                                });
                              },
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                              ),
                            ),
                          )
                              : null,
                          border: InputBorder.none,
                        ),
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      if (cubit.imageComment != null)
                        SizedBox(
                          height: 220.0,
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: GestureDetector(
                                  onTap: () {
                                    focusNode.unfocus();
                                    showImage(context, 'image-comment', '',
                                        imageUpload: cubit.imageComment);
                                  },
                                  child: Hero(
                                    tag: 'image-comment',
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                        border: Border.all(
                                          width: 0.0,
                                          color: ThemeCubit.get(context).isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      child: Image.file(
                                        File(cubit.imageComment!.path),
                                        width: double.infinity,
                                        height: 160.0,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              CircleAvatar(
                                radius: 20.0,
                                backgroundColor: ThemeCubit.get(context).isDark
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade300,
                                child: IconButton(
                                  onPressed: () {
                                    cubit.clearImageComment();
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
                      if (cubit.imageComment != null)
                        const SizedBox(
                          height: 20.0,
                        ),
                      if (cubit.imageComment == null)
                        Visibility(
                          visible: isOut,
                          child: OutlinedButton(
                            style: ButtonStyle(
                                shape: MaterialStatePropertyAll(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      8.0,
                                    ),
                                  ),
                                )),
                            onPressed: () {
                              focusNode.unfocus();
                              if(checkCubit.hasInternet) {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return SafeArea(
                                      child: Material(
                                        color: ThemeCubit.get(context).isDark
                                            ? HexColor('171717')
                                            : Colors.white,
                                        child: Wrap(
                                          children: <Widget>[
                                            ListTile(
                                              leading: const Icon(Icons.camera_alt),
                                              title: const Text('Take a new photo'),
                                              onTap: () async {
                                                cubit.getImageComment(
                                                    ImageSource.camera, context);
                                                Navigator.pop(context);
                                              },
                                            ),
                                            ListTile(
                                              leading:
                                              const Icon(Icons.photo_library),
                                              title:
                                              const Text('Choose from gallery'),
                                              onTap: () async {
                                                cubit.getImageComment(
                                                    ImageSource.gallery, context);
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                              } else {
                                showFlutterToast(message: 'No Internet Connection', state: ToastStates.error, context: context);
                              }
                            },
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  EvaIcons.imageOutline,
                                  size: 26.0,
                                ),
                                Text(
                                  'Add Image',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(
                        height: 20.0,
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
  }
}
