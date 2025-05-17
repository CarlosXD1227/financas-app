import 'dart:io';
import 'package:financas_app/models/transaction.dart';
import 'package:financas_app/models/category.dart';
import 'package:financas_app/models/savings_goal.dart';
import 'package:financas_app/services/database_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';

class ReportExportService {
  static final ReportExportService _instance = ReportExportService._internal();
  
  factory ReportExportService() {
    return _instance;
  }
  
  ReportExportService._internal();
  
  // Exportar relatório financeiro em PDF
  Future<String> exportFinancialReportPDF(DateTime startDate, DateTime endDate) async {
    try {
      // Obter dados para o relatório
      final transactions = await _getTransactionsForPeriod(startDate, endDate);
      final categories = await DatabaseHelper.instance.getAllCategories();
      final savingsGoals = await DatabaseHelper.instance.getAllSavingsGoals();
      
      // Calcular totais
      final totalIncome = transactions
          .where((t) => !t.isExpense)
          .fold(0.0, (sum, t) => sum + t.amount);
      
      final totalExpense = transactions
          .where((t) => t.isExpense)
          .fold(0.0, (sum, t) => sum + t.amount);
      
      final balance = totalIncome - totalExpense;
      
      // Agrupar despesas por categoria
      final expensesByCategory = <int, double>{};
      for (var transaction in transactions.where((t) => t.isExpense)) {
        expensesByCategory[transaction.categoryId] = 
            (expensesByCategory[transaction.categoryId] ?? 0.0) + transaction.amount;
      }
      
      // Criar documento PDF
      final pdf = pw.Document();
      
      // Formatador de moeda para Real brasileiro
      final currencyFormatter = NumberFormat.currency(
        locale: 'pt_BR',
        symbol: 'R\$',
        decimalDigits: 2,
      );
      
      // Formatador de data
      final dateFormatter = DateFormat('dd/MM/yyyy');
      
      // Adicionar página de capa
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'Relatório Financeiro',
                    style: pw.TextStyle(
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'Período: ${dateFormatter.format(startDate)} a ${dateFormatter.format(endDate)}',
                    style: const pw.TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  pw.SizedBox(height: 40),
                  pw.Text(
                    'Gerado em: ${dateFormatter.format(DateTime.now())}',
                    style: const pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
      
      // Adicionar página de resumo
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Text('Resumo Financeiro'),
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(10),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey300),
                          borderRadius: pw.BorderRadius.circular(5),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Entradas',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.green700,
                              ),
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              currencyFormatter.format(totalIncome),
                              style: const pw.TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 10),
                    pw.Expanded(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(10),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey300),
                          borderRadius: pw.BorderRadius.circular(5),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Saídas',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.red700,
                              ),
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              currencyFormatter.format(totalExpense),
                              style: const pw.TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 10),
                    pw.Expanded(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(10),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey300),
                          borderRadius: pw.BorderRadius.circular(5),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Saldo',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: balance >= 0 ? PdfColors.blue700 : PdfColors.red700,
                              ),
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              currencyFormatter.format(balance),
                              style: const pw.TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),
                pw.Header(
                  level: 1,
                  child: pw.Text('Despesas por Categoria'),
                ),
                pw.SizedBox(height: 10),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  children: [
                    // Cabeçalho da tabela
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey200,
                      ),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                            'Categoria',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                            'Valor',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                            'Percentual',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    // Linhas da tabela com dados
                    ...expensesByCategory.entries.map((entry) {
                      final category = categories.firstWhere(
                        (c) => c.id == entry.key,
                        orElse: () => Category(
                          name: 'Desconhecida',
                          icon: 'question',
                          color: '#607D8B',
                          isExpense: true,
                        ),
                      );
                      
                      final percentage = totalExpense > 0
                          ? (entry.value / totalExpense) * 100
                          : 0.0;
                      
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(category.name),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(
                              currencyFormatter.format(entry.value),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(
                              '${percentage.toStringAsFixed(1)}%',
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
                pw.SizedBox(height: 30),
                pw.Header(
                  level: 1,
                  child: pw.Text('Metas de Economia'),
                ),
                pw.SizedBox(height: 10),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  children: [
                    // Cabeçalho da tabela
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey200,
                      ),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                            'Meta',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                            'Valor Atual',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                            'Valor Alvo',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                            'Progresso',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    // Linhas da tabela com dados
                    ...savingsGoals.map((goal) {
                      final progress = (goal.currentAmount / goal.targetAmount) * 100;
                      
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(goal.title),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(
                              currencyFormatter.format(goal.currentAmount),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(
                              currencyFormatter.format(goal.targetAmount),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(
                              '${progress.toStringAsFixed(1)}%',
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ],
            );
          },
        ),
      );
      
      // Adicionar página de transações
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Text('Transações'),
                ),
                pw.SizedBox(height: 20),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  children: [
                    // Cabeçalho da tabela
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey200,
                      ),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                            'Data',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                            'Descrição',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                            'Categoria',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                            'Valor',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    // Linhas da tabela com dados
                    ...transactions.map((transaction) {
                      final category = categories.firstWhere(
                        (c) => c.id == transaction.categoryId,
                        orElse: () => Category(
                          name: 'Desconhecida',
                          icon: 'question',
                          color: '#607D8B',
                          isExpense: transaction.isExpense,
                        ),
                      );
                      
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(dateFormatter.format(transaction.date)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(transaction.description),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(category.name),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(
                              currencyFormatter.format(transaction.amount),
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(
                                color: transaction.isExpense
                                    ? PdfColors.red700
                                    : PdfColors.green700,
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ],
            );
          },
        ),
      );
      
      // Salvar o PDF
      final directory = await getApplicationDocumentsDirectory();
      final reportsDir = Directory('${directory.path}/reports');
      
      // Criar diretório de relatórios se não existir
      if (!await reportsDir.exists()) {
        await reportsDir.create(recursive: true);
      }
      
      // Nome do arquivo com data e hora
      final now = DateTime.now();
      final fileName = 'relatorio_financeiro_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}.pdf';
      final file = File('${reportsDir.path}/$fileName');
      
      await file.writeAsBytes(await pdf.save());
      
      return file.path;
    } catch (e) {
      throw Exception('Erro ao exportar relatório em PDF: $e');
    }
  }
  
  // Exportar relatório financeiro em Excel
  Future<String> exportFinancialReportExcel(DateTime startDate, DateTime endDate) async {
    try {
      // Obter dados para o relatório
      final transactions = await _getTransactionsForPeriod(startDate, endDate);
      final categories = await DatabaseHelper.instance.getAllCategories();
      final savingsGoals = await DatabaseHelper.instance.getAllSavingsGoals();
      
      // Calcular totais
      final totalIncome = transactions
          .where((t) => !t.isExpense)
          .fold(0.0, (sum, t) => sum + t.amount);
      
      final totalExpense = transactions
          .where((t) => t.isExpense)
          .fold(0.0, (sum, t) => sum + t.amount);
      
      final balance = totalIncome - totalExpense;
      
      // Agrupar despesas por categoria
      final expensesByCategory = <int, double>{};
      for (var transaction in transactions.where((t) => t.isExpense)) {
        expensesByCategory[transaction.categoryId] = 
            (expensesByCategory[transaction.categoryId] ?? 0.0) + transaction.amount;
      }
      
      // Criar planilha Excel
      final excel = Excel.createExcel();
      
      // Formatador de data
      final dateFormatter = DateFormat('dd/MM/yyyy');
      
      // Remover planilha padrão
      excel.delete('Sheet1');
      
      // Adicionar planilha de resumo
      final resumoSheet = excel['Resumo'];
      
      // Título
      resumoSheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('C1'));
      resumoSheet.cell(CellIndex.indexByString('A1')).value = 'Relatório Financeiro';
      resumoSheet.cell(CellIndex.indexByString('A1')).cellStyle = CellStyle(
        bold: true,
        fontSize: 16,
      );
      
      // Período
      resumoSheet.merge(CellIndex.indexByString('A2'), CellIndex.indexByString('C2'));
      resumoSheet.cell(CellIndex.indexByString('A2')).value = 
          'Período: ${dateFormatter.format(startDate)} a ${dateFormatter.format(endDate)}';
      
      // Data de geração
      resumoSheet.merge(CellIndex.indexByString('A3'), CellIndex.indexByString('C3'));
      resumoSheet.cell(CellIndex.indexByString('A3')).value = 
          'Gerado em: ${dateFormatter.format(DateTime.now())}';
      
      // Espaço
      resumoSheet.cell(CellIndex.indexByString('A4')).value = '';
      
      // Resumo financeiro
      resumoSheet.cell(CellIndex.indexByString('A5')).value = 'Resumo Financeiro';
      resumoSheet.cell(CellIndex.indexByString('A5')).cellStyle = CellStyle(
        bold: true,
        fontSize: 14,
      );
      
      resumoSheet.cell(CellIndex.indexByString('A6')).value = 'Entradas';
      resumoSheet.cell(CellIndex.indexByString('B6')).value = totalIncome;
      resumoSheet.cell(CellIndex.indexByString('B6')).cellStyle = CellStyle(
        numberFormat: '[$R$-pt-BR] #,##0.00',
      );
      
      resumoSheet.cell(CellIndex.indexByString('A7')).value = 'Saídas';
      resumoSheet.cell(CellIndex.indexByString('B7')).value = totalExpense;
      resumoSheet.cell(CellIndex.indexByString('B7')).cellStyle = CellStyle(
        numberFormat: '[$R$-pt-BR] #,##0.00',
      );
      
      resumoSheet.cell(CellIndex.indexByString('A8')).value = 'Saldo';
      resumoSheet.cell(CellIndex.indexByString('B8')).value = balance;
      resumoSheet.cell(CellIndex.indexByString('B8')).cellStyle = CellStyle(
        numberFormat: '[$R$-pt-BR] #,##0.00',
        fontColorHex: balance >= 0 ? '0000FF' : 'FF0000',
        bold: true,
      );
      
      // Espaço
      resumoSheet.cell(CellIndex.indexByString('A9')).value = '';
      
      // Despesas por categoria
      resumoSheet.cell(CellIndex.indexByString('A10')).value = 'Despesas por Categoria';
      resumoSheet.cell(CellIndex.indexByString('A10')).cellStyle = CellStyle(
        bold: true,
        fontSize: 14,
      );
      
      // Cabeçalho da tabela
      resumoSheet.cell(CellIndex.indexByString('A11')).value = 'Categoria';
      resumoSheet.cell(CellIndex.indexByString('B11')).value = 'Valor';
      resumoSheet.cell(CellIndex.indexByString('C11')).value = 'Percentual';
      
      resumoSheet.cell(CellIndex.indexByString('A11')).cellStyle = CellStyle(bold: true);
      resumoSheet.cell(CellIndex.indexByString('B11')).cellStyle = CellStyle(bold: true);
      resumoSheet.cell(CellIndex.indexByString('C11')).cellStyle = CellStyle(bold: true);
      
      // Dados da tabela
      var row = 12;
      for (var entry in expensesByCategory.entries) {
        final category = categories.firstWhere(
          (c) => c.id == entry.key,
          orElse: () => Category(
            name: 'Desconhecida',
            icon: 'question',
            color: '#607D8B',
            isExpense: true,
          ),
        );
        
        final percentage = totalExpense > 0
            ? (entry.value / totalExpense) * 100
            : 0.0;
        
        resumoSheet.cell(CellIndex.indexByString('A$row')).value = category.name;
        resumoSheet.cell(CellIndex.indexByString('B$row')).value = entry.value;
        resumoSheet.cell(CellIndex.indexByString('B$row')).cellStyle = CellStyle(
          numberFormat: '[$R$-pt-BR] #,##0.00',
        );
        resumoSheet.cell(CellIndex.indexByString('C$row')).value = '${percentage.toStringAsFixed(1)}%';
        
        row++;
      }
      
      // Adicionar planilha de transações
      final transacoesSheet = excel['Transações'];
      
      // Cabeçalho da tabela
      transacoesSheet.cell(CellIndex.indexByString('A1')).value = 'Data';
      transacoesSheet.cell(CellIndex.indexByString('B1')).value = 'Descrição';
      transacoesSheet.cell(CellIndex.indexByString('C1')).value = 'Categoria';
      transacoesSheet.cell(CellIndex.indexByString('D1')).value = 'Tipo';
      transacoesSheet.cell(CellIndex.indexByString('E1')).value = 'Valor';
      
      transacoesSheet.cell(CellIndex.indexByString('A1')).cellStyle = CellStyle(bold: true);
      transacoesSheet.cell(CellIndex.indexByString('B1')).cellStyle = CellStyle(bold: true);
      transacoesSheet.cell(CellIndex.indexByString('C1')).cellStyle = CellStyle(bold: true);
      transacoesSheet.cell(CellIndex.indexByString('D1')).cellStyle = CellStyle(bold: true);
      transacoesSheet.cell(CellIndex.indexByString('E1')).cellStyle = CellStyle(bold: true);
      
      // Dados da tabela
      row = 2;
      for (var transaction in transactions) {
        final category = categories.firstWhere(
          (c) => c.id == transaction.categoryId,
          orElse: () => Category(
            name: 'Desconhecida',
            icon: 'question',
            color: '#607D8B',
            isExpense: transaction.isExpense,
          ),
        );
        
        transacoesSheet.cell(CellIndex.indexByString('A$row')).value = dateFormatter.format(transaction.date);
        transacoesSheet.cell(CellIndex.indexByString('B$row')).value = transaction.description;
        transacoesSheet.cell(CellIndex.indexByString('C$row')).value = category.name;
        transacoesSheet.cell(CellIndex.indexByString('D$row')).value = transaction.isExpense ? 'Despesa' : 'Receita';
        transacoesSheet.cell(CellIndex.indexByString('E$row')).value = transaction.amount;
        transacoesSheet.cell(CellIndex.indexByString('E$row')).cellStyle = CellStyle(
          numberFormat: '[$R$-pt-BR] #,##0.00',
          fontColorHex: transaction.isExpense ? 'FF0000' : '008000',
        );
        
        row++;
      }
      
      // Adicionar planilha de metas
      final metasSheet = excel['Metas'];
      
      // Cabeçalho da tabela
      metasSheet.cell(CellIndex.indexByString('A1')).value = 'Meta';
      metasSheet.cell(CellIndex.indexByString('B1')).value = 'Valor Atual';
      metasSheet.cell(CellIndex.indexByString('C1')).value = 'Valor Alvo';
      metasSheet.cell(CellIndex.indexByString('D1')).value = 'Progresso';
      metasSheet.cell(CellIndex.indexByString('E1')).value = 'Prazo';
      
      metasSheet.cell(CellIndex.indexByString('A1')).cellStyle = CellStyle(bold: true);
      metasSheet.cell(CellIndex.indexByString('B1')).cellStyle = CellStyle(bold: true);
      metasSheet.cell(CellIndex.indexByString('C1')).cellStyle = CellStyle(bold: true);
      metasSheet.cell(CellIndex.indexByString('D1')).cellStyle = CellStyle(bold: true);
      metasSheet.cell(CellIndex.indexByString('E1')).cellStyle = CellStyle(bold: true);
      
      // Dados da tabela
      row = 2;
      for (var goal in savingsGoals) {
        final progress = (goal.currentAmount / goal.targetAmount) * 100;
        
        metasSheet.cell(CellIndex.indexByString('A$row')).value = goal.title;
        metasSheet.cell(CellIndex.indexByString('B$row')).value = goal.currentAmount;
        metasSheet.cell(CellIndex.indexByString('B$row')).cellStyle = CellStyle(
          numberFormat: '[$R$-pt-BR] #,##0.00',
        );
        metasSheet.cell(CellIndex.indexByString('C$row')).value = goal.targetAmount;
        metasSheet.cell(CellIndex.indexByString('C$row')).cellStyle = CellStyle(
          numberFormat: '[$R$-pt-BR] #,##0.00',
        );
        metasSheet.cell(CellIndex.indexByString('D$row')).value = '${progress.toStringAsFixed(1)}%';
        metasSheet.cell(CellIndex.indexByString('E$row')).value = goal.deadline != null
            ? dateFormatter.format(goal.deadline!)
            : 'Contínua';
        
        row++;
      }
      
      // Ajustar largura das colunas
      resumoSheet.setColumnWidth(0, 20);
      resumoSheet.setColumnWidth(1, 15);
      resumoSheet.setColumnWidth(2, 15);
      
      transacoesSheet.setColumnWidth(0, 15);
      transacoesSheet.setColumnWidth(1, 30);
      transacoesSheet.setColumnWidth(2, 20);
      transacoesSheet.setColumnWidth(3, 15);
      transacoesSheet.setColumnWidth(4, 15);
      
      metasSheet.setColumnWidth(0, 30);
      metasSheet.setColumnWidth(1, 15);
      metasSheet.setColumnWidth(2, 15);
      metasSheet.setColumnWidth(3, 15);
      metasSheet.setColumnWidth(4, 15);
      
      // Salvar o Excel
      final directory = await getApplicationDocumentsDirectory();
      final reportsDir = Directory('${directory.path}/reports');
      
      // Criar diretório de relatórios se não existir
      if (!await reportsDir.exists()) {
        await reportsDir.create(recursive: true);
      }
      
      // Nome do arquivo com data e hora
      final now = DateTime.now();
      final fileName = 'relatorio_financeiro_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}.xlsx';
      final file = File('${reportsDir.path}/$fileName');
      
      await file.writeAsBytes(excel.encode()!);
      
      return file.path;
    } catch (e) {
      throw Exception('Erro ao exportar relatório em Excel: $e');
    }
  }
  
  // Obter transações para um período específico
  Future<List<Transaction>> _getTransactionsForPeriod(DateTime startDate, DateTime endDate) async {
    try {
      final db = await DatabaseHelper.instance.database;
      
      final result = await db.query(
        'transactions',
        where: 'date BETWEEN ? AND ?',
        whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
        orderBy: 'date DESC',
      );
      
      return result.map((map) => Transaction.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Erro ao obter transações: $e');
    }
  }
}
