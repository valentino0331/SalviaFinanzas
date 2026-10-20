import 'package:flutter/material.dart';

class AdvisorNotesCard extends StatelessWidget {
  final String note;

  const AdvisorNotesCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notas del Asesor Salvia',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF9F7F1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.edit, size: 18, color: Color(0xFFB5704E)),
                  SizedBox(width: 8),
                  Text(
                    'Consejos Financieros de Campo',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5E4B3E),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Text(
                note,
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF4A3E36),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
