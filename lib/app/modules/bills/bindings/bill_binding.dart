import 'package:get/get.dart';
import 'package:wifi_billing/app/modules/bills/controllers/bill_controller.dart';

class BillBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BillController>(() => BillController());
  }
}
