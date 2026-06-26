import 'package:flutter/material.dart';

class EmployesPage extends StatefulWidget {
  const EmployesPage({super.key});

  @override
  State<EmployesPage> createState() => _EmployesPageState();
}

class _EmployesPageState extends State<EmployesPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> employees = [];

  @override
  void initState() {
    super.initState();
    loadEmployees();
  }

  Future<void> loadEmployees() async {
    // Simulation du chargement API
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        employees = [
          {"name": "Ali Ben", "role": "Manager"},
          {"name": "Sara Ali", "role": "Caissière"},
          {"name": "Mourad Tounsi", "role": "Livreur"},
          {"name": "Leila Ben Youssef", "role": "Comptable"},
        ];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.transparent, // Important pour le MainLayout global
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Employés",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 25),

            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : employees.isEmpty
                    ? const Center(
                        child: Text(
                          "Aucun employé trouvé",
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

  // Widget pour rendre le tableau scrollable sur mobile
  Widget _buildResponsiveTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width - 88,
          ),
          child: DataTable(
            columnSpacing: 24,
            headingRowColor: MaterialStateProperty.all(
              Colors.white.withOpacity(0.05),
            ),
            columns: const [
              DataColumn(
                label: Text(
                  "Nom",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "Rôle",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  "Statut",
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
            rows: employees.map((e) {
              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      e["name"] ?? "",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  DataCell(_buildRoleBadge(e["role"] ?? "")),
                  DataCell(
                    const Text(
                      "Actif",
                      style: TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  ),
                  DataCell(
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        size: 20,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        // Action de modification
                      },
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // Petit widget pour styliser le rôle
  Widget _buildRoleBadge(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        role,
        style: const TextStyle(color: Colors.blue, fontSize: 13),
      ),
    );
  }
}
