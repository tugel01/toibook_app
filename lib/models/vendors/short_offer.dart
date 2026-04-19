import 'package:toibook_app/models/user_model.dart';
import 'package:toibook_app/models/vendors/enums.dart';

class OfferResponse {
  final int id;
  final VendorType vendorType;
  final VenueType? venueType;
  final ServiceType? serviceType;
  final String name;
  final City city;
  final String? coverImageUrl;
  final String createdAt;
  OfferResponse({
    required this.id,
    required this.vendorType,
    this.venueType,
    this.serviceType,
    required this.name,
    required this.city,
    required this.createdAt,
    this.coverImageUrl,
  });

  factory OfferResponse.fromJson(Map<String, dynamic> json) => OfferResponse(
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
    coverImageUrl: json['coverImageUrl'],
    createdAt: json['createdAt'],
  );
}
