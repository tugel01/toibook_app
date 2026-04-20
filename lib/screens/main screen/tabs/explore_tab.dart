import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toibook_app/models/user_model.dart';
import 'package:toibook_app/models/vendors/enums.dart';
import 'package:toibook_app/models/vendors/short_offer.dart';
import 'package:toibook_app/providers/toi_provider.dart';
import 'package:toibook_app/screens/vendor_profile_screen.dart';
import 'package:toibook_app/services/vendor_service.dart';
import 'package:toibook_app/widgets/explore_vendor_card.dart';
import 'package:toibook_app/widgets/location_bar.dart';

enum _ExploreTab { top, places, people }

class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  City? _lastCity;
  final _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  _ExploreTab _activeTab = _ExploreTab.top;
  VenueType? _selectedVenueType;
  ServiceType? _selectedServiceType;

  String _sortDirection = 'desc';

  List<OfferResponse> _results = [];
  bool _isLoading = false;
  String? _error;
  bool _showBackToTopButton = false;

  @override
  void initState() {
    super.initState();
    _fetchFeed();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >= 300 && !_showBackToTopButton) {
      setState(() => _showBackToTopButton = true);
    } else if (_scrollController.offset < 300 && _showBackToTopButton) {
      setState(() => _showBackToTopButton = false);
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), _fetchFeed);
  }

  City? _currentCity() {
    final profile = context.read<ToiProvider>().userProfile;
    final cityLabel = profile?.city?.label;
    if (cityLabel == null) return null;
    try {
      return City.fromString(cityLabel);
    } catch (_) {
      return null;
    }
  }

  void _toggleSort() {
    setState(() {
      _sortDirection = _sortDirection == 'desc' ? 'asc' : 'desc';
    });
    _fetchFeed();
  }

  Future<void> _fetchFeed() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      VendorType? vendorType;
      if (_activeTab == _ExploreTab.places) vendorType = VendorType.venue;
      if (_activeTab == _ExploreTab.people) {
        vendorType = VendorType.serviceProvider;
      }

      final results = await VendorService().getFeed(
        vendorType: vendorType,
        venueType: _activeTab == _ExploreTab.places ? _selectedVenueType : null,
        serviceType:
            _activeTab == _ExploreTab.people ? _selectedServiceType : null,
        city: _currentCity(),
        query:
            _searchController.text.trim().isEmpty
                ? null
                : _searchController.text.trim(),
        sortBy: 'createdAt',
        sortDirection: _sortDirection,
      );

      if (!mounted) return;
      setState(() => _results = results);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _onTabChanged(_ExploreTab tab) {
    setState(() {
      _activeTab = tab;
      _selectedVenueType = null;
      _selectedServiceType = null;
    });
    _fetchFeed();
  }

  void _onVenueTypeSelected(VenueType type) {
    setState(() {
      _selectedVenueType = _selectedVenueType == type ? null : type;
    });
    _fetchFeed();
  }

  void _onServiceTypeSelected(ServiceType type) {
    setState(() {
      _selectedServiceType = _selectedServiceType == type ? null : type;
    });
    _fetchFeed();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ToiProvider>();
    final currentCity = provider.userProfile?.city;

    if (currentCity != _lastCity) {
      _lastCity = currentCity;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _fetchFeed();
      });
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton:
          _showBackToTopButton
              ? FloatingActionButton(
                onPressed: _scrollToTop,
                mini: true,
                child: const Icon(Icons.arrow_upward),
              )
              : null,
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LocationBar(location: currentCity?.label ?? 'Select City'),
                    const SizedBox(height: 32),
                    Text(
                      'Explore Vendors',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    // Search bar
                    TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _fetchFeed(),
                      decoration: InputDecoration(
                        hintText: 'Search vendors, venues...',
                        prefixIcon: const Icon(Icons.search_outlined),
                        suffixIcon:
                            _searchController.text.isNotEmpty
                                ? IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    _searchController.clear();
                                    _fetchFeed();
                                  },
                                )
                                : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tab selector
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children:
                            _ExploreTab.values.map((tab) {
                              final isActive = _activeTab == tab;
                              final label = switch (tab) {
                                _ExploreTab.top => 'Top',
                                _ExploreTab.places => 'Places',
                                _ExploreTab.people => 'People',
                              };

                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => _onTabChanged(tab),
                                  behavior: HitTestBehavior.opaque,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color:
                                          isActive
                                              ? Theme.of(
                                                context,
                                              ).colorScheme.surface
                                              : Colors.transparent,
                                      borderRadius: BorderRadius.circular(26),
                                      boxShadow:
                                          isActive
                                              ? [
                                                BoxShadow(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .shadow
                                                      .withValues(alpha: 0.1),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 1),
                                                ),
                                              ]
                                              : [],
                                    ),
                                    child: Text(
                                      label,
                                      style: TextStyle(
                                        fontWeight:
                                            isActive
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                        color:
                                            isActive
                                                ? Theme.of(
                                                  context,
                                                ).colorScheme.primary
                                                : Theme.of(
                                                  context,
                                                ).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),

                    // Filter chips
                    if (_activeTab == _ExploreTab.places)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children:
                              VenueType.values.map((type) {
                                final selected = _selectedVenueType == type;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: FilterChip(
                                    label: Text(type.label),
                                    selected: selected,
                                    onSelected:
                                        (_) => _onVenueTypeSelected(type),
                                  ),
                                );
                              }).toList(),
                        ),
                      ),

                    if (_activeTab == _ExploreTab.people)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children:
                              ServiceType.values.map((type) {
                                final selected = _selectedServiceType == type;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: FilterChip(
                                    label: Text(type.label),
                                    selected: selected,
                                    onSelected:
                                        (_) => _onServiceTypeSelected(type),
                                  ),
                                );
                              }).toList(),
                        ),
                      ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: _toggleSort,
                          icon: Icon(
                            _sortDirection == 'asc'
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          label: Text(
                            _sortDirection == 'desc'
                                ? 'Oldest first'
                                : 'Newest first',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 0,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Could not load vendors.'),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _fetchFeed,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_results.isEmpty)
              const SliverFillRemaining(
                child: Center(child: Text('No vendors found.')),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return GestureDetector(
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => VendorProfileScreen(
                                    offer: _results[index],
                                  ),
                            ),
                          ),
                      child: ExploreVendorCard(offer: _results[index]),
                    );
                  }, childCount: _results.length),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
