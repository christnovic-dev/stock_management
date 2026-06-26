import 'dart:html' as html;
import 'dart:typed_data';

import 'package:pdf/widgets.dart' as pw;

Future<void> generateReceiptPdf(Map<String, dynamic> order) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("REÇU DE VENTE", style: pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 20),
            pw.Text("Client : ${order['client_name']}"),
            pw.Text("Vendeur : ${order['seller_name']}"),
            pw.Text("Produit : ${order['product_name']}"),
            pw.Text("Quantité : ${order['quantity']}"),
            pw.Text("Prix unitaire : ${order['unit_price']}"),
            pw.Text("Total : ${order['total_price']}"),
            pw.Text("Date : ${order['created_at']}"),
          ],
        );
      },
    ),
  );

  final Uint8List bytes = await pdf.save();

  final blob = html.Blob([bytes], 'application/pdf');

  final url = html.Url.createObjectUrlFromBlob(blob);

  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", "recu_${order['id']}.pdf")
    ..click();

  html.Url.revokeObjectUrl(url);
}
