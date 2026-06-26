import 'package:flutter/material.dart';

import 'app_sidebar.dart'; // Importez votre sidebar ici

class MainLayout extends StatelessWidget {
  final Widget child; // C'est la page actuelle envoyée par GoRouter

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // On définit si on est sur mobile (largeur < 800 pixels)
    bool isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      // SUR MOBILE : On utilise le Drawer (la sidebar devient glissante)
      drawer: isMobile ? const AppSidebar() : null,

      // SUR MOBILE : On affiche une AppBar pour avoir le bouton "Menu" (hamburger)
      appBar: isMobile
          ? AppBar(title: const Text("GESTION STOCK"), elevation: 0)
          : null,

      body: Row(
        children: [
          // SUR PC : On affiche la sidebar fixe à gauche
          if (!isMobile) const AppSidebar(),

          // Le contenu principal de la page
          Expanded(child: child),
        ],
      ),
    );
  }
}
