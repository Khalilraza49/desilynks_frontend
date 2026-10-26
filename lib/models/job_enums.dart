// Enum Reference for Job Module API

enum JobCategory {
  restaurantAndFood,
  drivingAndDelivery,
  cleaningAndHousekeeping,
  constructionAndLabour,
  itAndTechnology,
  salesAndMarketing,
  healthcare,
  educationAndTeaching,
  securityAndGuard,
  retailAndShop,
  other,
}

extension JobCategoryX on JobCategory {
  String toApiKey() {
    switch (this) {
      case JobCategory.restaurantAndFood:
        return 'RESTAURANT_AND_FOOD';
      case JobCategory.drivingAndDelivery:
        return 'DRIVING_AND_DELIVERY';
      case JobCategory.cleaningAndHousekeeping:
        return 'CLEANING_AND_HOUSEKEEPING';
      case JobCategory.constructionAndLabour:
        return 'CONSTRUCTION_AND_LABOUR';
      case JobCategory.itAndTechnology:
        return 'IT_AND_TECHNOLOGY';
      case JobCategory.salesAndMarketing:
        return 'SALES_AND_MARKETING';
      case JobCategory.healthcare:
        return 'HEALTHCARE';
      case JobCategory.educationAndTeaching:
        return 'EDUCATION_AND_TEACHING';
      case JobCategory.securityAndGuard:
        return 'SECURITY_AND_GUARD';
      case JobCategory.retailAndShop:
        return 'RETAIL_AND_SHOP';
      case JobCategory.other:
        return 'OTHER';
    }
  }

  String get displayName {
    switch (this) {
      case JobCategory.restaurantAndFood:
        return 'Restaurant & Food';
      case JobCategory.drivingAndDelivery:
        return 'Driving & Delivery';
      case JobCategory.cleaningAndHousekeeping:
        return 'Cleaning & Housekeeping';
      case JobCategory.constructionAndLabour:
        return 'Construction & Labour';
      case JobCategory.itAndTechnology:
        return 'IT & Technology';
      case JobCategory.salesAndMarketing:
        return 'Sales & Marketing';
      case JobCategory.healthcare:
        return 'Healthcare';
      case JobCategory.educationAndTeaching:
        return 'Education & Teaching';
      case JobCategory.securityAndGuard:
        return 'Security & Guard';
      case JobCategory.retailAndShop:
        return 'Retail & Shop';
      case JobCategory.other:
        return 'Other';
    }
  }

  static JobCategory fromString(String? val) {
    if (val == null || val.trim().isEmpty) return JobCategory.other;
    final normalized = val
        .trim()
        .toUpperCase()
        .replaceAll('&', 'AND')
        .replaceAll(RegExp(r'[^A-Z0-9]'), '_');
    for (final cat in JobCategory.values) {
      if (cat.toApiKey() == normalized) return cat;
      final displayNorm = cat.displayName
          .toUpperCase()
          .replaceAll('&', 'AND')
          .replaceAll(RegExp(r'[^A-Z0-9]'), '_');
      if (displayNorm == normalized) return cat;
    }
    return JobCategory.other;
  }
}

enum JobType { fullTime, partTime, contract, freelance, internship }

extension JobTypeX on JobType {
  String toApiKey() {
    switch (this) {
      case JobType.fullTime:
        return 'FULL_TIME';
      case JobType.partTime:
        return 'PART_TIME';
      case JobType.contract:
        return 'CONTRACT';
      case JobType.freelance:
        return 'FREELANCE';
      case JobType.internship:
        return 'INTERNSHIP';
    }
  }

  String get displayName {
    switch (this) {
      case JobType.fullTime:
        return 'Full Time';
      case JobType.partTime:
        return 'Part Time';
      case JobType.contract:
        return 'Contract';
      case JobType.freelance:
        return 'Freelance';
      case JobType.internship:
        return 'Internship';
    }
  }

