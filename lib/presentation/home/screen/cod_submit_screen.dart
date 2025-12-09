import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../home/model/cod_submit_model.dart';
import '../home/provider/home_provider.dart';

class CODSubmitScreen extends StatefulWidget {
  final String agentId;
  const CODSubmitScreen({Key? key, required this.agentId}) : super(key: key);

  @override
  State<CODSubmitScreen> createState() => _CODSubmitScreenState();
}

class _CODSubmitScreenState extends State<CODSubmitScreen> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController notesController = TextEditingController();



  // Payment method selection
  String selectedMethod = "OnlineTransfer";
  final List<String> paymentMethods = [
    "CashDropAtHub",
    "OnlineTransfer"
  ];

  // Mock data - replace with actual values from your provider


  @override
  void initState() {
    super.initState();
  }




  Widget _buildInfoCard(AgentHomeProvider provider) {
    return Card(
      elevation: 2,

      shadowColor: Colors.black54,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Current Cash Held:",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                Text(
                  "₹${provider.agentCODHistoryModel?.currentCODHolding.toStringAsFixed(0)}",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: (provider.agentCODHistoryModel?.currentCODHolding??0) > (provider.agentCODHistoryModel?.codLimit??0) ? Colors.red : Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Cash Limit:",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  "₹${provider.agentCODHistoryModel?.codLimit.toStringAsFixed(0)}",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Amount to Submit",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: "Enter amount to submit",
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        ...paymentMethods.map((method) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: RadioListTile<String>(
            value: method,
            groupValue: selectedMethod,

            onChanged: (value) {
              setState(() {
                selectedMethod = value!;
              });
            },
            title: Text(
              method,
              style: const TextStyle(fontSize: 14),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            dense: true,
          ),
        )),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Notes (Optional)",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: notesController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: "Add notes here",
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }



  Widget _buildSubmitButton(AgentHomeProvider provider) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00C853),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
        onPressed: provider.isLoading ? null : (){

          provider.submitCOD(
            double.parse(amountController.text),
            selectedMethod,
            notesController.text.isEmpty ? "No notes provided" : notesController.text
          );
          amountController.clear();
          notesController.clear();
        },
        child: provider.isSubmit
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : const Text(
          "Submit COD",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Consumer<AgentHomeProvider>(

      builder: (context, provider, child) =>  Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(

          title: const Text("Submit Collected COD"),
          backgroundColor: Colors.white,
          // foregroundColor: Colors.black,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(provider),
              const SizedBox(height: 24),
              _buildAmountField(),
              _buildPaymentMethodSelection(),
              const SizedBox(height: 24),
              _buildNotesField(),
              const SizedBox(height: 32),
              _buildSubmitButton(provider),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    amountController.dispose();
    notesController.dispose();
    super.dispose();
  }
}