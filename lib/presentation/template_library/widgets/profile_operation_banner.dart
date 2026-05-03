import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

/// Frosted-glass style banner from the top (overlay), not full width.
void showProfileOperationTopBanner(
  BuildContext context, {
  required bool success,
  required String message,
  Duration visibleDuration = const Duration(seconds: 4),
}) {
  if (!context.mounted) return;
  final overlay = Overlay.of(context, rootOverlay: true);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (ctx) => _ProfileTopBannerOverlay(
      success: success,
      message: message,
      visibleDuration: visibleDuration,
      onRemove: () {
        if (entry.mounted) {
          entry.remove();
        }
      },
    ),
  );
  overlay.insert(entry);
}

class _ProfileTopBannerOverlay extends StatefulWidget {
  const _ProfileTopBannerOverlay({
    required this.success,
    required this.message,
    required this.visibleDuration,
    required this.onRemove,
  });

  final bool success;
  final String message;
  final Duration visibleDuration;
  final VoidCallback onRemove;

  @override
  State<_ProfileTopBannerOverlay> createState() =>
      _ProfileTopBannerOverlayState();
}

class _ProfileTopBannerOverlayState extends State<_ProfileTopBannerOverlay>
    with SingleTickerProviderStateMixin {
  bool _didRemove = false;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, -1),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  ));

  @override
  void initState() {
    super.initState();
    _controller.forward();
    Future<void>.delayed(widget.visibleDuration, _animateOutAndRemove);
  }

  void _safeRemove() {
    if (_didRemove || !mounted) return;
    _didRemove = true;
    widget.onRemove();
  }

  Future<void> _animateOutAndRemove() async {
    if (!mounted || _didRemove) return;
    await _controller.reverse();
    _safeRemove();
  }

  void _dismiss() {
    _animateOutAndRemove();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top + 6;
    final maxCardWidth = math.min(
      MediaQuery.sizeOf(context).width - 40,
      400.0,
    );

    final success = widget.success;
    final gradientColors = success
        ? <Color>[
            Colors.white.withOpacity(0.52),
            const Color(0xFFC8E6C9).withOpacity(0.42),
            const Color(0xFFA5D6A7).withOpacity(0.32),
          ]
        : <Color>[
            Colors.white.withOpacity(0.55),
            const Color(0xFFFFCDD2).withOpacity(0.45),
            const Color(0xFFFFB4AB).withOpacity(0.32),
          ];

    final accent = success
        ? const Color(0xFF2E7D32)
        : const Color(0xFFC62828);
    final iconBg = success
        ? const Color(0xFF4CAF50).withOpacity(0.18)
        : const Color(0xFFE57373).withOpacity(0.22);
    final textColor = const Color(0xFF263238);

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned(
            top: topInset,
            left: 0,
            right: 0,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxCardWidth),
                child: SlideTransition(
                  position: _slide,
                  child: FadeTransition(
                    opacity: _fade,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: gradientColors,
                            ),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.72),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.07),
                                blurRadius: 22,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: iconBg,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.55),
                                    ),
                                  ),
                                  child: Icon(
                                    success
                                        ? Icons.check_rounded
                                        : Icons.error_rounded,
                                    color: accent,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    widget.message,
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.5,
                                      height: 1.25,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                TextButton.icon(
                                  onPressed: _dismiss,
                                  icon: Icon(
                                    Icons.close_rounded,
                                    color: textColor.withOpacity(0.75),
                                    size: 18,
                                  ),
                                  label: Text(
                                    'Dismiss',
                                    style: TextStyle(
                                      color: textColor.withOpacity(0.85),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    foregroundColor: textColor,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
