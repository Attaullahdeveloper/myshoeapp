import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// ── FACEBOOK / WHATSAPP STYLE CIRCULAR PROFILE & PRODUCT CROP DIALOG ──
class WhatsAppCircularCropDialog extends StatefulWidget {
  final Uint8List imageBytes;
  final String title;

  const WhatsAppCircularCropDialog({
    super.key,
    required this.imageBytes,
    this.title = 'Crop & Adjust Image',
  });

  @override
  State<WhatsAppCircularCropDialog> createState() =>
      _WhatsAppCircularCropDialogState();
}

class _WhatsAppCircularCropDialogState
    extends State<WhatsAppCircularCropDialog> {
  final GlobalKey _cropKey = GlobalKey();
  final TransformationController _transformationController =
      TransformationController();
  int _quarterTurns = 0;
  bool _isProcessing = false;
  double _currentScale = 1.0;

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(() {
      final scale = _transformationController.value.getMaxScaleOnAxis();
      if ((scale - _currentScale).abs() > 0.05) {
        setState(() {
          _currentScale = scale;
        });
      }
    });
  }

  Future<Uint8List?> _exportCroppedImage() async {
    setState(() {
      _isProcessing = true;
    });
    try {
      await Future.delayed(const Duration(milliseconds: 120));
      final RenderRepaintBoundary? boundary =
          _cropKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('❌ Crop export error: $e');
      return null;
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _resetTransform() {
    setState(() {
      _transformationController.value = Matrix4.identity();
      _quarterTurns = 0;
      _currentScale = 1.0;
    });
  }

  void _setZoom(double zoom) {
    setState(() {
      _currentScale = zoom.clamp(1.0, 4.5);
      _transformationController.value = Matrix4.identity()..scale(_currentScale);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double cropSize = (size.width * 0.72).clamp(220.0, 280.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: cropSize + 56,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A), // Dark Luxury Slate
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Bar Header & Control Icons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.crop_rotate_rounded,
                        color: Color(0xFF5B9EE1),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    // Reset Button
                    GestureDetector(
                      onTap: _resetTransform,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white70,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Rotate Button
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _quarterTurns = (_quarterTurns + 1) % 4;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.rotate_right_rounded,
                          color: Colors.white70,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── CIRCULAR VIEWPORT CONTAINER WITH GRID & GLOW RING ──
            SizedBox(
              width: cropSize,
              height: cropSize,
              child: Stack(
                children: [
                  // RepaintBoundary Area (Captures the exact circular crop)
                  RepaintBoundary(
                    key: _cropKey,
                    child: ClipOval(
                      child: Container(
                        width: cropSize,
                        height: cropSize,
                        color: Colors.transparent,
                        child: RotatedBox(
                          quarterTurns: _quarterTurns,
                          child: InteractiveViewer(
                            transformationController: _transformationController,
                            minScale: 1.0,
                            maxScale: 4.5,
                            boundaryMargin: const EdgeInsets.all(double.infinity),
                            child: Center(
                              child: Image.memory(
                                widget.imageBytes,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Rule of Thirds Circular Grid Lines
                  IgnorePointer(
                    child: ClipOval(
                      child: Container(
                        width: cropSize,
                        height: cropSize,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: cropSize / 3,
                              left: 0,
                              right: 0,
                              child: Container(height: 0.5, color: Colors.white12),
                            ),
                            Positioned(
                              top: (cropSize / 3) * 2,
                              left: 0,
                              right: 0,
                              child: Container(height: 0.5, color: Colors.white12),
                            ),
                            Positioned(
                              left: cropSize / 3,
                              top: 0,
                              bottom: 0,
                              child: Container(width: 0.5, color: Colors.white12),
                            ),
                            Positioned(
                              left: (cropSize / 3) * 2,
                              top: 0,
                              bottom: 0,
                              child: Container(width: 0.5, color: Colors.white12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Premium Neon Glow Circular Border Ring
                  IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF5B9EE1),
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF5B9EE1).withValues(alpha: 0.35),
                            blurRadius: 14,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (_isProcessing)
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF5B9EE1),
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Zoom Slider Bar
            Row(
              children: [
                GestureDetector(
                  onTap: () => _setZoom(_currentScale - 0.25),
                  child: const Icon(Icons.remove_circle_outline_rounded,
                      color: Colors.white60, size: 20),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: const Color(0xFF5B9EE1),
                      inactiveTrackColor: Colors.white12,
                      thumbColor: const Color(0xFF5B9EE1),
                      overlayColor: const Color(0xFF5B9EE1).withValues(alpha: 0.2),
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    ),
                    child: Slider(
                      value: _currentScale.clamp(1.0, 4.5),
                      min: 1.0,
                      max: 4.5,
                      onChanged: (val) => _setZoom(val),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _setZoom(_currentScale + 0.25),
                  child: const Icon(Icons.add_circle_outline_rounded,
                      color: Colors.white60, size: 20),
                ),
              ],
            ),

            const Text(
              'Pinch or use slider to zoom • Drag to center',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 20),

            // Bottom Buttons (Cancel & Apply Photo)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => Navigator.of(context).pop(null),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B9EE1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 4,
                    ),
                    icon: const Icon(Icons.check_circle_rounded,
                        size: 18, color: Colors.white),
                    label: const Text(
                      'Apply Image',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: _isProcessing
                        ? null
                        : () async {
                            final nav = Navigator.of(context);
                            final croppedData = await _exportCroppedImage();
                            if (mounted) {
                              nav.pop(croppedData);
                            }
                          },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
