import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    // Utiliser Drawer ici permet d'avoir les animations natives sur mobile
    return Drawer(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Container(
        width: 260,
        color: AppColors.sidebar,
        child: Column(
          children: [
            const SizedBox(height: 50), // Un peu plus d'espace en haut
            const Text(
              "Gestion de stock",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            _menu(context, Icons.dashboard, "Dashboard", '/'),
            _menu(context, Icons.inventory_2, "Produits", '/products'),
            _menu(context, Icons.category, "Catégories", '/categories'),
            _menu(context, Icons.shopping_bag, "Commandes", '/commandes'),
            _menu(context, Icons.person, "Clients", '/clients'),
            _menu(context, Icons.person_2_outlined, "Employés", '/employes'),
            const Spacer(),
            _menu(context, Icons.logout, "Déconnexion", '/'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _menu(
    BuildContext context,
    IconData icon,
    String title,
    String route,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      onTap: () {
        // IMPORTANT : Fermer le drawer sur mobile avant de naviguer
        if (Scaffold.of(context).isDrawerOpen) {
          Navigator.pop(context);
        }
        context.go(route);
      },
    );
  }
}