  static JobType fromString(String? val) {
    if (val == null || val.trim().isEmpty) return JobType.fullTime;
    final normalized = val.trim().toUpperCase().replaceAll(
      RegExp(r'[^A-Z0-9]'),
      '_',
    );
    for (final t in JobType.values) {
      if (t.toApiKey() == normalized) return t;
      final displayNorm = t.displayName.toUpperCase().replaceAll(
        RegExp(r'[^A-Z0-9]'),
        '_',
      );
      if (displayNorm == normalized) return t;
    }
    return JobType.fullTime;
  }
}

enum SalaryPeriod { perHour, perDay, perWeek, perMonth }

extension SalaryPeriodX on SalaryPeriod {
  String toApiKey() {
    switch (this) {
      case SalaryPeriod.perHour:
        return 'PER_HOUR';
      case SalaryPeriod.perDay:
        return 'PER_DAY';
      case SalaryPeriod.perWeek:
        return 'PER_WEEK';
      case SalaryPeriod.perMonth:
        return 'PER_MONTH';
    }
  }

  String get displayName {
    switch (this) {
      case SalaryPeriod.perHour:
        return 'Per Hour';
      case SalaryPeriod.perDay:
        return 'Per Day';
      case SalaryPeriod.perWeek:
        return 'Per Week';
      case SalaryPeriod.perMonth:
        return 'Per Month';
    }
  }

  static SalaryPeriod fromString(String? val) {
    if (val == null || val.trim().isEmpty) return SalaryPeriod.perMonth;
    var upper = val.trim().toUpperCase();
    if (!upper.startsWith('PER_') && !upper.startsWith('PER ')) {
      upper = 'PER_$upper';
    }
    final normalized = upper.replaceAll(RegExp(r'[^A-Z0-9]'), '_');
    for (final sp in SalaryPeriod.values) {
      if (sp.toApiKey() == normalized) return sp;
    }
    return SalaryPeriod.perMonth;
  }
}

enum Experience {
  noExperience,
  onePlusYears,
  twoPlusYears,
  threePlusYears,
  fivePlusYears,
}

extension ExperienceX on Experience {
  String toApiKey() {
    switch (this) {
      case Experience.noExperience:
        return 'NO_EXPERIENCE';
      case Experience.onePlusYears:
        return 'ONE_PLUS_YEARS';
      case Experience.twoPlusYears:
        return 'TWO_PLUS_YEARS';
      case Experience.threePlusYears:
        return 'THREE_PLUS_YEARS';
      case Experience.fivePlusYears:
        return 'FIVE_PLUS_YEARS';
    }
  }

  String get displayName {
    switch (this) {
      case Experience.noExperience:
        return 'No Experience';
      case Experience.onePlusYears:
        return '1+ Years';
      case Experience.twoPlusYears:
        return '2+ Years';
      case Experience.threePlusYears:
        return '3+ Years';
      case Experience.fivePlusYears:
        return '5+ Years';
    }
  }

  static Experience fromString(String? val) {
    if (val == null || val.trim().isEmpty) return Experience.noExperience;
    final upper = val.trim().toUpperCase();
    if (upper == 'ANY' ||
        upper == 'NO_EXPERIENCE' ||
        upper == 'NO EXPERIENCE' ||
        upper == 'ENTRY LEVEL') {
      return Experience.noExperience;
    }
    if (upper == 'ONE_PLUS_YEARS' ||
        upper == '1+ YEARS' ||
        upper == '1-2 YEARS' ||
        upper == '1 YEAR') {
      return Experience.onePlusYears;
    }
    if (upper == 'TWO_PLUS_YEARS' ||
        upper == '2+ YEARS' ||
        upper == '2 YEARS') {
      return Experience.twoPlusYears;
    }
    if (upper == 'THREE_PLUS_YEARS' ||
        upper == '3+ YEARS' ||
        upper == '3-5 YEARS' ||
        upper == '3 YEARS') {
      return Experience.threePlusYears;
    }
    if (upper == 'FIVE_PLUS_YEARS' ||
        upper == '5+ YEARS' ||
        upper == '5 YEARS') {
      return Experience.fivePlusYears;
    }
    final normalized = upper.replaceAll(RegExp(r'[^A-Z0-9]'), '_');
    for (final exp in Experience.values) {
      if (exp.toApiKey() == normalized) return exp;
    }
    return Experience.noExperience;
  }
}

