import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/milestone_controller.dart';
import '../model/milestone_model.dart';

class MilestoneProgressPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MilestoneController>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow[700]!),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(

            automaticallyImplyLeading: false,

            title: Text(
              'Milestones & Rewards',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,

          ),
          body: Column(
            children: [
              // Header description
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Text(
                  'Track your progress and claim rewards as you reach new milestones.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ),

              // Milestones List
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: provider.mileStoneList.length,
                  itemBuilder: (context, index) {
                    final milestone = provider.mileStoneList[index];
                    return _buildMilestoneCard(milestone, context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMilestoneCard(Milestone milestone, BuildContext context) {
    Color statusColor = _getStatusColor(milestone);
    IconData statusIcon = _getStatusIcon(milestone);

    // Reduce opacity if status is Locked
    double cardOpacity = milestone.status.toLowerCase() == 'locked' ? 0.5 : 1.0;

    return Opacity(
      opacity: cardOpacity,
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status and Level Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        SizedBox(width: 6),
                        Text(
                          milestone.status,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  _buildLevelIcon(milestone.level.toString()),
                ],
              ),

              SizedBox(height: 16),

              // Level Title
              Text(
                milestone.title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),

              SizedBox(height: 20),

              // Progress Indicators
              ...milestone.conditions.map((condition) {
                return _buildProgressIndicator(condition);
              }).toList(),

              SizedBox(height: 20),

              // Reward Section
              _buildRewardSection(milestone, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(dynamic condition) {
    double progress = condition.target > 0 ? condition.done / condition.target : 0;
    progress = progress.clamp(0.0, 1.0);

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getConditionLabel(condition.name),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              Text(
                "${condition.done.toInt()}/${condition.target.toInt()}",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress >= 1.0 ? Colors.green : Colors.orange,
                ),
                minHeight: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardSection(Milestone milestone, BuildContext context) {
    bool canClaim = milestone.claimable;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.yellow[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: milestone.reward.imageUrl.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    milestone.reward.imageUrl,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.card_giftcard,
                          color: Colors.yellow[700]);
                    },
                  ),
                )
                    : Icon(Icons.card_giftcard,
                    color: Colors.yellow[700]),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Reward: ${milestone.reward.name}",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      milestone.reward.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // Claim Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: canClaim ? () {
                _showClaimDialog(context, milestone);
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canClaim ? Colors.yellow[700] : Colors.grey[300],
                foregroundColor: Colors.black,
                elevation: canClaim ? 2 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                canClaim ? "Claim Reward" : "Claim Reward",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelIcon(String level) {

    return Container(
      width: 50, // slightly bigger for better text fit
      height: 50,
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.amber, width: 1.5), // optional outline
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "$level",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.amberAccent,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              "Level",
              style: const TextStyle(
                fontSize: 10,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    )
    ;
  }

  Color _getStatusColor(Milestone milestone) {
    if (milestone.claimable) return Colors.green;
    if (milestone.status == "In Progress") return Colors.orange;
    if (milestone.status == "Locked") return Colors.grey;
    return Colors.green; // Completed
  }

  IconData _getStatusIcon(Milestone milestone) {
    if (milestone.claimable) return Icons.check_circle;
    if (milestone.status == "In Progress") return Icons.access_time;
    if (milestone.status == "Locked") return Icons.lock;
    return Icons.check_circle; // Completed
  }




  String _getConditionLabel(String key) {
    switch (key) {
      case "totalDeliveries":
        return "Total Deliveries";
      case "onTimeDeliveries":
        return "On-Time Deliveries";
      case "totalEarnings":
        return "Total Earnings";
      default:
        return key.replaceAll(RegExp(r'([A-Z])'), ' \$1').trim();
    }
  }

  void _showClaimDialog(BuildContext context, Milestone milestone) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.celebration, color: Colors.yellow[700]),
              SizedBox(width: 8),
              Text('Congratulations!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'You have successfully completed the ${milestone.title}!',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.yellow[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.card_giftcard, color: Colors.yellow[700]),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Reward: ${milestone.reward.name}',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Later'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Add claim logic here
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Reward claimed successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[700],
                foregroundColor: Colors.black,
              ),
              child: Text('Claim Now'),
            ),
          ],
        );
      },
    );
  }
}