import 'package:flutter/foundation.dart';
import '../../repositories/subscription_repository.dart';

class PromotionsViewModel extends ChangeNotifier {
  final SubscriptionRepository? _repository;

  PromotionsViewModel([this._repository]);

  SubscriptionRepository? get repository => _repository;

  String? _selectedAdId;
  String? get selectedAdId => _selectedAdId;

  final bool _isLoading = false;
  bool get isLoading => _isLoading;

  void selectAd(String adId) {
    _selectedAdId = adId;
    notifyListeners();
  }

  void clearSelection() {
    _selectedAdId = null;
    notifyListeners();
  }
}
