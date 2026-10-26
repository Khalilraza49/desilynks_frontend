import '../services/api/api_endpoints.dart';

class ProductAdOfferModel {
  final String id;
  final String adId;
  final String adTitle;
  final String offerPrice;
  final String? message;
  final String status; // PENDING, ACCEPTED, REJECTED, CANCELLED
  final String buyerName;
  final String buyerAvatar;
  final String buyerId;
  final String sellerName;
  final String sellerAvatar;
  final String sellerId;
  final String createdAt;

  const ProductAdOfferModel({
    required this.id,
    required this.adId,
    this.adTitle = '',
    required this.offerPrice,
    this.message,
    required this.status,
    this.buyerName = 'Buyer',
    this.buyerAvatar = '',
    this.buyerId = '',
    this.sellerName = 'Seller',
    this.sellerAvatar = '',
    this.sellerId = '',
    this.createdAt = '',
  });

  factory ProductAdOfferModel.fromJson(Map<String, dynamic> json) {
    // Parse buyer info
    String bId = json['buyerId']?.toString() ?? '';
    String bName = 'Buyer';
    String bAvatar = '';
    if (json['buyer'] is Map) {
      final buyer = json['buyer'] as Map<String, dynamic>;
      if (bId.isEmpty) {
        bId = (buyer['id'] ?? buyer['_id'] ?? '').toString();
      }
      final fn = buyer['firstName'] ?? '';
      final ln = buyer['lastName'] ?? '';
      final fullName = '$fn $ln'.trim();
      if (fullName.isNotEmpty) bName = fullName;
      if (buyer['profilePhoto'] is Map &&
          buyer['profilePhoto']['url'] != null) {
        String pUrl = buyer['profilePhoto']['url'].toString();
        if (!pUrl.startsWith('http')) {
          pUrl = '${ApiEndpoints.baseUrl}$pUrl';
        }
        bAvatar = pUrl;
      }
    }

    // Parse seller info
    String sId = json['sellerId']?.toString() ?? '';
    String sName = 'Seller';
    String sAvatar = '';
    if (json['seller'] is Map) {
      final seller = json['seller'] as Map<String, dynamic>;
      if (sId.isEmpty) {
        sId = (seller['id'] ?? seller['_id'] ?? '').toString();
      }
      final fn = seller['firstName'] ?? '';
      final ln = seller['lastName'] ?? '';
      final fullName = '$fn $ln'.trim();
      if (fullName.isNotEmpty) sName = fullName;
      if (seller['profilePhoto'] is Map &&
          seller['profilePhoto']['url'] != null) {
        String pUrl = seller['profilePhoto']['url'].toString();
        if (!pUrl.startsWith('http')) {
          pUrl = '${ApiEndpoints.baseUrl}$pUrl';
        }
        sAvatar = pUrl;
      }
    }

    // Parse ad title
    String adTitle = '';
    if (json['productAd'] is Map) {
      adTitle = (json['productAd'] as Map)['title']?.toString() ?? '';
    }

    // Format price
    final rawPrice = json['offerPrice']?.toString() ?? '0';
    final formattedPrice = rawPrice.startsWith('€') ? rawPrice : '€ $rawPrice';

    return ProductAdOfferModel(
      id: json['id']?.toString() ?? '',
      adId:
          json['productAdId']?.toString() ??
          json['productAd']?['id']?.toString() ??
          '',
      adTitle: adTitle,
      offerPrice: formattedPrice,
      message: json['message']?.toString(),
      status: json['status']?.toString() ?? 'PENDING',
      buyerName: bName,
      buyerAvatar: bAvatar,
      buyerId: bId,
      sellerName: sName,
      sellerAvatar: sAvatar,
      sellerId: sId,
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }

  bool get isPending => status == 'PENDING';
  bool get isAccepted => status == 'ACCEPTED';
  bool get isRejected => status == 'REJECTED';
  bool get isCancelled => status == 'CANCELLED';

  String get statusDisplay {
    switch (status) {
      case 'PENDING':
        return 'Pending';
      case 'ACCEPTED':
        return 'Accepted';
      case 'REJECTED':
        return 'Rejected';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String get timeAgo {
    if (createdAt.isEmpty) return 'Just now';
    try {
      final dateTime = DateTime.parse(createdAt);
      final diff = DateTime.now().difference(dateTime);
      if (diff.inMinutes < 60) {
        return diff.inMinutes <= 1 ? 'Just now' : '${diff.inMinutes} mins ago';
      } else if (diff.inHours < 24) {
        return '${diff.inHours} ${diff.inHours == 1 ? "hour" : "hours"} ago';
      } else {
        return '${diff.inDays} ${diff.inDays == 1 ? "day" : "days"} ago';
      }
    } catch (_) {
      return 'Just now';
    }
  }
}
