import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toibook_app/providers/toi_provider.dart';

class CityPicker extends StatelessWidget {
  const CityPicker({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return const CityPicker();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> cities = [
      "Almaty",
      "Astana",
      "Shymkent",
      "Aktau",
      "Kostanay",
    ];

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
            "Select City",
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ...cities.map(
            (city) => ListTile(
              leading: const Icon(Icons.location_city),
              title: Text(city),
              onTap: () {
                // TODO: IMPLEMENT

                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
