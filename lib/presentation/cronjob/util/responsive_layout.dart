import 'package:flutter/material.dart';

/// Responsive layout utilities for the Cronjob Automation feature
/// Provides breakpoints and responsive helpers for different screen sizes
class ResponsiveLayout {
  // Breakpoints for responsive design
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1000;
  static const double desktopBreakpoint = 1400;

  /// Get responsive padding based on screen width
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      // Mobile: 12-16dp padding
      return const EdgeInsets.all(12);
    } else if (width < tabletBreakpoint) {
      // Tablet: 16-20dp padding
      return const EdgeInsets.all(16);
    } else {
      // Desktop: 24dp padding with max width constraints
      return const EdgeInsets.all(24);
    }
  }

  /// Get responsive list item padding
  static EdgeInsets getListItemPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
    } else if (width < tabletBreakpoint) {
      return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
    } else {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    }
  }

  /// Check if device is in mobile view
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  /// Check if device is in tablet view
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
      MediaQuery.of(context).size.width < tabletBreakpoint;

  /// Check if device is in desktop view
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint;

  /// Get responsive max width for content
  static double getMaxContentWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return width; // Use full width on mobile
    } else if (width < tabletBreakpoint) {
      return width - 32; // Tablet: leave margins
    } else {
      return 1200; // Desktop: max width constraint
    }
  }

  /// Get responsive grid columns for data display
  static int getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return 1; // Mobile: single column
    } else if (width < tabletBreakpoint) {
      return 2; // Tablet: two columns
    } else {
      return 3; // Desktop: three columns
    }
  }

  /// Get responsive font size for text
  static double getResponsiveFontSize(
    BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return mobile;
    } else if (width < tabletBreakpoint) {
      return tablet;
    } else {
      return desktop;
    }
  }

  /// Get device orientation
  static Orientation getOrientation(BuildContext context) =>
      MediaQuery.of(context).orientation;

  /// Check if device is in landscape
  static bool isLandscape(BuildContext context) =>
      getOrientation(context) == Orientation.landscape;

  /// Check if device is in portrait
  static bool isPortrait(BuildContext context) =>
      getOrientation(context) == Orientation.portrait;
}
