import 'dart:convert';

class OrderAddress {
  final String firstName;
  final String lastName;
  final String fullAddress;
  final String city;
  final String street;
  final String house;

  OrderAddress({
    required this.firstName,
    required this.lastName,
    required this.fullAddress,
    required this.city,
    required this.street,
    required this.house,
  });

  String get fullName => '$firstName $lastName'.trim();

  Map<String, dynamic> toMap() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'full_address': fullAddress,
      'city': city,
      'street': street,
      'house': house,
    };
  }

  factory OrderAddress.fromMap(Map<String, dynamic> map) {
    return OrderAddress(
      firstName: map['first_name']?.toString() ?? '',
      lastName: map['last_name']?.toString() ?? '',
      fullAddress: map['full_address']?.toString() ?? '',
      city: map['city']?.toString() ?? '',
      street: map['street']?.toString() ?? '',
      house: map['house']?.toString() ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderAddress.fromJson(String source) =>
      OrderAddress.fromMap(json.decode(source));
}

class OrderModel {
  final int? id;
  final DateTime? createdAt;
  final String orderId;
  final String? userId;
  final int? prodId;
  final int? compId;
  final double price;
  final bool discountApplied;
  final bool paymentStatus;
  final String phoneNo;
  final String email;
  final String status;
  final OrderAddress address;

  OrderModel({
    this.id,
    this.createdAt,
    required this.orderId,
    this.userId,
    this.prodId,
    this.compId,
    required this.price,
    this.discountApplied = false,
    this.paymentStatus = false,
    required this.phoneNo,
    required this.email,
    this.status = 'created',
    required this.address,
  });

  Map<String, dynamic> toSupabaseMap() {
    return {
      'order_id': orderId,
      if (userId != null && userId!.isNotEmpty) 'user_id': userId,
      if (prodId != null) 'prod_id': prodId,
      if (compId != null) 'comp_id': compId,
      'price': price,
      'discount_applied': discountApplied,
      'payment_status': paymentStatus,
      'phone_no': phoneNo,
      'email': email,
      'status': status,
      'address': address.toMap(),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    OrderAddress parsedAddress;
    if (map['address'] is Map<String, dynamic>) {
      parsedAddress = OrderAddress.fromMap(map['address']);
    } else if (map['address'] is String) {
      try {
        parsedAddress = OrderAddress.fromJson(map['address']);
      } catch (_) {
        parsedAddress = OrderAddress(
          firstName: '',
          lastName: '',
          fullAddress: map['address'].toString(),
          city: '',
          street: '',
          house: '',
        );
      }
    } else {
      parsedAddress = OrderAddress(
        firstName: '',
        lastName: '',
        fullAddress: '',
        city: '',
        street: '',
        house: '',
      );
    }

    return OrderModel(
      id: map['id'] != null ? int.tryParse(map['id'].toString()) : null,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
      orderId: map['order_id']?.toString() ?? '',
      userId: map['user_id']?.toString(),
      prodId: map['prod_id'] != null ? int.tryParse(map['prod_id'].toString()) : null,
      compId: map['comp_id'] != null ? int.tryParse(map['comp_id'].toString()) : null,
      price: (map['price'] != null)
          ? double.tryParse(map['price'].toString()) ?? 0.0
          : 0.0,
      discountApplied: map['discount_applied'] == true,
      paymentStatus: map['payment_status'] == true,
      phoneNo: map['phone_no']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      status: map['status']?.toString() ?? 'created',
      address: parsedAddress,
    );
  }
}
