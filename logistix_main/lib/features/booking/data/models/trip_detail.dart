class User {
  final int id;
  final String phone;
  final String firstName;
  final String lastName;
  final String? profilePicture;

  User({
    required this.id,
    required this.phone,
    required this.firstName,
    required this.lastName,
    this.profilePicture,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      phone: json['phone'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      profilePicture: json['profile_picture'] as String?,
    );
  }

  String get fullName => '$firstName $lastName';
}

class Driver {
  final int id;
  final User user;
  final String licenseNumber;
  final bool isAvailable;
  final String averageRating;
  final double totalEarnings;

  Driver({
    required this.id,
    required this.user,
    required this.licenseNumber,
    required this.isAvailable,
    required this.averageRating,
    required this.totalEarnings,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] as int,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      licenseNumber: json['license_number'] as String,
      isAvailable: json['is_available'] as bool,
      averageRating: json['average_rating'] as String,
      totalEarnings: (json['total_earnings'] as num).toDouble(),
    );
  }

  double get rating {
    try {
      return double.parse(averageRating);
    } catch (e) {
      return 0.0;
    }
  }
}

class BookingRequestDetail {
  final int id;
  final String senderName;
  final String receiverName;
  final String senderPhone;
  final String receiverPhone;
  final DateTime pickupTime;
  final String pickupAddress;
  final String dropoffAddress;
  final String goodsType;
  final String goodsQuantity;
  final String paymentMode;
  final double estimatedFare;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  BookingRequestDetail({
    required this.id,
    required this.senderName,
    required this.receiverName,
    required this.senderPhone,
    required this.receiverPhone,
    required this.pickupTime,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.goodsType,
    required this.goodsQuantity,
    required this.paymentMode,
    required this.estimatedFare,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookingRequestDetail.fromJson(Map<String, dynamic> json) {
    return BookingRequestDetail(
      id: json['id'] as int,
      senderName: json['sender_name'] as String,
      receiverName: json['receiver_name'] as String,
      senderPhone: json['sender_phone'] as String,
      receiverPhone: json['receiver_phone'] as String,
      pickupTime: DateTime.parse(json['pickup_time'] as String),
      pickupAddress: json['pickup_address'] as String,
      dropoffAddress: json['dropoff_address'] as String,
      goodsType: json['goods_type'] as String,
      goodsQuantity: json['goods_quantity'] as String,
      paymentMode: json['payment_mode'] as String,
      estimatedFare: (json['estimated_fare'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class TripDetail {
  final int id;
  final Driver? driver;
  final BookingRequestDetail bookingRequest;
  final String status;
  final DateTime? loadingStartTime;
  final DateTime? loadingEndTime;
  final DateTime? unloadingStartTime;
  final DateTime? unloadingEndTime;
  final DateTime? paymentTime;
  final double? finalFare;
  final int? finalDuration;
  final String? finalDistance;
  final bool isPaymentDone;
  final DateTime createdAt;
  final DateTime updatedAt;

  TripDetail({
    required this.id,
    this.driver,
    required this.bookingRequest,
    required this.status,
    this.loadingStartTime,
    this.loadingEndTime,
    this.unloadingStartTime,
    this.unloadingEndTime,
    this.paymentTime,
    this.finalFare,
    this.finalDuration,
    this.finalDistance,
    required this.isPaymentDone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TripDetail.fromJson(Map<String, dynamic> json) {
    return TripDetail(
      id: json['id'] as int,
      driver: json['driver'] != null 
        ? Driver.fromJson(json['driver'] as Map<String, dynamic>)
        : null,
      bookingRequest: BookingRequestDetail.fromJson(
        json['booking_request'] as Map<String, dynamic>
      ),
      status: json['status'] as String,
      loadingStartTime: json['loading_start_time'] != null
        ? DateTime.parse(json['loading_start_time'] as String)
        : null,
      loadingEndTime: json['loading_end_time'] != null
        ? DateTime.parse(json['loading_end_time'] as String)
        : null,
      unloadingStartTime: json['unloading_start_time'] != null
        ? DateTime.parse(json['unloading_start_time'] as String)
        : null,
      unloadingEndTime: json['unloading_end_time'] != null
        ? DateTime.parse(json['unloading_end_time'] as String)
        : null,
      paymentTime: json['payment_time'] != null
        ? DateTime.parse(json['payment_time'] as String)
        : null,
      finalFare: json['final_fare'] != null 
        ? (json['final_fare'] as num).toDouble()
        : null,
      finalDuration: json['final_duration'] as int?,
      finalDistance: json['final_distance'] as String?,
      isPaymentDone: json['is_payment_done'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  bool get hasDriver => driver != null;
  bool get isAccepted => status == 'ACCEPTED';
  bool get isRequested => status == 'REQUESTED';
  bool get isCompleted => status == 'COMPLETED';
  bool get isCancelled => status == 'CANCELLED';
} 