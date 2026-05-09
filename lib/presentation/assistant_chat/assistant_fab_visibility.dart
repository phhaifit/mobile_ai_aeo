import 'package:flutter/foundation.dart';

/// When true, the global floating Assistant FAB is hidden (e.g. full-screen chat is open).
final ValueNotifier<bool> assistantFabSuppressed = ValueNotifier<bool>(false);
