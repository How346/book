import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'models.dart';

class PdfService {
  static Future<void> generateAndShareStatement(Party party, List<TransactionModel> txs) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('OK Book Statement', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Name: ${party.name}', style: const pw.TextStyle(fontSize: 18)),
              pw.Text('Phone: ${party.phone}', style: const pw.TextStyle(fontSize: 14)),
              pw.Text('Net Balance: ₹${(party.balancePaise.abs() / 100).toStringAsFixed(2)} ${party.balancePaise >= 0 ? '(Get)' : '(Give)'}'),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: ['Date', 'Note', 'Amount (Give)', 'Amount (Get)'],
                data: txs.map((tx) {
                  final amt = '₹${(tx.amountPaise / 100).toStringAsFixed(2)}';
                  return [
                    '${tx.date.day}/${tx.date.month}/${tx.date.year}',
                    tx.note,
                    tx.isGot ? '' : amt,
                    tx.isGot ? amt : '',
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
    await Printing.sharePdf(bytes: await pdf.save(), filename: 'statement_${party.name}.pdf');
  }
}
