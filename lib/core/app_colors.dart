import 'dart:ui';

class AppColors {
  static const Color primary = Color(0xFF606ce4);
  static const Color secondary = Color.fromARGB(255, 72, 80, 173);
  static const Color accent = Color(0xFF606ce4);
    static const Color error = Color.fromARGB(255, 254, 65, 65);

  //Backgrounds
  static const Color background = Color(0xFFF8F4FF);
  static const Color backgroundComponent = Color(0xFF260450);
  static const Color backgroundComponentSelected = Color(0xFFA472E2);
}

class AppTextColors {
  static const Color primaryText = Color.fromARGB(255, 40, 40, 40); 
  static const Color secondaryText = Color(0xFF757575); 
  static const Color disabledText = Color(0xFF9E9E9E); 
  static const Color inverseText = Color(0xFFFFFFFF);  
  static const Color errorText = AppColors.error; 
}
