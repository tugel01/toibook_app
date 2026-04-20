import 'package:toibook_app/models/user_model.dart';
import 'package:toibook_app/models/vendors/enums.dart';
import 'package:toibook_app/models/vendors/short_offer.dart';

class SavedOfferCardResponse {
  final int vendorId;
  final int ticketId;
  final int id;
  final VendorType vendorType;
  final VenueType? venueType;
  final ServiceType? serviceType;
  final String name;
  final City city;
  final OfferStatus status;
  final String? coverImageUrl;

  SavedOfferCardResponse({
    required this.vendorId,
    required this.ticketId,
    required this.id,
    required this.vendorType,
    this.venueType,
    this.serviceType,
    required this.name,
    required this.city,
    required this.status,
    this.coverImageUrl,
  });

  bool get isActive => status == OfferStatus.active;

  factory SavedOfferCardResponse.fromJson(Map<String, dynamic> json) =>
      SavedOfferCardResponse(
        vendorId: json['vendorId'],
        ticketId: json['ticketId'],
        id: json['id'],
        vendorType: VendorType.fromString(json['vendorType']),
        venueType:
            json['venueType'] != null
                ? VenueType.fromString(json['venueType'])
                : null,
        serviceType:
            json['serviceType'] != null
                ? ServiceType.fromString(json['serviceType'])
                : null,
        name: json['name'],
        city: City.fromString(json['city']),
        status: OfferStatus.fromString(json['status']),
        coverImageUrl: json['coverImageUrl'],
      );

  OfferResponse toOfferResponse() => OfferResponse(
    id: id,
    vendorType: vendorType,
    venueType: venueType,
    serviceType: serviceType,
    name: name,
    city: city,
    coverImageUrl: coverImageUrl,
  );
}
