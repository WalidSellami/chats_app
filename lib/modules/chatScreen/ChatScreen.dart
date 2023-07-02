import 'package:chat/models/userModel/UserModel.dart';
import 'package:chat/modules/chatScreen/UserChatScreen.dart';
import 'package:chat/shared/adaptive/circularIndicator/CircularIndicator.dart';
import 'package:chat/shared/components/Components.dart';
import 'package:chat/shared/components/Constants.dart';
import 'package:chat/shared/cubit/appCubit/AppCubit.dart';
import 'package:chat/shared/cubit/appCubit/AppStates.dart';
import 'package:chat/shared/cubit/checkCubit/CheckCubit.dart';
import 'package:chat/shared/cubit/checkCubit/CheckStates.dart';
import 'package:chat/shared/cubit/themeCubit/ThemeCubit.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        AppCubit.get(context).getAllUsers();
        return BlocConsumer<CheckCubit , CheckStates>(
          listener: (context , state) {},
          builder: (context , state) {

            var checkCubit = CheckCubit.get(context);

            return BlocConsumer<AppCubit , AppStates>(
              listener: (context , state) {},
              builder: (context , state) {

                var cubit = AppCubit.get(context);
                var users = cubit.allUsers;

                return Scaffold(
                  body: (checkCubit.hasInternet) ? ConditionalBuilder(
                    condition: users.isNotEmpty,
                    builder: (context) => Column(
                      children: [
                        const SizedBox(
                          height: 8.0,
                        ),
                        Container(
                          padding: const EdgeInsets.all(8.0,),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0,),
                            color: ThemeCubit.get(context).isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                          ),
                          child: const Text(
                            'Press anyone you want to chat with',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        Expanded(
                          child: RefreshIndicator(
                            key: refreshIndicatorKey,
                            color: Theme.of(context).colorScheme.primary,
                            backgroundColor: ThemeCubit.get(context).isDark
                                ? HexColor('181818')
                                : Colors.white,
                            strokeWidth: 2.5,
                            onRefresh: () async {
                              cubit.getAllUsers();
                              return Future<void>.delayed(const Duration(seconds: 2));
                            },
                            child: ListView.separated(
                              itemBuilder: (context , index) => buildItemUser(users[index] , context),
                              separatorBuilder: (context , index) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                ),
                                child: Divider(
                                  thickness: 0.7,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              itemCount: users.length,
                            ),
                          ),
                        ),
                      ],
                    ),
                    fallback: (context) => (state is LoadingGetAllUsersAppState) ? Center(child: CircularIndicator(os: getOs())) :
                    const Center(
                      child: Text(
                        'There is no user yet',
                        style: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold,
                        ),
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
      }
    );
  }

  Widget buildItemUser(UserModel user , context) => InkWell(
    onTap: () {
      Navigator.of(context).push(createSecondRoute(screen: UserChatScreen(user: user)));
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 12.0,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26.0,
            backgroundColor: Theme.of(context).colorScheme.primary,
            backgroundImage: NetworkImage('${user.imageProfile}'),
          ),
          const SizedBox(
            width: 20.0,
          ),
          Expanded(
            child: Text(
              '${user.userName}',
              maxLines: 1,
              style: const TextStyle(
                fontSize: 17.0,
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_outlined,
            size: 18.0,
          ),
        ],
      ),
    ),
  );
}