enum Education { highSchool, bachelor, master, phd }

extension EducationX on Education {
  String toApiKey() {
    switch (this) {
      case Education.highSchool:
        return 'HIGH_SCHOOL';
      case Education.bachelor:
        return 'BACHELOR';
      case Education.master:
        return 'MASTER';
      case Education.phd:
        return 'PHD';
    }
  }

  String get displayName {
    switch (this) {
      case Education.highSchool:
        return 'High School';
      case Education.bachelor:
        return 'Bachelor';
      case Education.master:
        return 'Master';
      case Education.phd:
        return 'PhD';
    }
  }

  static Education fromString(String? val) {
    if (val == null || val.trim().isEmpty) return Education.highSchool;
    final upper = val.trim().toUpperCase();
    if (upper.contains('HIGH') || upper.contains('DIPLOMA')) {
      return Education.highSchool;
    }
    if (upper.contains('BACHELOR')) return Education.bachelor;
    if (upper.contains('MASTER')) return Education.master;
    if (upper.contains('PHD') || upper.contains('DOCTOR')) return Education.phd;
    final normalized = upper.replaceAll(RegExp(r'[^A-Z0-9]'), '_');
    for (final edu in Education.values) {
      if (edu.toApiKey() == normalized) return edu;
    }
    return Education.highSchool;
  }
}

enum Language { english, spanish, urdu, hindi, arabic }

extension LanguageX on Language {
  String toApiKey() {
    switch (this) {
      case Language.english:
        return 'ENGLISH';
      case Language.spanish:
        return 'SPANISH';
      case Language.urdu:
        return 'URDU';
      case Language.hindi:
        return 'HINDI';
      case Language.arabic:
        return 'ARABIC';
    }
  }

  String get displayName {
    switch (this) {
      case Language.english:
        return 'English';
      case Language.spanish:
        return 'Spanish';
      case Language.urdu:
        return 'Urdu';
      case Language.hindi:
        return 'Hindi';
      case Language.arabic:
        return 'Arabic';
    }
  }

  static Language fromString(String? val) {
    if (val == null || val.trim().isEmpty) return Language.english;
    final upper = val.trim().toUpperCase();
    for (final lang in Language.values) {
      if (lang.toApiKey() == upper || lang.displayName.toUpperCase() == upper) {
        return lang;
      }
    }
    return Language.english;
  }
}

enum WorkMode { remote, onsite, hybrid }

extension WorkModeX on WorkMode {
  String toApiKey() {
    switch (this) {
      case WorkMode.remote:
        return 'REMOTE';
      case WorkMode.onsite:
        return 'ONSITE';
      case WorkMode.hybrid:
        return 'HYBRID';
    }
  }

  String get displayName {
    switch (this) {
      case WorkMode.remote:
        return 'Remote';
      case WorkMode.onsite:
        return 'On-site';
      case WorkMode.hybrid:
        return 'Hybrid';
    }
  }

  static WorkMode fromString(String? val) {
    if (val == null || val.trim().isEmpty) return WorkMode.onsite;
    final upper = val
        .trim()
        .toUpperCase()
        .replaceAll('-', '')
        .replaceAll('_', '');
    if (upper == 'REMOTE') return WorkMode.remote;
    if (upper == 'ONSITE') return WorkMode.onsite;
    if (upper == 'HYBRID') return WorkMode.hybrid;
    return WorkMode.onsite;
  }
}

enum Benefit {
  healthInsurance,
  freeMeals,
  transport,
  accommodation,
  commission,
  paidLeave,
}

extension BenefitX on Benefit {
  String toApiKey() {
    switch (this) {
      case Benefit.healthInsurance:
        return 'HEALTH_INSURANCE';
      case Benefit.freeMeals:
        return 'FREE_MEALS';
      case Benefit.transport:
        return 'TRANSPORT';
      case Benefit.accommodation:
        return 'ACCOMMODATION';
      case Benefit.commission:
        return 'COMMISSION';
      case Benefit.paidLeave:
        return 'PAID_LEAVE';
    }
  }

