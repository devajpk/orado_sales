// models/order_assignment_models.dart
class OrderAssignmentData {
  final OrderDetails orderDetails;
  final String allocationMethod;
  final int requestExpirySec;
  final bool showAcceptReject;
  final DateTime countdownStartAt;
  final String? ringTone;

  OrderAssignmentData({
    required this.orderDetails,
    required this.allocationMethod,
    required this.requestExpirySec,
    required this.showAcceptReject,
    required this.countdownStartAt,
    this.ringTone,
  });

  factory OrderAssignmentData.fromJson(Map<String, dynamic> json) {
    return OrderAssignmentData(
      orderDetails: OrderDetails.fromJson(json['orderDetails']),
      allocationMethod: json['allocationMethod'] ?? 'manual_assignment',
      requestExpirySec: json['requestExpirySec'] ?? 30,
      showAcceptReject: json['showAcceptReject'] ?? true,
      countdownStartAt: DateTime.parse(json['countdownStartAt']),
      ringTone: json['ringTone'],
    );
  }
}

class OrderDetails {
  final String id;
  final String status;
  final double totalPrice;
  final DeliveryAddress deliveryAddress;
  final Location deliveryLocation;
  final DateTime createdAt;
  final String paymentMethod;
  final List<OrderItem> items;
  final double estimatedEarning;
  final String distanceKm;
  final Customer customer;
  final Restaurant restaurant;

  OrderDetails({
    required this.id,
    required this.status,
    required this.totalPrice,
    required this.deliveryAddress,
    required this.deliveryLocation,
    required this.createdAt,
    required this.paymentMethod,
    required this.items,
    required this.estimatedEarning,
    required this.distanceKm,
    required this.customer,
    required this.restaurant,
  });

  factory OrderDetails.fromJson(Map<String, dynamic> json) {
    return OrderDetails(
      id: json['id'],
      status: json['status'],
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      deliveryAddress: DeliveryAddress.fromJson(json['deliveryAddress']),
      deliveryLocation: Location.fromJson(json['deliveryLocation']),
      createdAt: DateTime.parse(json['createdAt']),
      paymentMethod: json['paymentMethod'] ?? 'COD',
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      estimatedEarning: (json['estimatedEarning'] ?? 0).toDouble(),
      distanceKm: json['distanceKm'].toString(),
      customer: Customer.fromJson(json['customer']),
      restaurant: Restaurant.fromJson(json['restaurant']),
    );
  }
}

class DeliveryAddress {
  final String street;
  final String city;

  DeliveryAddress({required this.street, required this.city});

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      street: json['street'] ?? '',
      city: json['city'] ?? '',
    );
  }
}

class Location {
  final double lat;
  final double long;

  Location({required this.lat, required this.long});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: (json['lat'] ?? 0).toDouble(),
      long: (json['long'] ?? json['lng'] ?? 0).toDouble(),
    );
  }
}

class OrderItem {
  final String id;
  final String name;
  final int quantity;
  final double price;

  OrderItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}

class Customer {
  final String name;
  final String phone;
  final String email;

  Customer({required this.name, required this.phone, required this.email});

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class Restaurant {
  final String name;
  final String address;
  final String phone;
  final Location location;

  Restaurant({
    required this.name,
    required this.address,
    required this.phone,
    required this.location,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      location: Location.fromJson(json['location'] ?? {}),
    );
  }
}