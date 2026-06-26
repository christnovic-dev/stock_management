import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:stock_management/features/commandes/services/commandes_service.dart';

import '../../categories/model/categorie_model.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductsByCategoryPage extends StatefulWidget {
  final Category category;

  const ProductsByCategoryPage({super.key, required this.category});

  @override
  State<ProductsByCategoryPage> createState() => _ProductsByCategoryPageState();
}

class _ProductsByCategoryPageState extends State<ProductsByCategoryPage> {
  final ProductService _service = ProductService();
  final OrderService _orderService = OrderService();

  bool isLoading = true;
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  // ================= LOGIQUE (INCHANGÉE) =================
  Future<void> loadProducts() async {
    try {
      final data = await _service.getProductsByCategory(widget.category.id);
      if (mounted) {
        setState(() {
          products = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
      debugPrint(e.toString());
    }
  }

  Future<String> _generateInvoicePdf({
    required Product product,
    required String client,
    required String seller,
    required int quantity,
    required double total,
  }) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("FACTURE", style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              pw.Text("Client: $client"),
              pw.Text("Vendeur: $seller"),
              pw.Text("Produit: ${product.name}"),
              pw.Text("Quantité: $quantity"),
              pw.Text("Prix unitaire: ${product.sellingPrice}"),
              pw.Text("Total: $total"),
            ],
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final filePath =
        "${dir.path}/facture_${DateTime.now().millisecondsSinceEpoch}.pdf";
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    return filePath;
  }

  Future<void> _createOrder({
    required Product product,
    required String client,
    required String seller,
    required int quantity,
  }) async {
    final total = quantity * product.sellingPrice;
    await _orderService.createOrder(
      productId: product.id,
      productName: product.name,
      clientName: client,
      sellerName: seller,
      quantity: quantity,
      unitPrice: product.sellingPrice,
    );
    await _service.updateProduct(
      id: product.id,
      name: product.name,
      categoryId: product.categoryId,
      reference: product.reference,
      quantity: product.quantity - quantity,
      purchasePrice: product.purchasePrice,
      sellingPrice: product.sellingPrice,
    );
    await loadProducts();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Commande enregistrée")));
    final pdfPath = await _generateInvoicePdf(
      product: product,
      client: client,
      seller: seller,
      quantity: quantity,
      total: total,
    );
    final file = File(pdfPath);
    if (await file.exists()) {
      await OpenFile.open(pdfPath);
    }
  }

  // ================= DESIGN MIS À JOUR =================

  void _openOrderDialog(Product product) {
    final clientController = TextEditingController();
    final quantityController = TextEditingController();
    final sellerController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111827),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "Commander ${product.name}",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(
                  clientController,
                  "Nom du client",
                  Icons.person,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  quantityController,
                  "Quantité (Max: ${product.quantity})",
                  Icons.shopping_cart,
                  isNumber: true,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  sellerController,
                  "Nom du vendeur",
                  Icons.badge,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Annuler",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              child: const Text(
                "Confirmer",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                final qty = int.tryParse(quantityController.text) ?? 0;
                if (clientController.text.isEmpty ||
                    sellerController.text.isEmpty ||
                    qty <= 0 ||
                    qty > product.quantity) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Données invalides ou stock insuffisant"),
                    ),
                  );
                  return;
                }
                Navigator.pop(context);
                _createOrder(
                  product: product,
                  client: clientController.text,
                  seller: sellerController.text,
                  quantity: qty,
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.blueAccent, size: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blueAccent),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Fond sombre cohérent
      appBar: AppBar(
        title: Text(
          widget.category.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF111827),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Produits : ${widget.category.name}",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : products.isEmpty
                    ? const Center(
                        child: Text(
                          "Aucun produit dans cette catégorie",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return _buildProductItem(product);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(Product product) {
    bool isOutOfStock = product.quantity <= 0;

    return InkWell(
      onTap: isOutOfStock ? null : () => _openOrderDialog(product),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            // Icone Produit
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isOutOfStock ? Colors.red : Colors.blue).withOpacity(
                  0.1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.inventory_2,
                color: isOutOfStock ? Colors.red : Colors.blueAccent,
              ),
            ),
            const SizedBox(width: 15),
            // Infos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${product.sellingPrice} DT",
                    style: TextStyle(
                      color: Colors.blueAccent.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // Badge Stock
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: (isOutOfStock ? Colors.red : Colors.green).withOpacity(
                  0.1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isOutOfStock ? "Rupture" : "Stock: ${product.quantity}",
                style: TextStyle(
                  color: isOutOfStock ? Colors.red : Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}
