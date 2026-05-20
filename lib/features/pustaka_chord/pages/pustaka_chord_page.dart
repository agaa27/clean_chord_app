import 'package:flutter/material.dart';
import '../data/chord_library.dart';
import '../models/chord_model.dart';
import '../widgets/chord_fretboard_widget.dart';

class PustakaChordPage extends StatefulWidget {
  const PustakaChordPage({super.key});

  @override
  State<PustakaChordPage> createState() => _PustakaChordPageState();
}

class _PustakaChordPageState extends State<PustakaChordPage>
    with TickerProviderStateMixin {
  String _selectedRoot = 'C';
  String _selectedType = 'major';
  int _currentShapeIndex = 0;

  late PageController _pageController;
  late AnimationController _headerAnim;
  late Animation<double> _headerFade;

  final List<String> _roots = [
    'C',
    'C#',
    'D',
    'D#',
    'E',
    'F',
    'F#',
    'G',
    'G#',
    'A',
    'A#',
    'B',
  ];
  final List<String> _types = [
    'major',
    'minor',
    '7',
    'm7',
    'add9',
    'sus4',
    'maj7',
    '5',
  ];

  final Map<String, Color> _typeColors = {
    'major': Colors.cyanAccent,
    'minor': const Color(0xFFFF5CDB),
    '7': const Color(0xFFFFB347),
    'm7': const Color(0xFFBB86FC),
    'add9': const Color(0xFF7CFC00),
    'sus4': const Color(0xFF00CFFF),
    'maj7': const Color(0xFFFFD700),
    '5': const Color(0xFFFF4500),
  };

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _headerFade = CurvedAnimation(parent: _headerAnim, curve: Curves.easeIn);
    _headerAnim.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _headerAnim.dispose();
    super.dispose();
  }

  void _selectRoot(String root) {
    setState(() {
      _selectedRoot = root;
      _currentShapeIndex = 0;
    });
    _pageController.jumpToPage(0);
    _headerAnim.reset();
    _headerAnim.forward();
  }

  void _selectType(String type) {
    setState(() {
      _selectedType = type;
      _currentShapeIndex = 0;
    });
    _pageController.jumpToPage(0);
    _headerAnim.reset();
    _headerAnim.forward();
  }

  ChordModel get _selectedChord {
    return chordLibrary.firstWhere(
      (c) => c.root == _selectedRoot && c.type == _selectedType,
      orElse: () =>
          ChordModel(root: _selectedRoot, type: _selectedType, shapes: []),
    );
  }

  Color get _activeColor => _typeColors[_selectedType] ?? Colors.cyanAccent;

  String get _chordLabel {
    switch (_selectedType) {
      case 'major':
        return _selectedRoot;
      case 'minor':
        return '${_selectedRoot}m';
      case '7':
        return '${_selectedRoot}7';
      case 'm7':
        return '${_selectedRoot}m7';
      case 'add9':
        return '${_selectedRoot}add9';
      case 'sus4':
        return '${_selectedRoot}sus4';
      case 'maj7':
        return '${_selectedRoot}maj7';
      case '5':
        return '${_selectedRoot}5';
      default:
        return _selectedRoot;
    }
  }

  @override
  Widget build(BuildContext context) {
    final chord = _selectedChord;
    final hasShapes = chord.shapes.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // ── Root selector ─────────────────────────────
          const SizedBox(height: 16),
          _buildRootSelector(),
          const SizedBox(height: 12),

          // ── Type selector ─────────────────────────────
          _buildTypeSelector(),
          const SizedBox(height: 20),

          // ── Chord name + shape count ──────────────────
          FadeTransition(opacity: _headerFade, child: _buildChordHeader(chord)),
          const SizedBox(height: 16),

          // ── Fretboard PageView ────────────────────────
          Expanded(
            child: hasShapes
                ? PageView.builder(
                    controller: _pageController,
                    itemCount: chord.shapes.length,
                    onPageChanged: (i) =>
                        setState(() => _currentShapeIndex = i),
                    itemBuilder: (ctx, i) => Center(
                      child: ChordFretboardWidget(
                        shape: chord.shapes[i],
                        chordName: _chordLabel,
                      ),
                    ),
                  )
                : const Center(
                    child: Text(
                      'Chord belum tersedia',
                      style: TextStyle(color: Colors.white54, fontSize: 15),
                    ),
                  ),
          ),

          // ── Swipe hint + dots ─────────────────────────
          if (hasShapes) ...[
            const SizedBox(height: 8),
            _buildSwipeHint(chord.shapes.length),
            const SizedBox(height: 8),
            _buildDots(chord.shapes.length),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── AppBar ──────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.white70,
          size: 18,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Icon(Icons.library_music_outlined, color: _activeColor, size: 20),
          const SizedBox(width: 8),
          const Text(
            'Pustaka Chord',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Root selector ───────────────────────────────────
  Widget _buildRootSelector() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _roots.length,
        itemBuilder: (_, i) {
          final root = _roots[i];
          final isSelected = root == _selectedRoot;
          return GestureDetector(
            onTap: () => _selectRoot(root),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected ? _activeColor : const Color(0xFF1C1C1C),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? _activeColor : Colors.white12,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: _activeColor.withOpacity(0.4),
                          blurRadius: 12,
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  root,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Type selector ───────────────────────────────────
  Widget _buildTypeSelector() {
    final labels = {
      'major': 'Major',
      'minor': 'Minor',
      '7': '7',
      'm7': 'm7',
      'add9': 'Add9',
      '5': '5',
    };
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _types.length,
        itemBuilder: (_, i) {
          final type = _types[i];
          final isSelected = type == _selectedType;
          final tColor = _typeColors[type] ?? Colors.white;
          return GestureDetector(
            onTap: () => _selectType(type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: isSelected
                    ? tColor.withOpacity(0.15)
                    : const Color(0xFF1C1C1C),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? tColor : Colors.white12,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  labels[type] ?? type,
                  style: TextStyle(
                    color: isSelected ? tColor : Colors.white54,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Chord header ────────────────────────────────────
  Widget _buildChordHeader(ChordModel chord) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Big chord name
          Text(
            _chordLabel,
            style: TextStyle(
              color: _activeColor,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              shadows: [
                Shadow(color: _activeColor.withOpacity(0.5), blurRadius: 12),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Shape count badge
          if (chord.shapes.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _activeColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _activeColor.withOpacity(0.3)),
              ),
              child: Text(
                '${chord.shapes.length} posisi',
                style: TextStyle(
                  color: _activeColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          const Spacer(),
          // Shape index indicator
          if (chord.shapes.length > 1)
            Text(
              '${_currentShapeIndex + 1} / ${chord.shapes.length}',
              style: const TextStyle(color: Colors.white38, fontSize: 13),
            ),
        ],
      ),
    );
  }

  // ── Swipe hint ──────────────────────────────────────
  Widget _buildSwipeHint(int count) {
    if (count <= 1) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.chevron_left, color: Colors.white24, size: 16),
        SizedBox(width: 4),
        Text(
          'geser untuk posisi lain',
          style: TextStyle(color: Colors.white24, fontSize: 11),
        ),
        SizedBox(width: 4),
        Icon(Icons.chevron_right, color: Colors.white24, size: 16),
      ],
    );
  }

  // ── Page dots ───────────────────────────────────────
  Widget _buildDots(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == _currentShapeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive ? _activeColor : Colors.white24,
            borderRadius: BorderRadius.circular(3),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: _activeColor.withOpacity(0.5),
                      blurRadius: 6,
                    ),
                  ]
                : [],
          ),
        );
      }),
    );
  }
}
