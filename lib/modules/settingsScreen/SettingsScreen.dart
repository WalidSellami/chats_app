import 'package:chat/modules/editProfileScreen/EditProfileScreen.dart';
import 'package:chat/modules/startup/loginScreen/LoginScreen.dart';
import 'package:chat/shared/adaptive/circularIndicator/CircularRingIndicator.dart';
import 'package:chat/shared/components/Components.dart';
import 'package:chat/shared/components/Constants.dart';
import 'package:chat/shared/cubit/appCubit/AppCubit.dart';
import 'package:chat/shared/cubit/appCubit/AppStates.dart';
import 'package:chat/shared/cubit/checkCubit/CheckCubit.dart';
import 'package:chat/shared/cubit/checkCubit/CheckStates.dart';
import 'package:chat/shared/cubit/themeCubit/ThemeCubit.dart';
import 'package:chat/shared/cubit/themeCubit/ThemeStates.dart';
import 'package:chat/shared/network/local/CacheHelper.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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

            return BlocConsumer<AppCubit , AppStates>(
              listener: (context , state) {},
              builder: (context , state) {

                var cubit = AppCubit.get(context);
                var userProfile = cubit.userProfile;

                return Scaffold(
                  body: (checkCubit.hasInternet) ? SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 230.0,
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: GestureDetector(
                                    onTap: () {
                                      showImage(context, 'image-cover', userProfile?.imageCover);
                                    },
                                    child: Hero(
                                      tag: 'image-cover',
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(4.0,),
                                        ),
                                        clipBehavior: Clip.antiAliasWithSaveLayer,
                                        child: Image.network('${userProfile?.imageCover}',
                                          width: double.infinity,
                                          height: 180.0,
                                          fit: BoxFit.cover,
                                          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                                            return child;
                                          },
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if(loadingProgress == null) {
                                              return child;
                                            } else {
                                              return Container(
                                                width: double.infinity,
                                                height: 180.0,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    width: 0.0,
                                                    color: Colors.grey.shade900,
                                                  ),
                                                ),
                                                child: Center(child: CircularRingIndicator(os: getOs())),
                                              );
                                            }
                                          },
                                          errorBuilder: (context, error, stackTrace) {
                                            return const SizedBox(
                                              width: double.infinity,
                                              height: 180.0,
                                              child: Center(child:Text('Failed to load' , style: TextStyle(fontSize: 14.0,),)),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showImage(context, 'image-profile', userProfile?.imageProfile);
                                  },
                                  child: Hero(
                                    tag: 'image-profile',
                                    child: Container(
                                      decoration: const BoxDecoration(),
                                      child: CircleAvatar(
                                        radius: 62.0,
                                        backgroundColor: themeCubit.isDark ? Colors.white : Colors.black,
                                        child: CircleAvatar(
                                          radius: 60.0,
                                          backgroundColor: Theme.of(context).colorScheme.primary,
                                          backgroundImage: NetworkImage('${userProfile?.imageProfile}'),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 15.0,
                          ),
                          Text(
                            '${userProfile?.userName}',
                            style: const TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if(userProfile?.bio != null || userProfile?.bio != '')
                            const SizedBox(
                              height: 15.0,
                            ),
                          if(userProfile?.bio != null || userProfile?.bio != '')
                            Text(
                              '${userProfile?.bio}',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          SwitchListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0,),
                            ),
                            enableFeedback: true,
                            activeTrackColor: Theme.of(context).colorScheme.primary.withOpacity(.3),
                            selected: themeCubit.isDark,
                            activeColor: Theme.of(context).colorScheme.primary,
                            title: const Text(
                              'Dark Mode',
                              style: TextStyle(
                                fontSize: 17.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            value: themeCubit.isDark,
                            onChanged: (value) {
                              themeCubit.changeMode(value);
                            },
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0,),
                            ),
                            onTap: () {
                              Navigator.of(context).push(createSecondRoute(screen: const EditProfileScreen()));
                            },
                            leading: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              child: const Icon(
                                EvaIcons.edit,
                                color: Colors.white,
                              ),
                            ),
                            title: const Text(
                              'Edit Profile',
                              style: TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 17.0,
                            ),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0,),
                            ),
                            onTap: () {
                              showAlert(context);
                            },
                            leading: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              child: const Icon(
                                EvaIcons.logOutOutline,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              'Log Out',
                              style: TextStyle(
                                fontSize: 17.5,
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ) : const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'No Internet',
                          style: TextStyle(
                            fontSize: 19.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          width: 8.0,
                        ),
                        Icon(EvaIcons.wifiOffOutline),
                      ],
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
        builder: (dialogContext) {
           return AlertDialog(
             shape: RoundedRectangleBorder(
               borderRadius: BorderRadius.circular(14.0,),
             ),
             title: const Text(
               'Do you want to log out ?',
               style: TextStyle(
                 fontSize: 18.0,
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
                   Navigator.pop(dialogContext);
                   showLoading(context);
                   Future.delayed(const Duration(seconds: 1)).then((value) {
                     FirebaseAuth.instance.signOut();
                     CacheHelper.removeData(key: 'uId').then((value) {
                       if(value == true) {
                         Navigator.pop(context);
                         navigateAndNotReturn(context: context, screen: const LoginScreen());
                         AppCubit.get(context).currentIndex = 0;
                       }
                     });
                   });
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
           );
        },
    );
  }


}
