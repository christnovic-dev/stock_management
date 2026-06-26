import 'package:flutter/material.dart';

// Importez vos fichiers réels ici
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
      if (mounted) {
        setState(() {
          products = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: Colors.transparent, // Car géré par MainLayout
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Responsive
            isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Produits",
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(width: double.infinity, child: _addButton()),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Produits",
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                      ),
                      _addButton(),
                    ],
                  ),

            const SizedBox(height: 25),

            // Conteneur du tableau
            Expanded(
              child: Container(
                width: double.infinity,
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
                          "Aucun produit trouvé",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : _buildResponsiveTable(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour le bouton Ajouter
  Widget _addButton() {
    return ElevatedButton.icon(
      onPressed: () async {
        final result = await showDialog(
          context: context,
          builder: (_) => const AddProductDialog(),
        );
        if (result == true) loadProducts();
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        "Ajouter un produit",
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  // Construction du tableau avec défilement horizontal pour le mobile
  Widget _buildResponsiveTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection:
            Axis.horizontal, // Permet de slider de gauche à droite sur mobile
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width - 48,
          ),
          child: DataTable(
            columnSpacing: 20,
            headingRowColor: MaterialStateProperty.all(
              Colors.white.withOpacity(0.05),
            ),
            columns: const [
              DataColumn(
                label: Text(
                  "Référence",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "Catégorie",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  "Nom",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  "Stock",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  "Prix Achat",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  "Prix Vente",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  "Actions",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
            rows: products.map((product) {
              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      product.reference,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  DataCell(Text(product.categoryName ?? 'N/A')),
                  DataCell(
                    Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  DataCell(_buildStockBadge(product.quantity)),
                  DataCell(Text("${product.purchasePrice} DT")),
                  DataCell(Text("${product.sellingPrice} DT")),
                  DataCell(_buildActions(product)),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // Badge de couleur pour le stock
  Widget _buildStockBadge(int quantity) {
    Color color = quantity < 5 ? Colors.red : Colors.green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        quantity.toString(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Menu d'actions (Modifier / Supprimer)
  Widget _buildActions(Product product) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_horiz, color: Colors.grey),
      onSelected: (String value) async {
        if (value == 'edit') {
          final result = await showDialog(
            context: context,
            builder: (_) => EditProductDialog(product: product),
          );
          if (result == true) loadProducts();
        } else if (value == 'delete') {
          _confirmDelete(product);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 18),
              SizedBox(width: 8),
              Text("Modifier"),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 18, color: Colors.red),
              SizedBox(width: 8),
              Text("Supprimer", style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  // Dialogue de confirmation de suppression
  void _confirmDelete(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Supprimer le produit ?"),
        content: Text("Voulez-vous vraiment supprimer ${product.name} ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () async {
              await _productService.deleteProduct(product.id);
              Navigator.pop(context);
              loadProducts();
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
