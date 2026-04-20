import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Rounded card from the top (overlay), not full width — profile create / update / delete.
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

    final bg = widget.success
        ? const Color(0xFF1B5E20)
        : const Color(0xFFB71C1C);

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
                    child: Material(
                      elevation: 8,
                      shadowColor: Colors.black38,
                      borderRadius: BorderRadius.circular(14),
                      color: bg,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.22),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                widget.success
                                    ? Icons.check_rounded
                                    : Icons.error_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                widget.message,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13.5,
                                  height: 1.25,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            TextButton.icon(
                              onPressed: _dismiss,
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              label: const Text(
                                'Dismiss',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
        ],
      ),
    );
  }
}
