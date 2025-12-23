import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wifi_billing/app/modules/users/controllers/user_controller.dart';
import 'package:wifi_billing/app/routes/app_routes.dart';
import 'package:wifi_billing/app/widgets/loading_overlay.dart';
import 'package:wifi_billing/app/widgets/status_badge.dart';

class UsersListScreen extends GetView<UserController> {
  const UsersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => LoadingOverlay(
          isLoading: controller.isLoading.value,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Users'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: controller.refreshUsers,
                  tooltip: 'Refresh Users',
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    controller.clearForm();
                    Get.toNamed(AppRoutes.addEditUser);
                  },
                  tooltip: 'Add User',
                ),
              ],
            ),
            body: Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search Name, Mobile, UID',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.tune),
                        onPressed: () {},
                      ),
                    ),
                    onChanged: controller.searchUsers,
                  ),
                ),
                // Users List
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: controller.refreshUsers,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: controller.filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = controller.filteredUsers[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  Theme.of(context).primaryColor.withValues(alpha: 0.1),
                              child: Text(
                                user.name.substring(0, 1).toUpperCase(),
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(user.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('UID: ${user.uid}'),
                                Text(user.phone),
                              ],
                            ),
                            trailing: StatusBadge(status: user.status, showDot: true),
                            onTap: () {
                              Get.toNamed(
                                AppRoutes.userDetails,
                                arguments: {'user': user},
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
