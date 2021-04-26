import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChangeNotifierProvider<KickModel>(
        create: (context) {
          return KickModel();
        },
        child: MyApp(),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<KickModel>(context);
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            painter: CircleBackgroundPainter(100),
            child: Container(),
          ),
          CircleProgressTrack(),
          Stack(children: provider.lists),
          Column(
            children: [
              Text(
                provider.remainingDuration.toString(),
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
              Text(
                provider.listsLength.toString(),
                style: TextStyle(
                  fontSize: 60.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CircleProgressTrack extends StatefulWidget {
  @override
  _CircleProgressTrackState createState() => _CircleProgressTrackState();
}

class _CircleProgressTrackState extends State<CircleProgressTrack>
    with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;
  AnimationStatus animationStatus = AnimationStatus.dismissed;
  // Duration remainingDuration;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5),
    );

    Tween<double> _rotation = Tween(
      begin: -math.pi * 0.5,
      end: math.pi * 1.5,
    );

    animation = _rotation.animate(controller)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          animationStatus = AnimationStatus.completed;
          // controller.stop();
          controller.reverse();
          // controller.repeat();
        } else if (status == AnimationStatus.dismissed) {
          // controller.forward();
        }
      });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          painter: CirclePainter(100, animation.value),
          child: Container(),
        ),
        Consumer<KickModel>(
          builder: (context, kick, _) {
            // kick.setRemainingDuration(remainingDuration);
            return ElevatedButton(
              onPressed: () {
                kick.radians(animation.value);
                kick.kicked();
              },
              child: Text('Kick Now'),
            );
          },
        ),
      ],
    );
  }
}

// FOR PAINTING THE CIRCLE BACKGROUNDS
class CircleBackgroundPainter extends CustomPainter {
  final double radius;

  CircleBackgroundPainter(this.radius);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;

    var path = Path();
    path.addOval(
      Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: radius,
      ),
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

// FOR PAINTING THE CIRCLE
class CirclePainter extends CustomPainter {
  final double radius;
  final double radians;
  CirclePainter(this.radius, this.radians);
  final gradient = LinearGradient(
    colors: [
      Color(0xFFFC9858),
      Color(0xFFD73B98),
    ],
  );

  @override
  void paint(Canvas canvas, Size size) {
    var rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: radius,
    );
    var paint = Paint()
      // ..color = Colors.black.withOpacity(0.5)
      ..shader = gradient.createShader(rect)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;

    var path = Path();
    path.arcTo(
      rect,
      radians,
      1.5 * math.pi - radians,
      false,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

// FOR PAINTING THE TRACKING POINT
class PointPainter extends CustomPainter {
  final double radius;
  final double radians;
  PointPainter(this.radius, this.radians);

  @override
  void paint(Canvas canvas, Size size) {
    // var pointStroke = Paint()
    //   ..color = Colors.pink
    //   ..strokeWidth = 1
    //   ..style = PaintingStyle.stroke
    //   ..strokeCap = StrokeCap.round;

    var pointPaint = Paint()
      ..color = Colors.blue.shade400
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    var path = Path();

    Offset center = Offset(size.width / 2, size.height / 2);

    path.moveTo(center.dx, center.dy);

    Offset pointOnCircle = Offset(
      radius * math.cos(radians) + center.dx,
      radius * math.sin(radians) + center.dy,
    );

    canvas.drawCircle(pointOnCircle, 8, pointPaint);

    path.close();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

// FOR PAINTING THE TRACKING POINT
class GapPainter extends CustomPainter {
  final double radius;

  GapPainter(this.radius);

  @override
  void paint(Canvas canvas, Size size) {
    var gapPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2;

    Offset center = Offset(size.width / 2, size.height / 2);

    for (double i = 0; i < 360; i += 30) {
      canvas.drawLine(
        Offset(
          radius * math.cos(i * math.pi / 180) + center.dx,
          radius * math.sin(i * math.pi / 180) + center.dy,
        ),
        Offset(
          radius * math.cos(i * math.pi / 180) + center.dx,
          radius * math.sin(i * math.pi / 180) + center.dy,
        ),
        gapPaint,
      );
    }

    // path.close();
    // canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

// KICK MODEL
class KickModel extends ChangeNotifier {
  List<CustomPaint> _lists = [];
  List get lists => _lists;
  int get listsLength => _lists.length;
  double _currentRadians;
  double get currentRadians => _currentRadians;
  Duration _remainingDuration;
  Duration get remainingDuration => _remainingDuration;

  void setRemainingDuration(Duration duration) {
    _remainingDuration = duration;
    notifyListeners();
  }

  void radians(double radians) {
    _currentRadians = radians;
    notifyListeners();
  }

  void kicked() {
    _lists.add(
      CustomPaint(
        foregroundPainter: PointPainter(100, _currentRadians),
        child: Container(),
      ),
    );
    notifyListeners();
  }
}
