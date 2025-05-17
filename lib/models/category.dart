class Category {
  final int? id;
  final String name;
  final String icon;
  final String color;
  final bool isExpense;

  Category({
    this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.isExpense,
  });

  // Converter um objeto Category para um Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'isExpense': isExpense ? 1 : 0,
    };
  }

  // Criar um objeto Category a partir de um Map
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      icon: map['icon'],
      color: map['color'],
      isExpense: map['isExpense'] == 1,
    );
  }

  // Criar uma cópia do objeto com algumas propriedades alteradas
  Category copyWith({
    int? id,
    String? name,
    String? icon,
    String? color,
    bool? isExpense,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isExpense: isExpense ?? this.isExpense,
    );
  }
}
