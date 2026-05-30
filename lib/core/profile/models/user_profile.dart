/// Model data profil user offline.
/// Sepenuhnya terpisah dari UserProgress / ProgressionEngine.
class UserProfile {
  /// Nama tampilan user.
  final String name;

  /// Tipe sumber avatar: 'asset' atau 'file'.
  final String avatarType;

  /// Path avatar:
  ///   - kalau avatarType == 'asset' → path asset Flutter, e.g. 'assets/avatars/avatar1.png'
  ///   - kalau avatarType == 'file'  → absolute path file dari image_picker
  final String avatarPath;

  const UserProfile({
    required this.name,
    required this.avatarType,
    required this.avatarPath,
  });

  // ── Serialisasi ─────────────────────────────────────────────
  Map<String, dynamic> toJson() => {
    'name':       name,
    'avatarType': avatarType,
    'avatarPath': avatarPath,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name:       json['name']       as String? ?? '',
    avatarType: json['avatarType'] as String? ?? 'asset',
    avatarPath: json['avatarPath'] as String? ?? 'assets/images/man.jpg',
  );

  UserProfile copyWith({String? name, String? avatarType, String? avatarPath}) =>
      UserProfile(
        name:       name       ?? this.name,
        avatarType: avatarType ?? this.avatarType,
        avatarPath: avatarPath ?? this.avatarPath,
      );
}
