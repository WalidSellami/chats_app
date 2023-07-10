import 'package:chat/layout/appLayout/AppLayout.dart';
import 'package:chat/shared/adaptive/circularIndicator/CircularIndicator.dart';
import 'package:chat/shared/components/Components.dart';
import 'package:chat/shared/components/Constants.dart';
import 'package:chat/shared/cubit/checkCubit/CheckCubit.dart';
import 'package:chat/shared/cubit/checkCubit/CheckStates.dart';
import 'package:chat/shared/cubit/registerCubit/RegisterCubit.dart';
import 'package:chat/shared/cubit/registerCubit/RegisterStates.dart';
import 'package:chat/shared/network/local/CacheHelper.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  var nameController = TextEditingController();
  var phoneController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isPassword = true;

  final focusNode1 = FocusNode();
  final focusNode2 = FocusNode();
  final focusNode3 = FocusNode();
  final focusNode4 = FocusNode();

  @override
  void initState() {
    super.initState();
    passwordController.addListener(() {
      setState(() {});
    });
  }


  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CheckCubit , CheckStates>(
      listener: (context , state) {},
      builder: (context , state) {

        var checkCubit = CheckCubit.get(context);

        return BlocProvider(
          create: (BuildContext context) => RegisterCubit(),
          child: BlocConsumer<RegisterCubit , RegisterStates>(
            listener: (context , state) {
              if(state is ErrorRegisterState) {
                showFlutterToast(message: '${state.error}', state: ToastStates.error, context: context);
              }

              if(state is SuccessUserCreateRegisterState) {

                showFlutterToast(message: 'Register done successfully', state: ToastStates.success, context: context);

                CacheHelper.saveData(key: 'uId', value: state.userModel.uId).then((value) {

                  uId = state.userModel.uId;

                  navigateAndNotReturn(context: context, screen: const AppLayout());

                });
              }
            },
            builder: (context , state) {

              var cubit = RegisterCubit.get(context);

              return Scaffold(
                appBar: defaultAppBar(
                    onPress: () {
                      Navigator.pop(context);}
                ),
                body: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            Image.asset('assets/images/chat-logo.png',
                              width: 90.0,
                              height: 90.0,
                            ),
                            const SizedBox(
                              height: 30.0,
                            ),
                            const Text(
                              'Register now to join!',
                              style: TextStyle(
                                fontSize: 17.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              height: 30.0,
                            ),
                            defaultFormField(
                                controller: nameController,
                                type: TextInputType.name,
                                label: 'User Name',
                                focusNode: focusNode1,
                                prefixIcon: Icons.person,
                                validate: (value) {
                                  if(value == null || value.isEmpty) {
                                    return 'User Name must not be empty.';
                                  }
                                  if (value.length < 4) {
                                    return 'User Name must be at least 4 characters.';
                                  }
                                  bool validName = RegExp(r'^(?=.*[a-zA-Z])[a-zA-Z0-9\s_.]+$').hasMatch(value);
                                  if(!validName) {
                                    return 'Enter a valid name without (,-) and without only numbers.';
                                  }
                                  return null;
                                }),
                            const SizedBox(
                              height: 30.0,
                            ),
                            defaultFormField(
                                label: 'Phone',
                                controller: phoneController,
                                type: TextInputType.phone,
                                focusNode: focusNode2,
                                prefixIcon: Icons.phone,
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
                              height: 30.0,
                            ),
                            defaultFormField(
                                controller: emailController,
                                type: TextInputType.emailAddress,
                                label: 'Email',
                                focusNode: focusNode3,
                                prefixIcon: Icons.email_outlined,
                                validate: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Email must not be empty';
                                  }
                                  bool emailValid = RegExp(
                                      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
                                      .hasMatch(value);
                                  if (!emailValid) {
                                    return 'Enter a valid email.';
                                  }
                                  return null;
                                }
                            ),
                            const SizedBox(
                              height: 30.0,
                            ),
                            defaultFormField(
                                controller: passwordController,
                                type: TextInputType.visiblePassword,
                                label: 'Password',
                                focusNode: focusNode4,
                                isPassword: isPassword,
                                prefixIcon: Icons.lock_outline_rounded,
                                suffixIcon: (isPassword) ? Icons.visibility_off : Icons.visibility,
                                onPress: () {
                                  setState(() {
                                    isPassword = !isPassword;
                                  });
                                },
                                onSubmit: (value) {
                                  focusNode1.unfocus();
                                  focusNode2.unfocus();
                                  focusNode3.unfocus();
                                  focusNode4.unfocus();
                                  if(checkCubit.hasInternet) {
                                    if(formKey.currentState!.validate()) {
                                      cubit.userRegister(
                                          userName: nameController.text,
                                          phone: phoneController.text,
                                          email: emailController.text,
                                          password: passwordController.text);
                                    }
                                  } else {
                                    showFlutterToast(message: 'No Internet Connection', state: ToastStates.error, context: context);
                                  }
                                  return null;
                                },
                                validate: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Password must not be empty';
                                  } else if (value.length < 8) {
                                    return 'Password must be at least 8 characters.';
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
                                condition: state is! LoadingRegisterState,
                                builder: (context) => defaultButton(
                                    text: 'register'.toUpperCase(),
                                    onPress: () {
                                      focusNode1.unfocus();
                                      focusNode2.unfocus();
                                      focusNode3.unfocus();
                                      focusNode4.unfocus();
                                      if(checkCubit.hasInternet) {
                                        if(formKey.currentState!.validate()) {
                                          cubit.userRegister(
                                              userName: nameController.text,
                                              phone: phoneController.text,
                                              email: emailController.text,
                                              password: passwordController.text);
                                        }
                                      } else {
                                        showFlutterToast(message: 'No Internet Connection', state: ToastStates.error, context: context);
                                      }
                                    },
                                    context: context),
                                fallback: (context) => Center(child: CircularIndicator(os: getOs(),))),

                            const SizedBox(
                              height: 10.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );

      },
    );

  }
}
