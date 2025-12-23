import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wifi_billing/app/data/models/user_model.dart';
import 'package:wifi_billing/app/modules/bills/controllers/bill_controller.dart';
import 'package:wifi_billing/app/routes/app_routes.dart';

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  late UserModel user;
  final billController = Get.find<BillController>();
  double totalPaid = 0.0;
  double pendingAmount = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    user = Get.arguments['user'] as UserModel;
    _loadUserStats();
  }

  Future<void> _loadUserStats() async {
    setState(() => isLoading = true);
    totalPaid = await billController.getTotalPaidForUser(user.id!);
    pendingAmount = await billController.getPendingAmountForUser(user.id!);
    await billController.loadBillsByUser(user.id!);
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Get.toNamed(
                AppRoutes.addEditUser,
                arguments: {'user': user},
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Section
            CircleAvatar(
              radius: 48,
              backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              child: Text(
                user.name.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  fontSize: 36,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text('UID: ${user.uid}'),
            const SizedBox(height: 4),
            Text(user.phone),
            const SizedBox(height: 4),
            Text(user.address),
            const SizedBox(height: 24),

            // Stats Grid
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text('Total Paid'),
                          const SizedBox(height: 8),
                          Text(
                            'Rs ${totalPaid.toStringAsFixed(0)}',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text('Pending'),
                          const SizedBox(height: 8),
                          Text(
                            'Rs ${pendingAmount.toStringAsFixed(0)}',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Bills Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bills',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {
                    Get.toNamed(
                      AppRoutes.addEditBill,
                      arguments: {'userId': user.id},
                    );
                  },
                  child: const Text('Add Bill'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Obx(() => ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: billController.bills.length,
                  itemBuilder: (context, index) {
                    final bill = billController.bills[index];
                    return Card(
                      child: ListTile(
                        title: Text('${bill.month}/${bill.year}'),
                        subtitle: Text(bill.notes ?? ''),
                        trailing: Text(
                          'Rs ${bill.amount.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                )),
          ],
        ),
      ),
    );
  }
}
