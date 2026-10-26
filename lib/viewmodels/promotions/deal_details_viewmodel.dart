import 'package:flutter/material.dart';

class DealDetailsViewModel extends ChangeNotifier {
  bool _isFavorite = false;
  bool get isFavorite => _isFavorite;

  void toggleFavorite() {
    _isFavorite = !_isFavorite;
    notifyListeners();
  }

  bool _isCouponClaimed = false;
  bool get isCouponClaimed => _isCouponClaimed;

  String? _couponCode;
  String? get couponCode => _couponCode;

  void claimCoupon() {
    _isCouponClaimed = true;
    _couponCode = 'DESI20OFF';
    notifyListeners();
  }

  void resetCoupon() {
    _isCouponClaimed = false;
    _couponCode = null;
    notifyListeners();
  }
}
