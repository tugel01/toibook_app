import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toibook_app/providers/toi_provider.dart';
import 'package:toibook_app/screens/event_dashboard.dart';
import 'package:toibook_app/services/auth_service.dart';
import 'package:toibook_app/widgets/add_event_card.dart';
import '../widgets/event_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final toiProvider = Provider.of<ToiProvider>(context);
    final myEvents = toiProvider.getEventsByUserId(user?.id ?? "");
    final currentCity = Provider.of<ToiProvider>(context).currentCity;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // location notif bar
              Container(
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
                          onTap: () => _showCityPicker(context),
                          borderRadius: BorderRadius.circular(30),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Current Location",
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.labelSmall,
                                    ),
                                    Text(
                                      currentCity,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
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
              ),

              const SizedBox(height: 32),

              Text(
                "My events",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: myEvents.length + 1,
                itemBuilder: (context, index) {
                  if (index == myEvents.length) {
                    return const AddEventCard();
                  }
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  EventDashboard(event: myEvents[index]),
                        ),
                      );
                    },
                    child: EventCard(event: myEvents[index]),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        iconSize: 35,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Explore"),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  void _showCityPicker(BuildContext context) {
    final List<String> cities = [
      "Almaty, Kazakhstan",
      "Astana, Kazakhstan",
      "Shymkent, Kazakhstan",
      "Aktau, Kazakhstan",
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
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
              ...cities
                  .map(
                    (city) => ListTile(
                      leading: const Icon(Icons.location_city),
                      title: Text(city),
                      onTap: () {
                        Provider.of<ToiProvider>(
                          context,
                          listen: false,
                        ).updateCity(city);
                        Navigator.pop(context);
                      },
                    ),
                  )
                  .toList(),
            ],
          ),
        );
      },
    );
  }
}
