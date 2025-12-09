// import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart';
//
// import '../../../../services/navigation_service.dart';
// import '../../../../widgets/countdownTimerWidget.dart';
// import '../../../orders/model/new_order_model.dart';
//
// final AudioPlayer player = AudioPlayer();
// Future<void> _showOrderBottomSheet(OrderPayload order) async {
//   if (NavigationService.navigatorKey.currentContext == null) return;
//
//   // Play notification sound
//
//   try {
//     await player.setAsset("asstes/sounds/positive-notification-digital-strum-fast-gamemaster-audio-1-1-00-03.mp3"); // Correct path
//
//     await player.play(); // Start playback
//   } catch (e) {
//     print("Audio play error: $e");
//   }
//
//   showModalBottomSheet(
//     context: NavigationService.navigatorKey.currentContext!,
//     isScrollControlled: true,
//     enableDrag: false,
//     showDragHandle: false,
//
//     isDismissible: false,
//     backgroundColor: Colors.transparent,
//     builder: (context) {
//       return DraggableScrollableSheet(
//         initialChildSize: 0.6,
//         maxChildSize: 0.6,
//         minChildSize: 0.5,
//
//         expand: false,
//         builder: (context, scrollController) {
//
//
//           return Container(
//             decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 // Handle bar
//                 Container(
//                   width: 40,
//                   height: 4,
//                   margin: EdgeInsets.only(top: 8, bottom: 16),
//                   decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
//                 ),
//
//                 Expanded(
//                   child: SingleChildScrollView(
//                     controller: scrollController,
//                     padding: EdgeInsets.symmetric(horizontal: 16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         // Header
//                         Text(
//                           'New Order Assigned!',
//                           style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
//                         ),
//                         SizedBox(height: 8),
//
//                         // Status chip
//                         Container(
//                           padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                           decoration: BoxDecoration(color: Color(0xFF4CAF50), borderRadius: BorderRadius.circular(12)),
//                           child: Text(
//                             'ORDER • PICKUP • DROP',
//                             style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 0.5),
//                           ),
//                         ),
//                         SizedBox(height: 12),
//
//                         // Earnings section
//                         Text(
//                           'PICKUP EARNINGS',
//                           style: TextStyle(
//                             fontSize: 11,
//                             color: Colors.grey[600],
//                             fontWeight: FontWeight.w500,
//                             letterSpacing: 0.5,
//                           ),
//                         ),
//                         SizedBox(height: 2),
//
//                         Text(
//                           '₹${order.orderDetails.estimatedEarning}',
//                           style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
//                         ),
//
//                         Text('${order.orderDetails.distanceKm} kms', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
//                         SizedBox(height: 16),
//                         // Pickup Details section
//                         Text(
//                           'PICKUP DETAILS',
//                           style: TextStyle(
//                             fontSize: 11,
//                             color: Colors.grey[600],
//                             fontWeight: FontWeight.w600,
//                             letterSpacing: 0.5,
//                           ),
//                         ),
//                         SizedBox(height: 12),
//
//                         // Restaurant items
//                         Container(
//                           child: Column(
//                             children: [
//                               // First restaurant
//                               ...List.generate(
//                                 order.orderDetails.orderItems.length,
//                                     (index) => Row(
//                                   children: [
//                                     Container(
//                                       width: 32,
//                                       height: 32,
//                                       decoration: BoxDecoration(color: Colors.grey[800], shape: BoxShape.circle),
//                                       child: Icon(Icons.restaurant, color: Colors.white, size: 18),
//                                     ),
//                                     SizedBox(width: 12),
//                                     Expanded(
//                                       child: Text(
//                                         '${order.orderDetails.orderItems[index].name}- ₹${order.orderDetails.orderItems[index].price}',
//                                         style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w400),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//
//                         SizedBox(height: 20),
//
//                         // Locations section
//                         Column(
//                           children: [
//                             // Pickup location
//                             Row(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Container(
//                                   width: 32,
//                                   height: 32,
//                                   decoration: BoxDecoration(color: Color(0xFF2196F3), shape: BoxShape.circle),
//                                   child: Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 18),
//                                 ),
//                                 SizedBox(width: 12),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         '${order.orderDetails.restaurant.address.street}',
//                                         style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w400),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//
//                             SizedBox(height: 12),
//
//                             // Drop location
//                             Row(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Container(
//                                   width: 32,
//                                   height: 32,
//                                   decoration: BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle),
//                                   child: Icon(Icons.home, color: Colors.white, size: 18),
//                                 ),
//                                 SizedBox(width: 12),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         '${order.orderDetails.deliveryAddress.street}',
//                                         style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w400),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//
//                         SizedBox(height: 24),
//                         Center(child: SizedBox(height: 50, child: CountdownTimerWidget(initialSeconds: order.requestExpirySec))),
//
//                         SizedBox(height: 20),
//
//                         // Conditional buttons based on showAcceptReject flag
//                         if (order.showAcceptReject == true) ...[
//                           // Accept/Reject buttons
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: ElevatedButton(
//                                   onPressed: () {
//                                     Navigator.pop(context);
//                                     respond(order.orderDetails.id,"reject");
//                                     // Handle reject action
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.grey[100],
//                                     padding: EdgeInsets.symmetric(vertical: 14),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(8),
//                                       side: BorderSide(color: Colors.grey[300]!),
//                                     ),
//                                     elevation: 0,
//                                   ),
//                                   child: Text(
//                                     'Reject',
//                                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[700]),
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(width: 12),
//                               Expanded(
//                                 child: ElevatedButton(
//                                   onPressed: () {
//                                     Navigator.pop(context);
//                                     respond(order.orderDetails.id,"accept");
//
//                                     // Handle accept action
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Color(0xFF4CAF50),
//                                     padding: EdgeInsets.symmetric(vertical: 14),
//                                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                                     elevation: 0,
//                                   ),
//                                   child: Text(
//                                     'Accept',
//                                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ] else ...[
//                           // View Order Details Button
//                           SizedBox(
//                             width: double.infinity,
//                             child: ElevatedButton(
//                               onPressed: () async {
//
//
//
//                                 Navigator.pop(context);
//                                 // Navigate to order details page if needed
//                               },
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Color(0xFFFF9800),
//                                 padding: EdgeInsets.symmetric(vertical: 14),
//                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                                 elevation: 0,
//                               ),
//                               child: Text(
//                                 'View Order Details',
//                                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
//                               ),
//                             ),
//                           ),
//                         ],
//
//                         SizedBox(height: 20),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       );
//     },
//   );
// }
