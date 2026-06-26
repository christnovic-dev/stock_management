import 'dart:html' as html;
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<void> generateReceiptPdf(Map<String, dynamic> order) async {
  final pdf = pw.Document();

  // On définit des styles pour réutilisation
  final headerStyle = pw.TextStyle(
    fontSize: 10,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.grey700,
  );
  final valueStyle = pw.TextStyle(fontSize: 10, color: PdfColors.black);
  final tableHeaderStyle = pw.TextStyle(
    fontSize: 11,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.white,
  );

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return pw.Padding(
          padding: const pw.EdgeInsets.all(30),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // --- EN-TÊTE : LOGO & INFOS ENTREPRISE ---
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "GESTION STOCK PRO",
                        style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue800,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text("123 Rue de l'Énergie, Tunis"),
                      pw.Text("Tél : +216 71 000 000"),
                      pw.Text("Email : contact@entreprise.tn"),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        "REÇU DE VENTE",
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey800,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        "N° : REC-${order['id'].toString().padLeft(6, '0')}",
                      ),
                      pw.Text(
                        "Date : ${order['created_at'].toString().split(' ')[0]}",
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 40),

              // --- INFOS CLIENT & VENDEUR ---
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("FACTURÉ À", style: headerStyle),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        order['client_name'] ?? "Client Inconnu",
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text("VENDEUR", style: headerStyle),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        order['seller_name'] ?? "Admin",
                        style: valueStyle,
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 40),

              // --- TABLEAU DES PRODUITS ---
              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColors.grey300,
                  width: 0.5,
                ),
                columnWidths: {
                  0: const pw.FlexColumnWidth(4), // Produit
                  1: const pw.FlexColumnWidth(1), // Qté
                  2: const pw.FlexColumnWidth(2), // Prix Unit
                  3: const pw.FlexColumnWidth(2), // Total
                },
                children: [
                  // Ligne d'entête
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.blue800,
                    ),
                    children: [
                      _buildHeaderCell("Désignation", tableHeaderStyle),
                      _buildHeaderCell("Qté", tableHeaderStyle),
                      _buildHeaderCell("P.U (DT)", tableHeaderStyle),
                      _buildHeaderCell("Total (DT)", tableHeaderStyle),
                    ],
                  ),
                  // Ligne de données
                  pw.TableRow(
                    children: [
                      _buildDataCell(order['product_name']),
                      _buildDataCell(order['quantity'].toString()),
                      _buildDataCell("${order['unit_price']}"),
                      _buildDataCell("${order['total_price']}"),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 30),

              // --- RÉSUMÉ FINANCIER ---
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 200,
                    child: pw.Column(
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text("Sous-total :", style: valueStyle),
                            pw.Text(
                              "${order['total_price']} DT",
                              style: valueStyle,
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 5),
                        pw.Divider(color: PdfColors.grey300),
                        pw.SizedBox(height: 5),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              "TOTAL NET :",
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(
                              "${order['total_price']} DT",
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.blue800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.Spacer(),

              // --- PIED DE PAGE ---
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  "Merci pour votre achat !",
                  style: pw.TextStyle(
                    fontStyle: pw.FontStyle.italic,
                    color: PdfColors.grey700,
                  ),
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Center(
                child: pw.Text(
                  "REÇU GÉNÉRÉ PAR SYSTÈME DE GESTION DE STOCK",
                  style: const pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );

  // --- LOGIQUE DE TÉLÉCHARGEMENT (WEB) ---
  final Uint8List bytes = await pdf.save();
  final blob = html.Blob([bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", "recu_${order['id']}.pdf")
    ..click();
  html.Url.revokeObjectUrl(url);
}

// Helper pour créer les cellules d'entête du tableau
pw.Widget _buildHeaderCell(String text, pw.TextStyle style) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(8),
    child: pw.Text(text, style: style, textAlign: pw.TextAlign.center),
  );
}

// Helper pour créer les cellules de données du tableau
pw.Widget _buildDataCell(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(8),
    child: pw.Text(
      text,
      textAlign: pw.TextAlign.center,
      style: const pw.TextStyle(fontSize: 10),
    ),
  );
}
