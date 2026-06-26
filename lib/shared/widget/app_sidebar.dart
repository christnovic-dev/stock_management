import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: AppColors.sidebar,
      child: Column(
        children: [
          const SizedBox(height: 30),

          const Text(
            "GESTION STOCK",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
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
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
      ),
      onTap: () {
        context.go(route);
      },
    );
  }
}
