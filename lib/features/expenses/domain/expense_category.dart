import 'package:flutter/material.dart';


enum ExpenseCategory {
  alimentacion('Alimentación', Icons.restaurant_rounded, Color(0xFF2E7D4F)),
  transporte('Transporte', Icons.directions_bus_rounded, Color(0xFF7BC47F)),
  universidad('Universidad', Icons.school_rounded, Color(0xFFE3A857)),
  ocio('Ocio', Icons.theater_comedy_rounded, Color(0xFFD97757)),
  otros('Otros', Icons.widgets_rounded, Color(0xFF9AA79E));

  const ExpenseCategory(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;


  static ExpenseCategory fromLabel(String label) {
    const alias = {'Comida': alimentacion, 'Gym': otros};
    for (final c in values) {
      if (c.label == label) return c;
    }
    return alias[label] ?? otros;
  }
}
