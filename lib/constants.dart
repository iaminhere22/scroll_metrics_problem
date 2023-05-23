import 'sizes.dart';

abstract class Constants {
  static String get bar => "bar";

  static String get title => "title";

  static String get main => "main";

  static String get cell => "cell";

  static double get space => Sizes.space50 / 2;

  static double get fontSize => Sizes.space25;

  static double get mainHeight => (Sizes.screenWidth - Sizes.space50 * 1) / 7 * 6;

  static double get cellHeight => mainHeight / 6;

  static double get minHeight => Sizes.topSumHeight + cellHeight * 1.5;

  static double get maxHeight => Sizes.topSumHeight + cellHeight * 6.5;
}
