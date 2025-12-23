import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wifi_billing/app/modules/bills/controllers/bill_controller.dart';

class MonthlyBillsScreen extends GetView<BillController> {
  const MonthlyBillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Bills'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_month, size: 64),
            const SizedBox(height: 16),
            const Text('Monthly Bills View'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
