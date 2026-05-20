import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// TimeSignaturePage
class TimeSignaturePage extends StatefulWidget {
  final String selected;

  const TimeSignaturePage({super.key, required this.selected});

  @override
  State<TimeSignaturePage> createState() => _TimeSignaturePageState();
}

class _TimeSignaturePageState extends State<TimeSignaturePage>
    with SingleTickerProviderStateMixin {
  late String _selected;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  static const _signatures = [
    '1/4',
    '2/4',
    '3/4',
    '4/4',
    '5/4',
    '7/4',
    '5/8',
    '6/8',
    '7/8',
    '9/8',
    '12/8',
  ];

  static const _descriptions = {
    '1/4': 'Satu ketukan per birama',
    '2/4': 'Dua ketukan — mars, polka',
    '3/4': 'Tiga ketukan — waltz',
    '4/4': 'Empat ketukan — standar umum',
    '5/4': 'Lima ketukan — asimetris',
    '7/4': 'Tujuh ketukan — kompleks',
    '5/8': 'Lima delapanan',
    '6/8': 'Enam delapanan — feel 2',
    '7/8': 'Tujuh delapanan',
    '9/8': 'Sembilan delapanan — feel 3',
    '12/8': 'Dua belas delapanan — feel 4',
  };

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnim = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _select(String sig) {
    HapticFeedback.selectionClick();
    setState(() => _selected = sig);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) Navigator.pop(context, sig);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white70),
          onPressed: () => Navigator.pop(context, _selected),
        ),
        title: const Text(
          'Tanda Birama',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: AnimatedBuilder(
            animation: _pulseAnim,
            builder: (context, _) => Container(
              height: 1,
              color: const Color(
                0xFF9D00FF,
              ).withOpacity(0.2 + 0.15 * _pulseAnim.value),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Info banner ──────────────────────────
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (context, _) {
              return Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(
                      0xFF9D00FF,
                    ).withOpacity(0.3 + 0.2 * _pulseAnim.value),
                    width: 1,
                  ),
                  color: const Color(0xFF9D00FF).withOpacity(0.06),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.music_note_rounded,
                      color: const Color(0xFF9D00FF).withOpacity(0.8),
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Pilih tanda birama untuk metronom',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),

          // ── List ─────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _signatures.length,
              itemBuilder: (context, i) {
                final sig = _signatures[i];
                final isSelected = sig == _selected;
                return _SignatureItem(
                  signature: sig,
                  description: _descriptions[sig] ?? '',
                  isSelected: isSelected,
                  pulseAnim: _pulseAnim,
                  onTap: () => _select(sig),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Item row tanda birama
// ─────────────────────────────────────────────────────────────────────────────
class _SignatureItem extends StatefulWidget {
  final String signature;
  final String description;
  final bool isSelected;
  final Animation<double> pulseAnim;
  final VoidCallback onTap;

  const _SignatureItem({
    required this.signature,
    required this.description,
    required this.isSelected,
    required this.pulseAnim,
    required this.onTap,
  });

  @override
  State<_SignatureItem> createState() => _SignatureItemState();
}

class _SignatureItemState extends State<_SignatureItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _pressAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _pressAnim = CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF9D00FF);

    return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) {
        _pressController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressController.reverse(),
      child: AnimatedBuilder(
        animation: Listenable.merge([_pressAnim, widget.pulseAnim]),
        builder: (context, _) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.isSelected
                    ? accentColor.withOpacity(
                        0.7 + 0.2 * widget.pulseAnim.value,
                      )
                    : Colors.white.withOpacity(0.06),
                width: widget.isSelected ? 1.5 : 1,
              ),
              color: widget.isSelected
                  ? accentColor.withOpacity(0.08)
                  : Colors.white.withOpacity(0.02),
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color: accentColor.withOpacity(
                          0.15 + 0.1 * widget.pulseAnim.value,
                        ),
                        blurRadius: 16,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                // Tanda birama — angka besar
                SizedBox(
                  width: 56,
                  child: Text(
                    widget.signature,
                    style: TextStyle(
                      color: widget.isSelected
                          ? Colors.white
                          : Colors.white.withOpacity(0.7),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      shadows: widget.isSelected
                          ? [
                              Shadow(
                                color: accentColor.withOpacity(0.6),
                                blurRadius: 10,
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),

                // Divider vertikal
                Container(
                  width: 1,
                  height: 28,
                  color: Colors.white.withOpacity(0.08),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),

                // Deskripsi
                Expanded(
                  child: Text(
                    widget.description,
                    style: TextStyle(
                      color: widget.isSelected
                          ? Colors.white.withOpacity(0.6)
                          : Colors.white.withOpacity(0.3),
                      fontSize: 12,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),

                // Checkmark
                AnimatedOpacity(
                  opacity: widget.isSelected ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: accentColor, width: 1.5),
                      color: accentColor.withOpacity(0.15),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withOpacity(0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Color(0xFF9D00FF),
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
