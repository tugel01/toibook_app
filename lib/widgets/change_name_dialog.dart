import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toibook_app/models/user_model.dart';
import 'package:toibook_app/providers/toi_provider.dart';
import 'package:toibook_app/services/auth_service.dart';

class ChangeNameDialog extends StatefulWidget {
  const ChangeNameDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ChangeNameDialog(),
    );
  }

  @override
  State<ChangeNameDialog> createState() => _ChangeNameDialogState();
}

class _ChangeNameDialogState extends State<ChangeNameDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final user = context.read<ToiProvider>().userProfile;
    _controller = TextEditingController(text: user?.fullname ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("Change Name"),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          hintText: "Enter your full name",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () async {
            final newName = _controller.text.trim();
            if (newName.isEmpty) return;

            final parts = newName.split(' ');
            final name = parts.first;
            final surname = parts.length > 1 ? parts.sublist(1).join(' ') : '';

            final provider = context.read<ToiProvider>();
            final city = provider.userProfile?.city ?? City.notSelected;

            Navigator.pop(context);

            try {
              await AuthService().updateProfile(
                name: name,
                surname: surname,
                city: city,
              );
              await provider.loadUserProfile(force: true);
            } catch (e) {
              print('Could not update name: $e');
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
