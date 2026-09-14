import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    super.key,
    required this.template,
    this.onAdopt,
  });

  final Map<String, dynamic> template;
  final VoidCallback? onAdopt;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7ECE7)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE4EDE5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.eco_outlined, color: Color(0xFF285038), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  template['title'],
                  style: GoogleFonts.outfit(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF132A1D),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "${template['description']} • +${template['points_reward']} pts",
                  style: GoogleFonts.outfit(fontSize: 11, color: const Color(0xFF7A8B7E)),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onAdopt,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF009668),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text("Adoptar", style: GoogleFonts.outfit(fontSize: 11.5, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
