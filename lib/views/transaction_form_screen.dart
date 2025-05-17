import 'package:flutter/material.dart';
import 'package:financas_app/models/transaction.dart';
import 'package:financas_app/models/category.dart';
import 'package:financas_app/services/database_helper.dart';
import 'package:financas_app/utils/constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class TransactionFormScreen extends StatefulWidget {
  final Transaction? transaction; // Opcional, para edição

  const TransactionFormScreen({super.key, this.transaction});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  bool _isExpense = true;
  int? _selectedCategoryId;
  List<Category> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    
    // Se for edição, preencher os campos com os dados da transação
    if (widget.transaction != null) {
      _descriptionController.text = widget.transaction!.description;
      _amountController.text = widget.transaction!.amount.toString();
      _selectedDate = widget.transaction!.date;
      _isExpense = widget.transaction!.isExpense;
      _selectedCategoryId = widget.transaction!.categoryId;
    }
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final categories = await DatabaseHelper.instance.getCategoriesByType(_isExpense);
      setState(() {
        _categories = categories;
        if (_categories.isNotEmpty && _selectedCategoryId == null) {
          _selectedCategoryId = _categories.first.id;
        }
        _isLoading = false;
      });
    } catch (e) {
      // Tratar erro
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _toggleTransactionType() {
    setState(() {
      _isExpense = !_isExpense;
      _selectedCategoryId = null; // Resetar categoria ao mudar o tipo
    });
    _loadCategories(); // Recarregar categorias com base no novo tipo
  }

  Future<void> _saveTransaction() async {
    if (_formKey.currentState!.validate() && _selectedCategoryId != null) {
      try {
        final transaction = Transaction(
          id: widget.transaction?.id,
          description: _descriptionController.text,
          amount: double.parse(_amountController.text.replaceAll(',', '.')),
          categoryId: _selectedCategoryId!,
          date: _selectedDate,
          isExpense: _isExpense,
        );
        
        if (widget.transaction == null) {
          // Nova transação
          await DatabaseHelper.instance.insertTransaction(transaction);
        } else {
          // Editar transação existente
          await DatabaseHelper.instance.updateTransaction(transaction);
        }
        
        if (mounted) {
          Navigator.pop(context, true); // Retornar true para indicar sucesso
        }
      } catch (e) {
        // Tratar erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar transação: $e')),
        );
      }
    } else if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione uma categoria')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transaction == null ? 'Nova Transação' : 'Editar Transação'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Tipo de transação (Entrada/Saída)
                    Card(
                      margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.paddingMedium),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isExpense ? _toggleTransactionType : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isExpense
                                      ? Colors.white
                                      : AppColors.income,
                                  foregroundColor: _isExpense
                                      ? AppColors.income
                                      : Colors.white,
                                ),
                                child: const Text('Entrada'),
                              ),
                            ),
                            const SizedBox(width: AppSizes.paddingMedium),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isExpense ? null : _toggleTransactionType,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isExpense
                                      ? AppColors.expense
                                      : Colors.white,
                                  foregroundColor: _isExpense
                                      ? Colors.white
                                      : AppColors.expense,
                                ),
                                child: const Text('Saída'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Valor
                    Card(
                      margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.paddingMedium),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Valor',
                              style: AppTextStyles.caption,
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _amountController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                prefixText: 'R\$ ',
                                hintText: '0,00',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, informe o valor';
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
                    
                    // Descrição
                    Card(
                      margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.paddingMedium),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Descrição',
                              style: AppTextStyles.caption,
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _descriptionController,
                              decoration: const InputDecoration(
                                hintText: 'Ex: Supermercado, Salário, etc.',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, informe a descrição';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Categoria
                    Card(
                      margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.paddingMedium),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Categoria',
                              style: AppTextStyles.caption,
                            ),
                            const SizedBox(height: 8),
                            _categories.isEmpty
                                ? const Text('Nenhuma categoria disponível')
                                : DropdownButtonFormField<int>(
                                    value: _selectedCategoryId,
                                    decoration: const InputDecoration(
                                      hintText: 'Selecione uma categoria',
                                    ),
                                    items: _categories.map((category) {
                                      // Converter string de cor para Color
                                      final colorHex = category.color.replaceAll('#', '');
                                      final color = Color(int.parse('0xFF$colorHex'));
                                      
                                      return DropdownMenuItem<int>(
                                        value: category.id,
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: color.withOpacity(0.2),
                                              radius: 14,
                                              child: FaIcon(
                                                _getIconData(category.icon),
                                                color: color,
                                                size: 14,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(category.name),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedCategoryId = value;
                                      });
                                    },
                                  ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Data
                    Card(
                      margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.paddingMedium),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Data',
                              style: AppTextStyles.caption,
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () => _selectDate(context),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  suffixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  DateFormat('dd/MM/yyyy').format(_selectedDate),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Botão de salvar
                    ElevatedButton(
                      onPressed: _saveTransaction,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingMedium),
                      ),
                      child: Text(
                        widget.transaction == null ? 'ADICIONAR' : 'SALVAR',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
  
  IconData _getIconData(String iconName) {
    // Mapear nomes de ícones para FontAwesomeIcons
    switch (iconName) {
      case 'utensils':
        return FontAwesomeIcons.utensils;
      case 'house':
        return FontAwesomeIcons.house;
      case 'car':
        return FontAwesomeIcons.car;
      case 'heart-pulse':
        return FontAwesomeIcons.heartPulse;
      case 'film':
        return FontAwesomeIcons.film;
      case 'book':
        return FontAwesomeIcons.book;
      case 'briefcase':
        return FontAwesomeIcons.briefcase;
      case 'laptop':
        return FontAwesomeIcons.laptop;
      case 'chart-line':
        return FontAwesomeIcons.chartLine;
      case 'ellipsis':
        return FontAwesomeIcons.ellipsis;
      default:
        return FontAwesomeIcons.circleQuestion;
    }
  }
}
