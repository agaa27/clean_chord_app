class ValidationResult {
  final bool isValid;
  final bool notesMatch;
  final bool shapeMatch;
  final bool exactMatch;

  const ValidationResult({
    required this.isValid,
    required this.notesMatch,
    required this.shapeMatch,
    required this.exactMatch,
  });
}