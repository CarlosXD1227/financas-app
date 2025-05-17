import 'package:flutter/material.dart';
import 'package:financas_app/utils/constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'Mensal';
  final List<String> _periods = ['Semanal', 'Mensal', 'Anual'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Resumo'),
            Tab(text: 'Categorias'),
            Tab(text: 'Economias'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.calendar_today),
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
            },
            itemBuilder: (context) {
              return _periods.map((period) {
                return PopupMenuItem<String>(
                  value: period,
                  child: Text(period),
                );
              }).toList();
            },
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () {
              _showExportDialog(context);
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSummaryTab(),
          _buildCategoriesTab(),
          _buildSavingsTab(),
        ],
      ),
    );
  }

  Widget _buildSummaryTab() {
    // Formatador de moeda para Real brasileiro
    final currencyFormatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Período selecionado
          Card(
            margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Período: $_selectedPeriod',
                    style: AppTextStyles.subheading,
                  ),
                  Text(
                    _selectedPeriod == 'Mensal'
                        ? 'Maio 2025'
                        : _selectedPeriod == 'Semanal'
                            ? '10 - 17 Maio 2025'
                            : '2025',
                    style: AppTextStyles.body,
                  ),
                ],
              ),
            ),
          ),

          // Resumo financeiro
          Card(
            margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resumo Financeiro',
                    style: AppTextStyles.subheading,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildFinanceSummaryItem(
                        'Entradas',
                        currencyFormatter.format(3800.00),
                        Icons.arrow_upward,
                        AppColors.income,
                      ),
                      _buildFinanceSummaryItem(
                        'Saídas',
                        currencyFormatter.format(1299.25),
                        Icons.arrow_downward,
                        AppColors.expense,
                      ),
                      _buildFinanceSummaryItem(
                        'Saldo',
                        currencyFormatter.format(2500.75),
                        Icons.account_balance_wallet,
                        AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Gráfico de fluxo de caixa
          Card(
            margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fluxo de Caixa',
                    style: AppTextStyles.subheading,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      _createLineChartData(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Economias
          Card(
            margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Economias',
                    style: AppTextStyles.subheading,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildEconomySummaryItem(
                        'Total Economizado',
                        currencyFormatter.format(19200.00),
                        AppColors.saving,
                      ),
                      _buildEconomySummaryItem(
                        'Meta Mensal',
                        currencyFormatter.format(2000.00),
                        AppColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Progresso Mensal',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: 0.75,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.saving),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '75% da meta mensal atingida',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab() {
    // Formatador de moeda para Real brasileiro
    final currencyFormatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gráfico de pizza de despesas por categoria
          Card(
            margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Despesas por Categoria',
                    style: AppTextStyles.subheading,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      _createPieChartData(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryLegend(
                    'Alimentação',
                    Colors.orange,
                    '26.2%',
                    currencyFormatter.format(340.65),
                  ),
                  _buildCategoryLegend(
                    'Moradia',
                    Colors.blue,
                    '11.2%',
                    currencyFormatter.format(145.30),
                  ),
                  _buildCategoryLegend(
                    'Transporte',
                    Colors.green,
                    '9.2%',
                    currencyFormatter.format(120.00),
                  ),
                  _buildCategoryLegend(
                    'Saúde',
                    Colors.red,
                    '7.7%',
                    currencyFormatter.format(99.90),
                  ),
                  _buildCategoryLegend(
                    'Lazer',
                    Colors.purple,
                    '5.8%',
                    currencyFormatter.format(75.00),
                  ),
                  _buildCategoryLegend(
                    'Outros',
                    Colors.grey,
                    '39.9%',
                    currencyFormatter.format(518.40),
                  ),
                ],
              ),
            ),
          ),

          // Comparação com mês anterior
          Card(
            margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Comparação com Mês Anterior',
                    style: AppTextStyles.subheading,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      _createBarChartData(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsTab() {
    // Formatador de moeda para Real brasileiro
    final currencyFormatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Evolução das economias
          Card(
            margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Evolução das Economias',
                    style: AppTextStyles.subheading,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      _createSavingsLineChartData(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Progresso das metas
          Card(
            margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Progresso das Metas',
                    style: AppTextStyles.subheading,
                  ),
                  const SizedBox(height: 16),
                  _buildSavingsGoalProgress(
                    'Viagem de férias',
                    5000.00,
                    3500.00,
                    0.7,
                    Colors.blue,
                    currencyFormatter,
                  ),
                  const SizedBox(height: 16),
                  _buildSavingsGoalProgress(
                    'Novo notebook',
                    4000.00,
                    1200.00,
                    0.3,
                    Colors.purple,
                    currencyFormatter,
                  ),
                  const SizedBox(height: 16),
                  _buildSavingsGoalProgress(
                    'Fundo de emergência',
                    10000.00,
                    6500.00,
                    0.65,
                    Colors.red,
                    currencyFormatter,
                  ),
                  const SizedBox(height: 16),
                  _buildSavingsGoalProgress(
                    'Entrada do apartamento',
                    20000.00,
                    8000.00,
                    0.4,
                    Colors.green,
                    currencyFormatter,
                  ),
                ],
              ),
            ),
          ),

          // Distribuição das economias
          Card(
            margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Distribuição das Economias',
                    style: AppTextStyles.subheading,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      _createSavingsPieChartData(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceSummaryItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildEconomySummaryItem(
    String title,
    String value,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryLegend(
    String category,
    Color color,
    String percentage,
    String amount,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              category,
              style: AppTextStyles.body,
            ),
          ),
          Text(
            percentage,
            style: AppTextStyles.caption,
          ),
          const SizedBox(width: 16),
          Text(
            amount,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsGoalProgress(
    String title,
    double target,
    double current,
    double progress,
    Color color,
    NumberFormat formatter,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.body,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              formatter.format(current),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              formatter.format(target),
              style: AppTextStyles.body,
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 4),
        Text(
          '${(progress * 100).toInt()}% concluído',
          style: AppTextStyles.caption,
        ),
      ],
    );
  }

  LineChartData _createLineChartData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1000,
        verticalInterval: 1,
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              const style = TextStyle(
                color: Color(0xff68737d),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              );
              String text;
              switch (value.toInt()) {
                case 0:
                  text = 'JAN';
                  break;
                case 1:
                  text = 'FEV';
                  break;
                case 2:
                  text = 'MAR';
                  break;
                case 3:
                  text = 'ABR';
                  break;
                case 4:
                  text = 'MAI';
                  break;
                default:
                  return Container();
              }
              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 8.0,
                child: Text(text, style: style),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1000,
            getTitlesWidget: (value, meta) {
              const style = TextStyle(
                color: Color(0xff67727d),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              );
              String text = 'R\$${value.toInt()}';
              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 8.0,
                child: Text(text, style: style),
              );
            },
            reservedSize: 40,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d), width: 1),
      ),
      minX: 0,
      maxX: 4,
      minY: 0,
      maxY: 5000,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 3000),
            FlSpot(1, 2500),
            FlSpot(2, 3200),
            FlSpot(3, 2800),
            FlSpot(4, 3800),
          ],
          isCurved: true,
          color: AppColors.income,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.income.withOpacity(0.3),
          ),
        ),
        LineChartBarData(
          spots: const [
            FlSpot(0, 1800),
            FlSpot(1, 1900),
            FlSpot(2, 1700),
            FlSpot(3, 1500),
            FlSpot(4, 1300),
          ],
          isCurved: true,
          color: AppColors.expense,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.expense.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  PieChartData _createPieChartData() {
    return PieChartData(
      sections: [
        PieChartSectionData(
          color: Colors.orange,
          value: 26.2,
          title: '26.2%',
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        PieChartSectionData(
          color: Colors.blue,
          value: 11.2,
          title: '11.2%',
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        PieChartSectionData(
          color: Colors.green,
          value: 9.2,
          title: '9.2%',
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        PieChartSectionData(
          color: Colors.red,
          value: 7.7,
          title: '7.7%',
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        PieChartSectionData(
          color: Colors.purple,
          value: 5.8,
          title: '5.8%',
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        PieChartSectionData(
          color: Colors.grey,
          value: 39.9,
          title: '39.9%',
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
      sectionsSpace: 2,
      centerSpaceRadius: 40,
    );
  }

  BarChartData _createBarChartData() {
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: 400,
      barTouchData: BarTouchData(
        enabled: false,
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (double value, TitleMeta meta) {
              const style = TextStyle(
                color: Color(0xff68737d),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              );
              String text;
              switch (value.toInt()) {
                case 0:
                  text = 'Alim.';
                  break;
                case 1:
                  text = 'Mor.';
                  break;
                case 2:
                  text = 'Trans.';
                  break;
                case 3:
                  text = 'Saúde';
                  break;
                case 4:
                  text = 'Lazer';
                  break;
                default:
                  text = '';
                  break;
              }
              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 8.0,
                child: Text(text, style: style),
              );
            },
            reservedSize: 30,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: 100,
            getTitlesWidget: (value, meta) {
              const style = TextStyle(
                color: Color(0xff67727d),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              );
              String text = 'R\$${value.toInt()}';
              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 8.0,
                child: Text(text, style: style),
              );
            },
          ),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      gridData: FlGridData(
        show: true,
        checkToShowHorizontalLine: (value) => value % 100 == 0,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xffe7e8ec),
            strokeWidth: 1,
          );
        },
        drawVerticalLine: false,
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d), width: 1),
      ),
      barGroups: [
        BarChartGroupData(
          x: 0,
          barRods: [
            BarChartRodData(
              toY: 340.65,
              color: Colors.orange,
              width: 15,
              borderRadius: BorderRadius.circular(4),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: 380.50,
                color: Colors.orange.withOpacity(0.3),
              ),
            ),
          ],
        ),
        BarChartGroupData(
          x: 1,
          barRods: [
            BarChartRodData(
              toY: 145.30,
              color: Colors.blue,
              width: 15,
              borderRadius: BorderRadius.circular(4),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: 150.00,
                color: Colors.blue.withOpacity(0.3),
              ),
            ),
          ],
        ),
        BarChartGroupData(
          x: 2,
          barRods: [
            BarChartRodData(
              toY: 120.00,
              color: Colors.green,
              width: 15,
              borderRadius: BorderRadius.circular(4),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: 180.00,
                color: Colors.green.withOpacity(0.3),
              ),
            ),
          ],
        ),
        BarChartGroupData(
          x: 3,
          barRods: [
            BarChartRodData(
              toY: 99.90,
              color: Colors.red,
              width: 15,
              borderRadius: BorderRadius.circular(4),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: 120.00,
                color: Colors.red.withOpacity(0.3),
              ),
            ),
          ],
        ),
        BarChartGroupData(
          x: 4,
          barRods: [
            BarChartRodData(
              toY: 75.00,
              color: Colors.purple,
              width: 15,
              borderRadius: BorderRadius.circular(4),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: 95.00,
                color: Colors.purple.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ],
    );
  }

  LineChartData _createSavingsLineChartData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 5000,
        verticalInterval: 1,
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              const style = TextStyle(
                color: Color(0xff68737d),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              );
              String text;
              switch (value.toInt()) {
                case 0:
                  text = 'JAN';
                  break;
                case 1:
                  text = 'FEV';
                  break;
                case 2:
                  text = 'MAR';
                  break;
                case 3:
                  text = 'ABR';
                  break;
                case 4:
                  text = 'MAI';
                  break;
                default:
                  return Container();
              }
              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 8.0,
                child: Text(text, style: style),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 5000,
            getTitlesWidget: (value, meta) {
              const style = TextStyle(
                color: Color(0xff67727d),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              );
              String text = 'R\$${value.toInt()}';
              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 8.0,
                child: Text(text, style: style),
              );
            },
            reservedSize: 40,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d), width: 1),
      ),
      minX: 0,
      maxX: 4,
      minY: 0,
      maxY: 20000,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 10000),
            FlSpot(1, 12500),
            FlSpot(2, 15000),
            FlSpot(3, 17500),
            FlSpot(4, 19200),
          ],
          isCurved: true,
          color: AppColors.saving,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.saving.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  PieChartData _createSavingsPieChartData() {
    return PieChartData(
      sections: [
        PieChartSectionData(
          color: Colors.blue,
          value: 3500,
          title: '18%',
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        PieChartSectionData(
          color: Colors.purple,
          value: 1200,
          title: '6%',
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        PieChartSectionData(
          color: Colors.red,
          value: 6500,
          title: '34%',
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        PieChartSectionData(
          color: Colors.green,
          value: 8000,
          title: '42%',
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
      sectionsSpace: 2,
      centerSpaceRadius: 40,
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Exportar Relatório'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: const Text('Exportar como PDF'),
                onTap: () {
                  Navigator.pop(context);
                  // Implementar exportação para PDF
                },
              ),
              ListTile(
                leading: const Icon(Icons.table_chart),
                title: const Text('Exportar como Excel'),
                onTap: () {
                  Navigator.pop(context);
                  // Implementar exportação para Excel
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }
}
