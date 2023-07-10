import 'package:chat/models/postModel/PostModel.dart';
import 'package:chat/models/userModel/UserModel.dart';
import 'package:chat/modules/commentScreen/CommentsScreen.dart';
import 'package:chat/modules/commentScreen/PostCommentScreen.dart';
import 'package:chat/modules/usersLikeScreen/UsersLikeScreen.dart';
import 'package:chat/shared/adaptive/circularIndicator/CircularIndicator.dart';
import 'package:chat/shared/adaptive/circularIndicator/CircularRingIndicator.dart';
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

class HomeScreen extends StatefulWidget {

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  GlobalKey globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    AppCubit.get(context).getUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        if(CheckCubit.get(context).hasInternet) {
          AppCubit.get(context).getPosts();
          AppCubit.get(context).getAllUsers();
        }
        return BlocConsumer<CheckCubit , CheckStates>(
          listener: (context , state) {},
          builder: (context , state) {

            var checkCubit = CheckCubit.get(context);

            return BlocConsumer<AppCubit , AppStates>(
              listener: (context , state) {
                if(state is SuccessDeletePostAppState) {
                  showFlutterToast(message: 'Deleted successfully', state: ToastStates.success, context: context);
                }
              },
              builder: (context , state) {

                var cubit = AppCubit.get(context);
                var user = cubit.userProfile;
                var posts = cubit.posts;
                var postsId = cubit.postsId;
                var numberLikes = cubit.numberLikes;
                var numberComments = cubit.numberComments;

                return Scaffold(
                  body: (checkCubit.hasInternet) ? ConditionalBuilder(
                    condition: posts.isNotEmpty,
                    builder: (context) => RefreshIndicator(
                      key: refreshIndicatorKey,
                      color: Theme.of(context).colorScheme.primary,
                      backgroundColor: ThemeCubit.get(context).isDark
                          ? HexColor('181818')
                          : Colors.white,
                      strokeWidth: 2.5,
                      onRefresh: () async {
                        cubit.getPosts();
                        return Future<void>.delayed(const Duration(seconds: 2));
                      },
                      child: ListView.builder(
                        itemBuilder: (context , index) => buildItemPost(user , posts[index], postsId[index] , numberLikes , numberComments , context),
                        itemCount: posts.length,
                      ),
                    ),
                    fallback: (context) => (state is LoadingGetPostsAppState) ?  Center(child: CircularIndicator(os: getOs())) :
                    const Center(
                      child: Text(
                        'There is no posts',
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

  Widget buildItemPost(UserModel? user , PostModel post , postId , numberLikes , numberComments  , context) => Card(
    elevation: 3.0,
    margin: const EdgeInsets.symmetric(
      horizontal: 10.0,
      vertical: 8.0,
    ),
    clipBehavior: Clip.antiAliasWithSaveLayer,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20.0,
                backgroundColor: Theme.of(context).colorScheme.primary,
                backgroundImage: NetworkImage('${post.imageProfile}'),
              ),
              const SizedBox(
                width: 20.0,
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${post.userName} ',
                          maxLines: 1,
                          style: const TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(
                          Icons.check_circle_outline_outlined,
                          size: 19.0,
                          color: Colors.blue.shade700,
                        ),
                      ],
                    ),
                    Text(
                      '${post.datePost}',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                  onPressed: () {
                    AppCubit.get(context).deletePost(postId: postId , postImage: post.imagePost);
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                  ),
                tooltip: 'Remove',
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 8.0,
            ),
            child: Divider(
              thickness: 0.7,
              color: Colors.grey.shade500,
            ),
          ),
          Text(
            '${post.text}',
          ),
          if(post.tagPost != '')
          const SizedBox(
            height: 8.0,
          ),
          if(post.tagPost != '')
            Wrap(
            children: [
              (post.tagPost?.substring(0,1) != '#') ? Text(
                '#${post.tagPost}',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ) : Text(
                '${post.tagPost}',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 8.0,
          ),
          if(post.imagePost != '')
          GestureDetector(
            onTap: () {
              showFullImageAndSave(context, globalKey , 'image', post.imagePost);
            },
            child: Hero(
              tag: 'image',
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0,),
                  border: Border.all(
                    width: 0.0,
                    color: ThemeCubit.get(context).isDark ? Colors.white : Colors.grey.shade900,
                  ),
                ),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Image.network('${post.imagePost}',
                  width: double.infinity,
                  height: 160.0,
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
                        height: 160.0,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 0.2,
                            color: ThemeCubit.get(context).isDark ? Colors.white : Colors.grey.shade900,
                          ),
                        ),
                        child: Center(child: CircularRingIndicator(os: getOs())),
                      );
                    }
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 160.0,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 0.4,
                          color: ThemeCubit.get(context).isDark ? Colors.white : Colors.grey.shade900,
                        ),
                      ),
                      child: const Center(child:Text('Failed to load' , style: TextStyle(fontSize: 13.0,),)),
                    );
                  },
                ),
              ),
            ),
          ),
          if(post.imagePost != '')
            const SizedBox(
            height: 8.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(4.0),
                onTap: () {
                  AppCubit.get(context).getUsersLikes(postId: postId);
                  Navigator.of(context).push(createRoute(screen: UsersLikeScreen(postId: postId)));
                },
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    children: [
                      Icon(
                        (numberLikes[postId] != 0) ? Icons.favorite_outlined : Icons.favorite_outline_rounded,
                        size: 19.0,
                        color: HexColor('f9325f'),
                      ),
                      Text(
                        ' ${numberLikes[postId] ?? 0}',
                        style: const TextStyle(
                          fontSize: 14.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(4.0),
                onTap: () {
                  AppCubit.get(context).getPostComments(postId: postId);
                  Navigator.of(context).push(createRoute(screen: CommentsScreen(postId: postId,)));
                },
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    children: [
                      Icon(
                        EvaIcons.messageCircleOutline,
                        size: 19.0,
                        color: Colors.amber.shade700,
                      ),
                      Text(
                        ' ${numberComments[postId] ?? 0} comment(s)',
                        style: const TextStyle(
                          fontSize: 14.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 4.0,
            ),
            child: Divider(
              thickness: 0.7,
              color: Colors.grey.shade500,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18.0,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    backgroundImage: NetworkImage('${post.imageProfile}'),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(4.0),
                    onTap: () {
                      Navigator.of(context).push(createRoute(screen: PostCommentScreen(postId: postId)));
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Text(
                        ' Write a comment ...',
                        style: TextStyle(
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(
                  right: 8.0,
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(4.0),
                  onTap: () {

                    if(post.like == false) {

                      AppCubit.get(context).likePost(
                          userName: (user?.userName).toString(),
                          imageProfile: (user?.imageProfile).toString(),
                          imageCover: (user?.imageCover).toString(),
                          email: (user?.email).toString(),
                          phone: (user?.phone).toString(),
                          bio: (user?.bio).toString(),
                          postId: postId);

                    } else {

                      AppCubit.get(context).dislikePost(postId: postId);

                    }

                  },
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      children: [
                        ((post.like == true)) ? Icon(
                            Icons.favorite_rounded,
                          size: 19.0,
                          color: HexColor('f9325f'),
                        ) : Icon(
                          Icons.favorite_outline_rounded,
                          size: 19.0,
                          color: HexColor('f9325f'),
                        ),
                        (post.like == true) ? const Text(
                          ' Liked',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 13.0,
                          ),
                        ) : const Text(
                           ' Like',
                          style: TextStyle(
                            fontSize: 13.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );


}