  String get displayName {
    switch (this) {
      case Benefit.healthInsurance:
        return 'Health Insurance';
      case Benefit.freeMeals:
        return 'Free Meals';
      case Benefit.transport:
        return 'Transport';
      case Benefit.accommodation:
        return 'Accommodation';
      case Benefit.commission:
        return 'Commission';
      case Benefit.paidLeave:
        return 'Paid Leave';
    }
  }

  static Benefit fromString(String? val) {
    if (val == null || val.trim().isEmpty) return Benefit.paidLeave;
    final normalized = val.trim().toUpperCase().replaceAll(
      RegExp(r'[^A-Z0-9]'),
      '_',
    );
    for (final b in Benefit.values) {
      if (b.toApiKey() == normalized) return b;
      final displayNorm = b.displayName.toUpperCase().replaceAll(
        RegExp(r'[^A-Z0-9]'),
        '_',
      );
      if (displayNorm == normalized) return b;
    }
    return Benefit.paidLeave;
  }
}

enum JobStatus { open, closed, archived, pending }

extension JobStatusX on JobStatus {
  String toApiKey() {
    switch (this) {
      case JobStatus.open:
        return 'OPEN';
      case JobStatus.closed:
        return 'CLOSED';
      case JobStatus.archived:
        return 'ARCHIVED';
      case JobStatus.pending:
        return 'PENDING';
    }
  }

  String get displayName {
    switch (this) {
      case JobStatus.open:
        return 'Open';
      case JobStatus.closed:
        return 'Closed';
      case JobStatus.archived:
        return 'Archived';
      case JobStatus.pending:
        return 'Pending';
    }
  }

  static JobStatus fromString(String? val) {
    if (val == null || val.trim().isEmpty) return JobStatus.open;
    final upper = val.trim().toUpperCase();
    for (final js in JobStatus.values) {
      if (js.toApiKey() == upper || js.displayName.toUpperCase() == upper) {
        return js;
      }
    }
    return JobStatus.open;
  }
}

enum JobApplicationStatus {
  pending,
  reviewing,
  shortlisted,
  interview,
  offered,
  rejected,
  withdrawn,
}

extension JobApplicationStatusX on JobApplicationStatus {
  String toApiKey() {
    switch (this) {
      case JobApplicationStatus.pending:
        return 'PENDING';
      case JobApplicationStatus.reviewing:
        return 'REVIEWING';
      case JobApplicationStatus.shortlisted:
        return 'SHORTLISTED';
      case JobApplicationStatus.interview:
        return 'INTERVIEW';
      case JobApplicationStatus.offered:
        return 'OFFERED';
      case JobApplicationStatus.rejected:
        return 'REJECTED';
      case JobApplicationStatus.withdrawn:
        return 'WITHDRAWN';
    }
  }

  String get displayName {
    switch (this) {
      case JobApplicationStatus.pending:
        return 'Pending';
      case JobApplicationStatus.reviewing:
        return 'Reviewing';
      case JobApplicationStatus.shortlisted:
        return 'Shortlisted';
      case JobApplicationStatus.interview:
        return 'Interview';
      case JobApplicationStatus.offered:
        return 'Selected';
      case JobApplicationStatus.rejected:
        return 'Rejected';
      case JobApplicationStatus.withdrawn:
        return 'Withdrawn';
    }
  }

  static JobApplicationStatus fromString(String? val) {
    if (val == null || val.trim().isEmpty) return JobApplicationStatus.pending;
    final upper = val.trim().toUpperCase();
    if (upper == 'SELECTED' || upper == 'OFFERED' || upper == 'ACCEPTED') {
      return JobApplicationStatus.offered;
    }
    for (final jas in JobApplicationStatus.values) {
      if (jas.toApiKey() == upper || jas.displayName.toUpperCase() == upper) {
        return jas;
      }
    }
    return JobApplicationStatus.pending;
  }
}
