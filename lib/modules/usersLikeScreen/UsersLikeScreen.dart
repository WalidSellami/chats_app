import 'package:chat/models/userModel/UserModel.dart';
import 'package:chat/modules/userDetailsScreen/UserDetailsScreen.dart';
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

class UsersLikeScreen extends StatefulWidget {

  final String postId;

  const UsersLikeScreen({super.key , required this.postId});

  @override
  State<UsersLikeScreen> createState() => _UsersLikeScreenState();
}

class _UsersLikeScreenState extends State<UsersLikeScreen> {


  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CheckCubit , CheckStates>(
      listener: (context , state) {},
      builder: (context , state) {

        var checkCubit = CheckCubit.get(context);

        return BlocConsumer<AppCubit , AppStates>(
          listener: (context , state) {},
          builder: (context , state) {

            var cubit = AppCubit.get(context);
            var usersLikes = cubit.usersLikes;


            return Scaffold(
              appBar: defaultAppBar(
                onPress: () {
                  Navigator.pop(context);
                },
                text: 'Likes',
              ),
              body: (checkCubit.hasInternet) ? ConditionalBuilder(
                condition: usersLikes.isNotEmpty,
                builder: (context) => RefreshIndicator(
                  key: refreshIndicatorKey,
                  color: Theme.of(context).colorScheme.primary,
                  backgroundColor: ThemeCubit.get(context).isDark
                      ? HexColor('181818')
                      : Colors.white,
                  strokeWidth: 2.5,
                  onRefresh: () async {
                    cubit.getUsersLikes(postId: widget.postId);
                    return Future<void>.delayed(const Duration(seconds: 2));
                  },
                  child: ListView.separated(
                      itemBuilder: (context , index) => buildItemUserLike(usersLikes[index], context),
                      separatorBuilder: (context , index) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30.0,
                        ),
                        child: Divider(
                          thickness: 0.7,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      itemCount: 1),
                ),
                fallback: (context) => (state is LoadingGetUsersLikesAppState)  ? Center(child: CircularIndicator(os: getOs()))
                    : const Center(
                  child: Text(
                    'There is no one',
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

  Widget buildItemUserLike(UserModel user , context) => InkWell(
    onTap: () {
      Navigator.of(context).push(createRoute(screen: UserDetailsScreen(user: user)));
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 10.0,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24.0,
            backgroundColor: Theme.of(context).colorScheme.primary,
            backgroundImage: NetworkImage('${user.imageProfile}'),
          ),
          const SizedBox(
            width: 25.0,
          ),
          Expanded(
            child: Text(
              '${user.userName}',
              maxLines: 1,
              style: const TextStyle(
                fontSize: 16.0,
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
