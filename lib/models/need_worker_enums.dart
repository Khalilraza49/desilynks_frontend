// Enum Reference for Need-a-Worker Module API

enum WorkerType {
  electrician,
  plumber,
  painter,
  cleaner,
  driver,
  cook,
  labour,
  gardener,
  other,
}

extension WorkerTypeX on WorkerType {
  String toApiKey() {
    switch (this) {
      case WorkerType.electrician:
        return 'ELECTRICIAN';
      case WorkerType.plumber:
        return 'PLUMBER';
      case WorkerType.painter:
        return 'PAINTER';
      case WorkerType.cleaner:
        return 'CLEANER';
      case WorkerType.driver:
        return 'DRIVER';
      case WorkerType.cook:
        return 'COOK';
      case WorkerType.labour:
        return 'LABOUR';
      case WorkerType.gardener:
        return 'GARDENER';
      case WorkerType.other:
        return 'OTHER';
    }
  }

  String get displayName {
    switch (this) {
      case WorkerType.electrician:
        return 'Electrician';
      case WorkerType.plumber:
        return 'Plumber';
      case WorkerType.painter:
        return 'Painter';
      case WorkerType.cleaner:
        return 'Cleaner';
      case WorkerType.driver:
        return 'Driver';
      case WorkerType.cook:
        return 'Cook';
      case WorkerType.labour:
        return 'Labour';
      case WorkerType.gardener:
        return 'Gardener';
      case WorkerType.other:
        return 'Other';
    }
  }

  static WorkerType fromString(String? val) {
    if (val == null || val.trim().isEmpty) return WorkerType.other;
    final normalized = val.trim().toUpperCase();
    for (final type in WorkerType.values) {
      if (type.toApiKey() == normalized) return type;
      if (type.displayName.toUpperCase() == normalized) return type;
    }
    return WorkerType.other;
  }
}

enum BudgetType { fixed, perHour, negotiable }

extension BudgetTypeX on BudgetType {
  String toApiKey() {
    switch (this) {
      case BudgetType.fixed:
        return 'FIXED';
      case BudgetType.perHour:
        return 'PERHOUR';
      case BudgetType.negotiable:
        return 'NEGOTIABLE';
    }
  }

  String get displayName {
    switch (this) {
      case BudgetType.fixed:
        return 'Fixed';
      case BudgetType.perHour:
        return 'Per Hour';
      case BudgetType.negotiable:
        return 'Negotiable';
    }
  }

  static BudgetType fromString(String? val) {
    if (val == null || val.trim().isEmpty) return BudgetType.fixed;
    final normalized = val.trim().toUpperCase();
    for (final type in BudgetType.values) {
      if (type.toApiKey() == normalized) return type;
    }
    // Handle legacy "Hourly" / "Per Day" from old UI
    if (normalized == 'HOURLY' || normalized == 'PER HOUR') {
      return BudgetType.perHour;
    }
    if (normalized == 'PER DAY') return BudgetType.fixed;
    return BudgetType.fixed;
  }
}

enum NeedAWorkerApplicationStatus { pending, accepted, rejected, withdrawn }

extension NeedAWorkerApplicationStatusX on NeedAWorkerApplicationStatus {
  String toApiKey() {
    switch (this) {
      case NeedAWorkerApplicationStatus.pending:
        return 'PENDING';
      case NeedAWorkerApplicationStatus.accepted:
        return 'ACCEPTED';
      case NeedAWorkerApplicationStatus.rejected:
        return 'REJECTED';
      case NeedAWorkerApplicationStatus.withdrawn:
        return 'WITHDRAWN';
    }
  }

  String get displayName {
    switch (this) {
      case NeedAWorkerApplicationStatus.pending:
        return 'Pending';
      case NeedAWorkerApplicationStatus.accepted:
        return 'Accepted';
      case NeedAWorkerApplicationStatus.rejected:
        return 'Rejected';
      case NeedAWorkerApplicationStatus.withdrawn:
        return 'Withdrawn';
    }
  }

  static NeedAWorkerApplicationStatus fromString(String? val) {
    if (val == null || val.trim().isEmpty) {
      return NeedAWorkerApplicationStatus.pending;
    }
    final normalized = val.trim().toUpperCase();
    for (final status in NeedAWorkerApplicationStatus.values) {
      if (status.toApiKey() == normalized) return status;
    }
    return NeedAWorkerApplicationStatus.pending;
  }
}
