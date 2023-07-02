import 'package:chat/shared/adaptive/circularIndicator/CircularIndicator.dart';
import 'package:chat/shared/components/Components.dart';
import 'package:chat/shared/components/Constants.dart';
import 'package:chat/shared/cubit/checkCubit/CheckCubit.dart';
import 'package:chat/shared/cubit/checkCubit/CheckStates.dart';
import 'package:chat/shared/cubit/resetCubit/ResetCubit.dart';
import 'package:chat/shared/cubit/resetCubit/ResetStates.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  var emailController = TextEditingController();

  final focusNode = FocusNode();

  var formKey = GlobalKey<FormState>();

  bool isSend = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CheckCubit , CheckStates>(
      listener: (context , state) {},
      builder: (context , state) {

        var checkCubit = CheckCubit.get(context);

        return BlocProvider(
          create: (BuildContext context) => ResetCubit(),
          child: BlocConsumer<ResetCubit, ResetStates>(
            listener: (context, state) {
              if (state is SuccessResetState) {

                setState(() {
                  isSend = true;
                });

                showFlutterToast(
                    message: 'Link send with success',
                    state: ToastStates.success,
                    context: context);
              }

              if (state is ErrorResetState) {

                setState(() {
                  isSend = false;
                });

                showFlutterToast(
                    message: '${state.error}',
                    state: ToastStates.error,
                    context: context);
              }
            },
            builder: (context, state) {
              var cubit = ResetCubit.get(context);

              return WillPopScope(
                onWillPop: () async {
                  setState(() {
                    isSend = false;
                  });
                  return true;
                },
                child: Scaffold(
                  appBar: defaultAppBar(
                    onPress: () {
                      Navigator.pop(context);
                      setState(() {
                        isSend = false;
                      });
                    },
                    text: 'Email Verification',
                  ),
                  body: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Form(
                      key: formKey,
                      child: (!isSend)
                          ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          defaultFormField(
                              controller: emailController,
                              type: TextInputType.emailAddress,
                              label: 'Email',
                              focusNode: focusNode,
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
                              },
                              onSubmit: (value) {
                                focusNode.unfocus();
                                if(checkCubit.hasInternet) {
                                  if (formKey.currentState!.validate()) {
                                    cubit.resetPassword(
                                        email: emailController.text);
                                  }
                                } else {
                                  showFlutterToast(message: 'No Internet Connection', state: ToastStates.error, context: context);
                                }
                                return null;
                              },
                          ),
                          const SizedBox(
                            height: 80.0,
                          ),
                          ConditionalBuilder(
                            condition: state is! LoadingResetState,
                            builder: (context) => defaultButton(
                                text: 'Send'.toUpperCase(),
                                onPress: () {
                                  focusNode.unfocus();
                                  if(checkCubit.hasInternet) {
                                    if (formKey.currentState!.validate()) {
                                      cubit.resetPassword(
                                          email: emailController.text);
                                    }
                                  } else {
                                    showFlutterToast(message: 'No Internet Connection', state: ToastStates.error, context: context);
                                  }
                                },
                                context: context),
                            fallback: (context) =>
                                Center(child: CircularIndicator(os: getOs())),
                          )
                        ],
                      )
                          : const SizedBox(
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Check Your Email',
                              style: TextStyle(
                                  fontSize: 26.0,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            Text(
                              'We sent a link to your email to reset your password',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16.0,
                              ),
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
