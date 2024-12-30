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
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          cryptoDataFuture = fetchCryptoData();
        });
        await cryptoDataFuture;
      },
      child: FutureBuilder<List<CryptoData>?>(
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
                          final data =
                              await fetchCryptoDetails(items[index].id);
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
                                Colors.blueAccent,
                                Colors.blueGrey,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueGrey.withOpacity(0.6),
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
                              child: Image.network(
                                items[index].imageUrl,
                                height: 64,
                                width: 64,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.error,
                                    color: Colors.red,
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
                                    items[index].name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Avenir',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    items[index].symbol.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Avenir',
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "\$${items[index].priceUsd.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Avenir',
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    "${items[index].percentChange24h.toStringAsFixed(2)}% (24h)",
                                    style: TextStyle(
                                      color: items[index].percentChange24h < 0
                                          ? Colors.red
                                          : Colors.green,
                                      fontFamily: 'Avenir',
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
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
      ),
    );
  }
}

class CryptoData {
  final String id;
  final int market_cap_rank;
  final String symbol;
  final String name;
  final String imageUrl;
  final double priceUsd;
  final double percentChange24h;

  CryptoData({
    required this.id,
    required this.market_cap_rank,
    required this.symbol,
    required this.name,
    required this.imageUrl,
    required this.priceUsd,
    required this.percentChange24h,
  });

  factory CryptoData.fromJson(Map<String, dynamic> json) {
    return CryptoData(
      id: json['id'],
      symbol: json['symbol'],
      name: json['name'],
      imageUrl: json['image'],
      priceUsd: json['current_price'].toDouble(),
      percentChange24h: json['price_change_percentage_24h']?.toDouble() ?? 0.0,
      market_cap_rank: json['market_cap_rank'],
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

Future<List<CryptoData>> fetchCryptoData() async {
  const url = 'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => CryptoData.fromJson(json)).toList();
  } else {
    throw Exception('Failed to fetch cryptocurrency data');
  }
}

Future<Map<String, dynamic>?> fetchCryptoDetails(String id) async {
  final url = 'https://api.coingecko.com/api/v3/coins/$id';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    return json.decode(response.body) as Map<String, dynamic>;
  } else {
    print("Error fetching details: ${response.statusCode}");
    return null;
  }
}
