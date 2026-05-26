import 'package:flutter/material.dart';
import 'materi_page.dart';
import 'progress_page.dart';
import 'About_page.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _glowController;
  late Animation<double> _glowAnim;

  final List<Widget> _pages = const [
    MateriPage(),
    Center(
      child: const ProgressPage(),
    ),
    Center(
      child: const AboutPage(),
    ),
  ];

  final List<_NavItem> _navItems = const [
    _NavItem(
      icon: Icons.menu_book_rounded,
      label: "Materi",
      color: Color(0xFF00FFFF),
    ),
    _NavItem(
      icon: Icons.show_chart_rounded,
      label: "Progress",
      color: Color(0xFFFF00FF),
    ),
    _NavItem(
      icon: Icons.person_rounded,
      label: "About",
      color: Color(0xFF9D00FF),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _glowAnim = CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: _pages[_selectedIndex],
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildNavBar() {
    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (context, _) {
        final activeColor = _navItems[_selectedIndex].color;
        return Container(
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border(
              top: BorderSide(
                color: activeColor.withOpacity(0.3 + 0.2 * _glowAnim.value),
                width: 1.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: activeColor.withOpacity(0.08 + 0.07 * _glowAnim.value),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              height: 64,
              child: Row(
                children: List.generate(_navItems.length, (i) {
                  final item = _navItems[i];
                  final isSelected = i == _selectedIndex;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _onItemTapped(i),
                      behavior: HitTestBehavior.opaque,
                      child: _NavBarItem(
                        item: item,
                        isSelected: isSelected,
                        glowValue: _glowAnim.value,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final double glowValue;

  const _NavBarItem({
    required this.item,
    required this.isSelected,
    required this.glowValue,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Indicator dot + icon stack
          Stack(
            alignment: Alignment.topCenter,
            children: [
              // Glow blob behind icon when selected
              if (isSelected)
                Positioned(
                  top: 0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: item.color.withOpacity(
                            0.25 + 0.15 * glowValue,
                          ),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 40,
                height: 40,
                decoration: isSelected
                    ? BoxDecoration(
                        shape: BoxShape.circle,
                        color: item.color.withOpacity(0.12),
                        border: Border.all(
                          color: item.color.withOpacity(0.4),
                          width: 1,
                        ),
                      )
                    : null,
                child: Icon(
                  item.icon,
                  color: isSelected ? item.color : Colors.grey[600],
                  size: isSelected ? 22 : 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            style: TextStyle(
              color: isSelected ? item.color : Colors.grey[600]!,
              fontSize: isSelected ? 11 : 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              letterSpacing: isSelected ? 0.5 : 0,
              shadows: isSelected
                  ? [Shadow(color: item.color.withOpacity(0.8), blurRadius: 6)]
                  : [],
            ),
            child: Text(item.label),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final Color color;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.color,
  });
}
