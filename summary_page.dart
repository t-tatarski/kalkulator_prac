import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'main.dart'; // aby mieć dostęp do SelectedItem i ProteticItem

class SummaryPage extends StatelessWidget {
  final List<SelectedItem> selectedItems;
  final double total;

  const SummaryPage({
    Key? key,
    required this.selectedItems,
    required this.total,
  }) : super(key: key);

  // Funkcja generująca dokument PDF
  Future<pw.Document> _generatePdf() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Podsumowanie kosztów pracy protetycznej',
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 16),
              pw.Table.fromTextArray(
                headers: ['Nazwa', 'Ilość', 'Cena za szt.', 'Razem'],
                data: selectedItems
                    .map((item) => [
                          item.item.name,
                          item.quantity.toString(),
                          '${item.item.price.toStringAsFixed(2)} zł',
                          '${(item.item.price * item.quantity).toStringAsFixed(2)} zł',
                        ])
                    .toList(),
              ),
              pw.Divider(),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Suma całkowita: ${total.toStringAsFixed(2)} zł',
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
              ),
            ],
          );
        },
      ),
    );
    return pdf;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Podsumowanie'),
        backgroundColor: const Color(0xFF063C73),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Wybrane elementy:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: selectedItems.length,
                itemBuilder: (context, index) {
                  final item = selectedItems[index];
                  return ListTile(
                    title: Text(item.item.name),
                    subtitle: Text(
                        'Ilość: ${item.quantity} x ${item.item.price.toStringAsFixed(2)} zł'),
                    trailing: Text(
                      (item.item.price * item.quantity).toStringAsFixed(2) +
                          ' zł',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Suma całkowita:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${total.toStringAsFixed(2)} zł',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Generuj PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF063C73),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final pdf = await _generatePdf();
                    await Printing.layoutPdf(
                      onLayout: (PdfPageFormat format) async => pdf.save(),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
