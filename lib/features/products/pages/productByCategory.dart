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

  // ================= LOAD PRODUCTS =================
  Future<void> loadProducts() async {
    try {
      final data = await _service.getProductsByCategory(widget.category.id);

      setState(() {
        products = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint(e.toString());
    }
  }

  // ================= PDF GENERATION =================
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

  // ================= DIALOG =================
  void _openOrderDialog(Product product) {
    final clientController = TextEditingController();
    final quantityController = TextEditingController();
    final sellerController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111827),
          title: Text(
            "Commander ${product.name}",
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: clientController,
                decoration: const InputDecoration(labelText: "Nom du client"),
              ),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Quantité"),
              ),
              TextField(
                controller: sellerController,
                decoration: const InputDecoration(labelText: "Nom du vendeur"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              child: const Text("Commander"),
              onPressed: () {
                final qty = int.tryParse(quantityController.text) ?? 0;

                if (clientController.text.isEmpty ||
                    sellerController.text.isEmpty ||
                    qty <= 0 ||
                    qty > product.quantity) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Données invalides")),
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

  // ================= CREATE ORDER =================
  Future<void> _createOrder({
    required Product product,
    required String client,
    required String seller,
    required int quantity,
  }) async {
    final total = quantity * product.sellingPrice;

    // 1. Save order in Supabase
    await _orderService.createOrder(
      productId: product.id,
      productName: product.name,
      clientName: client,
      sellerName: seller,
      quantity: quantity,
      unitPrice: product.sellingPrice,
    );

    // 2. Update stock
    await _service.updateProduct(
      id: product.id,
      name: product.name,
      categoryId: product.categoryId,
      reference: product.reference,
      quantity: product.quantity - quantity,
      purchasePrice: product.purchasePrice,
      sellingPrice: product.sellingPrice,
    );

    // 3. Refresh UI
    await loadProducts();

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Commande enregistrée")));

    // 4. Generate PDF + open it
    final pdfPath = await _generateInvoicePdf(
      product: product,
      client: client,
      seller: seller,
      quantity: quantity,
      total: total,
    );

    print("PDF generated at: $pdfPath");

    final file = File(pdfPath);

    if (await file.exists()) {
      await OpenFile.open(pdfPath);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("PDF non trouvé")));
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(widget.category.name),
        backgroundColor: const Color(0xFF111827),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
          ? const Center(child: Text("Aucun produit dans cette catégorie"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];

                return InkWell(
                  onTap: () => _openOrderDialog(product),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
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
                            const SizedBox(height: 5),
                            Text(
                              "Stock: ${product.quantity}",
                              style: TextStyle(
                                color: product.quantity > 0
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const Icon(Icons.shopping_cart, color: Colors.white),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
