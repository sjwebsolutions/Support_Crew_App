import 'package:get/get.dart';

class NotificationController extends GetxController {
  var isViewed = false.obs;

  void markAsViewed() {
    isViewed.value = true;
  }

  void resetViewedStatus() {
    isViewed.value = false;
  }
}
