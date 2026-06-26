import 'package:flutter/material.dart';

import '../../../shared/layout/dashboard_layout.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../widgets/add_product_dialog.dart';
import '../widgets/edit_product_dialog.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final ProductService _productService = ProductService();

  bool isLoading = true;
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      final data = await _productService.getProducts();

      setState(() {
        products = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Produits",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),

                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await showDialog(
                      context: context,
                      builder: (_) => const AddProductDialog(),
                    );

                    if (result == true) {
                      loadProducts();
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Ajouter un produit"),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : products.isEmpty
                    ? const Center(child: Text("Aucun produit trouvé"))
                    : SingleChildScrollView(
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text("Référence")),
                            DataColumn(label: Text("categorie")),
                            DataColumn(label: Text("Nom")),
                            DataColumn(label: Text("Stock")),
                            DataColumn(label: Text("Prix Achat")),
                            DataColumn(label: Text("Prix Vente")),
                            DataColumn(label: Text("Actions")),
                          ],
                          rows: products.map((product) {
                            return DataRow(
                              cells: [
                                DataCell(Text(product.reference)),
                                DataCell(Text(product.categoryName ?? '')),
                                DataCell(Text(product.name)),
                                DataCell(Text(product.quantity.toString())),
                                DataCell(Text("${product.purchasePrice}")),
                                DataCell(Text("${product.sellingPrice}")),
                                DataCell(
                                  PopupMenuButton<String>(
                                    icon: const Icon(
                                      Icons.more_horiz,
                                    ), // Les trois points verticaux
                                    onSelected: (String value) async {
                                      if (value == 'edit') {
                                        // Logique de modification
                                        final result = await showDialog(
                                          context: context,
                                          builder: (_) => EditProductDialog(
                                            product: product,
                                          ),
                                        );

                                        if (result == true) {
                                          loadProducts();
                                        }
                                      } else if (value == 'delete') {
                                        // Logique de suppression
                                        // Optionnel : Ajouter un dialogue de confirmation ici avant de supprimer
                                        await _productService.deleteProduct(
                                          product.id,
                                        );
                                        loadProducts();
                                      }
                                    },
                                    itemBuilder: (BuildContext context) => [
                                      const PopupMenuItem<String>(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit, size: 20),
                                            SizedBox(width: 8),
                                            Text('Modifier'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                              size: 20,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Supprimer',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
