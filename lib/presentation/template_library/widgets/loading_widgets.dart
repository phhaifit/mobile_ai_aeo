import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

/// Beautiful loading indicator with multiple animation styles
class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color color;
  final AnimationType animationType;
  final Duration duration;

  const LoadingIndicator({
    Key? key,
    this.size = 50.0,
    this.color = Colors.blue,
    this.animationType = AnimationType.ring,
    this.duration = const Duration(milliseconds: 1200),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildAnimation(animationType);
  }

  Widget _buildAnimation(AnimationType type) {
    switch (type) {
      case AnimationType.wave:
        return SpinKitWave(
          color: color,
          size: size,
          duration: duration,
        );
      case AnimationType.pulse:
        return SpinKitPulse(
          color: color,
          size: size,
          duration: duration,
        );
      case AnimationType.threeBounce:
        return SpinKitThreeBounce(
          color: color,
          size: size,
          duration: duration,
        );
      case AnimationType.fadingCircle:
        return SpinKitFadingCircle(
          color: color,
          size: size,
          duration: duration,
        );
      case AnimationType.ring:
        return SpinKitRing(
          color: color,
          size: size,
          duration: duration,
          lineWidth: 3.0,
        );
      case AnimationType.spinningCircle:
        return SpinKitSpinningCircle(
          color: color,
          size: size,
          duration: duration,
        );
      case AnimationType.fadingGrid:
        return SpinKitFadingGrid(
          color: color,
          size: size,
          duration: duration,
        );
      case AnimationType.doubleBounce:
        return SpinKitDoubleBounce(
          color: color,
          size: size,
          duration: duration,
        );
    }
  }
}

enum AnimationType {
  wave,
  pulse,
  threeBounce,
  fadingCircle,
  ring,
  spinningCircle,
  fadingGrid,
  doubleBounce,
}

/// Loading button - shows spinner inside button when loading
class LoadingButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final AnimationType animationType;
  final double? width;

  const LoadingButton({
    Key? key,
    required this.isLoading,
    required this.onPressed,
    required this.label,
    this.backgroundColor = Colors.blue,
    this.foregroundColor = Colors.white,
    this.animationType = AnimationType.ring,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: backgroundColor.withOpacity(0.6),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: LoadingIndicator(
                  size: 20,
                  color: foregroundColor,
                  animationType: animationType,
                  duration: const Duration(milliseconds: 800),
                ),
              )
            : Text(label),
      ),
    );
  }
}

/// Loading dialog - full modal with loading indicator
class LoadingDialog extends StatelessWidget {
  final String? message;
  final AnimationType animationType;
  final Color indicatorColor;
  final double indicatorSize;

  const LoadingDialog({
    Key? key,
    this.message = 'Processing...',
    this.animationType = AnimationType.ring,
    this.indicatorColor = Colors.blue,
    this.indicatorSize = 60.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingIndicator(
              size: indicatorSize,
              color: indicatorColor,
              animationType: animationType,
            ),
            if (message != null && message!.isNotEmpty) ...[
              SizedBox(height: 24),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Loading overlay - semi-transparent overlay with loading indicator
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final AnimationType animationType;
  final Color indicatorColor;

  const LoadingOverlay({
    Key? key,
    required this.isLoading,
    required this.child,
    this.message,
    this.animationType = AnimationType.ring,
    this.indicatorColor = Colors.blue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoadingIndicator(
                    size: 60,
                    color: indicatorColor,
                    animationType: animationType,
                  ),
                  if (message != null && message!.isNotEmpty) ...[
                    SizedBox(height: 16),
                    Text(
                      message!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Inline loading indicator for compact use (inside buttons, chips, etc)
class InlineLoadingIndicator extends StatelessWidget {
  final Color color;
  final double size;

  const InlineLoadingIndicator({
    Key? key,
    this.color = Colors.white,
    this.size = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: LoadingIndicator(
        size: size,
        color: color,
        animationType: AnimationType.ring,
        duration: const Duration(milliseconds: 800),
      ),
    );
  }
}
