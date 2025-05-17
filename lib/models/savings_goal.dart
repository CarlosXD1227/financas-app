class SavingsGoal {
  final int? id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final String icon;
  final String color;
  final DateTime? deadline;
  final bool isContinuous;

  SavingsGoal({
    this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.icon,
    required this.color,
    this.deadline,
    this.isContinuous = false,
  });

  // Calcular o progresso da meta
  double get progress => currentAmount / targetAmount;

  // Converter um objeto SavingsGoal para um Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'icon': icon,
      'color': color,
      'deadline': deadline?.toIso8601String(),
      'isContinuous': isContinuous ? 1 : 0,
    };
  }

  // Criar um objeto SavingsGoal a partir de um Map
  factory SavingsGoal.fromMap(Map<String, dynamic> map) {
    return SavingsGoal(
      id: map['id'],
      title: map['title'],
      targetAmount: map['targetAmount'],
      currentAmount: map['currentAmount'],
      icon: map['icon'],
      color: map['color'],
      deadline: map['deadline'] != null ? DateTime.parse(map['deadline']) : null,
      isContinuous: map['isContinuous'] == 1,
    );
  }

  // Criar uma cópia do objeto com algumas propriedades alteradas
  SavingsGoal copyWith({
    int? id,
    String? title,
    double? targetAmount,
    double? currentAmount,
    String? icon,
    String? color,
    DateTime? deadline,
    bool? isContinuous,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      deadline: deadline ?? this.deadline,
      isContinuous: isContinuous ?? this.isContinuous,
    );
  }
}
