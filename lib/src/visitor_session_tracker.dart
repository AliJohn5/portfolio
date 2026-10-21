import 'dart:async';
import 'dart:js_interop';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

class VisitorSessionTracker {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static DocumentReference<Map<String, dynamic>>? _sessionRef;
  static Timer? _timer;

  static DateTime? _activeSince;
  static int _accumulatedSeconds = 0;
  static bool _windowFocused = true;
  static bool _listenersRegistered = false;

  static bool get isTracking => _sessionRef != null;
  static String? get sessionId => _sessionRef?.id;

  static bool get _isPageActive => !web.document.hidden && _windowFocused;

  // Keep listener references so they can be reused.
  static final _visibilityListener =
      ((web.Event _) => _syncTrackingState()).toJS;

  static final _blurListener = ((web.Event _) {
    _windowFocused = false;
    _syncTrackingState();
  }).toJS;

  static final _focusListener = ((web.Event _) {
    _windowFocused = true;
    _syncTrackingState();
  }).toJS;

  static void _registerListeners() {
    if (_listenersRegistered) return;

    _windowFocused = web.document.hasFocus();

    web.document.addEventListener(
      'visibilitychange',
      _visibilityListener,
    );

    web.window.addEventListener('blur', _blurListener);
    web.window.addEventListener('focus', _focusListener);

    _listenersRegistered = true;
  }

  static Future<String?> initialize() async {
    if (!kIsWeb) return null;

    if (_sessionRef != null) return _sessionRef!.id;

    try {
      final doc = await _firestore
          .collection(
        'visitor_sessions',
      )
          .add({
        'startedAt': FieldValue.serverTimestamp(),
        'lastUpdatedAt': FieldValue.serverTimestamp(),
        'durationSeconds': 0,
        'durationMinutes': 0,
        'status': 'active',
      });

      _sessionRef = doc;
      _accumulatedSeconds = 0;

      _registerListeners();
      _syncTrackingState();

      return doc.id;
    } catch (e) {
      debugPrint('Error initializing session: $e');
      return null;
    }
  }

  static void _syncTrackingState() {
    if (_sessionRef == null) return;

    if (_isPageActive) {
      _resumeTracking();
    } else {
      _pauseTracking();
    }
  }

  static void _resumeTracking() {
    if (_activeSince != null) return;

    _activeSince = DateTime.now();

    _timer = Timer.periodic(
      const Duration(minutes: 3),
      (_) => updateDuration(),
    );
  }

  static void _pauseTracking() {
    final activeSince = _activeSince;
    if (activeSince == null) return;

    _accumulatedSeconds += DateTime.now().difference(activeSince).inSeconds;

    _activeSince = null;

    _timer?.cancel();
    _timer = null;

    // Save the duration accumulated before losing focus.
    updateDuration();
  }

  static Future<void> updateDuration() async {
    final ref = _sessionRef;
    if (ref == null) return;

    final activeSince = _activeSince;

    final seconds = _accumulatedSeconds +
        (activeSince == null
            ? 0
            : DateTime.now().difference(activeSince).inSeconds);

    try {
      await ref.update({
        'durationSeconds': seconds,
        'durationMinutes': seconds ~/ 60,
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating session duration: $e');
    }
  }

  static Future<void> endSession() async {
    final ref = _sessionRef;
    if (ref == null) return;

    _pauseTracking();
    _timer?.cancel();
    _timer = null;

    await updateDuration();

    try {
      await ref.update({
        'status': 'ended',
        'endedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error ending session: $e');
    } finally {
      _sessionRef = null;
      _activeSince = null;
      _accumulatedSeconds = 0;
    }
  }
}
