import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/incentive_controller.dart';
import '../model/incentive_model.dart';

class IncentivesDashboard extends StatefulWidget {
  @override
  _IncentivesDashboardState createState() => _IncentivesDashboardState();
}

class _IncentivesDashboardState extends State<IncentivesDashboard> {
  int selectedTab = 0;

  @override
  void initState() {
    super.initState();
    // Default load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<IncentiveController>(context, listen: false).loadIncentive('daily');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<IncentiveController>(
      builder: (context, controller, child) {
        final data = controller.incentiveData;



        return Scaffold(
          backgroundColor: Colors.white,

          body: Column(
            children: [
              // Tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Container(
                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [_buildTab('Daily', 0, controller), _buildTab('Weekly', 1, controller), _buildTab('Monthly', 2, controller)]),
                ),
              ),

              controller.isLoading
                  ? Center(child: Column(children: [SizedBox(height: 30), CircularProgressIndicator(color: Colors.green)]))
                  : data == null || data.incentivePlans.isEmpty
                  ? Center(child: Text("No incentives available"))
                  : Expanded(
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (data.highestEligibleIncentive != null) Text('Current Eligible Incentive', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                      if (data.highestEligibleIncentive != null) SizedBox(height: 16),


                      if (data.highestEligibleIncentive != null)  _currentIncentiveCard(data, ),

                      if (data.highestEligibleIncentive != null) SizedBox(height: 32),
                      Text('All Incentives', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87)),
                      SizedBox(height: 16),

                      Expanded(
                        child: ListView.builder(
                          itemCount: data.incentivePlans.length,
                          itemBuilder: (context, index) {
                            final plan = data.incentivePlans[index];
                            return _buildIncentiveItem(
                              '\$${plan.incentive.toStringAsFixed(2)}',
                              plan.status,
                              '${plan.currentValue.toInt()}/${plan.minValue.toInt()}',
                              plan.highlighted == true ? Colors.green : Colors.grey[400]!,
                              plan.status.contains('Completed'),
                              progress: plan.percent / 100,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Container _currentIncentiveCard(IncentiveSummaryModel data, ) {
    double progress = (data.highestEligibleIncentive?.percent??0) / 100;
    return Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Earn an extra', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                                Text('\$${data.highestEligibleIncentive?.incentive.toStringAsFixed(2)}', style: TextStyle(color: Colors.green, fontSize: 28, fontWeight: FontWeight.bold)),
                                SizedBox(height: 8),
                                Text(data.highestEligibleIncentive?.name??"", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                                Text(data.highestEligibleIncentive?.description??"", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                SizedBox(height: 16),
                                Row(
                                  children: [
                                    Text('${data.highestEligibleIncentive?.currentValue.toInt()}/${data.highestEligibleIncentive?.minValue.toInt()}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                    Spacer(),
                                    Text('${(progress * 100).toInt()}%', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                  ],
                                ),
                                SizedBox(height: 8),
                                LinearProgressIndicator(value: progress, backgroundColor: Colors.grey[200], valueColor: AlwaysStoppedAnimation<Color>(Colors.green)),
                              ],
                            ),
                          ),
                          SizedBox(width: 20),
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                            child: Icon(Icons.delivery_dining, size: 40, color: Colors.blue[400]),
                          ),
                        ],
                      ),
                    );
  }

  Widget _buildTab(String title, int index, IncentiveController controller) {
    bool isSelected = selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = index;
          });
          String type =
          index == 0
              ? 'daily'
              : index == 1
              ? 'weekly'
              : 'monthly';
          controller.loadIncentive(type);
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: isSelected ? Colors.green : Colors.transparent, borderRadius: BorderRadius.circular(8)),
          margin: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(color: isSelected ? Colors.white : Colors.grey[600], fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
      ),
    );
  }



  Widget _buildIncentiveItem(String amount, String title, String subtitle, Color iconColor, bool isCompleted, {double? progress}) {
    return Container(
      margin: EdgeInsets.only(bottom: 5,top: 10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 1))],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: iconColor.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(isCompleted ? Icons.check : Icons.local_offer, color: iconColor, size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Earn an extra $amount', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                    Spacer(),
                    Text(subtitle.split(' ')[0], style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
                SizedBox(height: 4),
                Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                if (progress != null) ...[
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      Spacer(),
                      Text('${(progress * 100).toInt()}%', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                  SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
