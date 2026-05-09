import 'package:flutter/material.dart';

/// Root [MaterialApp] navigator. Widgets built in [MaterialApp.builder] sit *above*
/// the [Navigator], so they must use this key for [showModalBottomSheet] / overlay APIs.
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();
