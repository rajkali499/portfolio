class ExperienceProject {
  final String name;
  final String platforms;
  final List<String> bullets;

  const ExperienceProject({
    required this.name,
    required this.platforms,
    required this.bullets,
  });
}

class ExperienceModel {
  final String company;
  final String role;
  final String duration;
  final String location;
  final bool isCurrent;
  final List<ExperienceProject> projects;

  const ExperienceModel({
    required this.company,
    required this.role,
    required this.duration,
    required this.location,
    this.isCurrent = false,
    required this.projects,
  });
}
