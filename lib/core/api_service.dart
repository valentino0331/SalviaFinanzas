import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Cambia esto por tu URL de Render en producción.
  static const String baseUrl = 'https://finanzas-c2tc.onrender.com/api';
  
  static String? _token;
  static bool _isOfflineMode = false;

  // In-memory data para el modo sin conexión (fallback)
  static final Map<String, dynamic> _localDb = {
    'user': {
      'id': 'google_mock_123',
      'email': 'marca@example.com',
      'name': 'Marcio A.',
      'avatar_url': 'https://api.dicebear.com/7.x/bottts/png?seed=Marcio',
      'points': 0,
      'streak': 0,
      'monthly_income': 2000.00,
    },
    'expenses': [],
    'savings': [],
    'habits': []
  };

  static Future<void> _saveLocalDb() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('local_db_json', jsonEncode(_localDb));
  }

  static Future<void> init() async {
    _isOfflineMode = false;
    print("Salvia Finanzas inicializado en modo Online 🌿");
    
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');

    final dbJson = prefs.getString('local_db_json');
    if (dbJson != null) {
      try {
        final Map<String, dynamic> parsed = jsonDecode(dbJson);
        if (parsed['user'] != null) {
          _localDb['user'] = parsed['user'];
        }
        if (parsed['expenses'] != null) {
          _localDb['expenses'] = parsed['expenses'];
        }
        if (parsed['savings'] != null) {
          _localDb['savings'] = parsed['savings'];
        }
        if (parsed['habits'] != null) {
          _localDb['habits'] = parsed['habits'];
        }
        print("Base de datos local cargada con éxito.");
      } catch (e) {
        print("Error al cargar la base de datos local: $e");
      }
    }
  }

  static bool get isOffline => _isOfflineMode;

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // Autenticación de Google / Mock
  static Future<Map<String, dynamic>> loginWithGoogle({
    required String id,
    required String email,
    required String name,
    String? avatarUrl,
    double? monthlyIncome,
  }) async {
    final data = {
      'id': id,
      'email': email,
      'name': name,
      'avatar_url': avatarUrl,
      'monthly_income': monthlyIncome ?? 1500.00,
    };

    if (_isOfflineMode) {
      _token = id;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', id);
      _localDb['user']['id'] = id;
      _localDb['user']['name'] = name;
      _localDb['user']['email'] = email;
      _localDb['user']['avatar_url'] = avatarUrl ?? 'https://api.dicebear.com/7.x/bottts/png?seed=$name';
      _localDb['user']['monthly_income'] = monthlyIncome ?? 1500.00;
      await _saveLocalDb();
      return _localDb['user'];
    }

    final res = await http.post(
      Uri.parse('$baseUrl/auth/google'),
      headers: _headers,
      body: jsonEncode(data),
    );

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      _token = id;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', id);
      return body;
    } else {
      throw Exception("Error al autenticar: ${res.body}");
    }
  }

  static Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.setBool('onboarding_completed', false);
    await prefs.remove('local_db_json');
    // Resetear base de datos local
    _localDb['user'] = {
      'id': 'google_mock_123',
      'email': 'marca@example.com',
      'name': 'Marcio A.',
      'avatar_url': 'https://api.dicebear.com/7.x/bottts/png?seed=Marcio',
      'points': 0,
      'streak': 0,
      'monthly_income': 2000.00,
    };
    _localDb['expenses'] = [];
    _localDb['savings'] = [];
    _localDb['habits'] = [];
  }

  static Future<Map<String, dynamic>> updateMonthlyIncome(double income) async {
    if (_isOfflineMode) {
      _localDb['user']['monthly_income'] = income;
      await _saveLocalDb();
      return _localDb['user'];
    }

    final res = await http.put(
      Uri.parse('$baseUrl/user/income'),
      headers: _headers,
      body: jsonEncode({'monthly_income': income}),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw Exception("Error al actualizar ingresos");
  }

  // Perfil de Usuario
  static Future<Map<String, dynamic>?> getProfile() async {
    if (_isOfflineMode) {
      final prefs = await SharedPreferences.getInstance();
      final completed = prefs.getBool('onboarding_completed') ?? false;
      if (!completed) return null;
      return _localDb['user'];
    }
    final res = await http.get(Uri.parse('$baseUrl/user/profile'), headers: _headers);
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception("Error al cargar perfil");
  }

  // GASTOS
  static Future<List<dynamic>> getExpenses() async {
    if (_isOfflineMode) {
      List<dynamic> list = List.from(_localDb['expenses']);
      list.sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
      return list;
    }
    final res = await http.get(Uri.parse('$baseUrl/expenses'), headers: _headers);
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception("Error al cargar gastos");
  }

  static Future<Map<String, dynamic>> addExpense(Map<String, dynamic> expense) async {
    if (_isOfflineMode) {
      final newExp = {
        'id': _localDb['expenses'].length + 1,
        'user_id': _token ?? 'google_mock_123',
        'amount': double.parse(expense['amount'].toString()),
        'category': expense['category'],
        'subcategory': expense['subcategory'],
        'description': expense['description'] ?? '',
        'date': expense['date'] ?? DateTime.now().toIso8601String(),
        'recurrence': expense['recurrence'] ?? 'once',
      };
      _localDb['expenses'].add(newExp);
      await _saveLocalDb();
      return newExp;
    }

    final res = await http.post(
      Uri.parse('$baseUrl/expenses'),
      headers: _headers,
      body: jsonEncode(expense),
    );
    if (res.statusCode == 201) return jsonDecode(res.body);
    throw Exception("Error al agregar gasto");
  }

  static Future<void> deleteExpense(int id) async {
    if (_isOfflineMode) {
      _localDb['expenses'].removeWhere((e) => e['id'] == id);
      await _saveLocalDb();
      return;
    }
    final res = await http.delete(Uri.parse('$baseUrl/expenses/$id'), headers: _headers);
    if (res.statusCode != 200) throw Exception("Error al borrar gasto");
  }

  // MISIONES DE AHORRO
  static Future<List<dynamic>> getSavingsMissions() async {
    if (_isOfflineMode) {
      return List.from(_localDb['savings']);
    }
    final res = await http.get(Uri.parse('$baseUrl/savings-missions'), headers: _headers);
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception("Error al cargar misiones");
  }

  static Future<Map<String, dynamic>> addSavingsMission(Map<String, dynamic> mission) async {
    if (_isOfflineMode) {
      final newMission = {
        'id': _localDb['savings'].length + 1,
        'user_id': _token ?? 'google_mock_123',
        'title': mission['title'],
        'target_amount': double.parse(mission['target_amount'].toString()),
        'current_amount': 0.0,
        'deadline': mission['deadline'],
        'icon_name': mission['icon_name'] ?? 'savings',
        'is_completed': false,
      };
      _localDb['savings'].add(newMission);
      await _saveLocalDb();
      return newMission;
    }

    final res = await http.post(
      Uri.parse('$baseUrl/savings-missions'),
      headers: _headers,
      body: jsonEncode(mission),
    );
    if (res.statusCode == 201) return jsonDecode(res.body);
    throw Exception("Error al agregar misión");
  }

  static Future<Map<String, dynamic>> saveToMission(int id, double amount) async {
    if (_isOfflineMode) {
      final mission = _localDb['savings'].firstWhere((m) => m['id'] == id);
      mission['current_amount'] = (mission['current_amount'] as double) + amount;
      bool completed = false;
      if (mission['current_amount'] >= mission['target_amount']) {
        mission['current_amount'] = mission['target_amount'];
        if (mission['is_completed'] == false) {
          mission['is_completed'] = true;
          completed = true;
          _localDb['user']['points'] = (_localDb['user']['points'] as int) + 100;
        }
      }
      await _saveLocalDb();
      return {
        'mission': mission,
        'points_awarded': completed ? 100 : 0,
      };
    }

    final res = await http.post(
      Uri.parse('$baseUrl/savings-missions/$id/save'),
      headers: _headers,
      body: jsonEncode({'amount': amount}),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception("Error al ahorrar en la misión");
  }

  // HÁBITOS
  static Future<List<dynamic>> getHabits() async {
    if (_isOfflineMode) {
      return List.from(_localDb['habits']);
    }
    final res = await http.get(Uri.parse('$baseUrl/habits'), headers: _headers);
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception("Error al cargar hábitos");
  }

  static Future<Map<String, dynamic>> addHabit(Map<String, dynamic> habit) async {
    if (_isOfflineMode) {
      final newHabit = {
        'id': _localDb['habits'].length + 1,
        'user_id': _token ?? 'google_mock_123',
        'title': habit['title'],
        'description': habit['description'] ?? '',
        'points_reward': habit['points_reward'] ?? 10,
        'streak': 0,
        'last_completed_at': null,
      };
      _localDb['habits'].add(newHabit);
      await _saveLocalDb();
      return newHabit;
    }

    final res = await http.post(
      Uri.parse('$baseUrl/habits'),
      headers: _headers,
      body: jsonEncode(habit),
    );
    if (res.statusCode == 201) return jsonDecode(res.body);
    throw Exception("Error al agregar hábito");
  }

  static Future<Map<String, dynamic>> completeHabit(int id) async {
    final todayStr = DateTime.now().toIso8601String().split('T')[0];

    if (_isOfflineMode) {
      final habit = _localDb['habits'].firstWhere((h) => h['id'] == id);
      if (habit['last_completed_at'] == todayStr) {
        throw Exception("Hábito ya completado hoy");
      }

      final yesterdayStr = DateTime.now().subtract(const Duration(days: 1)).toIso8601String().split('T')[0];
      if (habit['last_completed_at'] == yesterdayStr) {
        habit['streak'] = (habit['streak'] as int) + 1;
      } else {
        habit['streak'] = 1;
      }
      habit['last_completed_at'] = todayStr;

      int pts = habit['points_reward'] as int;
      if (habit['streak'] % 5 == 0) pts += 15;

      _localDb['user']['points'] = (_localDb['user']['points'] as int) + pts;
      _localDb['user']['streak'] = [(_localDb['user']['streak'] as int), habit['streak'] as int].reduce((a, b) => a > b ? a : b);

      await _saveLocalDb();
      return {
        'habit': habit,
        'points_awarded': pts,
        'current_user_points': _localDb['user']['points'],
      };
    }

    final res = await http.post(
      Uri.parse('$baseUrl/habits/$id/complete'),
      headers: _headers,
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    final error = jsonDecode(res.body);
    throw Exception(error['error'] ?? "Error al completar hábito");
  }

  // TABLA DE CLASIFICACIÓN
  static Future<List<dynamic>> getLeaderboard() async {
    if (_isOfflineMode) {
      final bots = [
        { 'id': 'bot1', 'name': 'Sofía Financiera (Bot)', 'avatar_url': 'https://api.dicebear.com/7.x/bottts/png?seed=Sofia', 'points': 340, 'streak': 8 },
        { 'id': 'bot2', 'name': 'Mateo Ahorrador (Bot)', 'avatar_url': 'https://api.dicebear.com/7.x/bottts/png?seed=Mateo', 'points': 210, 'streak': 5 },
        { 'id': 'bot3', 'name': 'Valeria Inversora (Bot)', 'avatar_url': 'https://api.dicebear.com/7.x/bottts/png?seed=Valeria', 'points': 95, 'streak': 2 }
      ];
      final list = [_localDb['user'], ...bots];
      list.sort((a, b) => (b['points'] as int).compareTo(a['points'] as int));
      return list;
    }

    final res = await http.get(Uri.parse('$baseUrl/leaderboard'), headers: _headers);
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception("Error al cargar tabla de clasificación");
  }

  // ASESOR FINANCIERO
  static Future<Map<String, dynamic>> getFinancialAdvisorReport() async {
    if (_isOfflineMode) {
      // Simular cálculo de diagnóstico
      final expenses = _localDb['expenses'] as List<dynamic>;
      final missions = (_localDb['savings'] as List<dynamic>).where((m) => m['is_completed'] == false).toList();
      
      final oneMonthAgo = DateTime.now().subtract(const Duration(days: 30));
      final recentExpenses = expenses.where((e) => DateTime.parse(e['date']).isAfter(oneMonthAgo)).toList();
      
      double totalSpent = recentExpenses.fold(0.0, (acc, e) => acc + double.parse(e['amount'].toString()));
      
      Map<String, double> catSummary = {};
      for (var e in recentExpenses) {
        final cat = e['category'];
        catSummary[cat] = (catSummary[cat] ?? 0.0) + double.parse(e['amount'].toString());
      }

      int score = 100;
      List<String> tips = [];

      final double foodSpent = catSummary['Comida'] ?? 0.0;
      final double leisureSpent = catSummary['Ocio'] ?? 0.0;
      const double budget = 1500.0;

      if (totalSpent > budget) {
        score -= 30;
        tips.add("Has superado tu límite sugerido de S/. 1,500. Intenta aplazar compras no urgentes.");
      } else if (totalSpent > budget * 0.75) {
        score -= 15;
        tips.add("Estás por alcanzar el 80% de tu presupuesto de tranquilidad en Soles. Revisa el detalle de tus gastos.");
      }

      if (leisureSpent > budget * 0.20) {
        score -= 15;
        tips.add("Tus gastos en Ocio (S/. ${leisureSpent.toStringAsFixed(2)}) superan el 20% recomendado. ¡Aquí tienes oportunidad de ahorrar!");
      }

      if (foodSpent > budget * 0.35) {
        score -= 10;
        tips.add("Has gastado bastante comiendo fuera (S/. ${foodSpent.toStringAsFixed(2)}). Preparar más almuerzos en casa (ej. pollo) te ahorraría unos S/. 120 al mes.");
      }

      if (missions.isNotEmpty) {
        final mainMission = missions.first;
        final double missing = double.parse(mainMission['target_amount'].toString()) - double.parse(mainMission['current_amount'].toString());
        if (leisureSpent > 0) {
          final potential = (leisureSpent * 0.5 < missing) ? leisureSpent * 0.5 : missing;
          tips.add("💡 Consejo Salvia: Si recortas el 50% de tus compras en Ocio de este mes, acelerarás tu meta '${mainMission['title']}' sumándole S/. ${potential.toStringAsFixed(2)}.");
        }
      } else {
        tips.add("Aún no tienes misiones de ahorro activas. Añade una para dar dirección y propósito a tus finanzas.");
      }

      String status = "Excelente";
      if (score < 60) {
        status = "Crítico";
      } else if (score < 85) {
        status = "Moderado";
      }

      if (tips.isEmpty) {
        tips.add("¡Tus finanzas están en un estado óptimo! Continúa registrando tus gastos y manteniendo tus buenos hábitos.");
      }

      return {
        'score': score,
        'status': status,
        'total_spent_30_days': totalSpent,
        'category_summary': catSummary,
        'tips': tips
      };
    }

    final res = await http.get(Uri.parse('$baseUrl/financial-advisor'), headers: _headers);
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception("Error al cargar reporte de asesor");
  }
}
