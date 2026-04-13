import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    final currentUser = AuthService.currentUser;
    _controller = TextEditingController(text: currentUser?.fullName ?? "");
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
          onPressed: () {
            final newName = _controller.text.trim();
            if (newName.isNotEmpty) {
              Provider.of<ToiProvider>(
                context,
                listen: false,
              ).updateUserName(newName);

              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text("Save"),
        ),
      ],
    );
  }
}
