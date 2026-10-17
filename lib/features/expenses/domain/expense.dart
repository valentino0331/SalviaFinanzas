import 'expense_category.dart';


class Expense {
  const Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.detail,
    required this.date,
  });

  final int id;
  final double amount;
  final ExpenseCategory category;
  final String detail;
  final DateTime date;

  Map<String, dynamic> toMap() => {
        'id': id,
        'amount': amount,
        'category': category.label,
        'subcategory': '',
        'description': detail,
        'date': date.toIso8601String(),
      };

  factory Expense.fromMap(Map<String, dynamic> map) => Expense(
        id: (map['id'] as num).toInt(),
        amount: double.parse(map['amount'].toString()),
        category: ExpenseCategory.fromLabel(map['category'] as String),
        detail: (map['description'] ?? '') as String,
        date: DateTime.parse(map['date'] as String),
      );
}
