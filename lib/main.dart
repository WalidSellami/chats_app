import 'package:chat/layout/appLayout/AppLayout.dart';
import 'package:chat/models/dataModel/DataModel.dart';
import 'package:chat/modules/startup/loginScreen/LoginScreen.dart';
import 'package:chat/modules/startup/splashScreen/SplashScreen.dart';
import 'package:chat/shared/components/Constants.dart';
import 'package:chat/shared/cubit/appCubit/AppCubit.dart';
import 'package:chat/shared/cubit/checkCubit/CheckCubit.dart';
import 'package:chat/shared/cubit/themeCubit/ThemeCubit.dart';
import 'package:chat/shared/cubit/themeCubit/ThemeStates.dart';
import 'package:chat/shared/network/local/CacheHelper.dart';
import 'package:chat/shared/notifications/Notifications.dart';
import 'package:chat/shared/styles/Styles.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:overlay_support/overlay_support.dart';
import 'firebase_options.dart';


// Notification background
Future<void> handleBackgroundMessage(RemoteMessage message) async {

  if (kDebugMode) {
    print(message.data);
  }

  Data data = Data.fromJson(message.data);

  if((data.title != null) && (data.message != null)) {

    await Notifications().getNotification(title: data.title ?? '', body: data.message ?? '');

  }

  if (kDebugMode) {
    print('Notification from Background');
  }

}


Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Notifications().initialization();

  FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

  Notifications().onMessageListener();

  // var deviceToken = await FirebaseMessaging.instance.getToken();
  //
  // print(deviceToken);

  // FirebaseMessaging.onMessage.listen((event) async {
  //   // await Notifications().getNotification(title: 'Test', body: '......');
  //   print(event.data.toString());
  // });

  //
  // FirebaseMessaging.onMessageOpenedApp.listen((event) {
  //
  //   print(event.data.toString());
  //
  // });
  //
  //
  // FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await CacheHelper.init();

  uId = CacheHelper.getData(key: 'uId');
  var isDark = CacheHelper.getData(key: 'isDark');



  Widget? widget;

  if(uId != null) {
    widget = const AppLayout();
  } else {
    widget = const LoginScreen();
  }

  runApp(MyApp(startWidget: widget , isDark: isDark,));
}

class MyApp extends StatelessWidget {

  final Widget? startWidget;
  final bool? isDark;

  const MyApp({super.key , this.startWidget , this.isDark});



  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (BuildContext context) => AppCubit()),
        BlocProvider(create: (BuildContext context) => CheckCubit()..checkConnection(context)),
        BlocProvider(create: (BuildContext context) => ThemeCubit()..changeMode(isDark ?? false),
        ),
      ],
      child: BlocConsumer<ThemeCubit , ThemeStates>(
        listener: (context , state) {},
        builder: (context , state) {
          
          return OverlaySupport.global(
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: lightMode,
              darkTheme: darkMode,
              themeMode: ThemeCubit.get(context).isDark ? ThemeMode.dark : ThemeMode.light,
              home: SplashScreen(startWidget: startWidget!),
            ),
          );
        },
      ),
    );
  }
}
