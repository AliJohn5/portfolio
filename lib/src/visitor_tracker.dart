import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

class VisitorTracker {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static bool _hasLogged = false;

  static Future<void> logVisit() async {
    // Prevent logging multiple times during the same session/hot reload
    if (_hasLogged) return;
    _hasLogged = true;

    try {
      // Gather basic browser/visitor details
      final navigator = web.window.navigator;
      final screen = web.window.screen;
      final document = web.document;

      final userAgent = navigator.userAgent;
      final language = navigator.language;
      final screenWidth = screen.width;
      final screenHeight = screen.height;
      final referrer = document.referrer;

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
