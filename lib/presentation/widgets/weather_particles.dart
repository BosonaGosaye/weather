import 'package:flutter/material.dart';
import 'dart:math';

class WeatherParticles extends StatefulWidget {
  final int conditionId;
  
  const WeatherParticles({super.key, required this.conditionId});

  @override
  State<WeatherParticles> createState() => _WeatherParticlesState();
}

class _WeatherParticlesState extends State<WeatherParticles> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(() {
        setState(() {
          _updateParticles();
        });
      });
    _initializeParticles();
    _controller.repeat();
  }

  void _initializeParticles() {
    final particleType = _getParticleType(widget.conditionId);
    if (particleType == ParticleType.none) return;

    final count = _getParticleCount(particleType);
    for (int i = 0; i < count; i++) {
      _particles.add(Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        speed: _getParticleSpeed(particleType),
        size: _getParticleSize(particleType),
        type: particleType,
        angle: _getParticleAngle(particleType),
        opacity: _random.nextDouble() * 0.5 + 0.3,
      ));
    }

    // Add a sun for all conditions, but with varying opacity
    double sunOpacity = 1.0;
    if (widget.conditionId >= 200 && widget.conditionId < 300) sunOpacity = 0.1; // Thunderstorm
    else if (widget.conditionId >= 300 && widget.conditionId < 600) sunOpacity = 0.2; // Rain
    else if (widget.conditionId >= 600 && widget.conditionId < 700) sunOpacity = 0.1; // Snow
    else if (widget.conditionId >= 700 && widget.conditionId < 800) sunOpacity = 0.3; // Mist/Fog
    else if (widget.conditionId > 800) sunOpacity = 0.5; // Cloudy
    
    _particles.add(Particle(
      x: 0.8,
      y: 0.15,
      speed: 0,
      size: 80,
      type: ParticleType.sun,
      angle: 0,
      opacity: sunOpacity,
    ));

    // Add some clouds for all conditions except perfectly clear
    if (widget.conditionId != 800) {
      final cloudCount = widget.conditionId > 800 ? 10 : 5;
      for (int i = 0; i < cloudCount; i++) {
        _particles.add(Particle(
          x: _random.nextDouble(),
          y: _random.nextDouble() * 0.4,
          speed: 0.0005 + _random.nextDouble() * 0.0005,
          size: 120 + _random.nextDouble() * 80,
          type: ParticleType.cloud,
          angle: 0,
          opacity: 0.1 + _random.nextDouble() * 0.2,
        ));
      }
    }
  }

  ParticleType _getParticleType(int conditionId) {
    if (conditionId >= 200 && conditionId < 300) return ParticleType.lightning;
    if (conditionId >= 300 && conditionId < 400) return ParticleType.drizzle;
    if (conditionId >= 500 && conditionId < 600) return ParticleType.rain;
    if (conditionId >= 600 && conditionId < 700) return ParticleType.snow;
    if (conditionId >= 700 && conditionId < 800) return ParticleType.mist;
    if (conditionId == 800) return ParticleType.sun;
    if (conditionId > 800) return ParticleType.cloud;
    return ParticleType.none;
  }

  int _getParticleCount(ParticleType type) {
    switch (type) {
      case ParticleType.rain:
        return 100;
      case ParticleType.drizzle:
        return 60;
      case ParticleType.snow:
        return 80;
      case ParticleType.mist:
        return 40;
      case ParticleType.lightning:
        return 50;
      case ParticleType.cloud:
        return 15;
      case ParticleType.sun:
        return 1;
      default:
        return 0;
    }
  }

  double _getParticleSpeed(ParticleType type) {
    switch (type) {
      case ParticleType.rain:
        return 0.012 + _random.nextDouble() * 0.006; // Faster for AR feel
      case ParticleType.drizzle:
        return 0.005 + _random.nextDouble() * 0.003;
      case ParticleType.snow:
        return 0.003 + _random.nextDouble() * 0.002;
      case ParticleType.mist:
        return 0.001 + _random.nextDouble() * 0.001;
      case ParticleType.lightning:
        return 0.008 + _random.nextDouble() * 0.004;
      case ParticleType.cloud:
        return 0.0002 + _random.nextDouble() * 0.0003;
      case ParticleType.sun:
        return 0;
      default:
        return 0;
    }
  }

  double _getParticleSize(ParticleType type) {
    switch (type) {
      case ParticleType.rain:
        return 1.5 + _random.nextDouble() * 1;
      case ParticleType.drizzle:
        return 1.0 + _random.nextDouble() * 0.5;
      case ParticleType.snow:
        return 2.5 + _random.nextDouble() * 2;
      case ParticleType.mist:
        return 40 + _random.nextDouble() * 20; // Larger for AR feel
      case ParticleType.lightning:
        return 2 + _random.nextDouble() * 1;
      case ParticleType.cloud:
        return 60 + _random.nextDouble() * 40;
      case ParticleType.sun:
        return 60;
      default:
        return 2;
    }
  }

  double _getParticleAngle(ParticleType type) {
    if (type == ParticleType.rain || type == ParticleType.drizzle) {
      return pi / 4.5; // Slightly more tilted for realism
    }
    return 0;
  }

  void _updateParticles() {
    for (var particle in _particles) {
      if (particle.type == ParticleType.sun) continue;
      
      particle.y += particle.speed;
      
      if (particle.type == ParticleType.rain || 
          particle.type == ParticleType.drizzle ||
          particle.type == ParticleType.lightning) {
        particle.x += particle.speed * 0.2; // Wind effect
      } else if (particle.type == ParticleType.snow) {
        particle.x += sin(particle.y * 8) * 0.002;
      } else if (particle.type == ParticleType.mist || particle.type == ParticleType.cloud) {
        particle.x += cos(particle.y * 4 + particle.speed * 100) * 0.001;
      }

      if (particle.y > 1.1) {
        particle.y = -0.15;
        particle.x = _random.nextDouble();
      }
      if (particle.x > 1.1) {
        particle.x = -0.1;
      } else if (particle.x < -0.1) {
        particle.x = 1.1;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_particles.isEmpty) return const SizedBox.shrink();

    return IgnorePointer(
      child: CustomPaint(
        painter: ParticlePainter(_particles),
        size: Size.infinite,
      ),
    );
  }
}

