import 'package:flutter/material.dart';
import '../../models/toi_event.dart';

class OverviewPage extends StatelessWidget {
  final ToiEvent event;
  const OverviewPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text("Welcome to your ${event.type} dashboard!"),
          const SizedBox(height: 20),
          // We will build the budget/guest rings here next
        ],
      ),
    );
  }
}