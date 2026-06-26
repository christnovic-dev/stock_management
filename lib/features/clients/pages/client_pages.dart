import 'package:flutter/material.dart';

import '../../../shared/layout/dashboard_layout.dart';

class ClientPage extends StatefulWidget {
  const ClientPage({super.key});

  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  bool isLoading = true;

  List<Map<String, dynamic>> clients = [];

  @override
  void initState() {
    super.initState();
    loadClients();
  }

  Future<void> loadClients() async {
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      clients = [
        {"name": "Jean Dupont", "phone": "22133445", "email": "jean@mail.com"},
        {
          "name": "Marie Claire",
          "phone": "98765432",
          "email": "marie@mail.com",
        },
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
            Text("Clients", style: Theme.of(context).textTheme.headlineMedium),
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
                          DataColumn(label: Text("Téléphone")),
                          DataColumn(label: Text("Email")),
                        ],
                        rows: clients.map((c) {
                          return DataRow(
                            cells: [
                              DataCell(Text(c["name"])),
                              DataCell(Text(c["phone"])),
                              DataCell(Text(c["email"])),
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
