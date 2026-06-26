import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../services/product_service.dart';

class EditProductDialog extends StatefulWidget {
  final Product product;

  const EditProductDialog({super.key, required this.product});

  @override
  State<EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<EditProductDialog> {
  final ProductService _productService = ProductService();

  late TextEditingController nameController;
  late TextEditingController referenceController;
  late TextEditingController quantityController;
  late TextEditingController purchasePriceController;
  late TextEditingController sellingPriceController;
  late TextEditingController categoryController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.product.name);

    referenceController = TextEditingController(text: widget.product.reference);
    categoryController = TextEditingController(text: widget.product.categoryId);

    quantityController = TextEditingController(
      text: widget.product.quantity.toString(),
    );

    purchasePriceController = TextEditingController(
      text: widget.product.purchasePrice.toString(),
    );

    sellingPriceController = TextEditingController(
      text: widget.product.sellingPrice.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Modifier produit"),

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
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: "Catégorie"),
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
            setState(() {
              isLoading = true;
            });

            await _productService.updateProduct(
              id: widget.product.id,
              name: nameController.text.trim(),
              categoryId: categoryController.text.trim(),
              reference: referenceController.text.trim(),
              quantity: int.tryParse(quantityController.text) ?? 0,
              purchasePrice: double.tryParse(purchasePriceController.text) ?? 0,
              sellingPrice: double.tryParse(sellingPriceController.text) ?? 0,
            );

            if (mounted) {
              Navigator.pop(context, true);
            }
          },
          child: isLoading
              ? const CircularProgressIndicator()
              : const Text("Modifier"),
        ),
      ],
    );
  }
}
