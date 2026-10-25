import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/api_service.dart';
import '../domain/habit.dart';

class HabitsApiException implements Exception {
  const HabitsApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Transporte de hábitos sin ampliar el servicio compartido de core.
///
/// En modo local, la colección pertenece a esta feature y está separada por
/// usuario. Así un refresco o una escritura de core no resucita hábitos borrados.
class HabitsApi {
  HabitsApi(this._client);

  final http.Client _client;

  Future<List<Habit>> getHabits() async {
    final source = await ApiService.getHabits();
    final rows = ApiService.isOffline
        ? await _readLocalHabits(seed: source)
        : source.map((row) => Map<String, dynamic>.from(row as Map)).toList();
    return rows.map(Habit.fromMap).toList();
  }

  Future<Habit> addHabit(Map<String, dynamic> changes) async {
    if (!ApiService.isOffline) {
      return Habit.fromMap(await _request('POST', '/habits', changes));
    }
    final rows = await _readLocalHabits();
    final prefs = await SharedPreferences.getInstance();
    final nextId =
        rows.fold<int>(
          0,
          (highest, row) =>
              (row['id'] as int) > highest ? row['id'] as int : highest,
        ) +
        1;
    final row = <String, dynamic>{
      ...changes,
      'id': nextId,
      'user_id': prefs.getString('auth_token'),
      'streak': 0,
      'last_completed_at': null,
    };
    await _writeLocalHabits([...rows, row]);
    return Habit.fromMap(row);
  }

  Future<Habit> updateHabit(int id, Map<String, dynamic> changes) async {
    if (!ApiService.isOffline) {
      return Habit.fromMap(await _request('PUT', '/habits/$id', changes));
    }
    final rows = await _readLocalHabits();
    final index = _findHabit(rows, id);
    // Solo se editan los campos del formulario: la racha y la fecha permanecen.
    rows[index] = {...rows[index], ...changes};
    await _writeLocalHabits(rows);
    return Habit.fromMap(rows[index]);
  }

  Future<void> deleteHabit(int id) async {
    if (!ApiService.isOffline) {
      await _request('DELETE', '/habits/$id');
      return;
    }
    final rows = await _readLocalHabits();
    rows.removeAt(_findHabit(rows, id));
    await _writeLocalHabits(rows);
  }

  Future<Map<String, dynamic>> completeHabit(int id) async {
    if (!ApiService.isOffline) {
      return _request('POST', '/habits/$id/complete');
    }
    final rows = await _readLocalHabits();
    final index = _findHabit(rows, id);
    final habit = Habit.fromMap(rows[index]);
    final now = DateTime.now();
    if (habit.isCompletedOn(now)) {
      throw const HabitsApiException('Este hábito ya se completó hoy');
    }
    final streak = habit.isCompletedOn(now.subtract(const Duration(days: 1)))
        ? habit.streak + 1
        : 1;
    final points = habit.pointsReward + (streak % 5 == 0 ? 15 : 0);
    final user = await ApiService.getProfile();
    if (user == null) {
      throw const HabitsApiException('Inicia sesión para completar hábitos');
    }
    final updatedUser = Map<String, dynamic>.from(user);
    updatedUser['points'] = (user['points'] as num).toInt() + points;
    final userStreak = (user['streak'] as num?)?.toInt() ?? 0;
    updatedUser['streak'] = streak > userStreak ? streak : userStreak;
    rows[index] = {
      ...rows[index],
      'streak': streak,
      'last_completed_at': now.toIso8601String().split('T').first,
    };

    await _writeLocalHabits(rows);
    // Mantiene la misma cuenta y puntos que el resto de la app, sin modificar core.
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('local_db_json');
    final database = raw == null
        ? <String, dynamic>{}
        : Map<String, dynamic>.from(jsonDecode(raw) as Map);
    database['user'] = updatedUser;
    if (!await prefs.setString('local_db_json', jsonEncode(database))) {
      throw const HabitsApiException('No se pudieron guardar los puntos');
    }
    user.addAll(updatedUser);
    return {
      'habit': rows[index],
      'points_awarded': points,
      'current_user_points': updatedUser['points'],
    };
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, [
    Map<String, dynamic>? body,
  ]) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null || token.isEmpty) {
      throw const HabitsApiException(
        'Inicia sesión para gestionar tus hábitos',
      );
    }
    final request =
        http.Request(method, Uri.parse('${ApiService.baseUrl}$path'))
          ..headers.addAll({
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          });
    if (body != null) request.body = jsonEncode(body);
    try {
      final response = await _client
          .send(request)
          .then(http.Response.fromStream)
          .timeout(const Duration(seconds: 15));
      Map<String, dynamic>? data;
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) data = decoded;
      } on FormatException {
        // Un despliegue anterior puede devolver HTML en vez de JSON.
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HabitsApiException(
          data?['error']?.toString() ??
              'No se pudo realizar la operación. Verifica el despliegue del backend.',
        );
      }
      if (data == null) {
        throw const HabitsApiException('Respuesta de hábitos inválida');
      }
      return data;
    } on TimeoutException {
      throw const HabitsApiException(
        'El servidor tardó demasiado. Actualiza la lista antes de reintentar.',
      );
    } on http.ClientException {
      throw const HabitsApiException(
        'No se pudo conectar. Revisa tu conexión y actualiza la lista.',
      );
    }
  }

  String _localKey(SharedPreferences prefs) {
    final token = prefs.getString('auth_token');
    if (token == null || token.isEmpty) {
      throw const HabitsApiException(
        'Inicia sesión para gestionar tus hábitos',
      );
    }
    return 'habits_v1_$token';
  }

  Future<List<Map<String, dynamic>>> _readLocalHabits({
    List<dynamic>? seed,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _localKey(prefs);
    final saved = prefs.getString(key);
    final source = saved == null
        ? seed ?? await ApiService.getHabits()
        : jsonDecode(saved) as List<dynamic>;
    final rows = source
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList();
    if (saved == null) {
      if (!await prefs.setString(key, jsonEncode(rows))) {
        throw const HabitsApiException('No se pudieron guardar los hábitos');
      }
    }
    return rows;
  }

  Future<void> _writeLocalHabits(List<Map<String, dynamic>> rows) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _localKey(prefs);
    if (!await prefs.setString(key, jsonEncode(rows))) {
      throw const HabitsApiException('No se pudieron guardar los hábitos');
    }
  }

  int _findHabit(List<Map<String, dynamic>> rows, int id) {
    final index = rows.indexWhere((row) => row['id'] == id);
    if (index == -1) {
      throw const HabitsApiException(
        'Hábito no encontrado. Actualiza la lista.',
      );
    }
    return index;
  }
}
