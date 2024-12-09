class Achievement {
  final String title;
  final String description;
  final int requirement;
  bool unlocked;

  Achievement({
    required this.title,
    required this.description,
    required this.requirement,
    this.unlocked = false,
  });

  static List<Achievement> defaultAchievements = [
    Achievement(
      title: 'First Steps',
      description: 'Complete your first game',
      requirement: 1,
    ),
    Achievement(
      title: 'Combo Master',
      description: 'Achieve a 5x combo',
      requirement: 5,
    ),
    Achievement(
      title: 'Speed Demon',
      description: 'Complete a stage in under 30 seconds',
      requirement: 30,
    ),
    Achievement(
      title: 'Perfect Memory',
      description: 'Complete a stage without any mistakes',
      requirement: 1,
    ),
    Achievement(
      title: 'High Scorer',
      description: 'Score over 10,000 points',
      requirement: 10000,
    ),
  ];

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'requirement': requirement,
        'unlocked': unlocked,
      };

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
        title: json['title'],
        description: json['description'],
        requirement: json['requirement'],
        unlocked: json['unlocked'],
      );
}
