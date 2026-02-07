import 'dart:math' as math;
import 'package:flutter/material.dart';

// Color Palette
class BearColors {
  static const primaryTeal = Color(0xFF38B2AC);
  static const textDark = Color(0xFF2D3748);
  static const textSoft = Color(0xFF718096);
  static const blush = Color(0xFFFFB6C1);
  static const furWhite = Color(0xFFFFFFFF);
  static const bellyCream = Color(0xFFF7FAFC); 
  static const bgCream = Color(0xFFFDFBF7);
}

class KawaiiPolarBear extends StatefulWidget {
  final bool isTalking; // 1. Pass this in from parent

  const KawaiiPolarBear({
    super.key, 
    this.isTalking = false, // Default to silent
  });

  @override
  State<KawaiiPolarBear> createState() => _KawaiiPolarBearState();
}

class _KawaiiPolarBearState extends State<KawaiiPolarBear> with TickerProviderStateMixin {
  late AnimationController _idleCtrl;
  late AnimationController _blinkCtrl;
  late AnimationController _talkCtrl; 

  @override
  void initState() {
    super.initState();
    
    // Breathing/Bouncing animation
    _idleCtrl = AnimationController(
      vsync: this, 
      duration: const Duration(seconds: 3) 
    )..repeat(reverse: true);
    
    // Blinking animation
    _blinkCtrl = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 200)
    );

    // NEW: Talking animation setup
    _talkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200) // Slightly faster for snappier talking
    );

    // 2. Start talking immediately if initial state is true
    if (widget.isTalking) {
      _talkCtrl.repeat(reverse: true);
    }

    _startBlinking();
  }

  // 3. LISTEN FOR CHANGES
  @override
  void didUpdateWidget(KawaiiPolarBear oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isTalking != oldWidget.isTalking) {
      if (widget.isTalking) {
        _talkCtrl.repeat(reverse: true);
      } else {
        _talkCtrl.reset(); // Stops and snaps mouth closed
      }
    }
  }

  void _startBlinking() async {
    if (!mounted) return;
    while (mounted) {
      await Future.delayed(Duration(milliseconds: 2000 + math.Random().nextInt(3000)));
      if (mounted) {
        try {
          await _blinkCtrl.forward();
          await _blinkCtrl.reverse();
        } catch (e) {
          // ignore disposed
        }
      }
    }
  }

  @override
  void dispose() {
    _idleCtrl.dispose();
    _blinkCtrl.dispose();
    _talkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_idleCtrl, _blinkCtrl, _talkCtrl]),
      builder: (context, child) {
        final idleValue = Curves.easeInOutQuad.transform(_idleCtrl.value);
        final talkValue = _talkCtrl.value; // 0.0 to 1.0
        
        return Transform.scale(
          scale: 1.0 + (0.02 * idleValue), 
          child: SizedBox(
            width: 320,
            height: 320,
            child: CustomPaint(
              painter: _PolarBearPainter(
                idleValue: idleValue,
                blinkValue: _blinkCtrl.value,
                talkValue: talkValue,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PolarBearPainter extends CustomPainter {
  final double idleValue;
  final double blinkValue;
  final double talkValue;

  _PolarBearPainter({
    required this.idleValue, 
    required this.blinkValue, 
    required this.talkValue
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 10); 
    final floatY = -5.0 * idleValue; 
    
    // Shadow
    _drawShadow(canvas, center, idleValue);

    canvas.save();
    canvas.translate(center.dx, center.dy + floatY);
    canvas.translate(-center.dx, -center.dy);

    final paint = Paint()..style = PaintingStyle.fill;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..color = BearColors.textDark
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 1. EARS 
    _drawEar(canvas, center.translate(-95, -60), paint, stroke);
    _drawEar(canvas, center.translate(95, -60), paint, stroke);

    // 2. BODY 
    _drawCuteBody(canvas, center, paint, stroke);

    // 3. HEAD 
    final headRect = Rect.fromCenter(center: center, width: 280, height: 190);
    paint.color = BearColors.furWhite;
    canvas.drawOval(headRect, paint);
    canvas.drawOval(headRect, stroke);

    // 4. FACE (Now animated!)
    _drawFace(canvas, center, paint, stroke);

    // 5. ARMS 
    _drawArmWithDumbbell(canvas, center.translate(-90, 80), true, stroke, paint);
    _drawArmWithDumbbell(canvas, center.translate(90, 80), false, stroke, paint);

    canvas.restore();
  }

  void _drawShadow(Canvas canvas, Offset center, double lift) {
    final shadowPaint = Paint()
      ..color = const Color(0xFFCBD5E0).withOpacity(0.3 - (0.1 * lift))
      ..style = PaintingStyle.fill;
    
    final width = 140.0 - (15.0 * lift);
    final rect = Rect.fromCenter(center: center.translate(0, 165), width: width, height: 20);
    canvas.drawOval(rect, shadowPaint);
  }

  void _drawEar(Canvas canvas, Offset pos, Paint paint, Paint stroke) {
    paint.color = BearColors.furWhite;
    canvas.drawCircle(pos, 36, paint); 
    canvas.drawCircle(pos, 36, stroke);
    paint.color = BearColors.blush; 
    canvas.drawOval(Rect.fromCenter(center: pos, width: 34, height: 34), paint);
  }

  void _drawCuteBody(Canvas canvas, Offset center, Paint paint, Paint stroke) {
    final bodyCenter = center.translate(0, 70); 
    final path = Path();
    path.moveTo(bodyCenter.dx - 65, bodyCenter.dy - 40);
    path.quadraticBezierTo(bodyCenter.dx - 75, bodyCenter.dy + 40, bodyCenter.dx - 45, bodyCenter.dy + 85);
    path.quadraticBezierTo(bodyCenter.dx, bodyCenter.dy + 65, bodyCenter.dx + 45, bodyCenter.dy + 85);
    path.quadraticBezierTo(bodyCenter.dx + 75, bodyCenter.dy + 40, bodyCenter.dx + 65, bodyCenter.dy - 40);
    path.close();

    paint.color = BearColors.furWhite;
    canvas.drawPath(path, paint);
    canvas.drawPath(path, stroke);

    paint.color = BearColors.bellyCream;
    canvas.drawOval(Rect.fromCenter(center: bodyCenter.translate(0, 30), width: 70, height: 55), paint);
  }

  void _drawFace(Canvas canvas, Offset center, Paint paint, Paint stroke) {
    // Cheeks
    paint.color = BearColors.blush;
    canvas.drawOval(Rect.fromCenter(center: center.translate(-90, 10), width: 45, height: 28), paint);
    canvas.drawOval(Rect.fromCenter(center: center.translate(90, 10), width: 45, height: 28), paint);

    // Eyes 
    _drawEye(canvas, center.translate(-55, -5), stroke, blinkValue);
    _drawEye(canvas, center.translate(55, -5), stroke, blinkValue);

    // Nose
    paint.color = BearColors.textDark;
    paint.style = PaintingStyle.fill;
    final noseCenter = center.translate(0, 10);
    final nosePath = Path();
    nosePath.moveTo(noseCenter.dx - 12, noseCenter.dy - 6);
    nosePath.quadraticBezierTo(noseCenter.dx, noseCenter.dy - 9, noseCenter.dx + 12, noseCenter.dy - 6);
    nosePath.quadraticBezierTo(noseCenter.dx, noseCenter.dy + 10, noseCenter.dx - 12, noseCenter.dy - 6);
    canvas.drawPath(nosePath, paint);

    // --- MOUTH LOGIC ---
    paint.style = PaintingStyle.stroke;
    stroke.strokeWidth = 4;
    final mouthY = noseCenter.dy + 10;

    // The talkValue will be 0.0 when we call reset(), keeping mouth closed
    if (talkValue > 0.1) {
      // OPEN MOUTH
      paint.style = PaintingStyle.fill;
      paint.color = BearColors.textDark; 
      final mouthHeight = 8.0 + (talkValue * 8.0); 
      canvas.drawOval(Rect.fromCenter(center: Offset(center.dx, mouthY + 8), width: 18, height: mouthHeight), paint);
    } else {
      // CLOSED MOUTH
      final mouthPath = Path();
      mouthPath.moveTo(center.dx - 12, mouthY);
      mouthPath.quadraticBezierTo(center.dx - 6, mouthY + 10, center.dx, mouthY + 2);
      mouthPath.quadraticBezierTo(center.dx + 6, mouthY + 10, center.dx + 12, mouthY);
      canvas.drawPath(mouthPath, stroke);
    }
    
    stroke.strokeWidth = 6.0;
    paint.style = PaintingStyle.fill;
  }

  void _drawEye(Canvas canvas, Offset pos, Paint stroke, double blink) {
    if (blink > 0.1) {
      final p = Path();
      p.moveTo(pos.dx - 20, pos.dy + 5);
      p.quadraticBezierTo(pos.dx, pos.dy - 15, pos.dx + 20, pos.dy + 5);
      canvas.drawPath(p, stroke..strokeWidth = 5);
    } else {
      final eyePaint = Paint()..color = BearColors.textDark;
      canvas.drawOval(Rect.fromCenter(center: pos, width: 30, height: 36), eyePaint);
      canvas.drawCircle(pos.translate(8, -8), 7, Paint()..color = Colors.white);
      canvas.drawCircle(pos.translate(-8, 8), 3, Paint()..color = Colors.white.withOpacity(0.8));
    }
  }

  void _drawArmWithDumbbell(Canvas canvas, Offset pos, bool isLeft, Paint stroke, Paint fill) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(isLeft ? 0.3 : -0.3);
    fill.color = BearColors.textSoft; 
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-20, -5, 40, 10), const Radius.circular(5)), fill);
    fill.color = BearColors.textDark;
    final wSize = const Size(18, 40);
    _drawWeight(canvas, const Offset(-28, 0), wSize, fill, stroke);
    _drawWeight(canvas, const Offset(28, 0), wSize, fill, stroke);
    fill.color = BearColors.furWhite;
    canvas.drawCircle(Offset.zero, 20, fill);
    canvas.drawCircle(Offset.zero, 20, stroke);
    canvas.restore();
  }

  void _drawWeight(Canvas canvas, Offset center, Size size, Paint fill, Paint stroke) {
    final rect = RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: size.width, height: size.height), const Radius.circular(8));
    canvas.drawRRect(rect, fill);
  }

  @override
  bool shouldRepaint(_PolarBearPainter oldDelegate) => true;
}