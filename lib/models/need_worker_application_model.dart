import 'need_worker_model.dart';

class NeedWorkerApplicationWorker {
  final String id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phoneNumber;
  final String? profilePhotoUrl;

  NeedWorkerApplicationWorker({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phoneNumber,
    this.profilePhotoUrl,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory NeedWorkerApplicationWorker.fromJson(Map<String, dynamic> json) {
    final photo = json['profilePhoto'] as Map<String, dynamic>?;
    return NeedWorkerApplicationWorker(
      id: json['id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      profilePhotoUrl: photo?['url'] as String?,
    );
  }
}

class NeedWorkerApplicationModel {
  final String id;
  final String workerId;
  final String workRequestId;
  final String? coverLetter;
  final String? proposedPrice;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final NeedWorkerModel? workRequest;
  final NeedWorkerApplicationWorker? worker;

  NeedWorkerApplicationModel({
    required this.id,
    required this.workerId,
    required this.workRequestId,
    this.coverLetter,
    this.proposedPrice,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.workRequest,
    this.worker,
  });

  factory NeedWorkerApplicationModel.fromJson(Map<String, dynamic> json) {
    NeedWorkerModel? workRequest;
    if (json['workRequest'] is Map<String, dynamic>) {
      workRequest = NeedWorkerModel.fromJson(
        json['workRequest'] as Map<String, dynamic>,
      );
    }

    NeedWorkerApplicationWorker? worker;
    if (json['worker'] is Map<String, dynamic>) {
      worker = NeedWorkerApplicationWorker.fromJson(
        json['worker'] as Map<String, dynamic>,
      );
    }

    return NeedWorkerApplicationModel(
      id: json['id'] as String? ?? '',
      workerId: json['workerId'] as String? ?? '',
      workRequestId: json['workRequestId'] as String? ?? '',
      coverLetter: json['coverLetter'] as String?,
      proposedPrice: json['proposedPrice']?.toString(),
      status: json['status'] as String? ?? 'PENDING',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      workRequest: workRequest,
      worker: worker,
    );
  }

  NeedWorkerApplicationModel copyWith({
    String? id,
    String? workerId,
    String? workRequestId,
    String? coverLetter,
    String? proposedPrice,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    NeedWorkerModel? workRequest,
    NeedWorkerApplicationWorker? worker,
  }) {
    return NeedWorkerApplicationModel(
      id: id ?? this.id,
      workerId: workerId ?? this.workerId,
      workRequestId: workRequestId ?? this.workRequestId,
      coverLetter: coverLetter ?? this.coverLetter,
      proposedPrice: proposedPrice ?? this.proposedPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      workRequest: workRequest ?? this.workRequest,
      worker: worker ?? this.worker,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workerId': workerId,
      'workRequestId': workRequestId,
      'coverLetter': coverLetter,
      'proposedPrice': proposedPrice,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
