import 'package:flutter/material.dart';
import 'package:stock_management/features/recu/recu_service.dart';

import '../commandes/services/commandes_service.dart';

class ReceiptsPage extends StatefulWidget {
  const ReceiptsPage({super.key});

  @override
  State<ReceiptsPage> createState() => _ReceiptsPageState();
}

class _ReceiptsPageState extends State<ReceiptsPage> {
  final OrderService _service = OrderService();

  bool isLoading = true;
  List<Map<String, dynamic>> orders = [];

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  Future<void> loadOrders() async {
    final data = await _service.getOrders();

    setState(() {
      orders = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reçus")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];

                return Card(
                  child: ListTile(
                    title: Text(order['product_name']),
                    subtitle: Text(
                      "${order['client_name']} • ${order['total_price']} DT",
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.picture_as_pdf),
                      onPressed: () async {
                        await generateReceiptPdf(order);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
