import 'package:flutter/material.dart';

import '../widget/app_sidebar.dart';

class DashboardLayout extends StatelessWidget {
  final Widget child;

  const DashboardLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),

      body: Row(
        children: [
          const AppSidebar(),

          Expanded(
            child: Column(
              children: [
                Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  decoration: const BoxDecoration(
                    color: Color(0xFF111827),
                    border: Border(bottom: BorderSide(color: Colors.white10)),
                  ),

                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 45,

                          decoration: BoxDecoration(
                            color: const Color(0xFF1F2937),

                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: const TextField(
                            decoration: InputDecoration(
                              hintText: "Rechercher un produit...",

                              border: InputBorder.none,

                              prefixIcon: Icon(Icons.search),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 20),

                      Container(
                        padding: const EdgeInsets.all(8),

                        decoration: BoxDecoration(
                          color: const Color(0xFF1F2937),

                          borderRadius: BorderRadius.circular(12),
                        ),

                        child: const Icon(Icons.notifications),
                      ),

                      const SizedBox(width: 15),

                      const CircleAvatar(radius: 22, child: Icon(Icons.person)),
                    ],
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
