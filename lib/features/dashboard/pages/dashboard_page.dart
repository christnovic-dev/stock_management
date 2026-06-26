import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/layout/dashboard_layout.dart';
import '../../stock/valeur_stock.dart';
import '../services/dashboard_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DashboardService _service = DashboardService();

  List<Map<String, dynamic>> lowStockProducts = [];
  List<Map<String, dynamic>> latestProducts = [];
  List<Map<String, dynamic>> topProducts = [];

  List<Map<String, dynamic>> allProducts = [];

  final PageController _pageController = PageController();

  int currentProductIndex = 0;
  Timer? productTimer;

  void _startProductRotation() {
    productTimer?.cancel();

    if (allProducts.isEmpty) return;

    productTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted || !_pageController.hasClients) return;

      currentProductIndex++;

      if (currentProductIndex >= allProducts.length) {
        currentProductIndex = 0;
      }

      _pageController.animateToPage(
        currentProductIndex,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    });
  }

  bool isLoading = true;

  int totalProducts = 0;
  int totalQuantity = 0;
  double stockValue = 0;

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  @override
  void dispose() {
    productTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> loadStats() async {
    final products = await _service.getAllProducts();
    final stats = await _service.getStats();

    final lowStock = await _service.getLowStockProducts();

    final latest = await _service.getLatestProducts();

    final top = await _service.getTopProducts();

    setState(() {
      totalProducts = stats['totalProducts'];
      totalQuantity = stats['totalQuantity'];
      stockValue = stats['stockValue'];

      lowStockProducts = lowStock;
      latestProducts = latest;
      topProducts = top;
      allProducts = products;

      isLoading = false;
    });

    _startProductRotation();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Dashboard",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),

                    const SizedBox(height: 20),

                    Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: [
                        GestureDetector(
                          onTap: () => context.go('/products'),
                          child: _card(
                            "Produits",
                            totalProducts.toString(),
                            "assets/icons/produits.png",
                            const Color(0xFF00D4AA),
                          ),
                        ),

                        GestureDetector(
                          onTap: () => context.go('/categories'),
                          child: _card(
                            "Stock Total",
                            totalQuantity.toString(),
                            "assets/icons/entrepot.png",
                            const Color(0xFF6C5CE7),
                          ),
                        ),

                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const StockValueDetailsPage(),
                              ),
                            );
                          },
                          child: Container(
                            width: 300,
                            height: 170,
                            decoration: BoxDecoration(
                              color: const Color(0xFF111827),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFFF7A00).withOpacity(.4),
                              ),
                            ),
                            child: PageView.builder(
                              controller: _pageController,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: allProducts.length,
                              itemBuilder: (context, index) {
                                final product = allProducts[index];

                                final stockValue =
                                    ((product['quantity'] ?? 0) as num) *
                                    ((product['purchase_price'] ?? 0) as num);

                                return Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: const Color(
                                              0xFFFF7A00,
                                            ).withOpacity(.2),
                                            child: Image.asset(
                                              "assets/icons/dollar.png",
                                              width: 24,
                                              height: 24,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const Spacer(),

                                      Text(
                                        'valeur de ${product['name']}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      Text(
                                        "${stockValue.toStringAsFixed(0)} DT",
                                        style: const TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        _card(
                          "Alertes",
                          lowStockProducts.length.toString(),
                          "assets/icons/alarme.png",
                          Colors.red,
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _infoCard(
                            "⚠️ Stock Faible",
                            'assets/icons/box.png',
                            lowStockProducts,
                          ),
                        ),

                        const SizedBox(width: 20),

                        Expanded(
                          child: _infoCard(
                            "🆕 Derniers Produits",
                            'assets/icons/box.png',
                            latestProducts,
                          ),
                        ),

                        const SizedBox(width: 20),

                        Expanded(
                          child: _infoCard(
                            "🏆 Top Produits",
                            'assets/icons/box.png',
                            topProducts,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _card(String title, String value, String iconPath, Color color) {
    return Container(
      width: 300,
      height: 170,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: const Color(0xFF111827),

        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: color.withOpacity(.4)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(.2),
                child: Image.asset(iconPath, width: 24, height: 24),
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.all(8),

                decoration: BoxDecoration(
                  color: color.withOpacity(.15),
                  borderRadius: BorderRadius.circular(10),
                ),

                child: Icon(Icons.arrow_upward, color: color, size: 18),
              ),
            ],
          ),

          const Spacer(),

          AnimatedSwitcher(
            duration: const Duration(seconds: 1),
            transitionBuilder: (child, animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
            child: Text(
              'Valeur de $title',
              key: ValueKey(title),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            ),
          ),

          const SizedBox(height: 8),

          AnimatedSwitcher(
            duration: const Duration(seconds: 1),
            transitionBuilder: (child, animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
            child: Text(
              value,
              key: ValueKey(value),
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(
    String title,
    String iconPath,
    List<Map<String, dynamic>> products,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      child: Image.asset(iconPath, width: 24, height: 24),
                    ),

                    const SizedBox(width: 10),

                    Expanded(child: Text(product['name'])),

                    Text("${product['quantity']}"),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
