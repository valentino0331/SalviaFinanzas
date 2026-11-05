import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/api_service.dart';
import '../domain/habit.dart';
import '../domain/habit_calendar.dart';
import '../domain/habit_validators.dart';

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
  HabitsApi(this._client, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final http.Client _client;
  final DateTime Function() _now;
  Future<void> _localQueue = Future<void>.value();

  static const _receiptField = '_habits_completion_receipt';

  Future<List<Habit>> getHabits() async {
    final source = await ApiService.getHabits();
    final rows = ApiService.isOffline
        ? await _localOperation(() => _readLocalHabits(seed: source))
        : source.map((row) => Map<String, dynamic>.from(row as Map)).toList();
    return rows.map(Habit.fromMap).toList();
  }

  Future<Habit> addHabit(Map<String, dynamic> changes) async {
    if (!ApiService.isOffline) {
      return Habit.fromMap(await _request('POST', '/habits', changes));
    }
    return _localOperation(() async {
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
    });
  }

  Future<Habit> updateHabit(int id, Map<String, dynamic> changes) async {
    if (!ApiService.isOffline) {
      return Habit.fromMap(await _request('PUT', '/habits/$id', changes));
    }
    return _localOperation(() async {
      final rows = await _readLocalHabits();
      final index = _findHabit(rows, id);
      // Solo se editan los campos del formulario: la racha y la fecha permanecen.
      rows[index] = {...rows[index], ...changes};
      await _writeLocalHabits(rows);
      return Habit.fromMap(rows[index]);
    });
  }

  Future<void> deleteHabit(int id) async {
    if (!ApiService.isOffline) {
      await _request('DELETE', '/habits/$id');
      return;
    }
    return _localOperation(() async {
      final rows = await _readLocalHabits();
      rows.removeAt(_findHabit(rows, id));
      await _writeLocalHabits(rows);
    });
  }

  Future<Map<String, dynamic>> completeHabit(int id) async {
    if (!ApiService.isOffline) {
      return _request('POST', '/habits/$id/complete');
    }
    return _localOperation(() async {
      final rows = await _readLocalHabits();
      final index = _findHabit(rows, id);
      final habit = Habit.fromMap(rows[index]);
      final today = HabitCalendar.dayFor(_now());
      if (habit.isCompletedOn(today)) {
        throw const HabitsApiException('Este hábito ya se completó hoy');
      }
      final streak =
          habit.isCompletedOn(today.subtract(const Duration(days: 1)))
          ? habit.streak + 1
          : 1;
      final points = habit.pointsReward + (streak % 5 == 0 ? 15 : 0);
      final user = await ApiService.getProfile();
      if (user == null) {
        throw const HabitsApiException('Inicia sesión para completar hábitos');
      }
      final prefs = await SharedPreferences.getInstance();
      final key = _localKey(prefs);
      final token = prefs.getString('auth_token')!;
      if (user['id'] != token) {
        throw const HabitsApiException(
          'La sesión local no coincide con el usuario',
        );
      }
      final pending = <String, dynamic>{
        'version': 1,
        'operation_id':
            '${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(0x7fffffff)}',
        'user_id': token,
        'habit_id': id,
        'streak': streak,
        'last_completed_at': today.toIso8601String().split('T').first,
        'points_awarded': points,
      };
      // El registro debe ser durable ANTES de cambiar el hábito o los puntos.
      if (!await prefs.setString(
        '${key}_pending_completion',
        jsonEncode(pending),
      )) {
        throw const HabitsApiException('No se pudo registrar el completado');
      }
      return _applyPendingCompletion(prefs, key, pending);
    });
  }

  /// El controlador lo consulta antes de modificar una lista ya visible.
  Future<int?> recoverPendingCompletion() async {
    if (!ApiService.isOffline) return null;
    return _serializeLocal(_recoverPendingCompletion);
  }

  Future<int?> getLocalPoints() async {
    if (!ApiService.isOffline) return null;
    final user = await ApiService.getProfile();
    return (user?['points'] as num?)?.toInt();
  }

  Future<T> _serializeLocal<T>(Future<T> Function() action) {
    final result = _localQueue.then((_) => action());
    // Un fallo no debe inutilizar la cola para el próximo intento.
    _localQueue = result.then<void>(
      (_) {},
      onError: (Object error, StackTrace stack) {},
    );
    return result;
  }

  Future<T> _localOperation<T>(Future<T> Function() action) =>
      _serializeLocal(() async {
        await _recoverPendingCompletion();
        return action();
      });

  Future<int?> _recoverPendingCompletion() async {
    final prefs = await SharedPreferences.getInstance();
    // SharedPreferences puede conservar en caché una escritura que falló.
    await prefs.reload();
    final key = _localKey(prefs);
    final raw = prefs.getString('${key}_pending_completion');
    if (raw == null) return null;
    final Map<String, dynamic> pending;
    try {
      pending = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      final date = pending['last_completed_at'];
      if (pending['version'] != 1 ||
          pending['operation_id'] is! String ||
          (pending['operation_id'] as String).isEmpty ||
          pending['user_id'] != prefs.getString('auth_token') ||
          pending['habit_id'] is! int ||
          (pending['habit_id'] as int) <= 0 ||
          pending['streak'] is! int ||
          (pending['streak'] as int) <= 0 ||
          pending['points_awarded'] is! int ||
          (pending['points_awarded'] as int) <= 0 ||
          (pending['points_awarded'] as int) > HabitValidators.maxPoints + 15 ||
          date is! String ||
          date.length != 10 ||
          DateTime.tryParse(date)?.toIso8601String().split('T').first != date) {
        throw const FormatException();
      }
    } on FormatException {
      throw const HabitsApiException(
        'El registro de recuperación no es válido. Se conservó para revisión.',
      );
    } on TypeError {
      throw const HabitsApiException(
        'El registro de recuperación no es válido. Se conservó para revisión.',
      );
    }
    final result = await _applyPendingCompletion(prefs, key, pending);
    return result['current_user_points'] as int;
  }

  Future<Map<String, dynamic>> _applyPendingCompletion(
    SharedPreferences prefs,
    String key,
    Map<String, dynamic> pending,
  ) async {
    final user = await ApiService.getProfile();
    void checkSession() {
      if (user == null ||
          user['id'] != pending['user_id'] ||
          prefs.getString('auth_token') != pending['user_id']) {
        throw const HabitsApiException(
          'La sesión cambió. El completado pendiente se conservó.',
        );
      }
    }

    checkSession();
    final rows = await _readLocalHabits();
    final index = _findHabit(rows, pending['habit_id'] as int);
    if (rows[index]['last_completed_at'] != pending['last_completed_at'] ||
        rows[index]['streak'] != pending['streak']) {
      rows[index] = {
        ...rows[index],
        'streak': pending['streak'],
        'last_completed_at': pending['last_completed_at'],
      };
      checkSession();
      if (!await prefs.setString(key, jsonEncode(rows))) {
        throw const HabitsApiException(
          'Completado pendiente de guardar. Actualiza hábitos para recuperarlo.',
        );
      }
    }
    final raw = prefs.getString('local_db_json');
    final database = raw == null
        ? <String, dynamic>{}
        : Map<String, dynamic>.from(jsonDecode(raw) as Map);
    final storedUser = database['user'];
    if (storedUser is! Map || storedUser['id'] != pending['user_id']) {
      throw const HabitsApiException(
        'No se encontró la cuenta del completado pendiente. Se conservó el registro.',
      );
    }
    final updatedUser = Map<String, dynamic>.from(storedUser);
    if (updatedUser[_receiptField] != pending['operation_id']) {
      updatedUser['points'] =
          (updatedUser['points'] as num).toInt() +
          (pending['points_awarded'] as int);
      final oldStreak = (updatedUser['streak'] as num?)?.toInt() ?? 0;
      updatedUser['streak'] = max(oldStreak, pending['streak'] as int);
      updatedUser[_receiptField] = pending['operation_id'];
      database['user'] = updatedUser;
      checkSession();
      // Puntos y recibo se guardan juntos: una recuperación no vuelve a sumarlos.
      if (!await prefs.setString('local_db_json', jsonEncode(database))) {
        throw const HabitsApiException(
          'Puntos pendientes de guardar. Actualiza hábitos para recuperarlos.',
        );
      }
    }
    checkSession();
    user!.addAll({
      'points': updatedUser['points'],
      'streak': updatedUser['streak'],
      _receiptField: updatedUser[_receiptField],
    });
    try {
      await prefs.remove('${key}_pending_completion');
    } catch (_) {
      // Si no se puede limpiar, el recibo hará seguro el próximo intento.
    }
    return {
      'habit': rows[index],
      'points_awarded': pending['points_awarded'],
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
