import 'package:chat/layout/appLayout/AppLayout.dart';
import 'package:chat/modules/startup/registerScreen/RegisterScreen.dart';
import 'package:chat/modules/startup/resetPassword/ResetePassword.dart';
import 'package:chat/shared/adaptive/circularIndicator/CircularIndicator.dart';
import 'package:chat/shared/components/Components.dart';
import 'package:chat/shared/components/Constants.dart';
import 'package:chat/shared/cubit/checkCubit/CheckCubit.dart';
import 'package:chat/shared/cubit/checkCubit/CheckStates.dart';
import 'package:chat/shared/cubit/loginCubit/LoginCubit.dart';
import 'package:chat/shared/cubit/loginCubit/LoginStates.dart';
import 'package:chat/shared/cubit/themeCubit/ThemeCubit.dart';
import 'package:chat/shared/cubit/themeCubit/ThemeStates.dart';
import 'package:chat/shared/network/local/CacheHelper.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isPassword = true;

  final focusNode1 = FocusNode();
  final focusNode2 = FocusNode();

  int numberPressed = 0;

  @override
  void initState() {
    super.initState();
    passwordController.addListener(() {
      setState(() {});
    });
    isSaved = CacheHelper.getData(key: 'isSaved');
  }


  void alertPress() {
    numberPressed++;
    if (numberPressed == 3) {
      numberPressed = 0;
      Future.delayed(const Duration(
          milliseconds: 300))
          .then((value) {
        showAlertConnection(context);
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CheckCubit , CheckStates>(
      listener: (context , state) {},
      builder: (context , state) {

        var checkCubit = CheckCubit.get(context);

        return BlocConsumer<ThemeCubit , ThemeStates>(
          listener: (context , state) {},
          builder: (context , state) {

            var themeCubit = ThemeCubit.get(context);

            return BlocConsumer<LoginCubit , LoginStates>(
                listener: (context , state) {
                  if(state is ErrorLoginState) {
                    showFlutterToast(message: '${state.error}', state: ToastStates.error, context: context);
                  }

                  if(state is SuccessLoginState) {
                    showFlutterToast(message: 'Login done successfully', state: ToastStates.success, context: context);

                    CacheHelper.saveData(key: 'uId', value: state.uId).then((value) {

                      uId = state.uId;

                      navigateAndNotReturn(context: context, screen: const AppLayout());

                    });
                  }

                  if(state is ErrorGoogleLoginState) {
                    showFlutterToast(message: '${state.error}', state: ToastStates.error, context: context);
                    Navigator.pop(context);
                  }

                  if(state is SuccessUserLoginCreateLoginState) {
                    showFlutterToast(message: 'Login done successfully', state: ToastStates.success, context: context);

                    CacheHelper.saveData(key: 'uId', value: state.model.uId).then((value) {

                      uId = state.model.uId;

                      Navigator.pop(context);
                      navigateAndNotReturn(context: context, screen: const AppLayout());

                    });
                  }
                },
                builder: (context , state) {

                  var cubit = LoginCubit.get(context);

                  return WillPopScope(
                    onWillPop: () async {
                      if(isSaved == null) {
                        showAlert(context);
                      }
                      return true;
                    },
                    child: Scaffold(
                      appBar: AppBar(
                        leading: (isSaved != null) ? IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.arrow_back_ios_new_outlined,
                            ),
                        ) : null,
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
                                    height: 40.0,
                                  ),
                                  defaultFormField(
                                      controller: emailController,
                                      type: TextInputType.emailAddress,
                                      label: 'Email',
                                      focusNode: focusNode1,
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
                                      focusNode: focusNode2,
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
                                        if(checkCubit.hasInternet) {
                                          if(formKey.currentState!.validate()) {
                                            cubit.userLogin(
                                                email: emailController.text,
                                                password: passwordController.text);
                                          }
                                        } else {
                                          alertPress();
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
                                        return null;
                                      }
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: defaultTextButton(
                                        text: 'Forgot password ?',
                                        onPress: () {
                                          focusNode1.unfocus();
                                          focusNode2.unfocus();
                                          if(checkCubit.hasInternet) {
                                            Navigator.of(context).push(createRoute(screen: const ResetPassword()));
                                          } else {
                                            alertPress();
                                            showFlutterToast(message: 'No Internet Connection', state: ToastStates.error, context: context);
                                          }
                                        }),
                                  ),
                                  const SizedBox(
                                    height: 30.0,
                                  ),
                                  ConditionalBuilder(
                                      condition: state is! LoadingLoginState,
                                      builder: (context) => defaultButton(
                                          text: 'login'.toUpperCase(),
                                          onPress: () {
                                            focusNode1.unfocus();
                                            focusNode2.unfocus();
                                            if(checkCubit.hasInternet) {
                                              if(formKey.currentState!.validate()) {
                                                cubit.userLogin(
                                                    email: emailController.text,
                                                    password: passwordController.text);
                                              }
                                            } else {
                                              alertPress();
                                              showFlutterToast(message: 'No Internet Connection', state: ToastStates.error, context: context);
                                            }
                                          },
                                          context: context),
                                      fallback: (context) => Center(child: CircularIndicator(os: getOs(),))),
                                  const SizedBox(
                                    height: 30.0,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Divider(
                                          thickness: 0.5,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 4.0,
                                      ),
                                      Text(
                                        'or login with',
                                        style: TextStyle(
                                            color: themeCubit.isDark ? Colors.grey.shade300 : Colors.grey.shade800
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 4.0,
                                      ),
                                      Expanded(
                                        child: Divider(
                                          thickness: 0.5,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 30.0,
                                  ),
                                  Center(
                                    child: Material(
                                      borderRadius: BorderRadius.circular(16.0,),
                                      color: themeCubit.isDark ? HexColor('252525') : Colors.grey.shade200,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(16.0),
                                        onTap: () async {
                                          focusNode1.unfocus();
                                          focusNode2.unfocus();
                                          if(checkCubit.hasInternet) {
                                            showLoading(context);
                                            await cubit.signInWithGoogle();
                                          } else {
                                            alertPress();
                                            showFlutterToast(message: 'No Internet Connection', state: ToastStates.error, context: context);
                                          }
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Icon(
                                            EvaIcons.google,
                                            size: 32.0,
                                            // color: Colors.grey.shade800,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 40.0,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      const Text(
                                        'Don\' t have an account ?',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      defaultTextButton(
                                          text: 'register'.toUpperCase(),
                                          onPress: () {
                                            focusNode1.unfocus();
                                            focusNode2.unfocus();
                                            if(checkCubit.hasInternet) {
                                              Navigator.of(context).push(createRoute(screen: const RegisterScreen()));
                                            } else {
                                              alertPress();
                                              showFlutterToast(message: 'No Internet Connection', state: ToastStates.error, context: context);
                                            }
                                          }),
                                    ],
                                  ),
                                ],
                              ),
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
  }

  dynamic showAlert(BuildContext context) {

    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.0,),
          ),
          title: const Text(
            'Do you want exit ?',
            style: TextStyle(
              fontSize: 19.0,
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
                  SystemNavigator.pop();
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
        ),
    );
  }

  dynamic showAlertConnection(BuildContext context) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.0,),
            ),
            title: const Text(
              'No Internet Connection',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            content:  const Text(
              'You are currently offline!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17.0,
                // fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Wait',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  SystemNavigator.pop();
                },
                child: Text(
                  'Exit',
                  style: TextStyle(
                    color: HexColor('f9325f'),
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}
