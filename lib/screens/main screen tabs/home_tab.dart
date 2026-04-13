import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toibook_app/models/event_card_response.dart';
import 'package:toibook_app/providers/toi_provider.dart';
import 'package:toibook_app/services/auth_service.dart';
import 'package:toibook_app/widgets/add_event_card.dart';
import 'package:toibook_app/widgets/city_picker.dart';
import 'package:toibook_app/widgets/event_card.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late Future<List<EventCardResponse>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _eventsFuture = AuthService().getEventCards();
  }

  @override
  Widget build(BuildContext context) {
    final toiProvider = Provider.of<ToiProvider>(context);
    final currentCity = toiProvider.currentCity;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLocationBar(context, currentCity),
            const SizedBox(height: 32),
            Text(
              "My events",
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            FutureBuilder<List<EventCardResponse>>(
              future: _eventsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      children: [
                        const Text('Could not load events.'),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed:
                              () => setState(() {
                                _eventsFuture = AuthService().getEventCards();
                              }),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final events = snapshot.data!;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: events.length + 1,
                  itemBuilder: (context, index) {
                    if (index == events.length) {
                      return AddEventCard(
                        onReturn:
                            () => setState(() {
                              _eventsFuture = AuthService().getEventCards();
                            }),
                      );
                    }
                    return EventCard(event: events[index]);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationBar(BuildContext context, String currentCity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => CityPicker.show(context),
                borderRadius: BorderRadius.circular(30),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 22),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Current Location",
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          Text(
                            currentCity,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.notifications_none_outlined),
              onPressed: () => print("Notifications tapped"),
            ),
          ],
        ),
      ),
    );
  }
}
