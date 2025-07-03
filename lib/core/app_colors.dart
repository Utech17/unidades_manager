import 'dart:ui';

class AppColors {
  static const Color primary = Color(0xFF1D68FF);
  static const Color secondary = Color.fromARGB(255, 18, 85, 219);
  static const Color accent = Color.fromARGB(255, 58, 123, 255);
    static const Color error = Color.fromARGB(255, 254, 65, 65);

  //Backgrounds
  static const Color background = Color(0xFFF8F4FF);
  static const Color backgroundComponent = Color.fromARGB(255, 0, 18, 54);
  static const Color backgroundComponentSelected = Color.fromARGB(255, 94, 148, 255);
}

class AppTextColors {
  static const Color primaryText = Color.fromARGB(255, 40, 40, 40); 
  static const Color secondaryText = Color(0xFF757575); 
  static const Color disabledText = Color(0xFF9E9E9E); 
  static const Color inverseText = Color(0xFFFFFFFF);  
  static const Color errorText = AppColors.error; 
}
