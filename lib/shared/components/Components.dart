import 'dart:io';
import 'dart:ui' as ui;
import 'package:chat/shared/adaptive/circularIndicator/CircularIndicator.dart';
import 'package:chat/shared/adaptive/circularIndicator/CircularRingIndicator.dart';
import 'package:chat/shared/components/Constants.dart';
import 'package:chat/shared/cubit/appCubit/AppCubit.dart';
import 'package:chat/shared/cubit/themeCubit/ThemeCubit.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';

navigateTo({required BuildContext context, required Widget screen}) =>
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));

navigateAndNotReturn({required BuildContext context, required Widget screen}) =>
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => screen), (route) => false);

Route createRoute({required screen}) {
  return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeIn;

        var tween =
        Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      });
}

Route createSecondRoute({required screen}) {
  return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeIn;

        var tween =
        Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      });
}

Widget defaultFormField({
  required TextEditingController controller,
  required TextInputType type,
  required String label,
  required String? Function(String?)? validate,
  FocusNode? focusNode,
  IconData? prefixIcon,
  IconData? suffixIcon,
  bool isPassword = false,
  String? Function(String?)? onSubmit,
  String? Function(String?)? onChange,
  Function? onPress,
}) =>
    TextFormField(
      controller: controller,
      keyboardType: type,
      obscureText: isPassword,
      focusNode: focusNode,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
      onFieldSubmitted: (v) {
        onSubmit!(v);
      },
      validator: validate,
      decoration: InputDecoration(
        labelText: label,
        errorMaxLines: 3,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            8.0,
          ),
          borderSide: const BorderSide(
            width: 2.0,
          ),
        ),
        prefixIcon: Icon(prefixIcon),
        suffixIcon: (suffixIcon != null)
            ? IconButton(
                onPressed: () {
                  onPress!();
                },
                icon: Icon(suffixIcon),
              )
            : null,
      ),
    );

Widget defaultButton({
  double width = double.infinity,
  double height = 48.0,
  required String text,
  required Function onPress,
  required BuildContext context,
}) =>
    SizedBox(
      width: width,
      child: MaterialButton(
        height: height,
        color: ThemeCubit.get(context).isDark ? HexColor('2183D2') : HexColor('0070CC'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0,),
        ),
        onPressed: () {
          onPress();
        },
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 17.5,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );


Widget defaultTextButton({
  required String text,
  required Function onPress,
}) => TextButton(
    onPressed: () {
      onPress();
    },
    child: Text(
      text,
    style: const TextStyle(
      fontSize: 16.5,
      fontWeight: FontWeight.bold,
    ),
    ),
);


defaultAppBar({
  String? text,
  required Function onPress,
  List<Widget>? actions,
}) => AppBar(
  leading: IconButton(
      onPressed: () {
        onPress();
      },
      icon: const Icon(
        Icons.arrow_back_ios_new_outlined,
      ),
    tooltip: 'Back',
  ),
  title: Text(
    text ?? '',
  ),
  titleSpacing: 5.0,
  actions: actions,
);


// States of notification
enum ToastStates {success , error , warning}

void showFlutterToast({
  required String message,
  required ToastStates state,
  required BuildContext context,
}) =>
    showToast(
      message,
      context: context,
      backgroundColor: chooseToastColor(s: state),
      animation: StyledToastAnimation.scale,
      reverseAnimation: StyledToastAnimation.fade,
      position: StyledToastPosition.bottom,
      animDuration: const Duration(milliseconds: 1500),
      duration: const Duration(seconds: 3),
      curve: Curves.elasticInOut,
      reverseCurve: Curves.linear,
    );


Color chooseToastColor({
  required ToastStates s,
  context,
}) {
  Color? color;
  switch (s) {
    case ToastStates.success:
      color = HexColor('009b9b');
      break;
    case ToastStates.error:
      color = Colors.red;
      break;
    case ToastStates.warning:
      color = Colors.amber.shade800;
      break;
  }
  return color;
}

dynamic showLoading(BuildContext context) {
  return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: Center(
            child: Container(
                padding: const EdgeInsets.all(26.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14.0),
                  color: ThemeCubit.get(context).isDark ? HexColor('222222') : Colors.white,
                ),
                child: CircularIndicator(os: getOs())),
          ),
        );
      });
}




