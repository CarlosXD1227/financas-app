import 'package:flutter/material.dart';
import 'package:financas_app/models/category.dart';
import 'package:financas_app/services/database_helper.dart';
import 'package:financas_app/utils/constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CategoryFormScreen extends StatefulWidget {
  final Category? category; // Opcional, para edição
  final bool isExpense; // Tipo de categoria (despesa ou receita)

  const CategoryFormScreen({
    super.key, 
    this.category,
    required this.isExpense,
  });

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  String _selectedIcon = 'utensils';
  Color _selectedColor = Colors.orange;
  String _selectedColorValue = '#FF9800';
  
  final List<Map<String, dynamic>> _expenseIconOptions = [
    {'name': 'Alimentação', 'icon': FontAwesomeIcons.utensils, 'value': 'utensils'},
    {'name': 'Moradia', 'icon': FontAwesomeIcons.house, 'value': 'house'},
    {'name': 'Transporte', 'icon': FontAwesomeIcons.car, 'value': 'car'},
    {'name': 'Saúde', 'icon': FontAwesomeIcons.heartPulse, 'value': 'heart-pulse'},
    {'name': 'Lazer', 'icon': FontAwesomeIcons.film, 'value': 'film'},
    {'name': 'Educação', 'icon': FontAwesomeIcons.book, 'value': 'book'},
    {'name': 'Compras', 'icon': FontAwesomeIcons.bagShopping, 'value': 'bag-shopping'},
    {'name': 'Contas', 'icon': FontAwesomeIcons.fileInvoice, 'value': 'file-invoice'},
    {'name': 'Outros', 'icon': FontAwesomeIcons.ellipsis, 'value': 'ellipsis'},
  ];
  
  final List<Map<String, dynamic>> _incomeIconOptions = [
    {'name': 'Salário', 'icon': FontAwesomeIcons.briefcase, 'value': 'briefcase'},
    {'name': 'Freelance', 'icon': FontAwesomeIcons.laptop, 'value': 'laptop'},
    {'name': 'Investimentos', 'icon': FontAwesomeIcons.chartLine, 'value': 'chart-line'},
    {'name': 'Presente', 'icon': FontAwesomeIcons.gift, 'value': 'gift'},
    {'name': 'Outros', 'icon': FontAwesomeIcons.ellipsis, 'value': 'ellipsis'},
  ];
  
  final List<Map<String, dynamic>> _colorOptions = [
    {'name': 'Laranja', 'color': Colors.orange, 'value': '#FF9800'},
    {'name': 'Azul', 'color': Colors.blue, 'value': '#2196F3'},
    {'name': 'Verde', 'color': Colors.green, 'value': '#4CAF50'},
    {'name': 'Vermelho', 'color': Colors.red, 'value': '#F44336'},
    {'name': 'Roxo', 'color': Colors.purple, 'value': '#9C27B0'},
    {'name': 'Ciano', 'color': Colors.cyan, 'value': '#00BCD4'},
    {'name': 'Rosa', 'color': Colors.pink, 'value': '#E91E63'},
    {'name': 'Cinza', 'color': Colors.grey, 'value': '#607D8B'},
  ];

  @override
  void initState() {
    super.initState();
    
    // Se for edição, preencher os campos com os dados da categoria
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _selectedIcon = widget.category!.icon;
      _selectedColorValue = widget.category!.color;
      
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
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    if (_formKey.currentState!.validate()) {
      try {
        final category = Category(
          id: widget.category?.id,
          name: _nameController.text,
          icon: _selectedIcon,
          color: _selectedColorValue,
          isExpense: widget.isExpense,
        );
        
        if (widget.category == null) {
          // Nova categoria
          await DatabaseHelper.instance.insertCategory(category);
        } else {
          // Editar categoria existente
          await DatabaseHelper.instance.updateCategory(category);
        }
        
        if (mounted) {
          Navigator.pop(context, true); // Retornar true para indicar sucesso
        }
      } catch (e) {
        // Tratar erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar categoria: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconOptions = widget.isExpense ? _expenseIconOptions : _incomeIconOptions;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category == null 
            ? 'Nova Categoria de ${widget.isExpense ? 'Despesa' : 'Receita'}'
            : 'Editar Categoria'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Nome
              Card(
                margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nome da Categoria',
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'Ex: Alimentação, Salário, etc.',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, informe o nome da categoria';
                          }
                          return null;
                        },
                      ),
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
                        children: iconOptions.map((option) {
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
                onPressed: _saveCategory,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingMedium),
                  backgroundColor: _selectedColor,
                ),
                child: Text(
                  widget.category == null ? 'CRIAR CATEGORIA' : 'SALVAR ALTERAÇÕES',
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
