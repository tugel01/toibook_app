import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toibook_app/models/vendors/enums.dart';
import 'package:toibook_app/models/vendors/saved_offer_card.dart';
import 'package:toibook_app/models/vendors/ticket.dart';
import 'package:toibook_app/providers/chat_provider.dart';
import 'package:toibook_app/screens/event%20dashboard/chat_screen.dart';
import 'package:toibook_app/services/vendor_service.dart';
import 'package:toibook_app/widgets/saved_offer_card.dart';

class SavedPage extends StatefulWidget {
  final int eventId;

  const SavedPage({super.key, required this.eventId});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  VendorType _activeTab = VendorType.venue;
  List<SavedOfferCardResponse> _savedOffers = [];
  List<TicketCardResponse> _tickets = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        VendorService().getSavedOffers(
          eventId: widget.eventId,
          vendorType: _activeTab,
        ),
        VendorService().getTickets(widget.eventId),
      ]);

      if (!mounted) return;
      setState(() {
        _savedOffers = results[0] as List<SavedOfferCardResponse>;
        _tickets = results[1] as List<TicketCardResponse>;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _onTabChanged(VendorType tab) {
    setState(() {
      _activeTab = tab;
      _savedOffers = [];
    });
    _fetchAll();
  }

  bool _isContacted(SavedOfferCardResponse offer) {
    return _tickets.any((t) => t.offerId == offer.id && t.isContacted);
  }

  TicketCardResponse? _ticketFor(SavedOfferCardResponse offer) {
    try {
      return _tickets.firstWhere((t) => t.offerId == offer.id && t.isContacted);
    } catch (_) {
      return null;
    }
  }

  void _showSendRequestDialog(
    BuildContext context,
    SavedOfferCardResponse offer,
  ) {
    final messageController = TextEditingController();
    String? messageError;

    showDialog(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (ctx, setDialogState) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Send Request',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        offer.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                  content: TextField(
                    controller: messageController,
                    maxLines: 4,
                    autofocus: true,
                    onChanged: (_) {
                      if (messageError != null) {
                        setDialogState(() => messageError = null);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Write a message to the vendor...',
                      alignLabelWithHint: true,
                      errorText: messageError,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () async {
                        final message = messageController.text.trim();
                        if (message.isEmpty) {
                          setDialogState(
                            () => messageError = 'Please write a message',
                          );
                          return;
                        }

                        Navigator.pop(ctx);

                        try {
                          await VendorService().sendRequest(
                            eventId: widget.eventId,
                            ticketId: offer.ticketId,
                            offerId: offer.id,
                            message: message,
                          );

                          // Create conversation with vendor

                          final conversationId = await context
                              .read<ChatProvider>()
                              .getOrCreateConversation(offer.vendorId);

                          if (!context.mounted) return;

                          // Auto-send message
                          await context.read<ChatProvider>().sendMessage(
                            conversationId,
                            'Request for offer: ${offer.name}\nMessage: $message',
                          );

                          // Navigate to chat
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ChatScreen(
                                    conversationId: conversationId,
                                    vendorName: offer.name,
                                  ),
                            ),
                          );

                          _fetchAll();
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to send request: $e'),
                              backgroundColor:
                                  Theme.of(context).colorScheme.error,
                            ),
                          );
                        }
                      },
                      child: const Text('Send Request'),
                    ),
                  ],
                ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notContacted = _savedOffers.where((o) => !_isContacted(o)).toList();
    final contacted = _savedOffers.where((o) => _isContacted(o)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CURATED SELECTION',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your Shortlist',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Compare your selected venues and services to finalize your dream arrangements.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
        ),

        // Tab switcher
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                _buildTab(VendorType.venue, 'Places'),
                _buildTab(VendorType.serviceProvider, 'Service Providers'),
              ],
            ),
          ),
        ),

        const Divider(height: 1),

        // Content
        Expanded(
          child:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Could not load saved offers.'),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _fetchAll,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                  : _savedOffers.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bookmark_border,
                          size: 48,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No saved ${_activeTab == VendorType.venue ? 'places' : 'people'} yet',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  )
                  : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Not contacted section
                      if (notContacted.isNotEmpty) ...[
                        _sectionHeader(context, 'Contact the Vendor'),
                        const SizedBox(height: 12),
                        ...notContacted.map(
                          (offer) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap:
                                  () => _showSendRequestDialog(context, offer),
                              child: SavedOfferCard(
                                offer: offer,
                                onDelete: () async {
                                  try {
                                    await VendorService().deleteSavedOffer(
                                      widget.eventId,
                                      offer.ticketId,
                                    );
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Deleted ${offer.name} from saved offers',
                                        ),
                                        backgroundColor:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                      ),
                                    );
                                    await _fetchAll();
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to delete: $e'),
                                        backgroundColor:
                                            Theme.of(context).colorScheme.error,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Contacted section
                      if (contacted.isNotEmpty) ...[
                        _sectionHeader(context, 'Already Contacted'),
                        const SizedBox(height: 12),
                        ...contacted.map((offer) {
                          final ticket = _ticketFor(offer);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () async {
                                try {
                                  final conversationId = await context
                                      .read<ChatProvider>()
                                      .getOrCreateConversation(offer.vendorId);
                                  if (!context.mounted) return;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => ChatScreen(
                                            conversationId: conversationId,
                                            vendorName: offer.name,
                                          ),
                                    ),
                                  );
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Could not open chat: $e'),
                                    ),
                                  );
                                }
                              },
                              child: SavedOfferCard(
                                offer: offer,
                                ticket: ticket,
                                onDelete: () async {
                                  try {
                                    await VendorService().deleteSavedOffer(
                                      widget.eventId,
                                      offer.ticketId,
                                    );
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Deleted ${offer.name} from saved offers',
                                        ),
                                        backgroundColor:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                      ),
                                    );
                                    await _fetchAll();
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to delete: $e'),
                                        backgroundColor:
                                            Theme.of(context).colorScheme.error,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
        ),
      ],
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.outline,
      ),
    );
  }

  Widget _buildTab(VendorType type, String label) {
    final isActive = _activeTab == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabChanged(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color:
                isActive
                    ? Theme.of(context).colorScheme.surface
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow:
                isActive
                    ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color:
                  isActive
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
      ),
    );
  }
}
