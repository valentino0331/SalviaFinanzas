import 'expense_category.dart';

class QuickExpense {
  const QuickExpense({
    required this.label,
    required this.amount,
    required this.category,
  });

  final String label;
  final double amount;
  final ExpenseCategory category;

  bool isSameAs(QuickExpense other) =>
      label.toLowerCase() == other.label.toLowerCase() &&
      amount == other.amount &&
      category == other.category;

  Map<String, dynamic> toMap() => {
        'label': label,
        'amount': amount,
        'category': category.label,
      };

  factory QuickExpense.fromMap(Map<String, dynamic> map) => QuickExpense(
        label: map['label'] as String,
        amount: double.parse(map['amount'].toString()),
        category: ExpenseCategory.fromLabel(map['category'] as String),
      );
}
