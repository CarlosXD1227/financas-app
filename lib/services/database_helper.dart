import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:financas_app/models/transaction.dart';
import 'package:financas_app/models/category.dart';
import 'package:financas_app/models/savings_goal.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('financas_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const textNullable = 'TEXT';

    // Criar tabela de categorias
    await db.execute('''
    CREATE TABLE categories (
      id $idType,
      name $textType,
      icon $textType,
      color $textType,
      isExpense $integerType
    )
    ''');

    // Criar tabela de transações
    await db.execute('''
    CREATE TABLE transactions (
      id $idType,
      amount $realType,
      description $textType,
      categoryId $integerType,
      date $textType,
      isExpense $integerType,
      FOREIGN KEY (categoryId) REFERENCES categories (id)
    )
    ''');

    // Criar tabela de metas de economia
    await db.execute('''
    CREATE TABLE savings_goals (
      id $idType,
      title $textType,
      targetAmount $realType,
      currentAmount $realType,
      icon $textType,
      color $textType,
      deadline $textNullable,
      isContinuous $integerType
    )
    ''');

    // Inserir categorias padrão
    await _insertDefaultCategories(db);
  }

  Future<void> _insertDefaultCategories(Database db) async {
    // Categorias de despesas
    final expenseCategories = [
      {
        'name': 'Alimentação',
        'icon': 'utensils',
        'color': '#FF9800',
        'isExpense': 1
      },
      {
        'name': 'Moradia',
        'icon': 'house',
        'color': '#2196F3',
        'isExpense': 1
      },
      {
        'name': 'Transporte',
        'icon': 'car',
        'color': '#4CAF50',
        'isExpense': 1
      },
      {
        'name': 'Saúde',
        'icon': 'heart-pulse',
        'color': '#F44336',
        'isExpense': 1
      },
      {
        'name': 'Lazer',
        'icon': 'film',
        'color': '#9C27B0',
        'isExpense': 1
      },
      {
        'name': 'Educação',
        'icon': 'book',
        'color': '#FF5722',
        'isExpense': 1
      },
      {
        'name': 'Outros',
        'icon': 'ellipsis',
        'color': '#607D8B',
        'isExpense': 1
      },
    ];

    // Categorias de receitas
    final incomeCategories = [
      {
        'name': 'Salário',
        'icon': 'briefcase',
        'color': '#4CAF50',
        'isExpense': 0
      },
      {
        'name': 'Freelance',
        'icon': 'laptop',
        'color': '#2196F3',
        'isExpense': 0
      },
      {
        'name': 'Investimentos',
        'icon': 'chart-line',
        'color': '#9C27B0',
        'isExpense': 0
      },
      {
        'name': 'Outros',
        'icon': 'ellipsis',
        'color': '#607D8B',
        'isExpense': 0
      },
    ];

    // Inserir todas as categorias
    final allCategories = [...expenseCategories, ...incomeCategories];
    for (var category in allCategories) {
      await db.insert('categories', category);
    }
  }

  // CRUD para Transações
  Future<int> insertTransaction(Transaction transaction) async {
    final db = await instance.database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<Transaction>> getAllTransactions() async {
    final db = await instance.database;
    final result = await db.query('transactions', orderBy: 'date DESC');
    return result.map((map) => Transaction.fromMap(map)).toList();
  }

  Future<List<Transaction>> getTransactionsByType(bool isExpense) async {
    final db = await instance.database;
    final result = await db.query(
      'transactions',
      where: 'isExpense = ?',
      whereArgs: [isExpense ? 1 : 0],
      orderBy: 'date DESC',
    );
    return result.map((map) => Transaction.fromMap(map)).toList();
  }

  Future<int> updateTransaction(Transaction transaction) async {
    final db = await instance.database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await instance.database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD para Categorias
  Future<int> insertCategory(Category category) async {
    final db = await instance.database;
    return await db.insert('categories', category.toMap());
  }

  Future<List<Category>> getAllCategories() async {
    final db = await instance.database;
    final result = await db.query('categories');
    return result.map((map) => Category.fromMap(map)).toList();
  }

  Future<List<Category>> getCategoriesByType(bool isExpense) async {
    final db = await instance.database;
    final result = await db.query(
      'categories',
      where: 'isExpense = ?',
      whereArgs: [isExpense ? 1 : 0],
    );
    return result.map((map) => Category.fromMap(map)).toList();
  }

  Future<int> updateCategory(Category category) async {
    final db = await instance.database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await instance.database;
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD para Metas de Economia
  Future<int> insertSavingsGoal(SavingsGoal goal) async {
    final db = await instance.database;
    return await db.insert('savings_goals', goal.toMap());
  }

  Future<List<SavingsGoal>> getAllSavingsGoals() async {
    final db = await instance.database;
    final result = await db.query('savings_goals');
    return result.map((map) => SavingsGoal.fromMap(map)).toList();
  }

  Future<int> updateSavingsGoal(SavingsGoal goal) async {
    final db = await instance.database;
    return await db.update(
      'savings_goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<int> deleteSavingsGoal(int id) async {
    final db = await instance.database;
    return await db.delete(
      'savings_goals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Métodos para relatórios e estatísticas
  Future<Map<String, double>> getExpensesByCategory(DateTime startDate, DateTime endDate) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT c.name, SUM(t.amount) as total
      FROM transactions t
      JOIN categories c ON t.categoryId = c.id
      WHERE t.isExpense = 1 AND t.date BETWEEN ? AND ?
      GROUP BY c.name
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);

    Map<String, double> expensesByCategory = {};
    for (var row in result) {
      expensesByCategory[row['name'] as String] = row['total'] as double;
    }
    return expensesByCategory;
  }

  Future<double> getTotalIncome(DateTime startDate, DateTime endDate) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total
      FROM transactions
      WHERE isExpense = 0 AND date BETWEEN ? AND ?
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);

    return result.first['total'] as double? ?? 0.0;
  }

  Future<double> getTotalExpense(DateTime startDate, DateTime endDate) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total
      FROM transactions
      WHERE isExpense = 1 AND date BETWEEN ? AND ?
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);

    return result.first['total'] as double? ?? 0.0;
  }

  // Fechar o banco de dados
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