enum ParticleType {
  none,
  rain,
  drizzle,
  snow,
  mist,
  lightning,
  cloud,
  sun,
}

class Particle {
  double x;
  double y;
  final double speed;
  final double size;
  final ParticleType type;
  final double angle;
  final double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.type,
    required this.angle,
    required this.opacity,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = _getParticleColor(particle.type).withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;

      final x = particle.x * size.width;
      final y = particle.y * size.height;

      switch (particle.type) {
        case ParticleType.rain:
        case ParticleType.drizzle:
          paint.strokeWidth = particle.size;
          paint.strokeCap = StrokeCap.round;
          final endX = x + cos(particle.angle) * (particle.size * 12);
          final endY = y + sin(particle.angle) * (particle.size * 12);
          
          // Add a trail/blur effect for AR feel
          final gradient = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _getParticleColor(particle.type).withOpacity(0),
              _getParticleColor(particle.type).withOpacity(particle.opacity),
            ],
          );
          paint.shader = gradient.createShader(Rect.fromPoints(Offset(x, y), Offset(endX, endY)));
          canvas.drawLine(Offset(x, y), Offset(endX, endY), paint);
          break;
        
        case ParticleType.snow:
          canvas.drawCircle(Offset(x, y), particle.size, paint);
          paint.color = Colors.white.withOpacity(particle.opacity * 0.4);
          canvas.drawCircle(Offset(x, y), particle.size * 1.8, paint);
          break;
        
        case ParticleType.mist:
        case ParticleType.cloud:
          final gradient = RadialGradient(
            colors: [
              (particle.type == ParticleType.mist ? Colors.white : Colors.white70).withOpacity(particle.opacity * 0.3),
              Colors.white.withOpacity(0),
            ],
          );
          paint.shader = gradient.createShader(
            Rect.fromCircle(center: Offset(x, y), radius: particle.size),
          );
          canvas.drawCircle(Offset(x, y), particle.size, paint);
          break;
        
        case ParticleType.lightning:
          if (Random().nextDouble() > 0.95) { // Occasional flash
            paint.color = Colors.white.withOpacity(particle.opacity);
            _drawLightningBolt(canvas, Offset(x, y), particle.size * 20, paint);
          }
          break;
        
        case ParticleType.sun:
          _drawSun(canvas, Offset(x, y), particle.size, particle.opacity);
          break;
        
        default:
          break;
      }
    }
  }

  void _drawSun(Canvas canvas, Offset center, double size, double opacity) {
    // Sun Glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.orange.withOpacity(0.3 * opacity),
          Colors.orange.withOpacity(0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: size * 3));
    canvas.drawCircle(center, size * 3, glowPaint);

    // Sun Core
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.yellowAccent.withOpacity(opacity),
          Colors.orangeAccent.withOpacity(opacity * 0.8),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: size));
    canvas.drawCircle(center, size, corePaint);

    // Sun Rays
    final rayPaint = Paint()
      ..color = Colors.yellowAccent.withOpacity(0.6 * opacity)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final rayCount = 12;
    final angleStep = (2 * pi) / rayCount;
    final rotation = DateTime.now().millisecondsSinceEpoch / 2000;

    for (int i = 0; i < rayCount; i++) {
      final angle = i * angleStep + rotation;
      final start = Offset(
        center.dx + cos(angle) * (size * 1.2),
        center.dy + sin(angle) * (size * 1.2),
      );
      final end = Offset(
        center.dx + cos(angle) * (size * 1.8),
        center.dy + sin(angle) * (size * 1.8),
      );
      canvas.drawLine(start, end, rayPaint);
    }
  }

  void _drawLightningBolt(Canvas canvas, Offset start, double length, Paint paint) {
    final path = Path();
    path.moveTo(start.dx, start.dy);
    double curX = start.dx;
    double curY = start.dy;
    final random = Random();
    
    for (int i = 0; i < 5; i++) {
      curX += (random.nextDouble() - 0.5) * 40;
      curY += length / 5;
      path.lineTo(curX, curY);
    }
    
    canvas.drawPath(path, paint..style = PaintingStyle.stroke..strokeWidth = 2);
    // Glow effect
    canvas.drawPath(path, paint..strokeWidth = 6..color = paint.color.withOpacity(0.2));
  }

  Color _getParticleColor(ParticleType type) {
    switch (type) {
      case ParticleType.rain:
      case ParticleType.drizzle:
        return const Color(0xFFB3E5FC);
      case ParticleType.snow:
        return Colors.white;
      case ParticleType.mist:
        return const Color(0xFFECEFF1);
      case ParticleType.lightning:
        return Colors.yellowAccent;
      case ParticleType.cloud:
        return Colors.white;
      case ParticleType.sun:
        return Colors.orange;
      default:
        return Colors.white;
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}
