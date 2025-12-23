import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wifi_billing/app/modules/bills/controllers/bill_controller.dart';

class BillsYearScreen extends GetView<BillController> {
  const BillsYearScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bills'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long, size: 64),
            const SizedBox(height: 16),
            const Text('Bills Year View'),
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
