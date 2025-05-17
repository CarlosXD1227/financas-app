import 'package:flutter/material.dart';
import 'package:financas_app/services/database_helper.dart';
import 'package:financas_app/utils/constants.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class ChartService {
  // Método para obter dados de despesas por categoria para o gráfico de pizza
  static Future<List<PieChartSectionData>> getExpensesByCategoryChart() async {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    
    final expensesByCategory = await DatabaseHelper.instance.getExpensesByCategory(
      firstDayOfMonth, 
      lastDayOfMonth
    );
    
    // Calcular o total de despesas
    double totalExpenses = 0;
    expensesByCategory.forEach((_, value) {
      totalExpenses += value;
    });
    
    // Criar seções do gráfico de pizza
    final List<PieChartSectionData> sections = [];
    
    // Mapeamento de cores para categorias
    final Map<String, Color> categoryColors = {
      'Alimentação': Colors.orange,
      'Moradia': Colors.blue,
      'Transporte': Colors.green,
      'Saúde': Colors.red,
      'Lazer': Colors.purple,
      'Educação': Colors.amber,
      'Compras': Colors.teal,
      'Contas': Colors.indigo,
      'Outros': Colors.grey,
    };
    
    // Criar seções para cada categoria
    expensesByCategory.forEach((category, amount) {
      final percentage = (amount / totalExpenses) * 100;
      final color = categoryColors[category] ?? Colors.grey;
      
      sections.add(
        PieChartSectionData(
          color: color,
          value: amount,
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    });
    
    return sections;
  }
  
  // Método para obter dados de fluxo de caixa para o gráfico de linha
  static Future<List<LineChartBarData>> getCashFlowChart() async {
    final now = DateTime.now();
    final sixMonthsAgo = DateTime(now.year, now.month - 5, 1);
    
    // Lista de meses para análise
    final List<DateTime> months = [];
    for (int i = 0; i < 6; i++) {
      months.add(DateTime(sixMonthsAgo.year, sixMonthsAgo.month + i, 1));
    }
    
    // Listas para armazenar valores de entradas e saídas
    final List<FlSpot> incomeSpots = [];
    final List<FlSpot> expenseSpots = [];
    
    // Para cada mês, obter o total de entradas e saídas
    for (int i = 0; i < months.length; i++) {
      final startOfMonth = months[i];
      final endOfMonth = DateTime(startOfMonth.year, startOfMonth.month + 1, 0);
      
      final income = await DatabaseHelper.instance.getTotalIncome(startOfMonth, endOfMonth);
      final expense = await DatabaseHelper.instance.getTotalExpense(startOfMonth, endOfMonth);
      
      incomeSpots.add(FlSpot(i.toDouble(), income));
      expenseSpots.add(FlSpot(i.toDouble(), expense));
    }
    
    // Criar barras de dados para o gráfico de linha
    return [
      LineChartBarData(
        spots: incomeSpots,
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
        spots: expenseSpots,
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
    ];
  }
  
  // Método para obter dados de evolução das economias para o gráfico de linha
  static Future<LineChartBarData> getSavingsEvolutionChart() async {
    final now = DateTime.now();
    final sixMonthsAgo = DateTime(now.year, now.month - 5, 1);
    
    // Lista de meses para análise
    final List<DateTime> months = [];
    for (int i = 0; i < 6; i++) {
      months.add(DateTime(sixMonthsAgo.year, sixMonthsAgo.month + i, 1));
    }
    
    // Lista para armazenar valores de economias acumuladas
    final List<FlSpot> savingsSpots = [];
    
    // Valores simulados para demonstração
    // Em um app real, isso seria calculado com base no histórico de economias
    double accumulatedSavings = 10000.0;
    
    // Para cada mês, calcular o total de economias
    for (int i = 0; i < months.length; i++) {
      // Simulação de crescimento mensal
      if (i > 0) {
        accumulatedSavings += 1500.0 + (i * 200.0);
      }
      
      savingsSpots.add(FlSpot(i.toDouble(), accumulatedSavings));
    }
    
    // Criar barra de dados para o gráfico de linha
    return LineChartBarData(
      spots: savingsSpots,
      isCurved: true,
      color: AppColors.saving,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(show: true),
      belowBarData: BarAreaData(
        show: true,
        color: AppColors.saving.withOpacity(0.3),
      ),
    );
  }
  
  // Método para obter dados de comparação de categorias para o gráfico de barras
  static Future<BarChartGroupData> getCategoryComparisonChart(int categoryIndex, String categoryName) async {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    final lastMonth = DateTime(now.year, now.month - 1, 1);
    
    final currentMonthEnd = DateTime(now.year, now.month + 1, 0);
    final lastMonthEnd = DateTime(now.year, now.month, 0);
    
    // Obter despesas por categoria para o mês atual e o mês anterior
    final currentMonthExpenses = await DatabaseHelper.instance.getExpensesByCategory(
      currentMonth, 
      currentMonthEnd
    );
    
    final lastMonthExpenses = await DatabaseHelper.instance.getExpensesByCategory(
      lastMonth, 
      lastMonthEnd
    );
    
    // Obter valores para a categoria específica
    final currentMonthValue = currentMonthExpenses[categoryName] ?? 0.0;
    final lastMonthValue = lastMonthExpenses[categoryName] ?? 0.0;
    
    // Criar grupo de barras para o gráfico
    return BarChartGroupData(
      x: categoryIndex,
      barRods: [
        BarChartRodData(
          toY: currentMonthValue,
          color: Colors.blue,
          width: 15,
          borderRadius: BorderRadius.circular(4),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: lastMonthValue > currentMonthValue ? lastMonthValue : currentMonthValue * 1.2,
            color: Colors.blue.withOpacity(0.3),
          ),
        ),
      ],
    );
  }
  
  // Método para obter títulos dos meses para os gráficos
  static SideTitleWidget getMonthTitleWidget(double value, TitleMeta meta) {
    final now = DateTime.now();
    final sixMonthsAgo = DateTime(now.year, now.month - 5, 1);
    
    final month = DateTime(sixMonthsAgo.year, sixMonthsAgo.month + value.toInt(), 1);
    final monthName = DateFormat('MMM').format(month).toUpperCase();
    
    const style = TextStyle(
      color: Color(0xff68737d),
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8.0,
      child: Text(monthName, style: style),
    );
  }
  
  // Método para obter títulos de valores para os gráficos
  static SideTitleWidget getValueTitleWidget(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff67727d),
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    
    final formatter = NumberFormat.compactCurrency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );
    
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8.0,
      child: Text(formatter.format(value), style: style),
    );
  }
}
