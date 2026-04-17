import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toibook_app/screens/login_screen.dart';
import 'package:toibook_app/services/auth_service.dart';
import 'package:toibook_app/widgets/change_name_dialog.dart';
import 'package:toibook_app/widgets/city_picker.dart';
import '../../../providers/toi_provider.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ToiProvider>();
    final user = provider.userProfile;
    return Scaffold(
      appBar: AppBar(title: const Text("My Profile"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                user?.fullname[0] ?? "U",
                style: const TextStyle(fontSize: 32),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              user?.fullname ?? "Guest User",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              user?.email ?? "no-email@toi.kz",
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 30),
            const Divider(),

            // Settings
            _buildSectionHeader(context, "Account Information"),
            _buildListTile(
              context,
              Icons.person_outline,
              "Full name",
              user?.fullname ?? "",
              () => ChangeNameDialog.show(context),
            ),
            _buildListTile(
              context,
              Icons.location_city_outlined,
              "City",
              user?.city?.label ?? "",
              (() => CityPicker.show(context)),
            ),

            _buildSectionHeader(context, "Preferences"),

            SwitchListTile(
              secondary: Icon(
                provider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              ),
              title: const Text("Dark Mode"),
              value: provider.isDarkMode,
              onChanged: (val) => provider.toggleTheme(),
            ),

            const Divider(),

            // Logout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showLogoutDialog(context),
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback? onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right, size: 16),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Logout"),
            content: const Text("Are you sure you want to exit?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  context.read<ToiProvider>().clearUserProfile();

                  await AuthService().logout();

                  if (context.mounted) {
                    Navigator.of(
                      context,
                      rootNavigator: true,
                    ).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  }
                },
                child: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
