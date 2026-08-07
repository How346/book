import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
class PdfService {
  static Future<void> statement(String title,String body) async {
    final doc=pw.Document();
    doc.addPage(pw.Page(build:(_)=>pw.Column(children:[pw.Text(title,style:pw.TextStyle(fontSize:22)),pw.SizedBox(height:12),pw.Text(body)])));
    await Printing.layoutPdf(onLayout:(_)=>doc.save());
  }
}
