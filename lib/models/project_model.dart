import 'package:flutter/material.dart';

class ProjectModel {
  final String title;
  final String description;
  final List<String> tech;
  final List<String> platforms;
  final List<String> achievements;
  final Color accentColor;
  final int teamSize;
  final String? url;

  const ProjectModel({
    required this.title,
    required this.description,
    required this.tech,
    required this.platforms,
    required this.achievements,
    this.accentColor = const Color(0xFF54C5F8),
    this.teamSize = 1,
    this.url,
  });
}
