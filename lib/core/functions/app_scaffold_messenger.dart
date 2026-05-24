import 'package:flutter/material.dart';

/// مفتاح موحّد لـ [ScaffoldMessenger] الجذر لضمان ظهور الرسائل من أي مكان (بما فيها بعد await).
final GlobalKey<ScaffoldMessengerState> appScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
