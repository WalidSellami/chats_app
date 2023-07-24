import 'package:chat/layout/appLayout/AppLayout.dart';
import 'package:chat/shared/adaptive/circularIndicator/CircularIndicator.dart';
import 'package:chat/shared/components/Components.dart';
import 'package:chat/shared/components/Constants.dart';
import 'package:chat/shared/cubit/checkCubit/CheckCubit.dart';
import 'package:chat/shared/cubit/checkCubit/CheckStates.dart';
import 'package:chat/shared/cubit/loginCubit/LoginCubit.dart';
import 'package:chat/shared/cubit/loginCubit/LoginStates.dart';
import 'package:chat/shared/network/local/CacheHelper.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserAccessScreen extends StatefulWidget {

  final String email;
  final String imageProfile;

  const UserAccessScreen({super.key , required this.email , required this.imageProfile});

  @override
  State<UserAccessScreen> createState() => _UserAccessScreenState();
}

class _UserAccessScreenState extends State<UserAccessScreen> {

  var passwordController = TextEditingController();

  var formKey = GlobalKey<FormState>();

  final FocusNode focusNode = FocusNode();

  bool isPassword = true;


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

          },
          builder: (context , state) {

            var cubit = LoginCubit.get(context);

            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios_new_outlined,
                  ),
                  tooltip: 'Back',
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 34.0,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        backgroundImage: NetworkImage(widget.imageProfile),
                      ),
                      const SizedBox(
                        height: 40.0,
                      ),
                      defaultFormField(
                        controller: passwordController,
                        type: TextInputType.visiblePassword,
                        label: 'Password',
                        focusNode: focusNode,
                        isPassword: isPassword,
                        onSubmit: (value) {
                          if(checkCubit.hasInternet) {
                            if(formKey.currentState!.validate()) {
                              cubit.userLogin(email: widget.email, password: passwordController.text);
                            }
                          } else {
                            showFlutterToast(message: 'No Internet Connection', state: ToastStates.error, context: context);
                          }
                          focusNode.unfocus();
                          return null;
                        },
                        suffixIcon: isPassword ? Icons.visibility_off : Icons.visibility,
                        onPress: () {
                          setState(() {
                            isPassword = !isPassword;
                          });
                        },
                        prefixIcon: Icons.lock_outline_rounded,
                        validate: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password must not be empty';
                          } else if (value.length < 8) {
                            return 'Password must be at least 8 characters.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 40.0,
                      ),
                      ConditionalBuilder(
                        condition: state is! LoadingLoginState,
                        builder: (context) => defaultButton(
                            text: 'Login'.toUpperCase(),
                            onPress: () {
                              if(checkCubit.hasInternet) {
                                if(formKey.currentState!.validate()) {
                                  cubit.userLogin(email: widget.email, password: passwordController.text);
                                }
                              } else {
                                showFlutterToast(message: 'No Internet Connection', state: ToastStates.error, context: context);
                              }
                              focusNode.unfocus();
                            },
                            context: context),
                        fallback: (context) => Center(child: CircularIndicator(os: getOs())),

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
