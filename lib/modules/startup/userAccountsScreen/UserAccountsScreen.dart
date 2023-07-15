import 'package:chat/layout/appLayout/AppLayout.dart';
import 'package:chat/modules/startup/loginScreen/LoginScreen.dart';
import 'package:chat/modules/startup/registerScreen/RegisterScreen.dart';
import 'package:chat/modules/startup/userAccessScreen/UserAccessScreen.dart';
import 'package:chat/shared/adaptive/circularIndicator/CircularIndicator.dart';
import 'package:chat/shared/components/Components.dart';
import 'package:chat/shared/components/Constants.dart';
import 'package:chat/shared/cubit/appCubit/AppCubit.dart';
import 'package:chat/shared/cubit/appCubit/AppStates.dart';
import 'package:chat/shared/cubit/checkCubit/CheckCubit.dart';
import 'package:chat/shared/cubit/checkCubit/CheckStates.dart';
import 'package:chat/shared/cubit/loginCubit/LoginCubit.dart';
import 'package:chat/shared/cubit/loginCubit/LoginStates.dart';
import 'package:chat/shared/cubit/themeCubit/ThemeCubit.dart';
import 'package:chat/shared/cubit/themeCubit/ThemeStates.dart';
import 'package:chat/shared/network/local/CacheHelper.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';

class UserAccountsScreen extends StatefulWidget {
  const UserAccountsScreen({super.key});

  @override
  State<UserAccountsScreen> createState() => _UserAccountsScreenState();
}

class _UserAccountsScreenState extends State<UserAccountsScreen> {

  int numberPressed = 0;

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
    return Builder(
      builder: (context) {
        if(CheckCubit.get(context).hasInternet) {
          AppCubit.get(context).getUserAccounts(context);
        }
        return BlocConsumer<CheckCubit , CheckStates>(
          listener: (context , state) {},
          builder: (context , state) {

            var checkCubit = CheckCubit.get(context);

            return BlocConsumer<ThemeCubit , ThemeStates>(
              listener: (context , state) {},
              builder: (context , state) {

                return BlocConsumer<AppCubit , AppStates>(
                  listener: (context , state) {

                    if(state is SuccessDeleteUserAccountAppState) {
                      showFlutterToast(message: 'Removed Successfully from your phone', state: ToastStates.success, context: context);
                    }

                  },
                  builder: (context , state) {

                    var cubit = AppCubit.get(context);
                    var accountsSaved = cubit.accountsSaved;
                    var accountsSavedId = cubit.accountsSavedId;

                    return BlocConsumer<LoginCubit , LoginStates>(
                      listener: (context , state) {

                        if(state is ErrorGoogleLoginState) {
                          showFlutterToast(message: '${state.error}', state: ToastStates.error, context: context);
                        }

                        if(state is SuccessGoogleLoginState) {
                          showFlutterToast(message: 'Login done successfully', state: ToastStates.success, context: context);

                          CacheHelper.saveData(key: 'uId', value: state.uId).then((value) {

                            uId = state.uId;

                            Navigator.pop(context);
                            navigateAndNotReturn(context: context, screen: const AppLayout());

                          });
                        }

                      },
                      builder: (context , state) {

                        return WillPopScope(
                          onWillPop: () async {
                            showAlert(context);
                            return true;
                          },
                          child: Scaffold(
                            appBar: AppBar(),
                            body: Center(
                              child: SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      children: [
                                        Image.asset('assets/images/chat-logo.png',
                                          width: 70.0,
                                          height: 70.0,
                                        ),
                                        const SizedBox(
                                          height: 50.0,
                                        ),
                                        ConditionalBuilder(
                                          condition: accountsSaved.isNotEmpty,
                                          builder: (context) => ListView.separated(
                                              physics: const NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemBuilder: (context , index) => buildItemUserAccount(accountsSaved[index] , accountsSavedId[index] , context),
                                              separatorBuilder: (context , index) => Padding(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 30.0,
                                                ),
                                                child: Divider(
                                                  thickness: 0.7,
                                                  color: Colors.grey.shade500,
                                                ),
                                              ),
                                              itemCount: accountsSaved.length),
                                          fallback: (context) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8.0,
                                            ),
                                            child: CircularIndicator(os: getOs(),),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 20.0,
                                        ),
                                        InkWell(
                                          borderRadius: BorderRadius.circular(6.0),
                                          onTap: () {
                                            if(checkCubit.hasInternet) {
                                              Navigator.of(context).push(createRoute(screen: const LoginScreen()));
                                            } else {
                                              showFlutterToast(message: 'No Internet Connection', state: ToastStates.error, context: context);
                                              alertPress();
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0,
                                              vertical: 8.0,
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(6.0),
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(8.0),
                                                      color: Theme.of(context).colorScheme.primary
                                                  ),
                                                  child: const Icon(
                                                    Icons.login_rounded,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 20.0,
                                                ),
                                                Text(
                                                  'Login with another account',
                                                  style: TextStyle(
                                                    fontSize: 16.0,
                                                    color: Theme.of(context).colorScheme.primary,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 30.0,
                                        ),
                                        defaultButton(
                                            text: 'Create new account'.toUpperCase(),
                                            onPress: () {
                                              if(checkCubit.hasInternet) {
                                                Navigator.of(context).push(createRoute(screen: const RegisterScreen()));
                                              } else {
                                                showFlutterToast(message: 'No Internet Connection', state: ToastStates.error, context: context);
                                                alertPress();
                                              }
                                            },
                                            context: context),
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
                    );
                  },
                );

              },
            );

          },
        );
      }
    );
  }

  Widget buildItemUserAccount(account , accountId , context) => InkWell(
    borderRadius: BorderRadius.circular(6.0,),
    onTap: () async {
      if(CheckCubit.get(context).hasInternet) {
        if(account['isGoogleSignIn'] == false) {
          Navigator.of(context).push(createRoute(screen: UserAccessScreen(email: account['email'], imageProfile: account['image_profile'],)));
        } else {
          showLoading(context);
          await LoginCubit.get(context).signInWithGoogleAccount();
        }
      } else {
        showFlutterToast(message: 'No Internet Connection', state: ToastStates.error, context: context);
        alertPress();
      }
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 8.0,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26.0,
            backgroundColor: Theme.of(context).colorScheme.primary,
            backgroundImage: NetworkImage('${account['image_profile']}'),
          ),
          const SizedBox(
            width: 20.0,
          ),
          Expanded(
            child: Text(
              '${account['user_name']}',
              style: const TextStyle(
                fontSize: 17.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(12.0),
            onTap: () {
              if(CheckCubit.get(context).hasInternet) {
                AppCubit.get(context).deleteUserAccount(userAccountId: accountId);
              } else {
                showFlutterToast(message: 'No InternetConnection', state: ToastStates.error, context: context);
                alertPress();
              }
            },
            child: Tooltip(
              message: 'Remove',
              child: CircleAvatar(
                radius: 18.0,
                backgroundColor: ThemeCubit.get(context).isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                child: Icon(
                  Icons.close_rounded,
                  size: 18.0,
                  color: ThemeCubit.get(context).isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

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
