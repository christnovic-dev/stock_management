import 'package:flutter/material.dart';

import '../products/services/product_service.dart';

class StockValueDetailsPage extends StatefulWidget {
  const StockValueDetailsPage({super.key});

  @override
  State<StockValueDetailsPage> createState() => _StockValueDetailsPageState();
}

class _StockValueDetailsPageState extends State<StockValueDetailsPage> {
  final ProductService _service = ProductService();

  List products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    final data = await _service.getProducts();

    setState(() {
      products = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(title: const Text("Valeur du Stock")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text("Produit")),
                  DataColumn(label: Text("Prix U")),
                  DataColumn(label: Text("Qté")),
                  DataColumn(label: Text("Achat Total")),
                  DataColumn(label: Text("Vente Total")),
                  DataColumn(label: Text("Gain")),
                ],
                rows: products.map((product) {
                  final achat = product.quantity * product.purchasePrice;

                  final vente = product.quantity * product.sellingPrice;

                  final gain = vente - achat;

                  return DataRow(
                    cells: [
                      DataCell(Text(product.name)),
                      DataCell(Text("${product.purchasePrice} DT")),
                      DataCell(Text("${product.quantity}")),
                      DataCell(Text("${achat.toStringAsFixed(2)} DT")),
                      DataCell(Text("${vente.toStringAsFixed(2)} DT")),
                      DataCell(Text("${gain.toStringAsFixed(2)} DT")),
                    ],
                  );
                }).toList(),
              ),
            ),
    );
  }
}
