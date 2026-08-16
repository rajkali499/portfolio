import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/project_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'tilt_card.dart';

class ProjectCard extends StatefulWidget {
  final ProjectModel project;

  const ProjectCard({super.key, required this.project});

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool _hovered = false;

  Color _platformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'android':
        return AppColors.androidGreen;
      case 'ios':
        return AppColors.iosWhite;
      case 'web':
        return AppColors.webBlue;
      case 'desktop':
        return AppColors.desktopGold;
      default:
        return AppColors.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TiltCard(
      glowColor: widget.project.accentColor,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppColors.cardGradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hovered
                  ? widget.project.accentColor.withOpacity(0.5)
                  : AppColors.border,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + open icon
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      widget.project.title,
                      style: AppTextStyles.cardTitle,
                    ),
                  ),
                  if (widget.project.url != null) ...[
                    const SizedBox(width: 8),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => launchUrl(
                          Uri.parse(widget.project.url!),
                          mode: LaunchMode.externalApplication,
                        ),
                        child: Icon(
                          Icons.open_in_new_rounded,
                          size: 16,
                          color: _hovered
                              ? AppColors.accent
                              : AppColors.textSecondary.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              // Platform badges
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: widget.project.platforms.map((p) {
                  final color = _platformColor(p);
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color.withOpacity(0.4)),
                    ),
                    child: Text(p,
                        style: AppTextStyles.badgeLabel.copyWith(color: color)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              // Description – full width
              Text(
                widget.project.description,
                style: AppTextStyles.bodySm,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 14),
              // Achievements
              ...widget.project.achievements.map((a) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 6, right: 8),
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Expanded(
                          child: Text(a, style: AppTextStyles.bodySm),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 16),
              // Metadata row: team size + platform count
              Row(
                children: [
                  _metaItem(
                    Icons.people_outline_rounded,
                    '${widget.project.teamSize} dev${widget.project.teamSize > 1 ? "s" : ""}',
                  ),
                  const SizedBox(width: 20),
                  _metaItem(
                    Icons.devices_rounded,
                    '${widget.project.platforms.length} platform${widget.project.platforms.length > 1 ? "s" : ""}',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Tech stack – full width
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 12),
              Text(
                'TECH STACK',
                style: AppTextStyles.badgeLabel.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.project.tech.map((t) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: AppColors.primary.withOpacity(0.35)),
                    ),
                    child: Text(t, style: AppTextStyles.techTag),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metaItem(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 5),
        Text(label, style: AppTextStyles.bodySm),
      ],
    );
  }
}
