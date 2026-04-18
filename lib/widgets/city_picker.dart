import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toibook_app/models/user_model.dart';
import 'package:toibook_app/providers/toi_provider.dart';
import 'package:toibook_app/services/auth_service.dart';

class CityPicker extends StatelessWidget {
  const CityPicker({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const CityPicker(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cities = City.values.where((c) => c != City.notSelected).toList();

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Text(
            'Select City',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ...cities.map(
            (city) => ListTile(
              leading: const Icon(Icons.location_city),
              title: Text(city.label),
              onTap: () async {
                final provider = context.read<ToiProvider>();
                final profile = provider.userProfile;
                Navigator.pop(context);
                try {
                  await AuthService().updateProfile(
                    name: profile?.name ?? '',
                    surname: profile?.surname ?? '',
                    city: city,
                  );
                  await provider.loadUserProfile(force: true);
                } catch (e) {
                  print('Could not update city: $e');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
