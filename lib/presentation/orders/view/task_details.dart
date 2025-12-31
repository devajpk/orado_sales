import 'package:flutter/material.dart';
import 'package:oradosales/presentation/orders/model/order_details_model.dart';

class TaskDetailsPage extends StatelessWidget {
  final Order order;

  const TaskDetailsPage({
    super.key,
    required this.order,
  });

  double _calculateGrandTotal() {
    return order.items.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

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
        child: Column(
          children: [
            _tableHeader(),
            const SizedBox(height: 12),

            Expanded(
              child: ListView.separated(
                itemCount: order.items.length,
                separatorBuilder: (_, __) => Divider(
                  color: Colors.grey.shade800,
                  height: 24,
                ),
                itemBuilder: (context, index) {
                  return _orderItemRow(order.items[index]);
                },
              ),
            ),

            const SizedBox(height: 12),

            _grandTotalCard(),
          ],
        ),
      ),
    );
  }

  // ---------------- TABLE HEADER ----------------

  Widget _tableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade700),
      ),
      child: Row(
        children: const [
          Expanded(
            flex: 4,
            child: Text(
              "ITEM",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "QTY",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              "AMOUNT",
              textAlign: TextAlign.end,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- ORDER ITEM ROW ----------------

  Widget _orderItemRow(OrderItem item) {
    final double amount = item.price * item.quantity;

    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Text(
            item.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            item.quantity.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            "₹ ${amount.toStringAsFixed(2)}",
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- GRAND TOTAL ----------------

  Widget _grandTotalCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.green.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "GRAND TOTAL",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          Text(
            "₹ ${_calculateGrandTotal().toStringAsFixed(2)}",
            style: const TextStyle(
              color: Colors.greenAccent,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
