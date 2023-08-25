// import 'dart:async';
// import 'package:chat/layout/appLayout/AppLayout.dart';
// import 'package:chat/modules/startup/loginScreen/LoginScreen.dart';
// import 'package:chat/shared/adaptive/circularIndicator/CircularIndicator.dart';
// import 'package:chat/shared/components/Components.dart';
// import 'package:chat/shared/components/Constants.dart';
// import 'package:chat/shared/cubit/registerCubit/RegisterCubit.dart';
// import 'package:chat/shared/cubit/registerCubit/RegisterStates.dart';
// import 'package:chat/shared/cubit/themeCubit/ThemeCubit.dart';
// import 'package:chat/shared/cubit/themeCubit/ThemeStates.dart';
// import 'package:chat/shared/network/local/CacheHelper.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// class VerificationEmailScreen extends StatefulWidget {
//   const VerificationEmailScreen({super.key});
//
//   @override
//   State<VerificationEmailScreen> createState() =>
//       _VerificationEmailScreenState();
// }
//
// class _VerificationEmailScreenState extends State<VerificationEmailScreen> {
//
//   Timer? time;
//
//   int numberSeconds = 200;
//
//   void startTimer() {
//     time = Timer.periodic(const Duration(seconds: 1), (timer) {
//       setState(() {
//         numberSeconds--;
//         if (numberSeconds == 10) {
//           showFlutterToast(
//               message: '10 seconds left',
//               state: ToastStates.warning,
//               context: context);
//         }
//         if (numberSeconds <= 0) {
//           showFlutterToast(
//               message: '0 seconds left',
//               state: ToastStates.error,
//               context: context);
//           numberSeconds = 0;
//           showAlertVerify(context);
//           time?.cancel();
//         }
//       });
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     startTimer();
//   }
//
//   @override
//   void dispose() {
//     time?.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<ThemeCubit, ThemeStates>(
//       listener: (context, state) {},
//       builder: (context, state) {
//         return BlocConsumer<RegisterCubit, RegisterStates>(
//           listener: (context, state) {
//             if (state is SuccessAutoVerifiedEmailRegisterState) {
//               if (RegisterCubit.get(context).isVerified == true) {
//                 Future.delayed(const Duration(seconds: 1)).then((value) {
//                   navigateAndNotReturn(
//                       context: context, screen: const AppLayout());
//                 });
//               }
//             }
//
//             if (state is SuccessDeleteUserRegisterState) {
//               Future.delayed(const Duration(seconds: 1)).then((value) {
//                 CacheHelper.removeData(key: 'uId');
//                 Navigator.pop(context);
//                 navigateAndNotReturn(
//                     context: context, screen: const LoginScreen());
//               });
//             }
//           },
//           builder: (context, state) {
//             var cubit = RegisterCubit.get(context);
//
//             return Scaffold(
//               appBar: AppBar(
//                 title: const Text(
//                   'Verification Email',
//                 ),
//               ),
//               body: (!cubit.isVerified)
//                   ? const Center(
//                       child: Padding(
//                         padding: EdgeInsets.all(8.0),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               'Check Your Email',
//                               style: TextStyle(
//                                 fontSize: 26.0,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             SizedBox(
//                               height: 30.0,
//                             ),
//                             Text(
//                               'We sent a link to your email to verify it',
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 fontSize: 16.0,
//                               ),
//                             ),
//                             SizedBox(
//                               height: 30.0,
//                             ),
//                             Text(
//                               'You have 5 minutes to verify it, if you don\'t your account will be deleted.',
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 fontSize: 16.0,
//                                 color: Colors.red,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     )
//                   : Column(
//                     children: [
//                       const Expanded(
//                         child: Center(
//                           child: Text(
//                             'Done With Success!',
//                             style: TextStyle(
//                               fontSize: 26.0,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                       CircularIndicator(os: getOs()),
//                       const SizedBox(
//                         height: 16.0,
//                       ),
//                     ],
//                   ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   dynamic showAlertVerify(context) {
//     return showDialog(
//       barrierDismissible: false,
//         context: context,
//         builder: (BuildContext dialogContext) {
//           return WillPopScope(
//             onWillPop: () async {
//               return false;
//             },
//             child: AlertDialog(
//               title: const Text(
//                 'Time is up!',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 19.0,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               content: const Text(
//                 'You did not verify your email on specified time',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 17.0,
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pop(dialogContext);
//                     // showLoading(context);
//                     // RegisterCubit.get(context).deleteUser();
//                   },
//                   child: const Text(
//                     'Ok',
//                     style: TextStyle(
//                       fontSize: 16.0,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         });
//   }
// }
