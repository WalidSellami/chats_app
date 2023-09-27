import 'dart:io';
import 'package:chat/shared/adaptive/circularIndicator/CircularIndicator.dart';
import 'package:chat/shared/adaptive/circularIndicator/CircularRingIndicator.dart';
import 'package:chat/shared/components/Components.dart';
import 'package:chat/shared/components/Constants.dart';
import 'package:chat/shared/cubit/appCubit/AppCubit.dart';
import 'package:chat/shared/cubit/appCubit/AppStates.dart';
import 'package:chat/shared/cubit/checkCubit/CheckCubit.dart';
import 'package:chat/shared/cubit/checkCubit/CheckStates.dart';
import 'package:chat/shared/cubit/themeCubit/ThemeCubit.dart';
import 'package:chat/shared/cubit/themeCubit/ThemeStates.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  var nameController = TextEditingController();
  var bioController = TextEditingController();
  var phoneController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final focusNode1 = FocusNode();
  final focusNode2 = FocusNode();
  final focusNode3 = FocusNode();

  bool isVisible = true;

  @override
  Widget build(BuildContext context) {
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
                if ((state is LoadingUploadImageProfileAppState) ||
                    (state is LoadingUploadImageCoverAppState)) {
                  showLoading(context);
                }

                if (state is SuccessGetUserProfileAppState) {
                  showFlutterToast(
                      message: 'Done with success',
                      state: ToastStates.success,
                      context: context);
                  if((AppCubit.get(context).imageProfile != null) || (AppCubit.get(context).imageCover != null)) {
                    Navigator.pop(context);
                    AppCubit.get(context).clearImageProfile();
                    AppCubit.get(context).clearImageCover();
                  }
                }

                if (state is SuccessClearImageAppStates) {
                  setState(() {
                    isVisible = true;
                  });
                }
              },
              builder: (context, state) {
                var cubit = AppCubit.get(context);
                var userProfile = cubit.userProfile;

                nameController.text = (userProfile?.userName).toString();
                bioController.text = (userProfile?.bio ?? '').toString();
                phoneController.text = (userProfile?.phone ?? '').toString();

                return Scaffold(
                  appBar: defaultAppBar(
                      onPress: () {
                        Navigator.pop(context);
                      },
                      text: 'Edit Profile',
                      actions: [
                        if (cubit.imageProfile != null || cubit.imageCover != null)
                          TextButton(
                            onPressed: () {
                              if(checkCubit.hasInternet) {
                                focusNode1.unfocus();
                                focusNode2.unfocus();
                                focusNode3.unfocus();
                                if (cubit.imageProfile != null) {
                                  cubit.uploadImageProfile(
                                      userName: nameController.text,
                                      bio: bioController.text,
                                      phone: phoneController.text);
                                } else if (cubit.imageCover != null) {
                                  cubit.uploadImageCover(
                                      userName: nameController.text,
                                      bio: bioController.text,
                                      phone: phoneController.text);
                                }
                              } else {
                                showFlutterToast(message: 'No Internet Connection', state: ToastStates.error, context: context);
                              }
                            },
                            child: Text(
                              'upload & update'.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (cubit.imageProfile != null || cubit.imageCover != null)
                          const SizedBox(
                            width: 6.0,
                          ),
                      ]),
                  body: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: formKey,
                        child: Column(children: [
                          SizedBox(
                            height: 230.0,
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      GestureDetector(
                                        child: Hero(
                                          tag: 'image-cover',
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(
                                                4.0,
                                              ),
                                            ),
                                            clipBehavior:
                                            Clip.antiAliasWithSaveLayer,
                                            child: (cubit.imageCover == null)
                                                ? Image.network(
                                              '${userProfile?.imageCover}',
                                              width: double.infinity,
                                              height: 180.0,
                                              fit: BoxFit.cover,
                                              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                                                if(frame == null) {
                                                  return Container(
                                                    width: double.infinity,
                                                    height: 180.0,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        width: 0.0,
                                                        color: Colors
                                                            .grey.shade900,
                                                      ),
                                                    ),
                                                    child: Center(
                                                        child:
                                                        CircularRingIndicator(
                                                            os: getOs())),
                                                  );

                                                }
                                                return child;
                                              },
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                } else {
                                                  return Container(
                                                    width: double.infinity,
                                                    height: 180.0,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        width: 0.0,
                                                        color: themeCubit.isDark ? Colors.white : Colors.grey.shade900,
                                                      ),
                                                    ),
                                                    child: Center(
                                                        child:
                                                        CircularRingIndicator(
                                                            os: getOs())),
                                                  );
                                                }
                                              },
                                              errorBuilder: (context, error,
                                                  stackTrace) {
                                                return const SizedBox(
                                                  width: double.infinity,
                                                  height: 180.0,
                                                  child: Center(
                                                      child: Text(
                                                        'Failed to load',
                                                        style: TextStyle(
                                                          fontSize: 14.0,
                                                        ),
                                                      )),
                                                );
                                              },
                                            )
                                                : Image.file(
                                              File(cubit.imageCover!.path),
                                              width: double.infinity,
                                              height: 180.0,
                                              fit: BoxFit.cover,
                                              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                                                if(frame == null) {
                                                  return Container(
                                                    width: double.infinity,
                                                    height: 180.0,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        width: 0.0,
                                                        color: themeCubit.isDark ? Colors.white : Colors.grey.shade900,
                                                      ),
                                                    ),
                                                    child: Center(
                                                        child:
                                                        CircularRingIndicator(
                                                            os: getOs())),
                                                  );
                                                }
                                                return child;
                                              },
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          showImage(context, 'image-cover',
                                              userProfile?.imageCover,
                                              imageUpload: cubit.imageCover);
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: CircleAvatar(
                                          radius: 22.0,
                                          backgroundColor: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: CircleAvatar(
                                          radius: 20.0,
                                          backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                          child: Center(
                                            child: IconButton(
                                              onPressed: () {
                                                if(checkCubit.hasInternet) {
                                                  focusNode1.unfocus();
                                                  focusNode2.unfocus();
                                                  focusNode3.unfocus();
                                                  if ((cubit.imageCover == null) &&
                                                      (cubit.imageProfile == null)) {
                                                    showModalBottomSheet(
                                                        context: context,
                                                        builder:
                                                            (BuildContext context) {
                                                          return SafeArea(
                                                            child: Material(
                                                              color: themeCubit.isDark
                                                                  ? HexColor('171717')
                                                                  : Colors.white,
                                                              child: Wrap(
                                                                children: <Widget>[
                                                                  ListTile(
                                                                    leading: const Icon(
                                                                        Icons
                                                                            .camera_alt),
                                                                    title: const Text(
                                                                        'Take a new photo'),
                                                                    onTap: () async {
                                                                      cubit.getImageCover(
                                                                          ImageSource
                                                                              .camera,
                                                                          context);
                                                                      setState(() {
                                                                        isVisible =
                                                                        false;
                                                                      });
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
                                                                      cubit.getImageCover(
                                                                          ImageSource
                                                                              .gallery,
                                                                          context);
                                                                      setState(() {
                                                                        isVisible =
                                                                        false;
                                                                      });
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        });
                                                  } else if (cubit.imageProfile !=
                                                      null) {
                                                    showFlutterToast(
                                                        message:
                                                        'Upload your profile first!',
                                                        state: ToastStates.error,
                                                        context: context);
                                                  } else {
                                                    cubit.clearImageCover();
                                                  }
                                                } else {
                                                  showFlutterToast(message: 'No Internet Connection', state: ToastStates.error, context: context);
                                                }
                                              },
                                              icon: Icon(
                                                (cubit.imageCover == null)
                                                    ? Icons.camera_alt_outlined
                                                    : Icons.close_rounded,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    GestureDetector(
                                      child: Hero(
                                        tag: 'image-profile',
                                        child: Container(
                                          decoration: const BoxDecoration(),
                                          child: CircleAvatar(
                                            radius: 63.0,
                                            backgroundColor: themeCubit.isDark
                                                ? Colors.white
                                                : Colors.black,
                                            child: CircleAvatar(
                                              radius: 60.0,
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              backgroundImage: (cubit
                                                  .imageProfile ==
                                                  null)
                                                  ? NetworkImage(
                                                  '${userProfile?.imageProfile}')
                                                  : Image.file(
                                                File(
                                                    cubit.imageProfile!.path),
                                                width: double.infinity,
                                                height: 180.0,
                                                fit: BoxFit.cover,
                                              ).image,
                                            ),
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        showImage(context, 'image-profile',
                                            userProfile?.imageProfile,
                                            imageUpload: cubit.imageProfile);
                                      },
                                    ),
                                    CircleAvatar(
                                      radius: 22.0,
                                      backgroundColor:
                                      Theme.of(context).scaffoldBackgroundColor,
                                    ),
                                    CircleAvatar(
                                      radius: 20.0,
                                      backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                      child: Center(
                                        child: IconButton(
                                          onPressed: () {
                                            if(checkCubit.hasInternet) {
                                              focusNode1.unfocus();
                                              focusNode2.unfocus();
                                              focusNode3.unfocus();
                                              if ((cubit.imageProfile == null) &&
                                                  (cubit.imageCover == null)) {
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
                                                                  cubit
                                                                      .getImageProfile(
                                                                      ImageSource
                                                                          .camera,
                                                                      context);
                                                                  setState(() {
                                                                    isVisible = false;
                                                                  });
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
                                                                  cubit.getImageProfile(
                                                                      ImageSource
                                                                          .gallery,
                                                                      context);
                                                                  setState(() {
                                                                    isVisible = false;
                                                                  });
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    });
                                              } else if (cubit.imageCover != null) {
                                                showFlutterToast(
                                                    message:
                                                    'Upload your cover first!',
                                                    state: ToastStates.error,
                                                    context: context);
                                              } else {
                                                cubit.clearImageProfile();
                                              }
                                            } else {
                                              showFlutterToast(message: 'No Internet Connection', state: ToastStates.error, context: context);
                                            }
                                          },
                                          icon: Icon(
                                            (cubit.imageProfile == null)
                                                ? Icons.camera_alt_outlined
                                                : Icons.close_rounded,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 30.0,
                          ),
                          defaultFormField(
                              controller: nameController,
                              type: TextInputType.name,
                              prefixIcon: Icons.person,
                              label: 'User Name',
                              focusNode: focusNode1,
                              validate: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'User Name must not be empty.';
                                }
                                if (value.length < 4) {
                                  return 'User Name must be at least 4 characters.';
                                }
                                bool validName =
                                RegExp(r'^(?=.*[a-zA-Z])[a-zA-Z0-9\s_.]+$')
                                    .hasMatch(value);
                                if (!validName) {
                                  return 'Enter a valid name without (,-) and without only numbers.';
                                }
                                return null;
                              }),
                          const SizedBox(
                            height: 30.0,
                          ),
                          defaultFormField(
                              controller: bioController,
                              type: TextInputType.text,
                              focusNode: focusNode2,
                              prefixIcon: Icons.perm_identity_outlined,
                              label: 'Bio',
                              validate: (value) {
                                return null;
                              }),
                          const SizedBox(
                            height: 30.0,
                          ),
                          defaultFormField(
                              controller: phoneController,
                              prefixIcon: Icons.phone,
                              type: TextInputType.text,
                              focusNode: focusNode3,
                              label: 'Phone',
                              validate: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Phone must not be empty';
                                }
                                if (value.length < 9 || value.length > 10) {
                                  return 'Phone must be 9 or 10 numbers with 0 in the beginning.';
                                }

                                String firstLetter =
                                value.substring(0, 1).toUpperCase();
                                if (firstLetter != '0') {
                                  return 'Phone must be starting with 0';
                                }
                                return null;
                              }),
                          const SizedBox(
                            height: 40.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                            ),
                            child: ConditionalBuilder(
                              condition: state is! LoadingUpdateUserProfileAppState,
                              builder: (context) => Visibility(
                                visible: isVisible,
                                child: defaultButton(
                                    text: 'update'.toUpperCase(),
                                    onPress: () {
                                      if(checkCubit.hasInternet) {
                                        if (formKey.currentState!.validate()) {
                                          cubit.updateProfile(
                                              userName: nameController.text,
                                              bio: bioController.text,
                                              phone: phoneController.text);
                                        }
                                      } else {
                                        showFlutterToast(message: 'No Internet Connection', state: ToastStates.error, context: context);
                                      }

                                      focusNode1.unfocus();
                                      focusNode2.unfocus();
                                      focusNode3.unfocus();
                                    },
                                    context: context),
                              ),
                              fallback: (context) =>
                                  Center(child: CircularIndicator(os: getOs())),
                            ),
                          ),
                        ]),
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
  }
}
