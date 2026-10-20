enum ExpensePeriod {
  month,
  week,
  all,
}

extension ExpensePeriodExtension on ExpensePeriod {
  String get label {
    switch (this) {
      case ExpensePeriod.month:
        return 'Este Mes';
      case ExpensePeriod.week:
        return 'Esta Semana';
      case ExpensePeriod.all:
        return 'Histórico';
    }
  }

  String get heroTitle {
    switch (this) {
      case ExpensePeriod.month:
        return 'GASTO TOTAL DEL MES';
      case ExpensePeriod.week:
        return 'GASTO DE ESTA SEMANA';
      case ExpensePeriod.all:
        return 'GASTO TOTAL HISTÓRICO';
    }
  }

  String get badgeLabel {
    switch (this) {
      case ExpensePeriod.month:
        return 'Este mes';
      case ExpensePeriod.week:
        return 'Esta semana';
      case ExpensePeriod.all:
        return 'Todo';
    }
  }
}

class CategoryBreakdown {
  final String category;
  final double amount;
  final double percentage;

  const CategoryBreakdown({
    required this.category,
    required this.amount,
    required this.percentage,
  });
}

class ExpenseAggregation {
  const ExpenseAggregation._();

  static List<Map<String, dynamic>> filterByPeriod(
    List<dynamic> rawExpenses,
    ExpensePeriod period, {
    DateTime? referenceDate,
  }) {
    if (period == ExpensePeriod.all) {
      return rawExpenses.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }

    final ref = referenceDate ?? DateTime.now();

    if (period == ExpensePeriod.month) {
      return rawExpenses
          .map((e) => Map<String, dynamic>.from(e as Map))
          .where((e) {
            final dateStr = e['date']?.toString();
            if (dateStr == null) return false;
            final date = DateTime.tryParse(dateStr);
            if (date == null) return false;
            return date.year == ref.year && date.month == ref.month;
          })
          .toList();
    }

    // ExpensePeriod.week: Lunes 00:00:00 hasta Domingo 23:59:59
    final startOfWeek = DateTime(ref.year, ref.month, ref.day - (ref.weekday - 1));
    final endOfWeek = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day + 6,
      23,
      59,
      59,
      999,
    );

    return rawExpenses
        .map((e) => Map<String, dynamic>.from(e as Map))
        .where((e) {
          final dateStr = e['date']?.toString();
          if (dateStr == null) return false;
          final date = DateTime.tryParse(dateStr);
          if (date == null) return false;
          return !date.isBefore(startOfWeek) && !date.isAfter(endOfWeek);
        })
        .toList();
  }

  static double calculateTotal(List<dynamic> expenses) {
    return expenses.fold<double>(0.0, (acc, e) {
      final rawAmount = e['amount'];
      final amount = double.tryParse(rawAmount?.toString() ?? '0') ?? 0.0;
      return acc + (amount > 0 ? amount : 0.0);
    });
  }

  static Map<String, double> groupByCategory(List<dynamic> expenses) {
    final Map<String, double> totals = {};
    for (final e in expenses) {
      final category = (e['category'] ?? 'Otros').toString();
      final rawAmount = e['amount'];
      final amount = double.tryParse(rawAmount?.toString() ?? '0') ?? 0.0;
      if (amount > 0) {
        totals[category] = (totals[category] ?? 0.0) + amount;
      }
    }

    // Ordenar de mayor a menor gasto
    final sortedEntries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map<String, double>.fromEntries(sortedEntries);
  }

  static List<CategoryBreakdown> calculateBreakdown(
    List<dynamic> expenses, {
    double? precomputedTotal,
  }) {
    final total = precomputedTotal ?? calculateTotal(expenses);
    final grouped = groupByCategory(expenses);

    if (total <= 0) {
      return grouped.entries
          .map((entry) => CategoryBreakdown(
                category: entry.key,
                amount: entry.value,
                percentage: 0.0,
              ))
          .toList();
    }

    return grouped.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      return CategoryBreakdown(
        category: entry.key,
        amount: entry.value,
        percentage: double.parse(percentage.toStringAsFixed(1)),
      );
    }).toList();
  }

  static double calculateDailyAverage(
    double totalSpent,
    ExpensePeriod period, {
    DateTime? referenceDate,
  }) {
    if (totalSpent <= 0) return 0.0;
    final ref = referenceDate ?? DateTime.now();

    int days;
    switch (period) {
      case ExpensePeriod.week:
        days = ref.weekday.clamp(1, 7);
        break;
      case ExpensePeriod.month:
        days = ref.day.clamp(1, 31);
        break;
      case ExpensePeriod.all:
        days = 30;
        break;
    }

    return double.parse((totalSpent / days).toStringAsFixed(2));
  }
}
