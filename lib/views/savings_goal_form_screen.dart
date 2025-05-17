import 'package:flutter/material.dart';
import 'package:financas_app/models/savings_goal.dart';
import 'package:financas_app/services/database_helper.dart';
import 'package:financas_app/utils/constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class SavingsGoalFormScreen extends StatefulWidget {
  final SavingsGoal? savingsGoal; // Opcional, para edição

  const SavingsGoalFormScreen({super.key, this.savingsGoal});

  @override
  State<SavingsGoalFormScreen> createState() => _SavingsGoalFormScreenState();
}

class _SavingsGoalFormScreenState extends State<SavingsGoalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _currentAmountController = TextEditingController();
  
  DateTime? _selectedDeadline;
  bool _isContinuous = false;
  String _selectedIcon = 'plane';
  Color _selectedColor = Colors.blue;
  
  final List<Map<String, dynamic>> _iconOptions = [
    {'name': 'Viagem', 'icon': FontAwesomeIcons.plane, 'value': 'plane'},
    {'name': 'Casa', 'icon': FontAwesomeIcons.house, 'value': 'house'},
    {'name': 'Carro', 'icon': FontAwesomeIcons.car, 'value': 'car'},
    {'name': 'Educação', 'icon': FontAwesomeIcons.graduationCap, 'value': 'graduation-cap'},
    {'name': 'Tecnologia', 'icon': FontAwesomeIcons.laptop, 'value': 'laptop'},
    {'name': 'Emergência', 'icon': FontAwesomeIcons.shieldHalved, 'value': 'shield-halved'},
    {'name': 'Aposentadoria', 'icon': FontAwesomeIcons.personCane, 'value': 'person-cane'},
    {'name': 'Presente', 'icon': FontAwesomeIcons.gift, 'value': 'gift'},
    {'name': 'Outro', 'icon': FontAwesomeIcons.circleQuestion, 'value': 'circle-question'},
  ];
  
  final List<Map<String, dynamic>> _colorOptions = [
    {'name': 'Azul', 'color': Colors.blue, 'value': '#2196F3'},
    {'name': 'Verde', 'color': Colors.green, 'value': '#4CAF50'},
    {'name': 'Roxo', 'color': Colors.purple, 'value': '#9C27B0'},
    {'name': 'Vermelho', 'color': Colors.red, 'value': '#F44336'},
    {'name': 'Laranja', 'color': Colors.orange, 'value': '#FF9800'},
    {'name': 'Amarelo', 'color': Colors.amber, 'value': '#FFC107'},
    {'name': 'Ciano', 'color': Colors.cyan, 'value': '#00BCD4'},
    {'name': 'Rosa', 'color': Colors.pink, 'value': '#E91E63'},
  ];
  
  String _selectedColorValue = '#2196F3';

  @override
  void initState() {
    super.initState();
    
    // Se for edição, preencher os campos com os dados da meta
    if (widget.savingsGoal != null) {
      _titleController.text = widget.savingsGoal!.title;
      _targetAmountController.text = widget.savingsGoal!.targetAmount.toString();
      _currentAmountController.text = widget.savingsGoal!.currentAmount.toString();
      _selectedDeadline = widget.savingsGoal!.deadline;
      _isContinuous = widget.savingsGoal!.isContinuous;
      _selectedIcon = widget.savingsGoal!.icon;
      _selectedColorValue = widget.savingsGoal!.color;
      
      // Encontrar a cor correspondente
      final colorOption = _colorOptions.firstWhere(
        (option) => option['value'] == _selectedColorValue,
        orElse: () => _colorOptions.first,
      );
      _selectedColor = colorOption['color'];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetAmountController.dispose();
    _currentAmountController.dispose();
    super.dispose();
  }

  Future<void> _selectDeadline(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    
    if (picked != null) {
      setState(() {
        _selectedDeadline = picked;
      });
    }
  }

  void _toggleContinuous(bool value) {
    setState(() {
      _isContinuous = value;
      if (_isContinuous) {
        _selectedDeadline = null;
      }
    });
  }

  Future<void> _saveSavingsGoal() async {
    if (_formKey.currentState!.validate()) {
      try {
        final savingsGoal = SavingsGoal(
          id: widget.savingsGoal?.id,
          title: _titleController.text,
          targetAmount: double.parse(_targetAmountController.text.replaceAll(',', '.')),
          currentAmount: double.parse(_currentAmountController.text.replaceAll(',', '.')),
          icon: _selectedIcon,
          color: _selectedColorValue,
          deadline: _isContinuous ? null : _selectedDeadline,
          isContinuous: _isContinuous,
        );
        
        if (widget.savingsGoal == null) {
          // Nova meta
          await DatabaseHelper.instance.insertSavingsGoal(savingsGoal);
        } else {
          // Editar meta existente
          await DatabaseHelper.instance.updateSavingsGoal(savingsGoal);
        }
        
        if (mounted) {
          Navigator.pop(context, true); // Retornar true para indicar sucesso
        }
      } catch (e) {
        // Tratar erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar meta: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.savingsGoal == null ? 'Nova Meta' : 'Editar Meta'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título
              Card(
                margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Título da Meta',
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          hintText: 'Ex: Viagem de férias, Novo carro, etc.',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, informe o título da meta';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              // Valor alvo
              Card(
                margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Valor da Meta',
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _targetAmountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          prefixText: 'R\$ ',
                          hintText: '0,00',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, informe o valor da meta';
                          }
                          try {
                            final amount = double.parse(value.replaceAll(',', '.'));
                            if (amount <= 0) {
                              return 'O valor deve ser maior que zero';
                            }
                          } catch (e) {
                            return 'Valor inválido';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              // Valor atual
              Card(
                margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Valor Atual',
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _currentAmountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          prefixText: 'R\$ ',
                          hintText: '0,00',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, informe o valor atual';
                          }
                          try {
                            final currentAmount = double.parse(value.replaceAll(',', '.'));
                            if (currentAmount < 0) {
                              return 'O valor não pode ser negativo';
                            }
                            
                            if (_targetAmountController.text.isNotEmpty) {
                              final targetAmount = double.parse(_targetAmountController.text.replaceAll(',', '.'));
                              if (currentAmount > targetAmount) {
                                return 'O valor atual não pode ser maior que o valor da meta';
                              }
                            }
                          } catch (e) {
                            return 'Valor inválido';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              // Prazo
              Card(
                margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Prazo',
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        title: const Text('Meta contínua (sem prazo)'),
                        value: _isContinuous,
                        onChanged: _toggleContinuous,
                        contentPadding: EdgeInsets.zero,
                      ),
                      if (!_isContinuous) ...[
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _selectDeadline(context),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              _selectedDeadline == null
                                  ? 'Selecione uma data'
                                  : DateFormat('dd/MM/yyyy').format(_selectedDeadline!),
                            ),
                          ),
                        ),
                        if (_selectedDeadline == null) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'Por favor, selecione uma data limite',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
              
              // Ícone e cor
              Card(
                margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Personalização',
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: 16),
                      const Text('Ícone'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _iconOptions.map((option) {
                          final isSelected = _selectedIcon == option['value'];
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedIcon = option['value'];
                              });
                            },
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? _selectedColor.withOpacity(0.2)
                                    : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: isSelected
                                    ? Border.all(color: _selectedColor, width: 2)
                                    : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FaIcon(
                                    option['icon'],
                                    color: isSelected ? _selectedColor : Colors.grey,
                                    size: 20,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    option['name'],
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isSelected ? _selectedColor : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      const Text('Cor'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _colorOptions.map((option) {
                          final isSelected = _selectedColor == option['color'];
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedColor = option['color'];
                                _selectedColorValue = option['value'];
                              });
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: option['color'],
                                shape: BoxShape.circle,
                                border: isSelected
                                    ? Border.all(color: Colors.white, width: 2)
                                    : null,
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: option['color'].withOpacity(0.5),
                                          spreadRadius: 2,
                                          blurRadius: 4,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Botão de salvar
              ElevatedButton(
                onPressed: () {
                  if (!_isContinuous && _selectedDeadline == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Por favor, selecione uma data limite ou marque como meta contínua')),
                    );
                    return;
                  }
                  _saveSavingsGoal();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingMedium),
                  backgroundColor: _selectedColor,
                ),
                child: Text(
                  widget.savingsGoal == null ? 'CRIAR META' : 'SALVAR ALTERAÇÕES',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
