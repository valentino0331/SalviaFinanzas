import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../../../core/theme.dart';
import '../../../core/providers.dart';

class ExpenseForm extends ConsumerStatefulWidget {
  const ExpenseForm({super.key});

  @override
  ConsumerState<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends ConsumerState<ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  final _customSubcategoryController = TextEditingController();

  String _selectedCategory = 'Comida';
  String _selectedSubcategory = 'Almuerzo';
  String _selectedRecurrence = 'once';

  final Map<String, List<String>> _predefinedSubcategories = {
    'Comida': ['Almuerzo', 'Cena', 'Pollo', 'Supermercado', 'Merienda', 'Otro...'],
    'Universidad': ['Pensión', 'Libros / Copias', 'Almuerzo Universidad', 'Transporte', 'Otro...'],
    'Gym': ['Mensualidad', 'Suplementos (Proteína)', 'Ropa Deportiva', 'Otro...'],
    'Transporte': ['Taxi / Uber', 'Bus', 'Gasolina', 'Mantenimiento', 'Otro...'],
    'Ocio': ['Cine', 'Salida Amigos', 'Pool / Billar', 'Suscripciones (Netflix)', 'Otro...'],
    'Otros': ['Servicios', 'Ropa', 'Médico / Salud', 'Otro...'],
  };

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    _customSubcategoryController.dispose();
    super.dispose();
  }

  void _onCategoryChanged(String? category) {
    if (category == null) return;
    setState(() {
      _selectedCategory = category;
      _selectedSubcategory = _predefinedSubcategories[category]!.first;
    });
  }

  void _onSubcategorySelected(String sub) {
    setState(() {
      _selectedSubcategory = sub;
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    await HapticFeedback.mediumImpact();

    final double amount = double.parse(_amountController.text);
    final String sub = _selectedSubcategory == 'Otro...' 
        ? _customSubcategoryController.text.trim()
        : _selectedSubcategory;

    if (sub.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor especifica la subcategoría")),
      );
      return;
    }

    await ref.read(expensesProvider.notifier).addExpense(
      amount,
      _selectedCategory,
      sub,
      _descController.text.trim(),
      recurrence: _selectedRecurrence,
    );

    // Actualizar el asesor
    ref.read(advisorProvider.notifier).loadReport();

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gasto de $sub registrado con éxito 🍃"),
          backgroundColor: RusticTheme.primaryGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final subcategories = _predefinedSubcategories[_selectedCategory] ?? [];

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barra de arrastre visual para Bottom Sheet
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4D2CC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              
              Text(
                "Añadir Gasto",
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: RusticTheme.darkText,
                ),
              ),
              const SizedBox(height: 16),

              // MONTO INPUT
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: "Monto (S/.)",
                  prefixIcon: const Icon(Icons.payments_outlined, size: 28),
                  prefixText: "S/. ",
                  labelStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.normal),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Ingresa un monto";
                  if (double.tryParse(value) == null) return "Monto inválido";
                  if (double.parse(value) <= 0) return "El monto debe ser mayor a 0";
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // CATEGORÍA DROPDOWN
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: "Categoría",
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: _predefinedSubcategories.keys.map((String cat) {
                  return DropdownMenuItem<String>(
                    value: cat,
                    child: Text(cat, style: GoogleFonts.outfit()),
                  );
                }).toList(),
                onChanged: _onCategoryChanged,
              ),
              const SizedBox(height: 16),

              // SUBCATEGORÍA CHIPS SELECTION
              Text(
                "Especifique el Gasto:",
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: RusticTheme.lightText,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: subcategories.map((String sub) {
                  final isSelected = _selectedSubcategory == sub;
                  return ChoiceChip(
                    label: Text(sub, style: GoogleFonts.outfit(fontSize: 12.5)),
                    selected: isSelected,
                    selectedColor: RusticTheme.primaryGreen.withOpacity(0.18),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSelected ? RusticTheme.primaryGreen : const Color(0xFFE4E2DC),
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? RusticTheme.primaryGreen : RusticTheme.lightText,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (bool selected) {
                      if (selected) {
                        _onSubcategorySelected(sub);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              // CUSTOM SUBCATEGORY FIELD IF "Otro..." IS SELECTED
              if (_selectedSubcategory == 'Otro...') ...[
                TextFormField(
                  controller: _customSubcategoryController,
                  decoration: const InputDecoration(
                    labelText: "¿Qué compraste exactamente? (ej. Pollo a la brasa, Copias de examen)",
                    prefixIcon: Icon(Icons.edit_note_outlined),
                  ),
                  validator: (value) {
                    if (_selectedSubcategory == 'Otro...' && (value == null || value.trim().isEmpty)) {
                      return "Escribe la subcategoría específica";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              // RECURRENCIA DROPDOWN
              DropdownButtonFormField<String>(
                value: _selectedRecurrence,
                decoration: const InputDecoration(
                  labelText: "Recurrencia",
                  prefixIcon: Icon(Icons.replay),
                ),
                items: const [
                  DropdownMenuItem(value: 'once', child: Text("Una sola vez")),
                  DropdownMenuItem(value: 'daily', child: Text("Diario")),
                  DropdownMenuItem(value: 'monthly', child: Text("Mensual")),
                  DropdownMenuItem(value: 'yearly', child: Text("Anual")),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedRecurrence = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // DESCRIPCIÓN (OPCIONAL)
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: "Notas / Detalles (Opcional)",
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
              const SizedBox(height: 24),

              // BOTÓN REGISTRAR
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RusticTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    "Confirmar Registro",
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
