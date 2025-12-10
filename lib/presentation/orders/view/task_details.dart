import 'package:flutter/material.dart';
import 'package:oradosales/presentation/orders/model/order_details_model.dart';


class TaskDetailsPage extends StatelessWidget {
  final Order order;

  const TaskDetailsPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xff4AA3F9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Task Details",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: ListView(
          children: [
            ...order.items.map((item) => _orderItemTile(item)),

            const SizedBox(height: 12),

            if (order.taxDetails.isNotEmpty)
              ..._buildTaxDetails(order),

            const SizedBox(height: 12),

            if (order.offer != null) _offerTile(order.offer!),
          ],
        ),
      ),
    );
  }

  // ------------------------ ORDER ITEMS ------------------------

  Widget _orderItemTile(OrderItem item) {
    double amount = item.price * item.quantity;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row("ITEMS", item.name),
          const SizedBox(height: 12),
          _row("QTY", item.quantity.toString()),
          const SizedBox(height: 12),
          _row("AMOUNT", "₹ ${amount.toStringAsFixed(2)}"),
        ],
      ),
    );
  }

  // ------------------------ TAX DETAILS ------------------------

  List<Widget> _buildTaxDetails(Order order) {
    return order.taxDetails.map((tax) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row("ITEMS", tax["label"]?.toString() ?? "Tax"),
            const SizedBox(height: 12),
            _row("QTY", "-"),
            const SizedBox(height: 12),
            _row("AMOUNT", "₹ ${(tax["value"] as num?)?.toDouble().toString()}"),
          ],
        ),
      );
    }).toList();
  }

  // ------------------------ OFFER ------------------------

  Widget _offerTile(OrderOffer offer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row("OFFER", offer.name),
          const SizedBox(height: 12),
          _row("COUPON", offer.couponCode),
          const SizedBox(height: 12),
          _row("DISCOUNT", "₹ ${offer.discount.toStringAsFixed(2)}"),
        ],
      ),
    );
  }

  // ------------------------ REUSABLE ROW ------------------------

  Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade400,
            letterSpacing: 1,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
