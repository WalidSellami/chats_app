import 'package:chat/shared/cubit/themeCubit/ThemeStates.dart';
import 'package:chat/shared/network/local/CacheHelper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<ThemeStates> {

  ThemeCubit() : super(InitialThemeState());

  static ThemeCubit get(context) => BlocProvider.of(context);

  bool isDark = false;

  void changeMode(value) {
    isDark = value;
    CacheHelper.saveData(key: 'isDark', value: isDark).then((value) {
      emit(SuccessChangeThemeState());
    });
  }


}