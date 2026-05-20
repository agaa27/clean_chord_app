import 'package:flutter/material.dart';

class RootSelector extends StatelessWidget {
  final String selectedRoot;
  final Function(String) onSelected;

  const RootSelector({
    super.key,
    required this.selectedRoot,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Natural + sharp, urutan kromatis
    final roots = ['C','C#','D','D#','E','F','F#','G','G#','A','A#','B'];

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: roots.length,
        itemBuilder: (_, i) {
          final root = roots[i];
          final isSelected = root == selectedRoot;
          final isSharp = root.contains('#');

          return GestureDetector(
            onTap: () => onSelected(root),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: EdgeInsets.symmetric(horizontal: isSharp ? 10 : 14),
              decoration: BoxDecoration(
                color: isSelected ? Colors.cyanAccent : const Color(0xFF1C1C1C),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.cyanAccent : Colors.white12,
                  width: isSelected ? 1.5 : 1,
                ),
                boxShadow: isSelected
                    ? [BoxShadow(color: Colors.cyanAccent.withOpacity(0.35), blurRadius: 10)]
                    : [],
              ),
              alignment: Alignment.center,
              child: Text(
                root,
                style: TextStyle(
                  color: isSelected ? Colors.black : (isSharp ? Colors.white54 : Colors.white70),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: isSharp ? 12 : 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
