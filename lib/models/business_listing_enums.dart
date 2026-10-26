enum BusinessCategory {
  groceryAndSupermarket,
  restaurantAndCafe,
  salonAndBeauty,
  mobileAndElectronics,
  clothingAndFashion,
  healthAndPharmacy,
  carServices,
  courierAndDelivery,
  educationAndTutoring,
  moneyTransfer,
  travelAgency,
  construction,
  cleaningServices,
  other;

  String toApiKey() {
    switch (this) {
      case BusinessCategory.groceryAndSupermarket:
        return 'GROCERY_AND_SUPERMARKET';
      case BusinessCategory.restaurantAndCafe:
        return 'RESTAURANT_AND_CAFE';
      case BusinessCategory.salonAndBeauty:
        return 'SALON_AND_BEAUTY';
      case BusinessCategory.mobileAndElectronics:
        return 'MOBILE_AND_ELECTRONICS';
      case BusinessCategory.clothingAndFashion:
        return 'CLOTHING_AND_FASHION';
      case BusinessCategory.healthAndPharmacy:
        return 'HEALTH_AND_PHARMACY';
      case BusinessCategory.carServices:
        return 'CAR_SERVICES';
      case BusinessCategory.courierAndDelivery:
        return 'COURIER_AND_DELIVERY';
      case BusinessCategory.educationAndTutoring:
        return 'EDUCATION_AND_TUTORING';
      case BusinessCategory.moneyTransfer:
        return 'MONEY_TRANSFER';
      case BusinessCategory.travelAgency:
        return 'TRAVEL_AGENCY';
      case BusinessCategory.construction:
        return 'CONSTRUCTION';
      case BusinessCategory.cleaningServices:
        return 'CLEANING_SERVICES';
      case BusinessCategory.other:
        return 'OTHER';
    }
  }

  String get displayName {
    switch (this) {
      case BusinessCategory.groceryAndSupermarket:
        return 'Grocery & Supermarket';
      case BusinessCategory.restaurantAndCafe:
        return 'Restaurant & Cafe';
      case BusinessCategory.salonAndBeauty:
        return 'Salon & Beauty';
      case BusinessCategory.mobileAndElectronics:
        return 'Mobile & Electronics';
      case BusinessCategory.clothingAndFashion:
        return 'Clothing & Fashion';
      case BusinessCategory.healthAndPharmacy:
        return 'Health & Pharmacy';
      case BusinessCategory.carServices:
        return 'Car Services';
      case BusinessCategory.courierAndDelivery:
        return 'Courier & Delivery';
      case BusinessCategory.educationAndTutoring:
        return 'Education & Tutoring';
      case BusinessCategory.moneyTransfer:
        return 'Money Transfer';
      case BusinessCategory.travelAgency:
        return 'Travel Agency';
      case BusinessCategory.construction:
        return 'Construction';
      case BusinessCategory.cleaningServices:
        return 'Cleaning Services';
      case BusinessCategory.other:
        return 'Other Business';
    }
  }

  String get emoji {
    switch (this) {
      case BusinessCategory.groceryAndSupermarket:
        return '🛒';
      case BusinessCategory.restaurantAndCafe:
        return '🍽️';
      case BusinessCategory.salonAndBeauty:
        return '💈';
      case BusinessCategory.mobileAndElectronics:
        return '📱';
      case BusinessCategory.clothingAndFashion:
        return '👗';
      case BusinessCategory.healthAndPharmacy:
        return '🏥';
      case BusinessCategory.carServices:
        return '🚗';
      case BusinessCategory.courierAndDelivery:
        return '📦';
      case BusinessCategory.educationAndTutoring:
        return '🏫';
      case BusinessCategory.moneyTransfer:
        return '💰';
      case BusinessCategory.travelAgency:
        return '✈️';
      case BusinessCategory.construction:
        return '🏗️';
      case BusinessCategory.cleaningServices:
        return '🧹';
      case BusinessCategory.other:
        return '🏢';
    }
  }

  static BusinessCategory fromString(String? key) {
    if (key == null) return BusinessCategory.other;
    final upper = key.trim().toUpperCase();
    for (final val in BusinessCategory.values) {
      if (val.toApiKey() == upper || val.displayName.toUpperCase() == upper) {
        return val;
      }
    }
    return BusinessCategory.other;
  }
}

enum BusinessListingStatus {
  active,
  inactive,
  expired;

  String toApiKey() {
    switch (this) {
      case BusinessListingStatus.active:
        return 'ACTIVE';
      case BusinessListingStatus.inactive:
        return 'INACTIVE';
      case BusinessListingStatus.expired:
        return 'EXPIRED';
    }
  }

  static BusinessListingStatus fromString(String? key) {
    if (key == null) return BusinessListingStatus.active;
    final upper = key.trim().toUpperCase();
    switch (upper) {
      case 'INACTIVE':
        return BusinessListingStatus.inactive;
      case 'EXPIRED':
        return BusinessListingStatus.expired;
      case 'ACTIVE':
      default:
        return BusinessListingStatus.active;
    }
  }
}

enum AnalyticsPeriod {
  thisMonth,
  lastMonth,
  lastThreeMonths;

  String toApiKey() {
    switch (this) {
      case AnalyticsPeriod.thisMonth:
        return 'THIS_MONTH';
      case AnalyticsPeriod.lastMonth:
        return 'LAST_MONTH';
      case AnalyticsPeriod.lastThreeMonths:
        return 'LAST_THREE_MONTHS';
    }
  }

  static AnalyticsPeriod fromString(String? key) {
    if (key == null) return AnalyticsPeriod.thisMonth;
    final upper = key.trim().toUpperCase();
    switch (upper) {
      case 'LAST_MONTH':
        return AnalyticsPeriod.lastMonth;
      case 'LAST_THREE_MONTHS':
        return AnalyticsPeriod.lastThreeMonths;
      case 'THIS_MONTH':
      default:
        return AnalyticsPeriod.thisMonth;
    }
  }
}
