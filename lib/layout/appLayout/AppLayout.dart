import 'package:chat/modules/postScreen/PostScreen.dart';
import 'package:chat/modules/searchUserScreen/SearchUserScreen.dart';
import 'package:chat/shared/components/Components.dart';
import 'package:chat/shared/cubit/appCubit/AppCubit.dart';
import 'package:chat/shared/cubit/appCubit/AppStates.dart';
import 'package:chat/shared/cubit/checkCubit/CheckCubit.dart';
import 'package:chat/shared/cubit/checkCubit/CheckStates.dart';
import 'package:chat/shared/cubit/themeCubit/ThemeCubit.dart';
import 'package:chat/shared/cubit/themeCubit/ThemeStates.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class AppLayout extends StatefulWidget {
  const AppLayout({super.key});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {



  @override
  void initState() {
    super.initState();
    AppCubit.get(context).getUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    DateTime timePressed = DateTime.now();
    return BlocConsumer<CheckCubit, CheckStates>(
      listener: (context, state) {},
      builder: (context, state) {
        var checkCubit = CheckCubit.get(context);

        return BlocConsumer<ThemeCubit, ThemeStates>(
          listener: (context, state) {},
          builder: (context, state) {
            var themeCubit = ThemeCubit.get(context);

            return BlocConsumer<AppCubit, AppStates>(
              listener: (context, state) {
                if (state is ChangeToPostAppState) {
                  if (checkCubit.hasInternet) {
                    Navigator.of(context)
                        .push(createRoute(screen: const PostScreen()));
                  } else {
                    showFlutterToast(
                        message: 'No Internet Connection',
                        state: ToastStates.error,
                        context: context);
                  }
                }
              },
              builder: (context, state) {
                var cubit = AppCubit.get(context);

                return WillPopScope(
                  onWillPop: () async {
                    final difference = DateTime.now().difference(timePressed);
                    final isWarning = difference >= const Duration(milliseconds: 800);
                    timePressed = DateTime.now();

                    if (isWarning) {
                      showToast(
                        'Press back again to exit',
                        context: context,
                        backgroundColor: Colors.grey.shade800,
                        animation: StyledToastAnimation.scale,
                        reverseAnimation: StyledToastAnimation.fade,
                        position: StyledToastPosition.bottom,
                        animDuration: const Duration(milliseconds: 1500),
                        duration: const Duration(seconds: 3),
                        curve: Curves.elasticInOut,
                        reverseCurve: Curves.linear,
                      );
                      return false;
                    } else {
                      SystemNavigator.pop();
                      return true;
                    }
                  },
                  child: Scaffold(
                    appBar: AppBar(
                      title: Text(
                        cubit.titles[cubit.currentIndex],
                      ),
                      systemOverlayStyle: SystemUiOverlayStyle(
                        statusBarColor: themeCubit.isDark
                            ? HexColor('161616')
                            : Colors.white,
                        statusBarIconBrightness: themeCubit.isDark
                            ? Brightness.light
                            : Brightness.dark,
                        systemNavigationBarColor: themeCubit.isDark
                            ? HexColor('1a1a1a')
                            : HexColor('f2f7fc'),
                        systemNavigationBarIconBrightness: Brightness.light,
                      ),
                      actions: [
                        if (cubit.currentIndex == 1 || cubit.currentIndex == 3)
                          IconButton(
                            onPressed: () {
                              if (checkCubit.hasInternet) {
                                Navigator.of(context).push(createRoute(
                                    screen: const SearchUserScreen()));
                              } else {
                                showFlutterToast(
                                    message: 'No internet Connection',
                                    state: ToastStates.error,
                                    context: context);
                              }
                            },
                            icon: const Icon(
                              EvaIcons.searchOutline,
                            ),
                            tooltip: 'Search',
                          ),
                        const SizedBox(
                          width: 6.0,
                        ),
                      ],
                    ),
                    body: cubit.screens[cubit.currentIndex],
                    bottomNavigationBar: Container(
                      color: themeCubit.isDark
                          ? HexColor('1a1a1a')
                          : HexColor('f2f7fc'),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 8.0,
                        ),
                        child: SalomonBottomBar(
                          selectedItemColor:
                              Theme.of(context).colorScheme.primary,
                          curve: Curves.easeIn,
                          duration: const Duration(milliseconds: 200),
                          items: [
                            SalomonBottomBarItem(
                              icon: const Icon(
                                EvaIcons.homeOutline,
                                size: 26.0,
                              ),
                              title: const Text(''),
                              activeIcon: const Icon(
                                EvaIcons.home,
                                size: 28.0,
                              ),
                            ),
                            SalomonBottomBarItem(
                              icon: SizedBox(
                                height: 30.0,
                                child: Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    const Align(
                                      alignment: Alignment.center,
                                      child: Icon(
                                        EvaIcons.messageCircleOutline,
                                        size: 26.0,
                                      ),
                                    ),
                                    (cubit.numberNotice > 0) ? Badge(
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      largeSize: 14,
                                      alignment: Alignment.topRight,
                                      label: Text(
                                        (cubit.numberNotice <= 99) ? '${cubit.numberNotice}' : '+99',
                                        style: const TextStyle(
                                          fontSize: 8.0,
                                        ),
                                      ),
                                    ) : Container(),
                                  ],
                                ),
                              ),
                              title: const Text(''),
                              activeIcon: SizedBox(
                                height: 35.0,
                                child: Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    const Align(
                                      alignment: Alignment.center,
                                      child: Icon(
                                        EvaIcons.messageCircle,
                                        size: 28.0,
                                      ),
                                    ),
                                    (cubit.numberNotice > 0) ? Badge(
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      largeSize: 14,
                                      alignment: Alignment.topRight,
                                      label: Text(
                                        (cubit.numberNotice <= 99) ? '${cubit.numberNotice}' : '+99',
                                        style: const TextStyle(
                                          fontSize: 8.0,
                                        ),
                                      ),
                                    ) : Container(),
                                  ],
                                ),
                              ),
                            ),
                            SalomonBottomBarItem(
                              icon: const Icon(
                                Icons.add_circle_rounded,
                                size: 35.0,
                              ),
                              title: const Text(''),
                            ),
                            SalomonBottomBarItem(
                                icon: const Icon(
                                  EvaIcons.peopleOutline,
                                  size: 26.0,
                                ),
                                title: const Text(''),
                                activeIcon: const Icon(
                                  EvaIcons.people,
                                  size: 28.0,
                                )),
                            SalomonBottomBarItem(
                              icon: const Icon(
                                EvaIcons.settingsOutline,
                                size: 26.0,
                              ),
                              title: const Text(''),
                              activeIcon: const Icon(
                                EvaIcons.settings,
                                size: 28.0,
                              ),
                            ),
                          ],
                          currentIndex: cubit.currentIndex,
                          onTap: (index) => cubit.changeBottomNav(index),
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
}
