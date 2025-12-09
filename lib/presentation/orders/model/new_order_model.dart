class OrderPayload {
  final OrderDetails orderDetails;
  final String allocationMethod;
  final int requestExpirySec;
  final bool showAcceptReject;

  OrderPayload({
    required this.orderDetails,
    required this.allocationMethod,
    required this.requestExpirySec,
    required this.showAcceptReject,
  });

  factory OrderPayload.fromJson(Map<String, dynamic> json) => OrderPayload(
    orderDetails: OrderDetails.fromJson(json['orderDetails']),
    allocationMethod: json['allocationMethod'],
    requestExpirySec: json['requestExpirySec'],
    showAcceptReject: json['showAcceptReject'],
  );
}

class OrderDetails {
  final String id;
  final double totalPrice;
  final DeliveryAddress deliveryAddress;
  final Location deliveryLocation;
  final DateTime createdAt;
  final String paymentMethod;
  final List<OrderItem> orderItems;
  final double estimatedEarning;
  final double distanceKm;
  final Customer customer;
  final Restaurant restaurant;

  OrderDetails({
    required this.id,
    required this.totalPrice,
    required this.deliveryAddress,
    required this.deliveryLocation,
    required this.createdAt,
    required this.paymentMethod,
    required this.orderItems,
    required this.estimatedEarning,
    required this.distanceKm,
    required this.customer,
    required this.restaurant,
  });

  factory OrderDetails.fromJson(Map<String, dynamic> json) => OrderDetails(
    id: json['id'],
    totalPrice: json['totalPrice'].toDouble(),
    deliveryAddress: DeliveryAddress.fromJson(json['deliveryAddress']),
    deliveryLocation: Location.fromJson(json['deliveryLocation']),
    createdAt: DateTime.parse(json['createdAt']),
    paymentMethod: json['paymentMethod'],
    orderItems: (json['orderItems'] as List)
        .map((e) => OrderItem.fromJson(e))
        .toList(),
    estimatedEarning: json['estimatedEarning'].toDouble(),
    distanceKm: json['distanceKm'].toDouble(),
    customer: Customer.fromJson(json['customer']),
    restaurant: Restaurant.fromJson(json['restaurant']),
  );
}

class DeliveryAddress {
  final String street;
  final String area;
  final String city;
  final String state;
  final String country;

  DeliveryAddress({
    required this.street,
    required this.area,
    required this.city,
    required this.state,
    required this.country,
  });

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) =>
      DeliveryAddress(
        street: json['street'],
        area: json['area'],
        city: json['city'],
        state: json['state'],
        country: json['country'],
      );
}

class Location {
  final double lat;
  final double long;

  Location({required this.lat, required this.long});

  factory Location.fromJson(Map<String, dynamic> json) =>
      Location(lat: json['lat'].toDouble(), long: json['long'].toDouble());
}

class Customer {
  final String name;
  final String phone;
  final String email;

  Customer({required this.name, required this.phone, required this.email});

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
    name: json['name'],
    phone: json['phone'],
    email: json['email'],
  );
}

class Restaurant {
  final String name;
  final RestaurantAddress address;
  final Location location;

  Restaurant(
      {required this.name, required this.address, required this.location});

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
    name: json['name'],
    address: RestaurantAddress.fromJson(json['address']),
    location: Location.fromJson(json['location']),
  );
}

class RestaurantAddress {
  final String street;
  final String city;
  final String state;

  RestaurantAddress({
    required this.street,
    required this.city,
    required this.state,
  });

  factory RestaurantAddress.fromJson(Map<String, dynamic> json) =>
      RestaurantAddress(
        street: json['street'],
        city: json['city'],
        state: json['state'],
      );
}

class OrderItem {
  final String name;
  final int qty;
  final double price;

  OrderItem({required this.name, required this.qty, required this.price});

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    name: json['name'],
    qty: json['qty'],
    price: json['price'].toDouble(),
  );
}
