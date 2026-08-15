class SkillCategory {
  final String title;
  final String icon;
  final List<String> skills;

  const SkillCategory({
    required this.title,
    required this.icon,
    required this.skills,
  });
}

class CoreSkill {
  final String name;
  final double level;

  const CoreSkill({required this.name, required this.level});
}
