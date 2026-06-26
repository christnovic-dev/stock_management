import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Importez vos fichiers réels ici
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

  Future<void> loadStats() async {
    try {
      final products = await _service.getAllProducts();
      final stats = await _service.getStats();
      final lowStock = await _service.getLowStockProducts();
      final latest = await _service.getLatestProducts();
      final top = await _service.getTopProducts();

      if (mounted) {
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
    } catch (e) {
      debugPrint("Erreur lors du chargement des stats: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Détection de la largeur de l'écran
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 800;

    return Scaffold(
      backgroundColor:
          Colors.transparent, // Car le fond est géré par le layout principal
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Dashboard",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Cartes de statistiques (Wrap permet de passer à la ligne sur mobile)
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      _buildStatCard(
                        context,
                        "Produits",
                        totalProducts.toString(),
                        "assets/icons/produits.png",
                        const Color(0xFF00D4AA),
                        '/products',
                      ),
                      _buildStatCard(
                        context,
                        "Stock Total",
                        totalQuantity.toString(),
                        "assets/icons/entrepot.png",
                        const Color(0xFF6C5CE7),
                        '/categories',
                      ),

                      // Carte Valeur Spécifique (PageView)
                      _buildPageViewCard(isMobile),

                      _buildStatCard(
                        context,
                        "Alertes",
                        lowStockProducts.length.toString(),
                        "assets/icons/alarme.png",
                        Colors.red,
                        null,
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Section du bas : Listes de produits
                  // Sur Mobile : Column, Sur PC : Row
                  if (isMobile)
                    Column(
                      children: [
                        _infoCard(
                          "⚠️ Stock Faible",
                          'assets/icons/box.png',
                          lowStockProducts,
                        ),
                        const SizedBox(height: 20),
                        _infoCard(
                          "🆕 Derniers Produits",
                          'assets/icons/box.png',
                          latestProducts,
                        ),
                        const SizedBox(height: 20),
                        _infoCard(
                          "🏆 Top Produits",
                          'assets/icons/box.png',
                          topProducts,
                        ),
                      ],
                    )
                  else
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
    );
  }

  // Widget pour les cartes cliquables
  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    String icon,
    Color color,
    String? route,
  ) {
    return GestureDetector(
      onTap: route != null ? () => context.go(route) : null,
      child: _card(title, value, icon, color),
    );
  }

  // Widget spécifique pour le PageView des valeurs de produits
  Widget _buildPageViewCard(bool isMobile) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const StockValueDetailsPage()),
        );
      },
      child: Container(
        width: isMobile ? double.infinity : 300,
        height: 170,
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFF7A00).withOpacity(.4)),
        ),
        child: allProducts.isEmpty
            ? const Center(child: Text("Aucun produit"))
            : PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: allProducts.length,
                itemBuilder: (context, index) {
                  final product = allProducts[index];
                  final val =
                      ((product['quantity'] ?? 0) as num) *
                      ((product['purchase_price'] ?? 0) as num);

                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                        const Spacer(),
                        Text(
                          'Valeur de ${product['name']}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${val.toStringAsFixed(0)} DT",
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
    );
  }

  Widget _card(String title, String value, String iconPath, Color color) {
    return Container(
      width:
          300, // Sur mobile, le Wrap gérera la largeur ou on pourrait mettre MediaQuery
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
                child: Image.asset(
                  iconPath,
                  width: 24,
                  height: 24,
                  errorBuilder: (c, e, s) => const Icon(Icons.error),
                ),
              ),
              const Spacer(),
              Icon(Icons.arrow_upward, color: color, size: 18),
            ],
          ),
          const Spacer(),
          Text(
            'Total $title',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          if (products.isEmpty)
            const Text(
              "Aucune donnée disponible",
              style: TextStyle(color: Colors.grey),
            ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length > 5
                ? 5
                : products.length, // Limiter à 5 items
            itemBuilder: (context, index) {
              final product = products[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      iconPath,
                      width: 24,
                      height: 24,
                      errorBuilder: (c, e, s) => const Icon(Icons.inventory),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        product['name'] ?? "Inconnu",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    Text(
                      "${product['quantity'] ?? 0}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
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
