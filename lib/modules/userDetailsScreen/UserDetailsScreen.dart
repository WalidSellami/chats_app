import 'package:chat/models/userModel/UserModel.dart';
import 'package:chat/shared/adaptive/circularIndicator/CircularRingIndicator.dart';
import 'package:chat/shared/components/Components.dart';
import 'package:chat/shared/components/Constants.dart';
import 'package:chat/shared/cubit/checkCubit/CheckCubit.dart';
import 'package:chat/shared/cubit/checkCubit/CheckStates.dart';
import 'package:chat/shared/cubit/themeCubit/ThemeCubit.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserDetailsScreen extends StatelessWidget {

  final UserModel user;

  const UserDetailsScreen({super.key , required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CheckCubit , CheckStates>(
      listener: (context , state) {},
      builder: (context , state) {

        var checkCubit = CheckCubit.get(context);

        return (checkCubit.hasInternet) ? Scaffold(
          appBar: defaultAppBar(
            onPress: () {
              Navigator.pop(context);
            },
            text: '${user.userName}',
          ),
          body: Padding(
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
                            showImage(context, 'image-cover', user.imageCover);
                          },
                          child: Hero(
                            tag: 'image-cover',
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.0,),
                              ),
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              child: Image.network('${user.imageCover}',
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
                          showImage(context, 'image-profile', user.imageProfile);
                        },
                        child: Hero(
                          tag: 'image-profile',
                          child: Container(
                            decoration: const BoxDecoration(),
                            child: CircleAvatar(
                              radius: 62.0,
                              backgroundColor: ThemeCubit.get(context).isDark ? Colors.white : Colors.black,
                              child: CircleAvatar(
                                radius: 60.0,
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                backgroundImage: NetworkImage('${user.imageProfile}'),
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
                  '${user.userName}',
                  style: const TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if(user.bio != null || user.bio != '')
                  const SizedBox(
                    height: 15.0,
                  ),
                if(user.bio != null || user.bio != '')
                  Text(
                    '${user.bio}',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(
                  height: 30.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20.0,
                    horizontal: 8.0,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.email_outlined),
                          const SizedBox(
                            width: 20.0,
                          ),
                          Text(
                            '${user.email}',
                            style: const TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      Row(
                        children: [
                          const Icon(Icons.phone),
                          const SizedBox(
                            width: 20.0,
                          ),
                          Text(
                            user.phone ?? '',
                            style: const TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
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
        );
      },
    );
  }
}
