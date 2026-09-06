import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppDeleteDialog extends StatefulWidget {
  final String title;
  final String description;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const AppDeleteDialog({
    super.key,
    required this.title,
    required this.description,
    this.confirmText = 'Delete',
    this.cancelText = 'Cancel',
    required this.onConfirm,
    this.onCancel,
  });

  /// Animated Show Dialog Method with smooth entry bounce & backdrop fade
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String description,
    String confirmText = 'Delete',
    String cancelText = 'Cancel',
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
  }) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss Dialog',
      barrierColor: Colors.black.withValues(alpha: 0.55),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (ctx, anim1, anim2) => AppDeleteDialog(
        title: title,
        description: description,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
      transitionBuilder: (ctx, anim, secondaryAnim, child) {
        final curved = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeInBack,
        );

        return ScaleTransition(
          scale: Tween<double>(begin: 0.82, end: 1.0).animate(curved),
          child: FadeTransition(
            opacity: anim,
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<AppDeleteDialog> createState() => _AppDeleteDialogState();
}

class _AppDeleteDialogState extends State<AppDeleteDialog>
    with TickerProviderStateMixin {
  late AnimationController _badgeController;
  late Animation<double> _badgeScaleAnimation;

  late AnimationController _exitController;
  late Animation<double> _exitScaleAnimation;
  late Animation<double> _exitOpacityAnimation;

  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();

    // ── Entry Badge Pop Animation ──
    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _badgeScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.3, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 65,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 35,
      ),
    ]).animate(_badgeController);

    // ── On-Delete Exit Animation ──
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _exitScaleAnimation = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInOutCubic),
    );
    _exitOpacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInQuad),
    );

    // Trigger badge animation shortly after dialog pops in
    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) _badgeController.forward();
    });
  }

  @override
  void dispose() {
    _badgeController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  Future<void> _handleDeletePress() async {
    if (_isDeleting) return;

    HapticFeedback.mediumImpact();
    setState(() => _isDeleting = true);

    // Brief tactile animation before closing dialog and executing confirm
    await Future.delayed(const Duration(milliseconds: 220));
    if (!mounted) return;

    await _exitController.forward();
    if (!mounted) return;

    Navigator.of(context).pop(true);
    widget.onConfirm();
  }

  void _handleCancel() {
    if (_isDeleting) return;
    HapticFeedback.lightImpact();
    Navigator.of(context).pop(false);
    widget.onCancel?.call();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = (screenWidth * 0.88).clamp(280.0, 380.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Center(
        child: AnimatedBuilder(
          animation: _exitController,
          builder: (context, child) {
            return Transform.scale(
              scale: _exitScaleAnimation.value,
              child: Opacity(
                opacity: _exitOpacityAnimation.value,
                child: child,
              ),
            );
          },
          child: Container(
            width: dialogWidth,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Top Close Button ──
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: _handleCancel,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 22,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ),

                // ── Top Animated Red Circular Icon Badge with White 'X' ──
                ScaleTransition(
                  scale: _badgeScaleAnimation,
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFA5252), // Vibrant coral red
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFA5252).withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // ── Title ──
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Airbnb Cereal App',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.2,
                  ),
                ),

                const SizedBox(height: 10),

                // ── Description ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    widget.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Airbnb Cereal App',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w400,
                      height: 1.45,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Action Buttons (Cancel & Animated Delete) ──
                Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          onPressed: _isDeleting ? null : _handleCancel,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF1F5F9),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            widget.cancelText,
                            style: const TextStyle(
                              fontFamily: 'Airbnb Cereal App',
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Animated Delete Button
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          onPressed: _isDeleting ? null : _handleDeletePress,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFA5252),
                            elevation: _isDeleting ? 0 : 3,
                            shadowColor:
                                const Color(0xFFFA5252).withValues(alpha: 0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isDeleting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  widget.confirmText,
                                  style: const TextStyle(
                                    fontFamily: 'Airbnb Cereal App',
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
