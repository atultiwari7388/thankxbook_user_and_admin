import 'package:get/get.dart';

class TabIndexController extends GetxController {
  var _tabIndex = 0.obs; // ✅ Observable

  int get getTabIndex => _tabIndex.value; // ✅ Getter for observable

  set setTabIndex(int index) {
    _tabIndex.value = index; // ✅ Properly updates Rx variable
  }
}
