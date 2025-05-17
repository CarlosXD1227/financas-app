class Transaction {
  final int? id;
  final double amount;
  final String description;
  final int categoryId;
  final DateTime date;
  final bool isExpense;

  Transaction({
    this.id,
    required this.amount,
    required this.description,
    required this.categoryId,
    required this.date,
    required this.isExpense,
  });

  // Converter um objeto Transaction para um Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'categoryId': categoryId,
      'date': date.toIso8601String(),
      'isExpense': isExpense ? 1 : 0,
    };
  }

  // Criar um objeto Transaction a partir de um Map
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      amount: map['amount'],
      description: map['description'],
      categoryId: map['categoryId'],
      date: DateTime.parse(map['date']),
      isExpense: map['isExpense'] == 1,
    );
  }

  // Criar uma cópia do objeto com algumas propriedades alteradas
  Transaction copyWith({
    int? id,
    double? amount,
    String? description,
    int? categoryId,
    DateTime? date,
    bool? isExpense,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      isExpense: isExpense ?? this.isExpense,
    );
  }
}
