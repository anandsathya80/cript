import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const DetailScreen({required this.data, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double borderRadius = 24;

    return Scaffold(
      appBar: AppBar(
        title: Text(data['name'] ?? 'Detail'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: <Widget>[
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  gradient: const LinearGradient(
                    colors: [
                      Colors.blue,
                      Colors.purple,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                top: 0,
                child: CustomPaint(
                  size: const Size(100, 200),
                  painter: CustomCardShapePainter(
                    borderRadius,
                    Colors.blue,
                    Colors.purple,
                  ),
                ),
              ),
              Positioned.fill(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Image.network(
                        data['image']['large'],
                        height: 64,
                        width: 64,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.currency_bitcoin,
                            color: Colors.white,
                            size: 64,
                          );
                        },
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            data['name'] ?? 'Unknown',
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Avenir',
                              fontWeight: FontWeight.w700,
                              fontSize: 22,
                            ),
                          ),
                          Text(
                            'Symbol: ${data['symbol'] ?? 'N/A'}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontFamily: 'Avenir',
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Price: \$${data['current_price'] ?? '0.00'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Avenir',
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            'Change (24h): ${data['price_change_percentage_24h'] ?? '0.00'}%',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontFamily: 'Avenir',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Text(
                            'Rank',
                            style: TextStyle(
                              color: Colors.white70,
                              fontFamily: 'Avenir',
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            data['market_cap_rank'].toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Avenir',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomCardShapePainter extends CustomPainter {
  final double radius;
  final Color startColor;
  final Color endColor;

  CustomCardShapePainter(this.radius, this.startColor, this.endColor);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();

    var path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width - radius, size.height)
      ..quadraticBezierTo(
          size.width, size.height, size.width, size.height - radius)
      ..lineTo(size.width, radius)
      ..quadraticBezierTo(size.width, 0, size.width - radius, 0)
      ..lineTo(size.width - 1.5 * radius, 0)
      ..quadraticBezierTo(-radius, 2 * radius, 0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
