import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/splash_controller.dart';
import '../../utils/app_images.dart';
import '../../widgets/app_widgets.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SplashController());
    final size = MediaQuery.of(context).size;

    // Set system status bar style to match the dark background
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: Colors.black, // Solid fallback background
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: AnimatedBuilder(
          animation: controller.entranceController,
          builder: (context, _) {
            // Shoe starts completely off-screen above the top edge (-size.height * 0.75)
            // and falls down to center (0.0) as shoeRise goes from 0.0 to 1.0
            final double startY = -size.height * 0.75;
            final double currentShoeY = startY * (1.0 - controller.shoeRise.value);

            // Height factor goes from 0.0 (high up) to 1.0 (on the ground)
            final double heightFactor = controller.shoeRise.value;
            
            final double currentShadowScale = controller.shadowScale.value * heightFactor;
            final double currentShadowOpacity = controller.shadowOpacity.value * heightFactor;

            return Stack(
              children: [
                // ── Full-Screen Premium Radial Dark Teal Gradient Background ───────────────
                Opacity(
                  opacity: controller.bgOpacity.value,
                  child: Container(
                    width: size.width,
                    height: size.height,
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.2,
                        colors: [
                          Color(0xFF006663), // Vibrant deep teal from Figma
                          Color(0xFF00403E), // Dark premium teal
                          Color(0xFF040808), // Near pitch-black charcoal teal
                        ],
                        stops: [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                ),

                // ── Subtle Vignette overlay for text contrast ────────────────────
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.15),
                          Colors.black.withValues(alpha: 0.0),
                          Colors.black.withValues(alpha: 0.55),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Center Column containing floating boot and text ──────────────
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Bounded Box for aligned Shoe & Shadow Stack ────────────
                      SizedBox(
                        height: 290,
                        width: 290,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // ── Subtle Physical Shadow Beneath Shoe ────────────────
                            Center(
                              child: Opacity(
                                opacity: currentShadowOpacity,
                                child: Transform.translate(
                                  offset: const Offset(0, 75), // floor level
                                  child: Transform.scale(
                                    scaleX: currentShadowScale,
                                    scaleY: 0.25 * currentShadowScale, // flat ellipse shadow
                                    child: Container(
                                      width: 170,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.65),
                                            blurRadius: 18,
                                            spreadRadius: 5,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // ── Floating/Defying Gravity Shoe Asset (Larger size: 300x300) ──
                            Center(
                              child: Opacity(
                                opacity: controller.shoeOpacity.value,
                                child: Transform.translate(
                                  offset: Offset(0, currentShoeY),
                                  child: Transform.rotate(
                                    angle: controller.shoeTilt.value,
                                    child: SizedBox(
                                      height: 300,
                                      width: 300,
                                      child: Image.asset(
                                        AppImages.boot,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 0),

                      // ── Brand Name Section with Particles ──
                      SizedBox(
                        height: 140, // Fixed height to prevent vertical layout shifting
                        child: Transform.translate(
                          offset: const Offset(0, -35), // Shift text upwards closer to the shoe
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Golden particles behind the text as it settles
                              Obx(() {
                                if (!controller.isEntranceCompleted.value) {
                                  return const SizedBox.shrink();
                                }
                                return const SubtleParticleSystem();
                              }),

                              // Horizontal Ribbon Unfurling of the Big Brand Name Text
                              SizeTransition(
                                sizeFactor: controller.textUnfurl,
                                axis: Axis.horizontal,
                                axisAlignment: 0.0,
                                child: Opacity(
                                  opacity: controller.textOpacity.value,
                                  child: Transform.scale(
                                    scale: controller.textScale.value,
                                    child: Transform.translate(
                                      offset: Offset(0, controller.textSlideY.value),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ResponsiveText(
                                            'MM',
                                            fontSize: 64,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                            letterSpacing: 2.0,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black.withValues(alpha: 0.35),
                                                blurRadius: 12,
                                                offset: const Offset(1.5, 2.0),
                                              ),
                                              Shadow(
                                                color: const Color(0xFF00E4C0).withValues(alpha: 0.25), // Vibrant figma turquoise neon glow
                                                blurRadius: 20,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          ResponsiveText(
                                            'AMERICAN USED SHOES',
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white.withValues(alpha: 0.85),
                                            letterSpacing: controller.textLetterSpacing.value, // Dynamic tracking animation
                                            shadows: [
                                              Shadow(
                                                color: Colors.black.withValues(alpha: 0.25),
                                                blurRadius: 6,
                                                offset: const Offset(1.0, 1.0),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Subtle Particle System Widget (Floating Golden Energy Dots) ───────────────
class SubtleParticleSystem extends StatefulWidget {
  const SubtleParticleSystem({super.key});

  @override
  State<SubtleParticleSystem> createState() => _SubtleParticleSystemState();
}

class _SubtleParticleSystemState extends State<SubtleParticleSystem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Initialize particles scattered throughout the emission box
    for (int i = 0; i < 22; i++) {
      _particles.add(_generateParticle(randomY: true));
    }

    _controller.addListener(_updateParticles);
  }

  Particle _generateParticle({bool randomY = false}) {
    return Particle(
      x: _random.nextDouble() * 240 - 120, // spread across text width
      y: randomY ? _random.nextDouble() * 120 - 60 : 70.0, // start from bottom or scattered
      speed: _random.nextDouble() * 0.7 + 0.3,
      radius: _random.nextDouble() * 2.2 + 0.6,
      opacity: _random.nextDouble() * 0.45 + 0.15,
    );
  }

  void _updateParticles() {
    if (!mounted) return;
    setState(() {
      for (int i = 0; i < _particles.length; i++) {
        _particles[i].y -= _particles[i].speed; // rise upwards
        
        // Gradually fade out as they float high
        if (_particles[i].y < -20) {
          _particles[i].opacity -= 0.004;
        }
        
        // Reset particle when it goes too high or is fully faded
        if (_particles[i].y < -80 || _particles[i].opacity <= 0.0) {
          _particles[i] = _generateParticle();
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ParticlePainter(_particles),
      size: const Size(260, 160),
    );
  }
}

class Particle {
  double x;
  double y;
  double speed;
  double radius;
  double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.radius,
    required this.opacity,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00E4C0) // Vibrant turquoise color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);

    for (var particle in particles) {
      paint.color = const Color(0xFF00E4C0).withValues(alpha: particle.opacity.clamp(0.0, 1.0));
      canvas.drawCircle(
        center + Offset(particle.x, particle.y),
        particle.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
