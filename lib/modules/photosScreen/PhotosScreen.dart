import 'package:chat/shared/adaptive/circularIndicator/CircularIndicator.dart';
import 'package:chat/shared/adaptive/circularIndicator/CircularRingIndicator.dart';
import 'package:chat/shared/components/Components.dart';
import 'package:chat/shared/components/Constants.dart';
import 'package:chat/shared/cubit/appCubit/AppCubit.dart';
import 'package:chat/shared/cubit/appCubit/AppStates.dart';
import 'package:chat/shared/cubit/checkCubit/CheckCubit.dart';
import 'package:chat/shared/cubit/checkCubit/CheckStates.dart';
import 'package:chat/shared/cubit/themeCubit/ThemeCubit.dart';
import 'package:chat/shared/cubit/themeCubit/ThemeStates.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class PhotosScreen extends StatefulWidget {
  const PhotosScreen({super.key});

  @override
  State<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends State<PhotosScreen> {
  GlobalKey globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        AppCubit.get(context).getAllImagesProfileCover();
        return BlocConsumer<CheckCubit , CheckStates>(
          listener: (context , state) {},
          builder: (context , state) {

            var checkCubit = CheckCubit.get(context);

            return BlocConsumer<ThemeCubit, ThemeStates>(
              listener: (context, state) {},
              builder: (context, state) {
                return BlocConsumer<AppCubit, AppStates>(
                  listener: (context, state) {
                    if(state is SuccessDeleteImageProfileCoverAppState) {
                      showFlutterToast(message: 'Deleted Successfully', state: ToastStates.success, context: context);
                      AppCubit.get(context).getAllImagesProfileCover();
                    }

                    if(state is ErrorDeleteImageProfileCoverAppState) {
                      showFlutterToast(message: '${state.error}', state: ToastStates.error, context: context);
                    }

                  },
                  builder: (context, state) {
                    var cubit = AppCubit.get(context);
                    var photos = cubit.allImagesProfileCover;

                    return WillPopScope(
                      onWillPop: () async {
                        cubit.clearImagesProfileCover();
                        return true;
                      },
                      child: Scaffold(
                        appBar: defaultAppBar(
                          onPress: () {
                            cubit.clearImagesProfileCover();
                            Navigator.pop(context);
                          },
                          text: 'My Photos',
                        ),
                        body: (checkCubit.hasInternet) ? ConditionalBuilder(
                          condition: photos.isNotEmpty,
                          builder: (context) => Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: MasonryGridView.count(
                              physics: const BouncingScrollPhysics(),
                              crossAxisCount: 3,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              itemBuilder: (context, index) =>
                                  buildItemPhoto(photos[index], index, context),
                              itemCount: photos.length,
                            ),
                          ),
                          fallback: (context) =>
                          (state is LoadingGetAllImagesProfileCoverAppState)
                              ? Center(child: CircularIndicator(os: getOs()))
                              : const Center(
                            child: Text(
                              'There is no photos uploaded\n for profile and cover',
                              textAlign: TextAlign.center,
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
                      ),
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

  buildItemPhoto(image, index, context) => GestureDetector(
        onTap: () {
          showFullImageAndSave(context, globalKey, index.toString(), image, isMyPhotos: true);
        },
        child: Hero(
          tag: index.toString(),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(16),
                topLeft: Radius.circular(0),
                topRight: Radius.circular(16),
              ),
              border: Border.all(
                width: 0.0,
                color: ThemeCubit.get(context).isDark
                    ? Colors.white
                    : Colors.grey.shade900,
              ),
            ),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: Image.network(
              '$image',
              width: 120.0,
              height: 120.0,
              fit: BoxFit.cover,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                return child;
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                } else {
                  return Container(
                    width: 100.0,
                    height: 100.0,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(0),
                        bottomRight: Radius.circular(16),
                        topLeft: Radius.circular(0),
                        topRight: Radius.circular(16),
                      ),
                      border: Border.all(
                        width: 0.8,
                        color: ThemeCubit.get(context).isDark
                            ? Colors.white
                            : Colors.grey.shade900,
                      ),
                    ),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: Center(child: CircularRingIndicator(os: getOs())),
                  );
                }
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 100.0,
                  height: 100.0,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(16),
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(16),
                    ),
                    border: Border.all(
                      width: 0.8,
                      color: ThemeCubit.get(context).isDark
                          ? Colors.white
                          : Colors.grey.shade900,
                    ),
                  ),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: const Center(
                    child: Text(
                      'Failed to load',
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
}
