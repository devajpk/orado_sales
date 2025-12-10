import 'package:url_launcher/url_launcher.dart';

class AppLauncher {
  // ---------------------------------------------
  // PHONE CALL
  // ---------------------------------------------
  static Future<void> phoneCall(String phone) async {
    final Uri uri = Uri(scheme: "tel", path: phone);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw "Could not launch phone call";
    }
  }

  // ---------------------------------------------
  // WHATSAPP MESSAGE
  // ---------------------------------------------
  static Future<void> whatsapp(String phone, {String message = ""}) async {
    final Uri uri = Uri.parse(
      "https://wa.me/$phone?text=${Uri.encodeComponent(message)}",
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw "Could not launch WhatsApp";
    }
  }

  // ---------------------------------------------
  // SMS
  // ---------------------------------------------
  static Future<void> sendSMS(String phone, String message) async {
    final Uri uri = Uri(
      scheme: "sms",
      path: phone,
      queryParameters: {"body": message},
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw "Could not send SMS";
    }
  }

  // ---------------------------------------------
  // SIMPLE NAVIGATION (only destination)
  // ---------------------------------------------
  static Future<void> navigateTo(double lat, double lng) async {
    final Uri uri = Uri.parse(
      "https://www.google.com/maps/dir/?api=1"
      "&destination=$lat,$lng"
      "&travelmode=driving",
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw "Could not open Google Maps navigation";
    }
  }

  // ---------------------------------------------
  // FULL ROUTE: origin → destination
  // ---------------------------------------------
  static Future<void> navigateRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    String mode = "driving",
  }) async {
    final Uri uri = Uri.parse(
      "https://www.google.com/maps/dir/?api=1"
      "&origin=$startLat,$startLng"
      "&destination=$endLat,$endLng"
      "&travelmode=$mode",
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw "Could not launch route navigation";
    }
  }

  // ---------------------------------------------
  // OPEN ADDRESS IN MAP (WITHOUT ROUTE)
  // ---------------------------------------------
  static Future<void> openLocation(double lat, double lng) async {
    final Uri uri = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw "Could not open map location";
    }
  }
}
