import 'package:flutter/material.dart';

import '../services/categorie_services.dart';

class AddCategoryDialog extends StatefulWidget {
  const AddCategoryDialog({super.key});

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final controller = TextEditingController();

  final CategoryService service = CategoryService();

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Nouvelle catégorie"),

      content: TextField(
        controller: controller,
        decoration: const InputDecoration(labelText: "Nom de la catégorie"),
      ),

      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Annuler"),
        ),

        ElevatedButton(
          onPressed: () async {
            setState(() {
              loading = true;
            });

            await service.addCategory(controller.text.trim());

            if (mounted) {
              Navigator.pop(context, true);
            }
          },
          child: loading
              ? const CircularProgressIndicator()
              : const Text("Ajouter"),
        ),
      ],
    );
  }
}
