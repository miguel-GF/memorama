class ProgressSnapshot {
  ProgressSnapshot({Iterable<String> completedLevels = const []})
      : completedLevels = Set.unmodifiable(
          completedLevels.where((levelId) => levelId.trim().isNotEmpty),
        );

  final Set<String> completedLevels;

  factory ProgressSnapshot.fromJson(Object? value) {
    if (value is! Map<Object?, Object?>) {
      throw const FormatException('Invalid progress data');
    }
    final levels = value['completed_levels'];
    if (levels is! List<Object?>) {
      throw const FormatException('Invalid completed levels');
    }
    if (levels.any((levelId) => levelId is! String)) {
      throw const FormatException('Invalid completed level');
    }
    return ProgressSnapshot(completedLevels: levels.cast<String>());
  }

  Map<String, Object?> toJson() => {
        'completed_levels': completedLevels.toList(growable: false),
      };

  bool isCompleted(String packId, int pairCount) =>
      completedLevels.contains(levelId(packId, pairCount));

  ProgressSnapshot markCompleted(String packId, int pairCount) {
    return ProgressSnapshot(
      completedLevels: {
        ...completedLevels,
        levelId(packId, pairCount),
      },
    );
  }

  static String levelId(String packId, int pairCount) => '$packId:$pairCount';
}
