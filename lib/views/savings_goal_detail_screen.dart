import 'package:flutter/material.dart';
import 'package:financas_app/models/savings_goal.dart';
import 'package:financas_app/services/database_helper.dart';
import 'package:financas_app/utils/constants.dart';
import 'package:financas_app/views/savings_goal_form_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class SavingsGoalDetailScreen extends StatefulWidget {
  final SavingsGoal goal;

  const SavingsGoalDetailScreen({super.key, required this.goal});

  @override
  State<SavingsGoalDetailScreen> createState() => _SavingsGoalDetailScreenState();
}

class _SavingsGoalDetailScreenState extends State<SavingsGoalDetailScreen> {
  late SavingsGoal _goal;
  final _amountController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _goal = widget.goal;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _editGoal() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SavingsGoalFormScreen(savingsGoal: _goal),
      ),
    );

    if (result == true) {
      _refreshGoal();
    }
  }

  Future<void> _refreshGoal() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final goals = await DatabaseHelper.instance.getAllSavingsGoals();
      final updatedGoal = goals.firstWhere((g) => g.id == _goal.id);
      setState(() {
        _goal = updatedGoal;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar meta: $e')),
        );
      }
    }
  }

  Future<void> _showAddFundsDialog() async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Adicionar Fundos'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Quanto você deseja adicionar a esta meta?'),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  prefixText: 'R\$ ',
                  hintText: '0,00',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('CANCELAR'),
            ),
            TextButton(
              onPressed: () {
                _addFunds();
                Navigator.pop(context);
              },
              child: const Text('ADICIONAR'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addFunds() async {
    if (_amountController.text.isEmpty) return;

    try {
      final amount = double.parse(_amountController.text.replaceAll(',', '.'));
      if (amount <= 0) return;

      final newAmount = _goal.currentAmount + amount;
      final updatedGoal = _goal.copyWith(
        currentAmount: newAmount > _goal.targetAmount ? _goal.targetAmount : newAmount,
      );

      await DatabaseHelper.instance.updateSavingsGoal(updatedGoal);
      _amountController.clear();
      _refreshGoal();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fundos adicionados com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao adicionar fundos: $e')),
        );
      }
    }
  }

  Future<void> _showWithdrawFundsDialog() async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Retirar Fundos'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Quanto você deseja retirar desta meta?'),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  prefixText: 'R\$ ',
                  hintText: '0,00',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('CANCELAR'),
            ),
            TextButton(
              onPressed: () {
                _withdrawFunds();
                Navigator.pop(context);
              },
              child: const Text('RETIRAR'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _withdrawFunds() async {
    if (_amountController.text.isEmpty) return;

    try {
      final amount = double.parse(_amountController.text.replaceAll(',', '.'));
      if (amount <= 0 || amount > _goal.currentAmount) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Valor inválido ou maior que o saldo atual')),
          );
        }
        return;
      }

      final updatedGoal = _goal.copyWith(
        currentAmount: _goal.currentAmount - amount,
      );

      await DatabaseHelper.instance.updateSavingsGoal(updatedGoal);
      _amountController.clear();
      _refreshGoal();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fundos retirados com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao retirar fundos: $e')),
        );
      }
    }
  }

  Future<void> _deleteGoal() async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir Meta'),
          content: const Text('Tem certeza que deseja excluir esta meta? Esta ação não pode ser desfeita.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('CANCELAR'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await DatabaseHelper.instance.deleteSavingsGoal(_goal.id!);
                  if (mounted) {
                    Navigator.pop(context); // Fecha o diálogo
                    Navigator.pop(context, true); // Volta para a tela anterior
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao excluir meta: $e')),
                    );
                  }
                }
              },
              child: const Text('EXCLUIR'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Formatador de moeda para Real brasileiro
    final currencyFormatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );

    // Converter string de cor para Color
    final colorHex = _goal.color.replaceAll('#', '');
    final color = Color(int.parse('0xFF$colorHex'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Meta'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editGoal,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteGoal,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabeçalho da meta
                  Card(
                    margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.paddingMedium),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: color.withOpacity(0.2),
                                radius: 24,
                                child: FaIcon(
                                  _getIconData(_goal.icon),
                                  color: color,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _goal.title,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _goal.isContinuous
                                          ? 'Meta contínua'
                                          : 'Prazo: ${DateFormat('dd/MM/yyyy').format(_goal.deadline!)}',
                                      style: AppTextStyles.caption,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Valor Atual',
                                    style: AppTextStyles.caption,
                                  ),
                                  Text(
                                    currencyFormatter.format(_goal.currentAmount),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: color,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'Meta',
                                    style: AppTextStyles.caption,
                                  ),
                                  Text(
                                    currencyFormatter.format(_goal.targetAmount),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          LinearProgressIndicator(
                            value: _goal.progress,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                            minHeight: 10,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${(_goal.progress * 100).toInt()}% concluído',
                                style: AppTextStyles.caption,
                              ),
                              Text(
                                'Faltam: ${currencyFormatter.format(_goal.targetAmount - _goal.currentAmount)}',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Ações
                  Card(
                    margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.paddingMedium),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ações',
                            style: AppTextStyles.subheading,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _showAddFundsDialog,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Adicionar'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.income,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _showWithdrawFundsDialog,
                                  icon: const Icon(Icons.remove),
                                  label: const Text('Retirar'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.expense,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Dicas
                  Card(
                    margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.paddingMedium),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Dicas para Economizar',
                            style: AppTextStyles.subheading,
                          ),
                          const SizedBox(height: 16),
                          _buildTipItem(
                            'Defina uma quantia fixa para economizar todo mês',
                            Icons.calendar_today,
                          ),
                          const SizedBox(height: 8),
                          _buildTipItem(
                            'Economize pequenas quantias diariamente',
                            Icons.savings,
                          ),
                          const SizedBox(height: 8),
                          _buildTipItem(
                            'Reduza gastos desnecessários para atingir sua meta mais rápido',
                            Icons.trending_down,
                          ),
                          const SizedBox(height: 8),
                          _buildTipItem(
                            'Comemore cada marco alcançado no caminho para sua meta',
                            Icons.celebration,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Cálculo de tempo estimado
                  if (!_goal.isContinuous && _goal.currentAmount < _goal.targetAmount)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.paddingMedium),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Estimativa de Tempo',
                              style: AppTextStyles.subheading,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Com base no seu ritmo atual de economia:',
                              style: AppTextStyles.caption,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Você atingirá sua meta em aproximadamente ${_calculateEstimatedTime()} meses.',
                              style: AppTextStyles.body,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Prazo final: ${DateFormat('dd/MM/yyyy').format(_goal.deadline!)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _isOnTrack() ? AppColors.income : AppColors.expense,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isOnTrack()
                                  ? 'Você está no caminho certo para atingir sua meta no prazo!'
                                  : 'Você precisa aumentar suas economias para atingir a meta no prazo.',
                              style: TextStyle(
                                color: _isOnTrack() ? AppColors.income : AppColors.expense,
                              ),
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

  Widget _buildTipItem(String text, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.body,
          ),
        ),
      ],
    );
  }

  IconData _getIconData(String iconName) {
    // Mapear nomes de ícones para FontAwesomeIcons
    switch (iconName) {
      case 'plane':
        return FontAwesomeIcons.plane;
      case 'house':
        return FontAwesomeIcons.house;
      case 'car':
        return FontAwesomeIcons.car;
      case 'graduation-cap':
        return FontAwesomeIcons.graduationCap;
      case 'laptop':
        return FontAwesomeIcons.laptop;
      case 'shield-halved':
        return FontAwesomeIcons.shieldHalved;
      case 'person-cane':
        return FontAwesomeIcons.personCane;
      case 'gift':
        return FontAwesomeIcons.gift;
      case 'circle-question':
        return FontAwesomeIcons.circleQuestion;
      default:
        return FontAwesomeIcons.circleQuestion;
    }
  }

  int _calculateEstimatedTime() {
    // Valor que falta para atingir a meta
    final remainingAmount = _goal.targetAmount - _goal.currentAmount;
    
    // Supondo uma economia mensal média (para fins de demonstração)
    // Em um app real, isso seria calculado com base no histórico de economias
    const monthlyContribution = 500.0;
    
    // Cálculo do tempo estimado em meses
    final estimatedMonths = (remainingAmount / monthlyContribution).ceil();
    
    return estimatedMonths > 0 ? estimatedMonths : 1;
  }

  bool _isOnTrack() {
    if (_goal.isContinuous || _goal.deadline == null) return true;
    
    // Meses restantes até o prazo
    final today = DateTime.now();
    final monthsUntilDeadline = (_goal.deadline!.year - today.year) * 12 + 
                               (_goal.deadline!.month - today.month);
    
    // Valor que falta para atingir a meta
    final remainingAmount = _goal.targetAmount - _goal.currentAmount;
    
    // Economia mensal necessária para atingir a meta no prazo
    final requiredMonthlyContribution = monthsUntilDeadline > 0 
        ? remainingAmount / monthsUntilDeadline 
        : double.infinity;
    
    // Supondo uma economia mensal média (para fins de demonstração)
    const actualMonthlyContribution = 500.0;
    
    // Verificar se a economia atual é suficiente
    return actualMonthlyContribution >= requiredMonthlyContribution;
  }
}
