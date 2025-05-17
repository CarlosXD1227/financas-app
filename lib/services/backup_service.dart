import 'dart:convert';
import 'dart:io';
import 'package:financas_app/models/transaction.dart';
import 'package:financas_app/models/category.dart';
import 'package:financas_app/models/savings_goal.dart';
import 'package:financas_app/services/database_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BackupService {
  static final BackupService _instance = BackupService._internal();
  
  factory BackupService() {
    return _instance;
  }
  
  BackupService._internal();
  
  // Chave para armazenar a data do último backup
  static const String _lastBackupKey = 'last_backup_date';
  
  // Realizar backup local dos dados
  Future<String> createLocalBackup() async {
    try {
      // Obter diretório de documentos
      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/backups');
      
      // Criar diretório de backups se não existir
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }
      
      // Nome do arquivo de backup com data e hora
      final now = DateTime.now();
      final fileName = 'financas_backup_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}.json';
      final backupFile = File('${backupDir.path}/$fileName');
      
      // Obter dados do banco de dados
      final backupData = await _getBackupData();
      
      // Salvar dados no arquivo
      await backupFile.writeAsString(jsonEncode(backupData));
      
      // Atualizar data do último backup
      await _updateLastBackupDate();
      
      return backupFile.path;
    } catch (e) {
      throw Exception('Erro ao criar backup local: $e');
    }
  }
  
  // Restaurar backup local
  Future<bool> restoreLocalBackup(String backupFilePath) async {
    try {
      final backupFile = File(backupFilePath);
      
      if (!await backupFile.exists()) {
        throw Exception('Arquivo de backup não encontrado');
      }
      
      // Ler dados do arquivo
      final backupContent = await backupFile.readAsString();
      final backupData = jsonDecode(backupContent);
      
      // Restaurar dados no banco de dados
      await _restoreBackupData(backupData);
      
      return true;
    } catch (e) {
      throw Exception('Erro ao restaurar backup local: $e');
    }
  }
  
  // Realizar backup na nuvem (simulado)
  Future<bool> createCloudBackup() async {
    try {
      // Obter dados do banco de dados
      final backupData = await _getBackupData();
      
      // Simular envio para a nuvem
      // Em um app real, isso seria enviado para um servidor ou serviço de armazenamento em nuvem
      final response = await http.post(
        Uri.parse('https://api.example.com/backup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': 'user123', // Em um app real, seria o ID do usuário autenticado
          'timestamp': DateTime.now().toIso8601String(),
          'data': backupData,
        }),
      );
      
      if (response.statusCode == 200) {
        // Atualizar data do último backup
        await _updateLastBackupDate();
        return true;
      } else {
        throw Exception('Falha ao enviar backup para a nuvem: ${response.statusCode}');
      }
    } catch (e) {
      // Em um app real, aqui poderia ter uma lógica de retry ou fallback para backup local
      print('Erro ao criar backup na nuvem: $e');
      
      // Criar backup local como fallback
      await createLocalBackup();
      
      return false;
    }
  }
  
  // Restaurar backup da nuvem (simulado)
  Future<bool> restoreCloudBackup() async {
    try {
      // Simular recuperação da nuvem
      // Em um app real, isso seria obtido de um servidor ou serviço de armazenamento em nuvem
      final response = await http.get(
        Uri.parse('https://api.example.com/backup/user123/latest'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final backupData = responseData['data'];
        
        // Restaurar dados no banco de dados
        await _restoreBackupData(backupData);
        
        return true;
      } else {
        throw Exception('Falha ao recuperar backup da nuvem: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao restaurar backup da nuvem: $e');
    }
  }
  
  // Obter lista de backups locais disponíveis
  Future<List<Map<String, dynamic>>> getLocalBackups() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/backups');
      
      if (!await backupDir.exists()) {
        return [];
      }
      
      final files = await backupDir.list().toList();
      final backupFiles = files
          .where((file) => file.path.endsWith('.json'))
          .map((file) {
            final fileName = file.path.split('/').last;
            final dateString = fileName.replaceAll('financas_backup_', '').replaceAll('.json', '');
            
            // Extrair data do nome do arquivo
            final year = int.parse(dateString.substring(0, 4));
            final month = int.parse(dateString.substring(4, 6));
            final day = int.parse(dateString.substring(6, 8));
            final hour = int.parse(dateString.substring(9, 11));
            final minute = int.parse(dateString.substring(11, 13));
            
            final date = DateTime(year, month, day, hour, minute);
            
            return {
              'path': file.path,
              'name': fileName,
              'date': date.toIso8601String(),
              'size': File(file.path).lengthSync(),
            };
          })
          .toList();
      
      // Ordenar por data, mais recente primeiro
      backupFiles.sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
      
      return backupFiles;
    } catch (e) {
      throw Exception('Erro ao listar backups locais: $e');
    }
  }
  
  // Verificar se é necessário fazer backup
  Future<bool> shouldBackup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastBackupString = prefs.getString(_lastBackupKey);
      
      if (lastBackupString == null) {
        return true; // Nunca fez backup
      }
      
      final lastBackup = DateTime.parse(lastBackupString);
      final now = DateTime.now();
      
      // Verificar se o último backup foi há mais de 24 horas
      return now.difference(lastBackup).inHours >= 24;
    } catch (e) {
      return true; // Em caso de erro, melhor fazer backup
    }
  }
  
  // Atualizar data do último backup
  Future<void> _updateLastBackupDate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastBackupKey, DateTime.now().toIso8601String());
  }
  
  // Obter dados para backup
  Future<Map<String, dynamic>> _getBackupData() async {
    // Obter dados do banco de dados
    final transactions = await DatabaseHelper.instance.getAllTransactions();
    final categories = await DatabaseHelper.instance.getAllCategories();
    final savingsGoals = await DatabaseHelper.instance.getAllSavingsGoals();
    
    // Converter para formato JSON
    return {
      'version': '1.0',
      'timestamp': DateTime.now().toIso8601String(),
      'transactions': transactions.map((t) => t.toMap()).toList(),
      'categories': categories.map((c) => c.toMap()).toList(),
      'savingsGoals': savingsGoals.map((g) => g.toMap()).toList(),
    };
  }
  
  // Restaurar dados de backup
  Future<void> _restoreBackupData(Map<String, dynamic> backupData) async {
    final db = await DatabaseHelper.instance.database;
    
    // Iniciar transação para garantir consistência
    await db.transaction((txn) async {
      // Limpar tabelas existentes
      await txn.delete('transactions');
      await txn.delete('categories');
      await txn.delete('savings_goals');
      
      // Restaurar categorias
      final categoriesData = backupData['categories'] as List;
      for (var categoryData in categoriesData) {
        await txn.insert('categories', categoryData as Map<String, dynamic>);
      }
      
      // Restaurar transações
      final transactionsData = backupData['transactions'] as List;
      for (var transactionData in transactionsData) {
        await txn.insert('transactions', transactionData as Map<String, dynamic>);
      }
      
      // Restaurar metas de economia
      final savingsGoalsData = backupData['savingsGoals'] as List;
      for (var goalData in savingsGoalsData) {
        await txn.insert('savings_goals', goalData as Map<String, dynamic>);
      }
    });
  }
  
  // Excluir um backup local
  Future<bool> deleteLocalBackup(String backupFilePath) async {
    try {
      final backupFile = File(backupFilePath);
      
      if (await backupFile.exists()) {
        await backupFile.delete();
        return true;
      }
      
      return false;
    } catch (e) {
      throw Exception('Erro ao excluir backup local: $e');
    }
  }
}
