import 'package:cript/detail_screen/detail_screen.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class CardMainScreen extends StatefulWidget {
  CardMainScreen({
    super.key,
  });

  @override
  State<CardMainScreen> createState() => _CardMainScreenState();
}

class _CardMainScreenState extends State<CardMainScreen> {
  final double _borderRadius = 24;
  late Future<List<CryptoData>?> cryptoDataFuture;

  @override
  void initState() {
    super.initState();
    cryptoDataFuture = fetchCryptoData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CryptoData>?>(
      future: cryptoDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data available'));
        }

        final items = snapshot.data!;
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Stack(
                  children: <Widget>[
                    InkWell(
                      onTap: () async {
                        final data = await fetchCryptoDetails(items[index].id);
                        if (data != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailScreen(data: data),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Failed to fetch details for ${items[index].name}'),
                            ),
                          );
                        }
                      },
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(_borderRadius),
                          gradient: LinearGradient(
                            colors: [
                              items[index].startColor,
                              items[index].endColor,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: items[index].endColor,
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Container(),
                            // Icon(CryptoFontIcons().items[index].symbol),
                          ),
                          Expanded(
                            flex: 4,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  items[index].name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Avenir',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  items[index].symbol,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Avenir',
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "\$${items[index].priceUsd}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Avenir',
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  "${items[index].percentChange24h}% (24h)",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Avenir',
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
            );
          },
        );
      },
    );
  }
}

class CryptoData {
  final String id;
  final String name;
  final String symbol;
  final String priceUsd;
  final String percentChange24h;
  final Color startColor;
  final Color endColor;

  CryptoData({
    required this.id,
    required this.name,
    required this.symbol,
    required this.priceUsd,
    required this.percentChange24h,
    required this.startColor,
    required this.endColor,
  });

  factory CryptoData.fromJson(Map<String, dynamic> json) {
    return CryptoData(
      id: json['id'],
      name: json['name'],
      symbol: json['symbol'],
      priceUsd: json['price_usd'],
      percentChange24h: json['percent_change_24h'],
      startColor: Colors.blue,
      endColor: Colors.green,
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
    var radius = 24.0;

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

Future<List<CryptoData>?> fetchCryptoData() async {
  final response =
      await http.get(Uri.parse('https://api.coinlore.net/api/tickers/'));
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body)['data'];
    return data.map((item) => CryptoData.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load data');
  }
}

Future<Map<String, dynamic>?> fetchCryptoDetails(String id) async {
  final url = 'https://api.coinlore.net/api/ticker/?id=$id';
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.isNotEmpty ? data[0] : null; // Ambil item pertama
    } else {
      print('Failed to load details: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error fetching details: $e');
    return null;
  }
}
