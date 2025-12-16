import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:oradosales/presentation/home/home/provider/available_provider.dart';
import 'package:oradosales/presentation/home/screen/cod_history_screen.dart';
import 'package:oradosales/presentation/home/screen/cod_submit_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:oradosales/presentation/notification_fcm/service/fcm_service.dart';
import 'package:oradosales/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:oradosales/constants/styles.dart';
import 'package:oradosales/presentation/home/home/provider/home_provider.dart';
import 'package:lottie/lottie.dart';
import '../../../constants/colors.dart';
import '../../socket_io/socket_controller.dart';
import 'dart:developer';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  
    checkBatteryOptimization();
    // player.setAsset("assets/sounds/new_order.mp3");

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final provider = Provider.of<AgentHomeProvider>(context, listen: false);
        provider.loadAgentHomeData();
      } catch (e) {
        log('Error loading home data: $e');
      }
       intiLocation();
    });
  }
  Future<void> checkBatteryOptimization() async {
    // Handle nullable bool by using ?? (null coalescing operator)
    bool isBatteryOptimizationDisabled =
        await DisableBatteryOptimization.isBatteryOptimizationDisabled ?? false;

    // Note: if battery optimization is ON, the value is false
    // if battery optimization is OFF, the value is true
    // So we check if it's NOT disabled (meaning optimization is ON)
    if (!isBatteryOptimizationDisabled) {
      // Battery optimization ON hai, dialog show karo
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text("Battery Optimization Alert"),
            content: const Text(
                "Battery optimization is ON. To get location updates in the background, please turn it OFF."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  await DisableBatteryOptimization.showDisableBatteryOptimizationSettings();
                  Navigator.pop(context);
                },
                child: const Text("Open Settings"),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> intiLocation() async {
    try {
      final socketController = SocketController.instance;
      await socketController.setupBackgroundService();
      log('Background service setup completed from home screen');
    } catch (e) {
      log('Error setting up background service: $e');
    }
  }

  final AudioPlayer player = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set white background here
      body: Consumer<AgentHomeProvider>(
        builder: (context, agentHomeProvider, child) {
          final homeData = agentHomeProvider.homeData;
          final theme = Theme.of(context);

          return agentHomeProvider.isLoading
              ? Center(child: Lottie.asset('asstes/Delivery guy out for delivery.json', width: 180, height: 180, fit: BoxFit.contain))
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _buildHeader(theme),
                    const SizedBox(height: 24),
                    _buildStatsGrid(agentHomeProvider),
                    const SizedBox(height: 24),
                    _buildCODStatus(theme, agentHomeProvider),
                    const SizedBox(height: 10),
                    _buildSummaryCard(homeData, theme),
                  ],
                ),
              );
        },
      ),
    );
  }

  Widget _buildCODStatus(ThemeData theme, AgentHomeProvider agentHomeProvider) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, spreadRadius: 2)],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text('COD Status', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.black87))],
                ),
                const SizedBox(height: 16),
                _buildMetricRow(
                  icon: Icons.account_balance_wallet,
                  title: 'Current Cash Held',
                  value: agentHomeProvider.agentCODModel?.currentCashHeld.toString() ?? "10",
                  iconColor: const Color(0xFF4CAF50),
                ),
                _buildMetricRow(
                  icon: Icons.warning_amber,
                  title: 'Maximum Allowed',
                  value: agentHomeProvider.agentCODModel?.codLimit.toString() ?? "0",
                  iconColor: Colors.orange,
                ),
                _buildMetricRow(
                  isLast: true,
                  icon: Icons.bar_chart,
                  title: 'COD Usage',
                  value: "${agentHomeProvider.agentCODModel?.codUsagePercent ?? 0}% used",
                  iconColor: Colors.redAccent,
                ),
                SizedBox(height: 10),
                LinearProgressIndicator(
                  borderRadius: BorderRadius.circular(10),
                  value: (agentHomeProvider.agentCODModel?.codUsagePercent ?? 0) / 100,
                  backgroundColor: Colors.grey[300],
                  color: (agentHomeProvider.agentCODModel?.limitExceeded ?? false) ? Colors.red : Color(0xFF6366F1),
                  minHeight: 10,
                ),
              ],
            ),
          ),
        ),
        (agentHomeProvider.agentCODModel?.limitExceeded ?? false)
            ? Container(
              // padding: EdgeInsets.only(16),
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Color(0xFFFFF4E5), // Light yellow background
                borderRadius: BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)),
                // border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 120,
                    width: 3.5,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 16),
                    child: Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16, top: 16, right: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "You have exceeded your COD limit!",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade800, fontSize: 16),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "You cannot accept new cash orders. Please submit the pending cash first to continue accepting COD orders.",
                            style: TextStyle(color: Colors.orange.shade700, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
            : SizedBox(),
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {

                    agentHomeProvider.getCODHistoryData();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => CODSubmitScreen(agentId: agentHomeProvider.agentCODHistoryModel?.agentId??"",)),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        "Submit Collected COD",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8), // gap between buttons
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    agentHomeProvider.getCODHistoryData();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => CodHistoryScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        "View COD History",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
        ,
      ],
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final socketController = SocketController.instance;

    return Consumer<AgentAvailableController>(
      builder:
          (context, agentController, child) => Container(
            margin: const EdgeInsets.all(0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.baseColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: Icon(Icons.delivery_dining, color: AppColors.baseColor, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome back!', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: Colors.black87)),
                          const SizedBox(height: 4),
                          Text('Here\'s your daily summary', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54, fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Availability Toggle Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          agentController.isAvailable
                              ? [const Color(0xFF4CAF50).withOpacity(0.1), const Color(0xFF66BB6A).withOpacity(0.05)]
                              : [const Color(0xFFFF5722).withOpacity(0.1), const Color(0xFFFF7043).withOpacity(0.05)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: agentController.isAvailable ? const Color(0xFF4CAF50).withOpacity(0.2) : const Color(0xFFFF5722).withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), spreadRadius: 0, blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Column(
                    children: [
                      // Status Header
                      Row(
                        children: [
                          // Status Icon
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: agentController.isAvailable ? const Color(0xFF4CAF50) : const Color(0xFFFF5722),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: (agentController.isAvailable ? const Color(0xFF4CAF50) : const Color(0xFFFF5722)).withOpacity(0.3),
                                  spreadRadius: 0,
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              agentController.isAvailable ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Status Text
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text('Delivery Status', style: TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: agentController.isAvailable ? const Color(0xFF4CAF50) : const Color(0xFFFF5722),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      agentController.isAvailable ? 'Available for Orders' : 'Currently Offline',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: agentController.isAvailable ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  agentController.isAvailable ? 'Ready to receive and deliver orders' : 'Switch on to start receiving orders',
                                  style: TextStyle(fontSize: 13, color: Colors.black45),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Toggle Button
                      Container(
                        width: double.infinity,
                        height: 45,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: LinearGradient(
                            colors:
                                agentController.isAvailable
                                    ? [const Color(0xFF4CAF50), const Color(0xFF66BB6A)]
                                    : [const Color(0xFFBDBDBD), const Color(0xFF9E9E9E)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (agentController.isAvailable ? const Color(0xFF4CAF50) : const Color(0xFF9E9E9E)).withOpacity(0.3),
                              spreadRadius: 0,
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(28),
                            onTap:
                                agentController.isLoading
                                    ? null
                                    : () async {
                                      await agentController.toggleAvailability(context);
                                      if (agentController.isAvailable) {
                                        await socketController.connectSocket();
                                      } else {
                                        socketController.disconnectSocket();
                                      }
                                    },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (agentController.isLoading) ...[
                                    SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                    ),
                                    const SizedBox(width: 12),
                                    Text('Updating...', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                                  ] else ...[
                                    Icon(
                                      agentController.isAvailable ? Icons.pause_circle_outline : Icons.play_circle_outline,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      agentController.isAvailable ? 'Go Offline' : 'Go Online',
                                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Quick Stats Row (Optional)
                // const SizedBox(height: 16),
                // Row(
                //   children: [
                //     Expanded(
                //       child: Container(
                //         padding: const EdgeInsets.all(16),
                //         decoration: BoxDecoration(
                //           color: Colors.white,
                //           borderRadius: BorderRadius.circular(12),
                //           border: Border.all(color: Colors.grey.withOpacity(0.1)),
                //           boxShadow: [
                //             BoxShadow(
                //               color: Colors.black.withOpacity(0.02),
                //               spreadRadius: 0,
                //               blurRadius: 4,
                //               offset: const Offset(0, 2),
                //             ),
                //           ],
                //         ),
                //         child: Column(
                //           children: [
                //             Icon(Icons.access_time, color: AppColors.baseColor, size: 20),
                //             const SizedBox(height: 8),
                //             Text(
                //               agentController.isAvailable ? 'Online Now' : 'Offline',
                //               style: TextStyle(
                //                 fontSize: 12,
                //                 color: Colors.black54,
                //                 fontWeight: FontWeight.w500,
                //               ),
                //             ),
                //           ],
                //         ),
                //       ),
                //     ),
                //     const SizedBox(width: 12),
                //     Expanded(
                //       child: Container(
                //         padding: const EdgeInsets.all(16),
                //         decoration: BoxDecoration(
                //           color: Colors.white,
                //           borderRadius: BorderRadius.circular(12),
                //           border: Border.all(color: Colors.grey.withOpacity(0.1)),
                //           boxShadow: [
                //             BoxShadow(
                //               color: Colors.black.withOpacity(0.02),
                //               spreadRadius: 0,
                //               blurRadius: 4,
                //               offset: const Offset(0, 2),
                //             ),
                //           ],
                //         ),
                //         child: Column(
                //           children: [
                //             Icon(Icons.notifications_active, color: AppColors.baseColor, size: 20),
                //             const SizedBox(height: 8),
                //             Text(
                //               'Notifications',
                //               style: TextStyle(
                //                 fontSize: 12,
                //                 color: Colors.black54,
                //                 fontWeight: FontWeight.w500,
                //               ),
                //             ),
                //           ],
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
    );
  }

  Widget _buildStatsGrid(AgentHomeProvider provider) {
    final homeData = provider.homeData;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      childAspectRatio: 0.8,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _buildStatCard(
          title: 'New Orders',
          value: homeData?.orderSummary.newOrders ?? 0, // Using newOrders from OrderSummary
          icon: Icons.add_shopping_cart,
          color: const Color(0xFFE3F2FD),
          iconColor: const Color(0xFF1976D2),
        ),
        _buildStatCard(
          title: 'Cancelled',
          value: homeData?.orderSummary.rejectedOrders ?? 0, // Using rejectedOrders from OrderSummary
          icon: Icons.cancel_outlined,
          color: const Color(0xFFFFEBEE),
          iconColor: const Color(0xFFD32F2F),
        ),
        _buildStatCard(
          title: 'Total Orders',
          value: homeData?.orderSummary.totalOrders ?? 0, // Using totalOrders from OrderSummary
          icon: Icons.list_alt,
          color: const Color(0xFFE8F5E9),
          iconColor: const Color(0xFF388E3C),
        ),
      ],
    );
  }

  Widget _buildStatCard({required String title, required int value, required IconData icon, required Color color, required Color iconColor}) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, spreadRadius: 1)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, spreadRadius: 1)],
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(height: 12),
            Text(value.toString(), style: AppStyles.getBoldTextStyle(fontSize: 20).copyWith(color: Colors.black87)),
            const SizedBox(height: 4),
            Text(title, textAlign: TextAlign.center, style: AppStyles.getMediumTextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(homeData, ThemeData theme) {
    final earnings = homeData?.dailySummary?.earnings ?? 0;
    final rating = homeData?.dailySummary?.rating ?? 0.0;
    final distance = homeData?.dailySummary?.distanceTravelledKm ?? 0.0;
    final deliveries = homeData?.dailySummary?.totalDeliveries ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, spreadRadius: 2)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Today\'s Performance', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.black87)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text('Today', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMetricRow(
              icon: Icons.local_shipping_outlined,
              title: 'Deliveries',
              value: deliveries.toString(),
              iconColor: const Color(0xFF4CAF50),
            ),
            _buildMetricRow(
              icon: Icons.currency_rupee_outlined,
              title: 'Earnings',
              value: "₹${earnings.toStringAsFixed(0)}",
              iconColor: const Color(0xFF2196F3),
            ),
            _buildMetricRow(
              icon: Icons.directions_walk,
              title: 'Distance',
              value: "${distance.toStringAsFixed(1)} km",
              iconColor: const Color(0xFF9C27B0),
            ),
            _buildMetricRow(
              icon: Icons.star_outline,
              title: 'Rating',
              value: rating.toStringAsFixed(1),
              iconColor: const Color(0xFFFF9800),
              isLast: true,
            ),
            const SizedBox(height: 24),
            Text('Incentive Progress', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.black87)),
            const SizedBox(height: 16),
            SizedBox(height: 220, child: _buildIncentiveChart()),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow({required IconData icon, required String title, required String value, required Color iconColor, bool isLast = false}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: iconColor),
                const SizedBox(width: 12),
                Text(title, style: AppStyles.getMediumTextStyle(fontSize: 14, color: Colors.black87)),
              ],
            ),
            Text(value, style: AppStyles.getBoldTextStyle(fontSize: 15).copyWith(color: Colors.black87)),
          ],
        ),
        if (!isLast) Divider(height: 24, color: Colors.grey.shade200, thickness: 1),
      ],
    );
  }

  Widget _buildIncentiveChart() {
    final incentiveGraph = Provider.of<AgentHomeProvider>(context, listen: false).incentiveGraph;

    final List<SalesData> data = incentiveGraph.map((item) => SalesData(
      year: item['period']?.toString() ?? 'N/A', 
      sales: (item['value'] ?? 0).toDouble()
    )).toList();

    return SfCartesianChart(
      margin: EdgeInsets.zero,
      plotAreaBorderWidth: 0,
      primaryXAxis: CategoryAxis(
        labelStyle: AppStyles.getMediumTextStyle(fontSize: 12).copyWith(color: Colors.black54),
        majorGridLines: const MajorGridLines(width: 0),
      ),
      primaryYAxis: NumericAxis(
        labelStyle: AppStyles.getMediumTextStyle(fontSize: 12).copyWith(color: Colors.black54),
        majorGridLines: const MajorGridLines(width: 0),
        axisLine: const AxisLine(width: 0),
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        header: '',
        format: 'point.x : point.y',
        textStyle: AppStyles.getMediumTextStyle(fontSize: 12).copyWith(color: Colors.white),
      ),
      series: <ColumnSeries<SalesData, String>>[
        ColumnSeries<SalesData, String>(
          width: 0.4,
          spacing: 0.2,
          dataSource: data,
          borderRadius: BorderRadius.circular(4),
          color: const Color(0xFF6366F1),
          gradient: LinearGradient(
            colors: [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          xValueMapper: (SalesData sales, _) => sales.year!,
          yValueMapper: (SalesData sales, _) => sales.sales!,
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelAlignment: ChartDataLabelAlignment.top,
            textStyle: TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}

class SalesData {
  SalesData({this.year, this.sales});
  final String? year;
  final double? sales;
}
