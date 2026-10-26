import 'dart:convert';
import 'dart:io';
import '../models/marketplace_item_model.dart';
import '../models/product_ad_offer_model.dart';
import '../services/api/api_endpoints.dart';
import '../services/api/api_service.dart';

class ProductAdRepository {
  final ApiService _apiService;

  ProductAdRepository(this._apiService);

  // 1. Create Product Ad (POST /product-ad - multipart/form-data)
  Future<MarketplaceItemModel> createProductAd({
    required String category,
    required String title,
    String? brand,
    required String condition,
    required String price,
    required bool negotiable,
    required String description,
    required String location,
    required List<File> photos,
  }) async {
    // Clean price string for backend decimal validation
    final cleanPrice = price.replaceAll(RegExp(r'[^0-9.]'), '');

    final fields = <String, String>{
      'category': category,
      'title': title,
      if (brand != null && brand.trim().isNotEmpty) 'brand': brand.trim(),
      'condition': condition,
      'price': cleanPrice.isEmpty ? '0' : cleanPrice,
      'negotiable': negotiable.toString(),
      'description': description,
      'location': location,
    };

    final response = await _apiService.multipartRequest(
      method: 'POST',
      endpoint: ApiEndpoints.productAdEndpoint,
      fields: fields,
      files: photos,
      filesKey: 'photos',
    );

    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final data = resBody['data'] as Map<String, dynamic>;
    return MarketplaceItemModel.fromJson(data);
  }

