import 'package:oradosales/presentation/home/home/provider/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CodHistoryScreen extends StatefulWidget {
  const CodHistoryScreen({super.key});

  @override
  State<CodHistoryScreen> createState() => _CodHistoryScreenState();
}

class _CodHistoryScreenState extends State<CodHistoryScreen> {

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    Provider.of<AgentHomeProvider>(context, listen: false).codHistoryList.clear();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Cod History"),),

      body: Consumer<AgentHomeProvider>(
        builder: (context, provider, child) => (provider.istrue)? Center(child: CircularProgressIndicator(color: Colors.black12,)):ListView.builder(
          itemCount: provider.codHistoryList.length,
          itemBuilder: (context, index) {
            final item = provider.codHistoryList[index];
            return buildCODHistoryCard(
              amount: item.amount,
              method: item.method,
              notes: item.notes,
              status: item.status,
              droppedAt: item.droppedAt,
            );
          },
        )
        ,
      ),
    );
  }

  Widget buildCODHistoryCard({
    required double amount,
    required String method,
    required String notes,
    required String status,
    required DateTime droppedAt,
  }) {
    // Status ke hisaab se color
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'completed':
        statusColor = Colors.green;
        break;
      case 'failed':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "₹${amount.toStringAsFixed(2)}",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                          color: statusColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Method
              Row(
                children: [
                  const Icon(Icons.payment, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    method,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Notes
              Row(
                children: [
                  const Icon(Icons.note, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      notes,
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Dropped date
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('dd MMM yyyy, hh:mm a').format(droppedAt),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
