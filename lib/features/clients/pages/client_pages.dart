import 'package:flutter/material.dart';

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
    // Simulation du chargement
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        clients = [
          {
            "name": "Jean Dupont",
            "phone": "22133445",
            "email": "jean@mail.com",
          },
          {
            "name": "Marie Claire",
            "phone": "98765432",
            "email": "marie@mail.com",
          },
          {
            "name": "Ahmed Ben Ali",
            "phone": "55443322",
            "email": "ahmed@mail.com",
          },
          {
            "name": "Sonia Mansour",
            "phone": "20102030",
            "email": "sonia@mail.com",
          },
        ];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Fond géré par le MainLayout
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Clients",
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
                    : clients.isEmpty
                    ? const Center(
                        child: Text(
                          "Aucun client trouvé",
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
        scrollDirection:
            Axis.horizontal, // Permet le défilement latéral sur mobile
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth:
                MediaQuery.of(context).size.width - 88, // Ajuste la largeur min
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
                  "Téléphone",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  "Email",
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
            rows: clients.map((c) {
              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      c["name"] ?? "",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  DataCell(
                    Text(
                      c["phone"] ?? "",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  DataCell(
                    Text(
                      c["email"] ?? "",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  DataCell(
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        size: 20,
                        color: Colors.blue,
                      ),
                      onPressed: () {
                        // Action pour modifier le client
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
}
