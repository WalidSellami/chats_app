import 'package:chat/shared/adaptive/circularIndicator/CircularIndicator.dart';
import 'package:chat/shared/components/Components.dart';
import 'package:chat/shared/components/Constants.dart';
import 'package:chat/shared/cubit/appCubit/AppCubit.dart';
import 'package:chat/shared/cubit/appCubit/AppStates.dart';
import 'package:chat/shared/cubit/checkCubit/CheckCubit.dart';
import 'package:chat/shared/cubit/checkCubit/CheckStates.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChangePasswordsScreen extends StatefulWidget {
  const ChangePasswordsScreen({super.key});

  @override
  State<ChangePasswordsScreen> createState() => _ChangePasswordsScreenState();
}

class _ChangePasswordsScreenState extends State<ChangePasswordsScreen> {

  var oldPasswordController = TextEditingController();

  var newPasswordController = TextEditingController();

  var formKey = GlobalKey<FormState>();

  final focusNode1 = FocusNode();

  final focusNode2 = FocusNode();

  bool isOldPassword = true;

  bool isNewPassword = true;


  @override
  void initState() {
    super.initState();
    oldPasswordController.addListener(() {
      setState(() {});
    });
    newPasswordController.addListener(() {
      setState(() {});
    });
  }




  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CheckCubit , CheckStates>(
      listener: (context , state) {},
      builder: (context , state) {

        var checkCubit = CheckCubit.get(context);

        return  BlocConsumer<AppCubit , AppStates>(
          listener: (context , state) {

            if(state is SuccessChangePasswordAppState) {
              showFlutterToast(message: 'Password changed successfully', state: ToastStates.success, context: context);
              Navigator.pop(context);
            }

            if(state is ErrorChangePasswordAppState) {
              if(state.error.toString().contains('wrong-password')) {
                showFlutterToast(message: '[firebase_auth/wrong-password] Old Password is wrong, enter the correct one.', state: ToastStates.error, context: context);
              } else {
                showFlutterToast(message: state.error.toString(), state: ToastStates.error, context: context);
              }
            }

          },
          builder: (context , state) {

            var cubit = AppCubit.get(context);

            return Scaffold(
              appBar: defaultAppBar(
                  onPress: () {
                    Navigator.pop(context);
                  },
                  text: 'Change Password'),
              body: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: formKey,
                    autovalidateMode: AutovalidateMode.always,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Enter your old password : ',
                          style: TextStyle(
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 14.0,
                        ),
                        defaultFormField(
                            controller: oldPasswordController,
                            type: TextInputType.visiblePassword,
                            label: 'Old Password',
                            focusNode: focusNode1,
                            isPassword: isOldPassword,
                            onPress: () {
                              setState(() {
                                isOldPassword = !isOldPassword;
                              });
                            },
                            prefixIcon: Icons.lock_outline_rounded,
                            suffixIcon: isOldPassword ? Icons.visibility_off : Icons.visibility,
                            validate: (value) {
                              if(value == null || value.isEmpty) {
                                return 'Old Password must not be empty';
                              }
                              if(value.length < 8) {
                                return 'Old Password must be at least 8 characters.';
                              }
                              return null;
                            }),
                        const SizedBox(
                          height: 35.0,
                        ),
                        const Text(
                          'Enter your new password : ',
                          style: TextStyle(
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 14.0,
                        ),
                        defaultFormField(
                            controller: newPasswordController,
                            type: TextInputType.visiblePassword,
                            label: 'New Password',
                            focusNode: focusNode2,
                            prefixIcon: Icons.lock_outline_rounded,
                            suffixIcon: isNewPassword ? Icons.visibility_off : Icons.visibility,
                            isPassword: isNewPassword,
                            onPress: () {
                              setState(() {
                                isNewPassword = !isNewPassword;
                              });
                            },
                            validate: (value) {
                              if(value == null || value.isEmpty) {
                                return 'New Password must not be empty';
                              }
                              if(value.length < 8) {
                                return 'New Password must be at least 8 characters.';
                              }
                              if(value == oldPasswordController.text) {
                                return 'New Password must be different';
                              }
                              bool passwordValid = RegExp(
                                  r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~,.]).{8,}$')
                                  .hasMatch(value);
                              if (!passwordValid) {
                                return 'Enter a strong password with a mix of uppercase letters, lowercase letters, numbers, special characters(@#%&!?), and at least 8 characters';
                              }
                              return null;
                            }),
                        const SizedBox(
                          height: 40.0,
                        ),
                        ConditionalBuilder(
                          condition: state is! LoadingChangePasswordAppState,
                          builder: (context) =>  Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                            ),
                            child: defaultButton(
                                text: 'Change'.toUpperCase(),
                                onPress: () {
                                  if(checkCubit.hasInternet) {
                                    if(formKey.currentState!.validate()) {
                                      cubit.changePassword(
                                          oldPassword: oldPasswordController.text,
                                          newPassword: newPasswordController.text);
                                      // formKey.currentState?.save();
                                    }
                                  } else {
                                    showFlutterToast(message: 'No Internet Connection', state: ToastStates.error, context: context);
                                  }
                                  focusNode1.unfocus();
                                  focusNode2.unfocus();
                                },
                                context: context),
                          ),
                          fallback: (context) => Center(child: CircularIndicator(os: getOs())),
                        ),
                      ],
                    ),
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
