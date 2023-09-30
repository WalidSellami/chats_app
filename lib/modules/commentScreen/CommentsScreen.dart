import 'package:chat/models/commentModel/CommentModel.dart';
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

class CommentsScreen extends StatelessWidget {
  final String postId;

  const CommentsScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        if(CheckCubit.get(context).hasInternet) {
          AppCubit.get(context).getPostComments(postId: postId);
        }
        return BlocConsumer<CheckCubit , CheckStates>(
          listener: (context , state) {},
          builder: (context , state) {

            var checkCubit = CheckCubit.get(context);

            return BlocConsumer<AppCubit, AppStates>(
              listener: (context, state) {},
              builder: (context, state) {
                var cubit = AppCubit.get(context);
                var comments = cubit.comments;
                var commentsId = cubit.commentsId;

                return Scaffold(
                  appBar: defaultAppBar(
                    onPress: () {
                      Navigator.pop(context);
                    },
                    text: 'Comments',
                  ),
                  body: (checkCubit.hasInternet) ? ConditionalBuilder(
                    condition: comments.isNotEmpty,
                    builder: (context) => ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) => buildItemComment(
                          comments[index], postId, commentsId[index], context),
                      itemCount: comments.length,
                    ),
                    fallback: (context) => (state is LoadingGetCommentsAppState)
                        ? Center(child: CircularIndicator(os: getOs()))
                        : const Center(
                      child: Text(
                        'There is no comments',
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

  Widget buildItemComment(CommentModel comment, postId, commentId, context) =>
      Card(
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
                    backgroundImage: NetworkImage('${comment.imageProfile}'),
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
                              '${comment.userName} ',
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
                          '${comment.dateComment}',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if(CheckCubit.get(context).hasInternet) {
                        AppCubit.get(context).deleteComment(
                          postId: postId,
                          commentId: commentId,
                          commentImage: comment.imageComment);
                      } else {
                        showFlutterToast(message: 'No Internet Connection', state: ToastStates.error, context: context);
                      }
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                    ),
                    tooltip: 'Remove',
                  ),
                ],
              ),
              const SizedBox(
                height: 16.0,
              ),
              Text(
                '${comment.text}',
              ),
              if (comment.imageComment != '')
                GestureDetector(
                  onTap: () {
                    showImage(context, 'image', comment.imageComment);
                  },
                  child: Hero(
                    tag: 'image',
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          4.0,
                        ),
                      ),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: Image.network(
                        '${comment.imageComment}',
                        width: double.infinity,
                        height: 160.0,
                        fit: BoxFit.cover,
                        frameBuilder:
                            (context, child, frame, wasSynchronouslyLoaded) {
                          if(frame == null) {
                            return Container(
                              width: double.infinity,
                              height: 150.0,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 0.2,
                                  color: ThemeCubit.get(context).isDark
                                      ? Colors.white
                                      : Colors.grey.shade900,
                                ),
                              ),
                              child: Center(
                                  child: CircularRingIndicator(os: getOs())),
                            );
                          }
                          return child;
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          } else {
                            return Container(
                              width: double.infinity,
                              height: 150.0,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 0.2,
                                  color: ThemeCubit.get(context).isDark
                                      ? Colors.white
                                      : Colors.grey.shade900,
                                ),
                              ),
                              child: Center(
                                  child: CircularRingIndicator(os: getOs())),
                            );
                          }
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            height: 150.0,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 0.6,
                                color: ThemeCubit.get(context).isDark
                                    ? Colors.white
                                    : Colors.grey.shade900,
                              ),
                            ),
                            child: const Center(
                                child: Text(
                              'Failed to load',
                              style: TextStyle(
                                fontSize: 13.0,
                              ),
                            )),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              if (comment.imageComment != '')
                const SizedBox(
                  height: 8.0,
                ),
              const SizedBox(
                height: 8.0,
              ),
            ],
          ),
        ),
      );
}
