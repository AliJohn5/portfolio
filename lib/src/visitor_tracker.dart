import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html; // Optional: for browser info

class VisitorTracker {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static bool _hasLogged = false;

  static Future<void> logVisit() async {
    // Prevent logging multiple times during the same session/hot reload
    if (_hasLogged) return;
    _hasLogged = true;

    try {
      // Gather basic browser/visitor details
      final userAgent = html.window.navigator.userAgent;
      final language = html.window.navigator.language;
      final screenWidth = html.window.screen?.width;
      final screenHeight = html.window.screen?.height;
      final referrer = html.document.referrer;

      await _firestore.collection('visitors').add({
        'timestamp': FieldValue.serverTimestamp(),
        'userAgent': userAgent,
        'language': language,
        'screenResolution': '${screenWidth}x$screenHeight',
        'referrer': referrer.isEmpty ? 'Direct' : referrer,
        'platform': kIsWeb ? 'Web' : 'Mobile/Desktop',
      });
    } catch (e) {
      debugPrint('Error logging visitor: $e');
    }
  }
}
