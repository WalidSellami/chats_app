import 'package:chat/models/userModel/UserModel.dart';
import 'package:chat/modules/chatScreen/UserChatScreen.dart';
import 'package:chat/modules/userDetailsScreen/UserDetailsScreen.dart';
import 'package:chat/shared/components/Components.dart';
import 'package:chat/shared/cubit/appCubit/AppCubit.dart';
import 'package:chat/shared/cubit/appCubit/AppStates.dart';
import 'package:chat/shared/cubit/checkCubit/CheckCubit.dart';
import 'package:chat/shared/cubit/checkCubit/CheckStates.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchUserScreen extends StatefulWidget {
  const SearchUserScreen({super.key});

  @override
  State<SearchUserScreen> createState() => _SearchUserScreenState();
}

class _SearchUserScreenState extends State<SearchUserScreen> {
  var searchController = TextEditingController();

  final focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

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
            var users = cubit.searchUsers;

            return Scaffold(
              appBar: defaultAppBar(
                onPress: () {
                  Navigator.pop(context);
                },
                text: 'Search User',
              ),
              body: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: searchController,
                      keyboardType: TextInputType.name,
                      focusNode: focusNode,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Type ...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                            width: 2.0,
                          ),
                        ),
                        prefixIcon: const Icon(
                          EvaIcons.searchOutline,
                        ),
                        suffixIcon: (searchController.text.isNotEmpty)
                            ? IconButton(
                          onPressed: () {
                            searchController.text = '';
                            cubit.clearSearchUser();
                          },
                          icon: const Icon(
                            Icons.close_rounded,
                          ),
                        )
                            : null,
                      ),
                      onChanged: (value) {
                        if(checkCubit.hasInternet) {
                          cubit.searchUser(value);
                        }
                      },
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Expanded(
                      child: (checkCubit.hasInternet) ? ConditionalBuilder(
                        condition: users.isNotEmpty,
                        builder: (context) => ListView.separated(
                          physics: const BouncingScrollPhysics(),
                            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                            itemBuilder: (context , index) => buildItemSearchUser(users[index], context),
                            separatorBuilder: (context , index) => Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                              ),
                              child: Divider(
                                thickness: 0.7,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            itemCount: users.length),
                        fallback: (context) => const Center(
                          child: Text(
                            'There is no user',
                            style: TextStyle(
                                fontSize: 17.0,
                                fontWeight: FontWeight.bold
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
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget buildItemSearchUser(UserModel user , context) => InkWell(
    borderRadius: BorderRadius.circular(4.0,),
    onTap: () {
      focusNode.unfocus();
       if(AppCubit.get(context).currentIndex == 1) {

         Navigator.of(context).push(createSecondRoute(screen: UserChatScreen(user: user)));

       } else if(AppCubit.get(context).currentIndex == 3) {

         Navigator.of(context).push(createRoute(screen: UserDetailsScreen(user: user)));
       }
    },
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
         const Text(
           '-',
           style: TextStyle(
             fontSize: 17.0,
             fontWeight: FontWeight.bold,
           ),
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
          const SizedBox(
            width: 12.0,
          ),
          const Icon(
            EvaIcons.diagonalArrowRightUpOutline,
            size: 19.0,
          ),
        ],
      ),
    ),
  );

}
