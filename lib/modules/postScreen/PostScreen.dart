import 'dart:io';

import 'package:chat/shared/adaptive/circularIndicator/CircularRingIndicator.dart';
import 'package:chat/shared/components/Components.dart';
import 'package:chat/shared/components/Constants.dart';
import 'package:chat/shared/cubit/appCubit/AppCubit.dart';
import 'package:chat/shared/cubit/appCubit/AppStates.dart';
import 'package:chat/shared/cubit/checkCubit/CheckCubit.dart';
import 'package:chat/shared/cubit/checkCubit/CheckStates.dart';
import 'package:chat/shared/cubit/themeCubit/ThemeCubit.dart';
import 'package:chat/shared/cubit/themeCubit/ThemeStates.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  var textController = TextEditingController();
  var tagController = TextEditingController();


  final focusNode1 = FocusNode();
  final focusNode2 = FocusNode();

  @override
  void initState() {
    super.initState();
    textController.addListener(() {
      setState(() {});
    });
    tagController.addListener(() {
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

        return BlocConsumer<ThemeCubit, ThemeStates>(
          listener: (context, state) {},
          builder: (context, state) {
            var themeCubit = ThemeCubit.get(context);

            return BlocConsumer<AppCubit, AppStates>(
              listener: (context, state) {
                if (state is LoadingUploadImagePostAppState) {
                  showLoading(context);
                }

                if (state is SuccessAddPostAppState) {
                  showFlutterToast(
                      message: 'Done with success',
                      state: ToastStates.success,
                      context: context);
                  AppCubit.get(context).currentIndex = 0;
                  if(AppCubit.get(context).imagePost == null) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    AppCubit.get(context).clearImagePost();
                  }
                }

                if(state is ErrorAddPostAppState) {

                  showFlutterToast(message: '${state.error}', state: ToastStates.error, context: context);

                }
              },
              builder: (context, state) {
                var cubit = AppCubit.get(context);
                var userProfile = cubit.userProfile;

                return LayoutBuilder(
                  builder: (context, constraints) {
                    return Scaffold(
                      appBar: defaultAppBar(
                          text: 'Add Post',
                          onPress: () {
                            Navigator.pop(context);
                          },
                          actions: [
                            if ((textController.text != '') ||
                                (cubit.imagePost != null))
                              ConditionalBuilder(
                                condition: state is! LoadingAddPostAppState,
                                builder: (context) => IconButton(
                                  onPressed: () {
                                    if(checkCubit.hasInternet) {
                                      if (cubit.imagePost == null) {
                                        cubit.addPost(
                                            text: textController.text,
                                            tag: tagController.text,
                                            date: DateFormat(
                                                'dd MMM yyyy \'at\' HH:mm')
                                                .format(DateTime.now()),
                                            timestamp: Timestamp.now(),
                                        );
                                      } else {
                                        cubit.uploadImagePost(
                                            text: textController.text,
                                            tag: tagController.text,
                                            date: DateFormat(
                                                'dd MMM yyyy \'at\' HH:mm')
                                                .format(DateTime.now()),
                                            timestamp: Timestamp.now(),
                                        );
                                      }
                                    } else {
                                      showFlutterToast(message: 'No Internet Connection', state: ToastStates.error, context: context);
                                    }

                                    focusNode1.unfocus();
                                    focusNode2.unfocus();
                                  },
                                  icon: Icon(
                                    EvaIcons.plusSquareOutline,
                                    size: 28.0,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  tooltip: 'Add Post',
                                ),
                                fallback: (context) => Padding(
                                  padding: const EdgeInsets.only(
                                    right: 10.0,
                                  ),
                                  child: CircularRingIndicator(os: getOs()),
                                ),
                              ),
                            const SizedBox(
                              width: 6.0,
                            ),
                          ]),
                      body: SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 24.0,
                                        backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                        backgroundImage: NetworkImage(
                                            '${userProfile?.imageProfile}'),
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
                                    maxLines: 14,
                                    focusNode: focusNode1,
                                    keyboardType: TextInputType.multiline,
                                    decoration: InputDecoration(
                                      hintText: 'Write something ...',
                                      suffixIcon: textController.text.isNotEmpty
                                          ? CircleAvatar(
                                        radius: 20.0,
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        child: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              textController.text = '';
                                              tagController.text = '';
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
                                  if (textController.text.isNotEmpty)
                                    TextFormField(
                                      controller: tagController,
                                      maxLines: 5,
                                      focusNode: focusNode2,
                                      keyboardType: TextInputType.multiline,
                                      decoration: InputDecoration(
                                        hintText:
                                        'Add tag or tags if you want (start with #) ...',
                                        suffixIcon: tagController.text.isNotEmpty
                                            ? CircleAvatar(
                                          radius: 20.0,
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          child: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                tagController.text = '';
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
                                  if (cubit.imagePost != null)
                                    SizedBox(
                                      height: 220.0,
                                      child: Stack(
                                        alignment: Alignment.topRight,
                                        children: [
                                          Align(
                                            alignment: Alignment.center,
                                            child: GestureDetector(
                                              onTap: () {
                                                focusNode1.unfocus();
                                                focusNode2.unfocus();
                                                showImage(
                                                    context, 'image-post', '',
                                                    imageUpload: cubit.imagePost);
                                              },
                                              child: Hero(
                                                tag: 'image-post',
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                      8.0,
                                                    ),
                                                    border: Border.all(
                                                      width: 0.0,
                                                      color: themeCubit.isDark
                                                          ? Colors.white
                                                          : Colors.black,
                                                    ),
                                                  ),
                                                  clipBehavior:
                                                  Clip.antiAliasWithSaveLayer,
                                                  child: Image.file(
                                                    File(cubit.imagePost!.path),
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
                                            backgroundColor: themeCubit.isDark
                                                ? Colors.grey.shade700
                                                : Colors.grey.shade300,
                                            child: IconButton(
                                              onPressed: () {
                                                cubit.clearImagePost();
                                              },
                                              icon: Icon(
                                                Icons.close_rounded,
                                                color: themeCubit.isDark
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (cubit.imagePost != null)
                                    const SizedBox(
                                      height: 20.0,
                                    ),
                                  if (cubit.imagePost == null)
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
                                          focusNode1.unfocus();
                                          focusNode2.unfocus();
                                          if(checkCubit.hasInternet) {
                                            showModalBottomSheet(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return SafeArea(
                                                  child: Material(
                                                    color: themeCubit.isDark
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
                                                            cubit.getImagePost(
                                                                ImageSource
                                                                    .camera,
                                                                context);
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                        ),
                                                        ListTile(
                                                          leading: const Icon(
                                                              Icons
                                                                  .photo_library),
                                                          title: const Text(
                                                              'Choose from gallery'),
                                                          onTap: () async {
                                                            cubit.getImagePost(
                                                                ImageSource
                                                                    .gallery,
                                                                context);
                                                            Navigator.pop(
                                                                context);
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
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );

      },
    );
  }
}