  // 2. Get Public Product Ads (GET /product-ad)
  Future<Map<String, dynamic>> getPublicProductAds({
    int page = 1,
    int limit = 10,
    String? category,
    String? condition,
    double? minPrice,
    double? maxPrice,
    bool? negotiable,
    String? brand,
  }) async {
    final safeLimit = (limit > 50 || limit < 1) ? 50 : limit;
    final queryParams = <String>[
      'page=$page',
      'limit=$safeLimit',
      if (category != null && category.isNotEmpty && category != 'All')
        'category=$category',
      if (condition != null && condition.isNotEmpty) 'condition=$condition',
      if (minPrice != null) 'minPrice=$minPrice',
      if (maxPrice != null && maxPrice < 1000.0) 'maxPrice=$maxPrice',
      if (negotiable != null) 'negotiable=$negotiable',
      if (brand != null && brand.isNotEmpty) 'brand=$brand',
    ];

    final queryString = queryParams.isNotEmpty
        ? '?${queryParams.join('&')}'
        : '';
    final response = await _apiService.get(
      '${ApiEndpoints.productAdEndpoint}$queryString',
    );

    final Map<String, dynamic> body = jsonDecode(response.body);
    final List<dynamic> dataList = body['data'] as List? ?? [];

    final items = dataList
        .map(
          (item) => MarketplaceItemModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();

    return {'data': items, 'meta': body['meta'] ?? {}};
  }

  // 3. Get Seller's Own Ads (GET /product-ad/my-ads)
  Future<Map<String, dynamic>> getMyProductAds({
    int page = 1,
    int limit = 50,
    String? status,
  }) async {
    final safeLimit = (limit > 50 || limit < 1) ? 50 : limit;
    final queryParams = <String>[
      'page=$page',
      'limit=$safeLimit',
      if (status != null && status.isNotEmpty) 'status=$status',
    ];

    final queryString = queryParams.isNotEmpty
        ? '?${queryParams.join('&')}'
        : '';
    final response = await _apiService.get(
      '${ApiEndpoints.myProductAdsEndpoint}$queryString',
    );

    final dynamic body = jsonDecode(response.body);
    List<dynamic> dataList = [];
    Map<String, dynamic> meta = {};
    if (body is List) {
      dataList = body;
    } else if (body is Map<String, dynamic>) {
      dataList = body['data'] as List? ?? body['ads'] as List? ?? [];
      meta = body['meta'] as Map<String, dynamic>? ?? {};
    }

    final items = dataList
        .whereType<Map<String, dynamic>>()
        .map(
          (item) => MarketplaceItemModel.fromJson(item),
        )
        .toList();

    return {'data': items, 'meta': meta};
  }

  // 4. Get Product Ad Details by ID (GET /product-ad/:id)
  Future<MarketplaceItemModel> getProductAdById(String id) async {
    final response = await _apiService.get(
      ApiEndpoints.productAdByIdEndpoint(id),
    );
    final Map<String, dynamic> body = jsonDecode(response.body);
    final data = body['data'] as Map<String, dynamic>;
    return MarketplaceItemModel.fromJson(data);
  }

  // 5. Update Product Ad Details (PATCH /product-ad/:id)
  Future<MarketplaceItemModel> updateProductAd(
    String id, {
    String? category,
    String? title,
    String? brand,
    String? condition,
    String? price,
    bool? negotiable,
    String? description,
    String? location,
  }) async {
    final Map<String, dynamic> body = {};
    if (category != null) body['category'] = category;
    if (title != null) body['title'] = title;
    if (brand != null) body['brand'] = brand;
    if (condition != null) body['condition'] = condition;
    if (price != null) {
      body['price'] = price.replaceAll(RegExp(r'[^0-9.]'), '');
    }
    if (negotiable != null) body['negotiable'] = negotiable;
    if (description != null) body['description'] = description;
    if (location != null) body['location'] = location;

    final response = await _apiService.patch(
      ApiEndpoints.productAdByIdEndpoint(id),
      body,
    );
    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final data = resBody['data'] as Map<String, dynamic>;
    return MarketplaceItemModel.fromJson(data);
  }

  // 6. Update Product Ad Photos (PATCH /product-ad/:id/photos - multipart)
  Future<MarketplaceItemModel> updateProductAdPhotos(
    String id,
    List<File> photos,
  ) async {
    final response = await _apiService.multipartRequest(
      method: 'PATCH',
      endpoint: ApiEndpoints.productAdPhotosEndpoint(id),
      fields: <String, String>{},
      files: photos,
      filesKey: 'photos',
    );
    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final data = resBody['data'] as Map<String, dynamic>;
    return MarketplaceItemModel.fromJson(data);
  }

  // 8. Update Product Ad Status (PATCH /product-ad/:id/status)
  Future<MarketplaceItemModel> updateProductAdStatus(
    String id,
    String status,
  ) async {
    final response = await _apiService.patch(
      ApiEndpoints.productAdStatusEndpoint(id),
      {'status': status},
    );
    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final data = resBody['data'] as Map<String, dynamic>;
    return MarketplaceItemModel.fromJson(data);
  }

  // 9. Delete Product Ad (DELETE /product-ad/:id)
  Future<void> deleteProductAd(String id) async {
    await _apiService.delete(ApiEndpoints.productAdByIdEndpoint(id));
  }

  // 10. Send Offer (POST /product-ad/:id/send-offer)
  Future<Map<String, dynamic>> sendOffer(
    String adId,
    String offerPrice, {
    String? message,
  }) async {
    final cleanPrice = offerPrice.replaceAll(RegExp(r'[^0-9.]'), '');
    final response = await _apiService
        .post(ApiEndpoints.productAdSendOfferEndpoint(adId), {
          'offerPrice': cleanPrice,
          if (message != null && message.trim().isNotEmpty)
            'message': message.trim(),
        });
    return jsonDecode(response.body);
  }

  // 11. Cancel Offer (PATCH /product-ad/:id/cancel-offer)
  Future<void> cancelOffer(String adId) async {
    await _apiService.patch(ApiEndpoints.cancelProductOfferEndpoint(adId), {});
  }

  // 12. Get Offers on My Ad (GET /product-ad/:id/offers)
  Future<List<ProductAdOfferModel>> getOffersOnMyAd(String adId) async {
    final response = await _apiService.get(
      ApiEndpoints.productAdOffersOnMyAdEndpoint(adId),
    );
    final Map<String, dynamic> body = jsonDecode(response.body);
    final List<dynamic> dataList = body['data'] as List? ?? [];
    return dataList
        .map(
          (item) => ProductAdOfferModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  // 13. Get My Sent Offers (GET /product-ad/my-offers)
  Future<List<ProductAdOfferModel>> getMySentOffers() async {
    final response = await _apiService.get(
      ApiEndpoints.myProductOffersEndpoint,
    );
    final Map<String, dynamic> body = jsonDecode(response.body);
    final List<dynamic> dataList = body['data'] as List? ?? [];
    return dataList
        .map(
          (item) => ProductAdOfferModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  // 14. Accept Offer (PATCH /product-ad/offers/:offerId/accept)
  Future<void> acceptOffer(String offerId) async {
    await _apiService.patch(
      ApiEndpoints.acceptProductOfferEndpoint(offerId),
      {},
    );
  }

  // 15. Reject Offer (PATCH /product-ad/offers/:offerId/reject)
  Future<void> rejectOffer(String offerId) async {
    await _apiService.patch(
      ApiEndpoints.rejectProductOfferEndpoint(offerId),
      {},
    );
  }

  // 16. Save / Bookmark Ad (POST /product-ad/:id/save)
  Future<void> saveAd(String adId) async {
    await _apiService.post(ApiEndpoints.saveProductAdEndpoint(adId), {});
  }

  // 17. Remove Saved / Unbookmark Ad (DELETE /product-ad/:id/save)
  Future<void> unsaveAd(String adId) async {
    await _apiService.delete(ApiEndpoints.saveProductAdEndpoint(adId));
  }
}
