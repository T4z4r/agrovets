import 'dart:math' as math;

import 'package:flutter/material.dart';

class AppTourStep {
  final String title;
  final String description;
  final GlobalKey? targetKey;
  final String? highlightLabel;
  final Future<void> Function(BuildContext context)? onNext;
  final Future<void> Function(BuildContext context)? onBack;

  const AppTourStep({
    required this.title,
    required this.description,
    this.targetKey,
    this.highlightLabel,
    this.onNext,
    this.onBack,
  });
}

class AppTourDialog {
  static Future<void> show(
    BuildContext context, {
    required String title,
    required List<AppTourStep> steps,
  }) async {
    if (!context.mounted || steps.isEmpty) return;

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: title,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return _AppTourDialog(
          title: title,
          steps: steps,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}

class _AppTourDialog extends StatefulWidget {
  final String title;
  final List<AppTourStep> steps;

  const _AppTourDialog({
    required this.title,
    required this.steps,
  });

  @override
  State<_AppTourDialog> createState() => _AppTourDialogState();
}

class _AppTourDialogState extends State<_AppTourDialog> {
  int _index = 0;

  AppTourStep get _step => widget.steps[_index];
  bool get _isLast => _index == widget.steps.length - 1;

  Rect? _rectForTarget(GlobalKey? key) {
    final context = key?.currentContext;
    if (context == null) return null;

    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.attached) return null;

    final offset = renderObject.localToGlobal(Offset.zero);
    return offset & renderObject.size;
  }

  void _next() {
    _advance(forward: true);
  }

  void _back() {
    _advance(forward: false);
  }

  Future<void> _advance({required bool forward}) async {
    if (forward) {
      if (_isLast) {
        Navigator.of(context).pop();
        return;
      }
      await _step.onNext?.call(context);
      if (!mounted) return;
      setState(() => _index += 1);
    } else {
      if (_index == 0) return;
      await _step.onBack?.call(context);
      if (!mounted) return;
      setState(() => _index -= 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rect = _rectForTarget(_step.targetKey);

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _TourBackdropPainter(rect: rect),
            ),
          ),
          if (rect != null)
            Positioned(
              left: math.max(12, rect.left - 6),
              top: math.max(12, rect.top - 6),
              width: rect.width + 12,
              height: rect.height + 12,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
          SafeArea(
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Card(
                    elevation: 18,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.title,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              Text(
                                '${_index + 1}/${widget.steps.length}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _step.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _step.description,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.4,
                              color: Colors.grey[700],
                            ),
                          ),
                          if (rect != null && _step.highlightLabel != null) ...[
                            const SizedBox(height: 14),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF72140C).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                _step.highlightLabel!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              TextButton(
                                onPressed: _back,
                                child: Text(
                                  'Back',
                                  style: TextStyle(
                                    color: _index == 0
                                        ? Colors.grey
                                        : const Color(0xFF72140C),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Skip'),
                              ),
                              const Spacer(),
                              ElevatedButton(
                                onPressed: _next,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF72140C),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 14,
                                  ),
                                ),
                                child: Text(_isLast ? 'Done' : 'Next'),
                              ),
                            ],
                          ),
                        ],
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

class _TourBackdropPainter extends CustomPainter {
  final Rect? rect;

  _TourBackdropPainter({required this.rect});

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = Colors.black.withOpacity(0.38);
    final path = Path()..addRect(Offset.zero & size);

    if (rect != null) {
      final hole = RRect.fromRectAndRadius(
        rect!.inflate(8),
        const Radius.circular(16),
      );
      path.addRRect(hole);
      path.fillType = PathFillType.evenOdd;
    }

    canvas.drawPath(path, bg);
  }

  @override
  bool shouldRepaint(covariant _TourBackdropPainter oldDelegate) {
    return oldDelegate.rect != rect;
  }
}
