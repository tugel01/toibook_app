import 'package:flutter/material.dart';
import 'package:toibook_app/providers/toi_provider.dart';
import 'package:toibook_app/widgets/location_bar.dart';
import 'package:provider/provider.dart';

class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ToiProvider>();
    final profile = provider.userProfile;
    final String currentCity = profile?.city?.label ?? 'Select City';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LocationBar(location: currentCity),
            const SizedBox(height: 32),
            Text(
              'Explore Vendors',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
