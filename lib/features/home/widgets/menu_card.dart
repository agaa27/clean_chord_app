import 'package:flutter/material.dart';
import 'dart:math' as math;

class MenuCard extends StatefulWidget {
  final Color color;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  const MenuCard({
    super.key,
    required this.color,
    required this.title,
    this.subtitle = '',
    required this.icon,
    this.onTap,
  });

  @override
  State<MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<MenuCard> with TickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _idleController;
  late AnimationController _pressController;
  late Animation<double> _idleAnim;
  late Animation<double> _pressAnim;

  @override
  void initState() {
    super.initState();
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _idleAnim = CurvedAnimation(
      parent: _idleController,
      curve: Curves.easeInOut,
    );

    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _pressAnim = CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _idleController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    setState(() => _isPressed = true);
    _pressController.forward();
  }

  void _onTapUp(_) {
    setState(() => _isPressed = false);
    _pressController.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: Listenable.merge([_idleAnim, _pressAnim]),
        builder: (context, _) {
          final scale = 1.0 - 0.05 * _pressAnim.value;
          final glowOpacity = _isPressed ? 0.85 : 0.35 + 0.25 * _idleAnim.value;
          final glowBlur = _isPressed ? 30.0 : 12.0 + 10.0 * _idleAnim.value;

          return Transform.scale(
            scale: scale,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0D0D0D),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.color.withOpacity(
                    _isPressed ? 0.9 : 0.45 + 0.3 * _idleAnim.value,
                  ),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(glowOpacity * 0.5),
                    blurRadius: glowBlur,
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: widget.color.withOpacity(glowOpacity * 0.2),
                    blurRadius: glowBlur * 2,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(19),
                child: Stack(
                  children: [
                    // Background gradient
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              widget.color.withOpacity(0.07),
                              Colors.transparent,
                              widget.color.withOpacity(0.03),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Corner accent lines
                    Positioned(
                      top: 0,
                      left: 0,
                      child: _CornerAccent(color: widget.color, flip: false),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: _CornerAccent(color: widget.color, flip: true),
                    ),

                    // Scan line effect when pressed
                    if (_isPressed)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                widget.color.withOpacity(0.12),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Icon with glow container
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.color.withOpacity(0.1),
                              border: Border.all(
                                color: widget.color.withOpacity(0.3),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.color.withOpacity(
                                    0.2 + 0.15 * _idleAnim.value,
                                  ),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: Icon(
                              widget.icon,
                              color: widget.color,
                              size: 26,
                            ),
                          ),

                          // Title + subtitle + arrow
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: TextStyle(
                                  color: widget.color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  letterSpacing: 0.3,
                                  shadows: [
                                    Shadow(
                                      color: widget.color.withOpacity(0.6),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                              if (widget.subtitle.isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Text(
                                  widget.subtitle,
                                  style: TextStyle(
                                    color: widget.color.withOpacity(0.5),
                                    fontSize: 11,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              // Bottom row: status + arrow
                              Row(
                                children: [
                                  Container(
                                    height: 1,
                                    width: 24,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          widget.color.withOpacity(0.6),
                                          widget.color.withOpacity(0.1),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    widget.onTap != null
                                        ? Icons.arrow_forward_ios_rounded
                                        : Icons.lock_outline_rounded,
                                    color: widget.color.withOpacity(
                                      widget.onTap != null ? 0.6 : 0.25,
                                    ),
                                    size: 12,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Small L-shaped corner accent
class _CornerAccent extends StatelessWidget {
  final Color color;
  final bool flip;
  const _CornerAccent({required this.color, required this.flip});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: flip ? math.pi : 0,
      child: SizedBox(
        width: 18,
        height: 18,
        child: CustomPaint(painter: _CornerPainter(color: color)),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  const _CornerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(0, 12), const Offset(0, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(12, 0), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
