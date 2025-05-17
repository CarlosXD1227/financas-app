import 'package:flutter/material.dart';
import 'package:financas_app/utils/constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  @override
  Widget build(BuildContext context) {
    // Formatador de moeda para Real brasileiro
    final currencyFormatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );

    // Lista de metas de economia de exemplo
    final savingsGoals = [
      {
        'title': 'Viagem de férias',
        'icon': FontAwesomeIcons.plane,
        'color': Colors.blue,
        'target': 5000.00,
        'current': 3500.00,
        'progress': 0.7,
        'deadline': '31/12/2025',
      },
      {
        'title': 'Novo notebook',
        'icon': FontAwesomeIcons.laptop,
        'color': Colors.purple,
        'target': 4000.00,
        'current': 1200.00,
        'progress': 0.3,
        'deadline': '30/09/2025',
      },
      {
        'title': 'Fundo de emergência',
        'icon': FontAwesomeIcons.shieldHalved,
        'color': Colors.red,
        'target': 10000.00,
        'current': 6500.00,
        'progress': 0.65,
        'deadline': 'Contínuo',
      },
      {
        'title': 'Entrada do apartamento',
        'icon': FontAwesomeIcons.house,
        'color': Colors.green,
        'target': 20000.00,
        'current': 8000.00,
        'progress': 0.4,
        'deadline': '31/12/2026',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Economias'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_chart),
            onPressed: () {
              // Implementar visualização de estatísticas
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Resumo de economias
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            color: AppColors.primary,
            child: Column(
              children: [
                const Text(
                  'Total Economizado',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currencyFormatter.format(19200.00),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSavingSummaryItem(
                      'Este mês',
                      currencyFormatter.format(1500.00),
                    ),
                    _buildSavingSummaryItem(
                      'Meta mensal',
                      currencyFormatter.format(2000.00),
                    ),
                    _buildSavingSummaryItem(
                      'Progresso',
                      '75%',
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Lista de metas de economia
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              itemCount: savingsGoals.length,
              itemBuilder: (context, index) {
                final goal = savingsGoals[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.paddingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: (goal['color'] as Color).withOpacity(0.2),
                              child: FaIcon(
                                goal['icon'] as IconData,
                                color: goal['color'] as Color,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    goal['title'] as String,
                                    style: AppTextStyles.subheading,
                                  ),
                                  Text(
                                    'Prazo: ${goal['deadline']}',
                                    style: AppTextStyles.caption,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.more_vert),
                              onPressed: () {
                                // Implementar menu de opções
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              currencyFormatter.format(goal['current']),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.saving,
                              ),
                            ),
                            Text(
                              currencyFormatter.format(goal['target']),
                              style: AppTextStyles.body,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: goal['progress'] as double,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            goal['color'] as Color,
                          ),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${(goal['progress'] as double * 100).toInt()}%',
                              style: AppTextStyles.caption,
                            ),
                            Text(
                              'Faltam: ${currencyFormatter.format((goal['target'] as double) - (goal['current'] as double))}',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildActionButton(
                              'Adicionar',
                              Icons.add,
                              AppColors.income,
                              () {
                                // Implementar adição de valor à meta
                              },
                            ),
                            _buildActionButton(
                              'Histórico',
                              Icons.history,
                              AppColors.primary,
                              () {
                                // Implementar visualização de histórico
                              },
                            ),
                            _buildActionButton(
                              'Editar',
                              Icons.edit,
                              Colors.grey,
                              () {
                                // Implementar edição de meta
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Implementar adição de nova meta
        },
        icon: const Icon(Icons.add),
        label: const Text('Nova Meta'),
      ),
    );
  }

  Widget _buildSavingSummaryItem(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 16,
        color: color,
      ),
      label: Text(
        label,
        style: TextStyle(color: color),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        elevation: 0,
      ),
    );
  }
}
