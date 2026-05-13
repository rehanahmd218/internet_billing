// GetX Controller for navigation
import 'package:get/get.dart';

class NavigationController extends GetxController {
  final _currentIndex = 0.obs; // Start at Dashboard (index 0)
  int get currentIndex => _currentIndex.value;

  void changeIndex(int index) {
    _currentIndex.value = index;
  }
}