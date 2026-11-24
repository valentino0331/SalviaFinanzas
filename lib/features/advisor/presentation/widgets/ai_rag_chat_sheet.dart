import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/api_service.dart';

/// Tarjeta y modal interactivo para consultar a Salvia IA (OpenRouter + RAG)
/// sobre educación financiera y buenos hábitos.
class AiRagAdvisorBanner extends StatelessWidget {
  const AiRagAdvisorBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showAiRagChatSheet(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1F3B2B), Color(0xFF335B43)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1F3B2B).withValues(alpha: 0.18),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.auto_awesome, color: Color(0xFF9DF0B8), size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preguntar a Salvia IA',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Asesoría con OpenRouter + RAG en finanzas y hábitos',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: const Color(0xFFD2EAD7),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF9DF0B8), size: 16),
          ],
        ),
      ),
    );
  }
}

void showAiRagChatSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _AiRagChatSheet(),
  );
}

class _AiRagChatSheet extends StatefulWidget {
  const _AiRagChatSheet();

  @override
  State<_AiRagChatSheet> createState() => _AiRagChatSheetState();
}

class _AiRagChatSheetState extends State<_AiRagChatSheet> {
  final TextEditingController _questionCtrl = TextEditingController();
  bool _loading = false;
  Map<String, dynamic>? _result;

  static const List<String> _quickTopics = [
    '¿Cómo recorto gastos hormiga?',
    'Regla 50/30/20',
    'Buenos hábitos diarios',
    'Fondo de emergencia',
  ];

  @override
  void initState() {
    super.initState();
    _consultAi();
  }

  @override
  void dispose() {
    _questionCtrl.dispose();
    super.dispose();
  }

  Future<void> _consultAi([String? customQuestion]) async {
    final q = customQuestion ?? _questionCtrl.text;
    setState(() => _loading = true);
    final res = await ApiService.askSalviaAi(question: q);
    if (!mounted) return;
    setState(() {
      _result = res;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final sources = (_result?['rag_sources'] as List<dynamic>?) ?? const [];

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      decoration: const BoxDecoration(
        color: Color(0xFFF6F9F6),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFC8D5CB),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Color(0xFF285038), size: 22),
                const SizedBox(width: 8),
                Text(
                  'Salvia IA · OpenRouter + RAG',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF132A1D),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickTopics.map((topic) {
                return ActionChip(
                  label: Text(
                    topic,
                    style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  backgroundColor: const Color(0xFFE5EFE6),
                  side: BorderSide.none,
                  onPressed: _loading
                      ? null
                      : () {
                          _questionCtrl.text = topic;
                          _consultAi(topic);
                        },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _questionCtrl,
                    decoration: InputDecoration(
                      hintText: 'Pregunta sobre finanzas o hábitos...',
                      hintStyle: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF7B8E80)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFDDE6DF)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFDDE6DF)),
                      ),
                    ),
                    onSubmitted: (_) => _consultAi(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _loading ? null : () => _consultAi(),
                  style: IconButton.styleFrom(backgroundColor: const Color(0xFF285038)),
                  icon: const Icon(Icons.send_rounded, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator(color: Color(0xFF285038))),
              )
            else if (_result != null) ...[
              _adviceBlock('Diagnóstico', _result!['diagnosis']?.toString() ?? '', Icons.analytics_outlined),
              const SizedBox(height: 10),
              _adviceBlock('Micropaso financiero', _result!['daily_tip']?.toString() ?? '', Icons.savings_outlined),
              const SizedBox(height: 10),
              if ((_result!['habit_tip']?.toString() ?? '').isNotEmpty) ...[
                _adviceBlock('Buen hábito', _result!['habit_tip']!.toString(), Icons.repeat_rounded),
                const SizedBox(height: 10),
              ],
              if (sources.isNotEmpty) ...[
                Text(
                  'Fuentes RAG consultadas:',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF526E5D),
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: sources.map((s) {
                    final map = s as Map<String, dynamic>;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F1EA),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${map['category']?.toString().toUpperCase()}: ${map['title']}',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF285038),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _adviceBlock(String title, String body, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4ECE6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF285038)),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF132A1D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: const Color(0xFF3E5244),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
