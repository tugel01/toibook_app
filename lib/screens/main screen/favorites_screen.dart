import 'package:flutter/material.dart';
import 'package:toibook_app/models/vendors/short_offer.dart';
import 'package:toibook_app/screens/vendor_profile_screen.dart';
import 'package:toibook_app/services/vendor_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<OfferResponse>? _favorites;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final favorites = await VendorService().getFavorites();
      if (!mounted) return;
      setState(() => _favorites = favorites);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Favorites')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Could not load favorites.'),
            const SizedBox(height: 8),
            TextButton(onPressed: _loadFavorites, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_favorites!.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text('No favorites yet.'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _favorites!.length,
        itemBuilder: (context, index) {
          final offer = _favorites![index];
          return _FavoriteCard(
            offer: offer,
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VendorProfileScreen(offer: offer),
                  ),
                ).then((_) => _loadFavorites()),
          );
        },
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final OfferResponse offer;
  final VoidCallback onTap;

  const _FavoriteCard({required this.offer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            // Thumbnail
            SizedBox(
              width: 90,
              height: 90,
              child:
                  offer.coverImageUrl != null
                      ? Image.network(
                        offer.coverImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, _, _) => const Icon(Icons.image_outlined),
                      )
                      : Container(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        child: const Icon(Icons.image_outlined),
                      ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      offer.city.label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 16),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
