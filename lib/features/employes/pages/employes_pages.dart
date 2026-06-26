import 'package:flutter/material.dart';

import '../../../shared/layout/dashboard_layout.dart';

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
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      employees = [
        {"name": "Ali Ben", "role": "Manager"},
        {"name": "Sara Ali", "role": "Caissière"},
      ];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Employés", style: Theme.of(context).textTheme.headlineMedium),
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
                    : DataTable(
                        columns: const [
                          DataColumn(label: Text("Nom")),
                          DataColumn(label: Text("Rôle")),
                        ],
                        rows: employees.map((e) {
                          return DataRow(
                            cells: [
                              DataCell(Text(e["name"])),
                              DataCell(Text(e["role"])),
                            ],
                          );
                        }).toList(),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
