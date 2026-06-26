import 'package:flutter/material.dart';

import '../../categories/model/categorie_model.dart';
import '../../categories/services/categorie_services.dart';
import '../services/product_service.dart';

class AddProductDialog extends StatefulWidget {
  const AddProductDialog({super.key});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final nameController = TextEditingController();
  final referenceController = TextEditingController();
  final quantityController = TextEditingController();
  final purchasePriceController = TextEditingController();
  final sellingPriceController = TextEditingController();

  final ProductService _productService = ProductService();

  String? selectedCategoryId;

  List<Category> categories = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    categories = await CategoryService().getCategories();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Ajouter un produit"),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Nom"),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: referenceController,
                decoration: const InputDecoration(labelText: "Référence"),
              ),

              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                value: selectedCategoryId,

                decoration: const InputDecoration(labelText: "Catégorie"),

                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category.id,
                    child: Text(category.name),
                  );
                }).toList(),

                onChanged: (value) {
                  setState(() {
                    selectedCategoryId = value;
                  });
                },
              ),

              const SizedBox(height: 10),

              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Quantité"),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: purchasePriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Prix achat"),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: sellingPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Prix vente"),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Annuler"),
        ),

        ElevatedButton(
          onPressed: () async {
            try {
              setState(() {
                isLoading = true;
              });

              if (selectedCategoryId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Veuillez sélectionner une catégorie"),
                  ),
                );

                setState(() {
                  isLoading = false;
                });

                return;
              }

              await _productService.addProduct(
                name: nameController.text.trim(),
                category: selectedCategoryId!,
                reference: referenceController.text.trim(),
                quantity: int.tryParse(quantityController.text) ?? 0,
                purchasePrice:
                    double.tryParse(purchasePriceController.text) ?? 0,
                sellingPrice: double.tryParse(sellingPriceController.text) ?? 0,
              );

              if (mounted) {
                Navigator.pop(context, true);
              }
            } catch (e) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(e.toString())));
            } finally {
              if (mounted) {
                setState(() {
                  isLoading = false;
                });
              }
            }
          },
          child: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(),
                )
              : const Text("Enregistrer"),
        ),
      ],
    );
  }
}
