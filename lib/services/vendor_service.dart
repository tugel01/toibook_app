import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:toibook_app/models/user_model.dart';
import 'package:toibook_app/models/vendors/enums.dart';
import 'package:toibook_app/models/vendors/full_offer.dart';
import 'package:toibook_app/models/vendors/short_offer.dart';
import 'package:toibook_app/services/auth_service.dart';

class VendorService {
  final _baseUrl = 'https://toibook.up.railway.app/api';
  final _authService = AuthService();

  Future<Map<String, String>> get _headers async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }

  Future<List<OfferResponse>> getFeed({
    VendorType? vendorType,
    VenueType? venueType,
    ServiceType? serviceType,
    City? city,
    String? query,
    int page = 0,
    int size = 10,
    String? sortBy,
    String? sortDirection,
  }) async {
    try {
      final params = <String, String?>{
        'page': page.toString(),
        'size': size.toString(),
        'sortBy': sortBy,
        'sortDirection': sortDirection,
      };

      if (vendorType != null) params['vendorType'] = vendorType.toQueryString();
      if (venueType != null) params['venueType'] = venueType.toQueryString();
      if (serviceType != null) {
        params['serviceType'] = serviceType.toQueryString();
      }
      if (city != null) params['city'] = city.label;
      if (query != null && query.isNotEmpty) params['query'] = query;

      final uri = Uri.parse(
        '$_baseUrl/offers/feed',
      ).replace(queryParameters: params);

      final res = await http.get(uri, headers: await _headers);

      if (res.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(res.body);
        final List<dynamic> content = body['content'];
        return content.map((e) => OfferResponse.fromJson(e)).toList();
      }
      if (res.statusCode == 404) return [];

      throw Exception('Failed to load feed: ${res.statusCode}');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<OfferDetailResponse> getOffer(int offerId) async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/offers/$offerId'),
        headers: await _headers,
      );

      if (res.statusCode == 200) {
        return OfferDetailResponse.fromJson(jsonDecode(res.body));
      }
      throw Exception('Failed to load offer: ${res.statusCode}');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
