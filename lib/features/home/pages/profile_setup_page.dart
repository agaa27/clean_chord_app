import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/profile/profile.dart';
import 'home_page.dart';

class ProfileSetupPage extends StatefulWidget {
  /// isEdit: true  → mode edit (dari Progress Page), tidak reset progression
  /// isEdit: false → mode setup awal (dari Splash)
  final bool isEdit;

  const ProfileSetupPage({super.key, this.isEdit = false});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage>
    with TickerProviderStateMixin {

  final _nameController = TextEditingController();
  final _nameFocus      = FocusNode();

  String? _selectedAvatarAsset; // path asset yang dipilih
  String? _pickedFilePath;       // path file dari gallery

  bool _isSaving = false;

  // Avatar asset bawaan
  static const List<Map<String, String>> _avatarAssets = [
   {'path': 'assets/images/man.jpg',   'label': 'Pria'},
   {'path': 'assets/images/woman.jpg', 'label': 'Wanita'},
  ];

  // Animasi
  late AnimationController _fadeCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<double>   _pulseAnim;

  static const _cyan   = Color(0xFF00E5FF);
  static const _purple = Color(0xFF9D00FF);
  static const _bg     = Color(0xFF070A0F);

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))
      ..forward();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);

    _fadeAnim  = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _pulseAnim = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);

    // Pre-fill kalau mode edit
    if (widget.isEdit) {
      final p = ProfileService.instance.profile;
      if (p != null) {
        _nameController.text = p.name;
        if (p.avatarType == 'asset') {
          _selectedAvatarAsset = p.avatarPath;
        } else {
          _pickedFilePath = p.avatarPath;
        }
      }
    } else {
      // Default: pilih avatar pertama
      _selectedAvatarAsset = _avatarAssets[0]['path'];
    }
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _pulseCtrl.dispose();
    _nameController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  // ── Pilih dari galeri ──────────────────────────────────────
  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 512,
    );
    if (picked != null) {
      setState(() {
        _pickedFilePath      = picked.path;
        _selectedAvatarAsset = null; // clear asset selection
      });
    }
  }

  // ── Simpan profil ──────────────────────────────────────────
  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showError('Nama tidak boleh kosong');
      return;
    }

    setState(() => _isSaving = true);

    final String avatarType;
    final String avatarPath;

    if (_pickedFilePath != null) {
      avatarType = 'file';
      avatarPath = _pickedFilePath!;
    } else {
      avatarType = 'asset';
      avatarPath = _selectedAvatarAsset ?? _avatarAssets[0]['path']!;
    }

    await ProfileService.instance.save(UserProfile(
      name:       name,
      avatarType: avatarType,
      avatarPath: avatarPath,
    ));

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (widget.isEdit) {
      // Mode edit: kembali ke halaman sebelumnya
      Navigator.of(context).pop();
    } else {
      // Mode setup awal: push replace ke HomePage
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, __, ___) => const HomePage(),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeIn),
            child: child,
          ),
        ),
      );
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.warning_rounded, color: Colors.white70, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(msg, style: const TextStyle(fontFamily: 'Orbitron', fontSize: 11))),
      ]),
      backgroundColor: const Color(0xFF1A0A1E),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  // ── BUILD ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildTopBar()),
                SliverToBoxAdapter(child: _buildTitle()),
                SliverToBoxAdapter(child: _buildAvatarSection()),
                SliverToBoxAdapter(child: _buildNameSection()),
                SliverToBoxAdapter(child: _buildCTA()),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Top bar (hanya tampil di mode edit) ───────────────────
  Widget _buildTopBar() {
    if (!widget.isEdit) return const SizedBox(height: 20);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white54, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'Edit Profil',
            style: TextStyle(
              fontFamily: 'Orbitron', color: Colors.white70,
              fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  // ── Title ──────────────────────────────────────────────────
  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (b) => const LinearGradient(
              colors: [_cyan, Color(0xFF00BFFF), _purple],
            ).createShader(b),
            child: Text(
              widget.isEdit ? 'Perbarui\nProfilmu' : 'Halo,\nSiapa Kamu?',
              style: const TextStyle(
                fontFamily: 'Orbitron', color: Colors.white,
                fontSize: 28, fontWeight: FontWeight.w900,
                height: 1.25, letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.isEdit
                ? 'Edit nama atau avatar kamu.'
                : 'Buat profilmu sebelum mulai menggunakan aplikasi.',
            style: const TextStyle(
              fontFamily: 'Orbitron', color: Colors.white38,
              fontSize: 11, height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ── Avatar section ─────────────────────────────────────────
  Widget _buildAvatarSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('PILIH AVATAR'),
          const SizedBox(height: 14),

          // Preview avatar aktif (besar di tengah)
          Center(child: _buildAvatarPreview()),
          const SizedBox(height: 20),

          // Row: 2 avatar asset + tombol galeri
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ..._avatarAssets.map((a) => _buildAssetOption(a['path']!, a['label']!)),
              const SizedBox(width: 12),
              _buildGalleryOption(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPreview() {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, _) {
        return Container(
          width: 100, height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [_cyan.withOpacity(0.12), _purple.withOpacity(0.18)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: _cyan.withOpacity(0.4 + 0.2 * _pulseAnim.value),
              width: 2.5,
            ),
            boxShadow: [BoxShadow(
              color: _cyan.withOpacity(0.15 + 0.1 * _pulseAnim.value),
              blurRadius: 20, spreadRadius: 2,
            )],
          ),
          child: ClipOval(child: _avatarPreviewWidget()),
        );
      },
    );
  }

  Widget _avatarPreviewWidget() {
    if (_pickedFilePath != null) {
      return Image.file(
        File(_pickedFilePath!),
        width: 100, height: 100,
        fit: BoxFit.cover,
        cacheWidth: 200,
        gaplessPlayback: true,
      );
    }
    if (_selectedAvatarAsset != null) {
      return Image.asset(
        _selectedAvatarAsset!,
        width: 100, height: 100,
        fit: BoxFit.cover,
        cacheWidth: 200,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => _defaultAvatarIcon(),
      );
    }
    return _defaultAvatarIcon();
  }

  Widget _defaultAvatarIcon() => const Icon(Icons.person_rounded, color: Color(0xFF00E5FF), size: 48);

  Widget _buildAssetOption(String path, String label) {
    final isSelected = _selectedAvatarAsset == path && _pickedFilePath == null;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedAvatarAsset = path;
          _pickedFilePath      = null;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 68, height: 68,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? _cyan : Colors.white12,
              width: isSelected ? 2.5 : 1.5,
            ),
            boxShadow: isSelected ? [BoxShadow(
              color: _cyan.withOpacity(0.35), blurRadius: 12,
            )] : [],
          ),
          child: ClipOval(
            child: Image.asset(
              path,
              width: 68, height: 68,
              fit: BoxFit.cover,
              cacheWidth: 136,
              gaplessPlayback: true,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFF0D1520),
                child: Icon(Icons.person_rounded, color: isSelected ? _cyan : Colors.white24, size: 32),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryOption() {
    final isSelected = _pickedFilePath != null;
    return GestureDetector(
      onTap: _pickFromGallery,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 68, height: 68,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? _purple.withOpacity(0.12) : const Color(0xFF0D1520),
          border: Border.all(
            color: isSelected ? _purple : Colors.white12,
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected ? [BoxShadow(
            color: _purple.withOpacity(0.35), blurRadius: 12,
          )] : [],
        ),
        child: isSelected
          ? ClipOval(child: Image.file(
              File(_pickedFilePath!),
              width: 68, height: 68,
              fit: BoxFit.cover,
              cacheWidth: 136,
              gaplessPlayback: true,
            ))
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate_rounded, color: Colors.white38, size: 24),
                const SizedBox(height: 2),
                const Text('Galeri', style: TextStyle(
                  color: Colors.white24, fontSize: 8, fontFamily: 'Orbitron',
                )),
              ],
            ),
      ),
    );
  }

  // ── Name section ───────────────────────────────────────────
  Widget _buildNameSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('NAMA KAMU'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _cyan.withOpacity(0.2), width: 1),
              color: const Color(0xFF0D1520),
            ),
            child: TextField(
              controller: _nameController,
              focusNode: _nameFocus,
              maxLength: 24,
              style: const TextStyle(
                fontFamily: 'Orbitron', color: Colors.white,
                fontSize: 14, letterSpacing: 0.5,
              ),
              decoration: InputDecoration(
                hintText: 'Masukkan namamu...',
                hintStyle: TextStyle(
                  fontFamily: 'Orbitron', color: Colors.white24,
                  fontSize: 13, letterSpacing: 0.3,
                ),
                prefixIcon: Icon(Icons.person_outline_rounded, color: _cyan.withOpacity(0.6), size: 20),
                counterStyle: const TextStyle(color: Colors.white24, fontSize: 9),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── CTA button ─────────────────────────────────────────────
  Widget _buildCTA() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 36, 24, 0),
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (context, _) {
          return GestureDetector(
            onTap: _isSaving ? null : _save,
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    _cyan.withOpacity(0.85 + 0.1 * _pulseAnim.value),
                    _purple.withOpacity(0.85 + 0.1 * _pulseAnim.value),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _cyan.withOpacity(0.25 + 0.15 * _pulseAnim.value),
                    blurRadius: 20, spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: _isSaving
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      widget.isEdit ? 'SIMPAN PERUBAHAN' : 'MULAI BELAJAR',
                      style: const TextStyle(
                        fontFamily: 'Orbitron', color: Colors.white,
                        fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2,
                      ),
                    ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: TextStyle(
      fontFamily: 'Orbitron', color: _cyan.withOpacity(0.6),
      fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 2,
    ),
  );
}