dynamic showImage(BuildContext context , String tag , image , {XFile? imageUpload}) {

  return navigateTo(context: context, screen: Scaffold(
    appBar: defaultAppBar(
        onPress: () {
          Navigator.pop(context);
        }),
    body: Center(
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Hero(
          tag: tag,
          child: Container(
            decoration: const BoxDecoration(),
            child: (imageUpload == null) ? Image.network('$image',
             width: double.infinity,
             height: 450.0,
             fit: BoxFit.fitWidth,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                return child;
              },
              loadingBuilder: (context, child, loadingProgress) {
                if(loadingProgress == null) {
                  return child;
                } else {
                  return Container(
                    width: double.infinity,
                    height: 450.0,
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
                  height: 450.0,
                  child: Center(child:Text('Failed to load' , style: TextStyle(fontSize: 14.0,),)),
                );
              },
            ) : Image.file(File(imageUpload.path),
              width: double.infinity,
              height: 450.0,
              fit: BoxFit.fitWidth,
            ),
          ),
        ),
      ),
    ),
  ),
  );
}



Future<void> saveImage(GlobalKey globalKey , context) async {

  double devicePixelRatio = MediaQuery
      .of(context)
      .devicePixelRatio;

  await Future.delayed(const Duration(milliseconds: 300)).then((value) async {

    RenderRepaintBoundary boundary = globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary;

    ui.Image? image = await boundary.toImage(pixelRatio: devicePixelRatio);

    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    Uint8List? pngBytes = byteData?.buffer.asUint8List();

    // Save the image to the device's gallery
    await ImageGallerySaver.saveImage(pngBytes!);


  });


}



dynamic showFullImageAndSave(BuildContext context , globalKey , String tag , image , {bool isMyPhotos = false}) {

  return navigateTo(context: context, screen: Scaffold(
        appBar: defaultAppBar(
          onPress: () {
            Navigator.pop(context);
          },
          actions: [
            (isMyPhotos == false) ?
            IconButton(
              onPressed: () async {
                await saveImage(globalKey , context).then((value) {
                  Navigator.pop(context);
                  showFlutterToast(message: 'The image has been saved to your gallery', state: ToastStates.success, context: context);
                }).catchError((error) {
                  showFlutterToast(message: '$error', state: ToastStates.error, context: context);
                });
              },
              icon: Icon(
                EvaIcons.downloadOutline,
                color: Theme.of(context).colorScheme.primary,
              ),
              tooltip: 'Save',
            ) :
            PopupMenuButton(
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                    value: 'save',
                    child: Row(
                      children: [
                        Icon(
                          EvaIcons.downloadOutline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(
                          width: 4.0,
                        ),
                        const Text('Save'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(
                          Icons.close_rounded,
                          color: Colors.red,
                        ),
                        SizedBox(
                          width: 4.0,
                        ),
                        Text('Remove'),
                      ],
                    ),
                  ),
                  // Add more PopupMenuItems as needed
                ];
              },
              onSelected: (value) async {
                if(value == 'save') {
                  await saveImage(globalKey , context).then((value) {
                    Navigator.pop(context);
                    showFlutterToast(message: 'The image has been saved to your gallery', state: ToastStates.success, context: context);
                  }).catchError((error) {
                    showFlutterToast(message: '$error', state: ToastStates.error, context: context);
                  });
                } else if (value == 'remove') {
                  AppCubit.get(context).deleteImageProfileCover(image);
                  Navigator.pop(context);
                }
              },
            ),
            const SizedBox(
              width: 6.0,
            ),
          ],
        ),
        body: Center(
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: RepaintBoundary(
              key: globalKey,
              child: Hero(
                tag: tag,
                child: Container(
                  decoration: const BoxDecoration(),
                  child: Image.network('$image',
                    width: double.infinity,
                    height: 450.0,
                    fit: BoxFit.fitWidth,
                    frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                      return child;
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if(loadingProgress == null) {
                        return child;
                      } else {
                        return Container(
                          width: double.infinity,
                          height: 450.0,
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
                        height: 450.0,
                        child: Center(child:Text('Failed to load' , style: TextStyle(fontSize: 14.0,),)),
                      );
                    },
                  ),),
              ),
            ),
          ),
        ),
        ),
      );
}
