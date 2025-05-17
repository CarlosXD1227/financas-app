import 'package:flutter/material.dart';
import 'package:financas_app/utils/constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'Todos';
  final List<String> _filters = ['Todos', 'Entradas', 'Saídas'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: const Text('Transações'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Recentes'),
            Tab(text: 'Categorias'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) {
              return _filters.map((filter) {
                return PopupMenuItem<String>(
                  value: filter,
                  child: Text(filter),
                );
              }).toList();
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implementar busca de transações
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRecentTransactionsTab(),
          _buildCategoriesTab(),
        ],
      ),
    );
  }

  Widget _buildRecentTransactionsTab() {
    // Formatador de moeda para Real brasileiro
    final currencyFormatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );

    // Lista de transações de exemplo
    final transactions = [
      {
        'title': 'Supermercado',
        'category': 'Alimentação',
        'date': '15/05/2025',
        'amount': 250.75,
        'icon': FontAwesomeIcons.cartShopping,
        'color': AppColors.expense,
        'isExpense': true,
      },
      {
        'title': 'Salário',
        'category': 'Renda',
        'date': '10/05/2025',
        'amount': 3800.00,
        'icon': FontAwesomeIcons.briefcase,
        'color': AppColors.income,
        'isExpense': false,
      },
      {
        'title': 'Conta de luz',
        'category': 'Moradia',
        'date': '08/05/2025',
        'amount': 145.30,
        'icon': FontAwesomeIcons.bolt,
        'color': AppColors.expense,
        'isExpense': true,
      },
      {
        'title': 'Restaurante',
        'category': 'Alimentação',
        'date': '05/05/2025',
        'amount': 89.90,
        'icon': FontAwesomeIcons.utensils,
        'color': AppColors.expense,
        'isExpense': true,
      },
      {
        'title': 'Freelance',
        'category': 'Renda Extra',
        'date': '03/05/2025',
        'amount': 450.00,
        'icon': FontAwesomeIcons.laptop,
        'color': AppColors.income,
        'isExpense': false,
      },
      {
        'title': 'Transporte',
        'category': 'Transporte',
        'date': '02/05/2025',
        'amount': 120.00,
        'icon': FontAwesomeIcons.car,
        'color': AppColors.expense,
        'isExpense': true,
      },
      {
        'title': 'Academia',
        'category': 'Saúde',
        'date': '01/05/2025',
        'amount': 99.90,
        'icon': FontAwesomeIcons.dumbbell,
        'color': AppColors.expense,
        'isExpense': true,
      },
    ];

    // Filtrar transações com base no filtro selecionado
    final filteredTransactions = _selectedFilter == 'Todos'
        ? transactions
        : _selectedFilter == 'Entradas'
            ? transactions.where((t) => t['isExpense'] == false).toList()
            : transactions.where((t) => t['isExpense'] == true).toList();

    return filteredTransactions.isEmpty
        ? const Center(
            child: Text(
              'Nenhuma transação encontrada',
              style: AppTextStyles.body,
            ),
          )
        : ListView.separated(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            itemCount: filteredTransactions.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final transaction = filteredTransactions[index];
              return _buildTransactionItem(
                context,
                transaction['title'] as String,
                transaction['category'] as String,
                transaction['date'] as String,
                currencyFormatter.format(transaction['amount']),
                transaction['icon'] as IconData,
                transaction['color'] as Color,
                isExpense: transaction['isExpense'] as bool,
              );
            },
          );
  }

  Widget _buildCategoriesTab() {
    // Formatador de moeda para Real brasileiro
    final currencyFormatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );

    // Categorias de exemplo
    final categories = [
      {
        'name': 'Alimentação',
        'icon': FontAwesomeIcons.utensils,
        'color': Colors.orange,
        'amount': 340.65,
        'percentage': 26.2,
      },
      {
        'name': 'Moradia',
        'icon': FontAwesomeIcons.house,
        'color': Colors.blue,
        'amount': 145.30,
        'percentage': 11.2,
      },
      {
        'name': 'Transporte',
        'icon': FontAwesomeIcons.car,
        'color': Colors.green,
        'amount': 120.00,
        'percentage': 9.2,
      },
      {
        'name': 'Saúde',
        'icon': FontAwesomeIcons.heartPulse,
        'color': Colors.red,
        'amount': 99.90,
        'percentage': 7.7,
      },
      {
        'name': 'Lazer',
        'icon': FontAwesomeIcons.film,
        'color': Colors.purple,
        'amount': 75.00,
        'percentage': 5.8,
      },
      {
        'name': 'Outros',
        'icon': FontAwesomeIcons.ellipsis,
        'color': Colors.grey,
        'amount': 518.40,
        'percentage': 39.9,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: (category['color'] as Color).withOpacity(0.2),
                  child: FaIcon(
                    category['icon'] as IconData,
                    color: category['color'] as Color,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category['name'] as String,
                        style: AppTextStyles.body,
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: (category['percentage'] as double) / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          category['color'] as Color,
                        ),
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currencyFormatter.format(category['amount']),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.expense,
                      ),
                    ),
                    Text(
                      '${category['percentage']}%',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    String title,
    String category,
    String date,
    String amount,
    IconData icon,
    Color color,
    {required bool isExpense},
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: FaIcon(
          icon,
          color: color,
          size: 16,
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.body,
      ),
      subtitle: Text(
        '$category • $date',
        style: AppTextStyles.caption,
      ),
      trailing: Text(
        isExpense ? '- $amount' : '+ $amount',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      onTap: () {
        // Implementar visualização detalhada da transação
      },
    );
  }
}
