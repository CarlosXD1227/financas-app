import 'package:flutter/material.dart';
import 'package:financas_app/utils/constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Formatador de moeda para Real brasileiro
    final currencyFormatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finanças Pessoais'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Implementar visualização de notificações
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Implementar tela de configurações
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cartão de saldo
            Card(
              margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Saldo Atual',
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currencyFormatter.format(2500.75),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildFinanceInfoItem(
                          context,
                          'Entradas',
                          currencyFormatter.format(3800.00),
                          Icons.arrow_upward,
                          AppColors.income,
                        ),
                        _buildFinanceInfoItem(
                          context,
                          'Saídas',
                          currencyFormatter.format(1299.25),
                          Icons.arrow_downward,
                          AppColors.expense,
                        ),
                      ],
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Economias',
                          style: AppTextStyles.subheading,
                        ),
                        TextButton(
                          onPressed: () {
                            // Navegar para a tela de economias
                          },
                          child: const Text('Ver mais'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildSavingsProgressBar(
                      context,
                      'Viagem de férias',
                      5000.00,
                      3500.00,
                      0.7,
                    ),
                    const SizedBox(height: 16),
                    _buildSavingsProgressBar(
                      context,
                      'Novo notebook',
                      4000.00,
                      1200.00,
                      0.3,
                    ),
                  ],
                ),
              ),
            ),

            // Últimas transações
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Últimas Transações',
                          style: AppTextStyles.subheading,
                        ),
                        TextButton(
                          onPressed: () {
                            // Navegar para a tela de transações
                          },
                          child: const Text('Ver todas'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildTransactionItem(
                      context,
                      'Supermercado',
                      'Alimentação',
                      '15/05/2025',
                      currencyFormatter.format(250.75),
                      FontAwesomeIcons.cartShopping,
                      AppColors.expense,
                      isExpense: true,
                    ),
                    const Divider(),
                    _buildTransactionItem(
                      context,
                      'Salário',
                      'Renda',
                      '10/05/2025',
                      currencyFormatter.format(3800.00),
                      FontAwesomeIcons.briefcase,
                      AppColors.income,
                      isExpense: false,
                    ),
                    const Divider(),
                    _buildTransactionItem(
                      context,
                      'Conta de luz',
                      'Moradia',
                      '08/05/2025',
                      currencyFormatter.format(145.30),
                      FontAwesomeIcons.bolt,
                      AppColors.expense,
                      isExpense: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinanceInfoItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              title,
              style: AppTextStyles.caption,
            ),
          ],
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

  Widget _buildSavingsProgressBar(
    BuildContext context,
    String title,
    double target,
    double current,
    double progress,
  ) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.body,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              currencyFormatter.format(current),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.saving,
              ),
            ),
            Text(
              ' / ${currencyFormatter.format(target)}',
              style: AppTextStyles.caption,
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.saving),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
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
    );
  }
}
