import 'dart:io';

import 'package:chat/shared/adaptive/circularIndicator/CircularIndicator.dart';
import 'package:chat/shared/adaptive/circularIndicator/CircularRingIndicator.dart';
import 'package:chat/shared/components/Constants.dart';
import 'package:chat/shared/cubit/themeCubit/ThemeCubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:hexcolor/hexcolor.dart';
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
  required String? Function(String?) ? validate,
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
      color = Colors.amber;
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
