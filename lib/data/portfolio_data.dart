import 'package:flutter/material.dart';
import '../models/project_model.dart';
import '../models/skill_model.dart';
import '../models/experience_model.dart';

class PortfolioData {
  PortfolioData._();

  static const List<CoreSkill> coreSkills = [
    CoreSkill(name: 'Flutter / Dart', level: 0.95),
    CoreSkill(name: 'BLoC / Cubit', level: 0.92),
    CoreSkill(name: 'Riverpod / Provider', level: 0.88),
    CoreSkill(name: 'Firebase', level: 0.82),
    CoreSkill(name: 'REST API / Dio', level: 0.88),
    CoreSkill(name: 'NPCI / UPI / BBPS', level: 0.90),
    CoreSkill(name: 'CI/CD (GH Actions)', level: 0.80),
    CoreSkill(name: 'AES Encryption / OAuth2', level: 0.78),
  ];

  static const List<SkillCategory> skillCategories = [
    SkillCategory(
      title: 'Languages & Frameworks',
      icon: '⚡',
      skills: ['Flutter', 'Dart', 'Kotlin', 'Java', 'Swift', 'JavaScript'],
    ),
    SkillCategory(
      title: 'State Management',
      icon: '🔄',
      skills: ['BLoC', 'Cubit', 'Provider', 'Riverpod'],
    ),
    SkillCategory(
      title: 'Cloud & Backend',
      icon: '☁️',
      skills: [
        'Firebase Auth', 'Firestore', 'Storage',
        'Remote Config', 'Analytics', 'Crashlytics',
        'AWS Cognito', 'AWS S3', 'REST APIs', 'Dio', 'Socket.IO',
      ],
    ),
    SkillCategory(
      title: 'Security & Payments',
      icon: '🔐',
      skills: ['AES-256 Encryption', 'OAuth2', 'Stripe', 'Razorpay', 'UPI', 'BBPS', 'NPCI'],
    ),
    SkillCategory(
      title: 'CI/CD & Testing',
      icon: '🚀',
      skills: [
        'GitHub Actions', 'Codemagic', 'Shorebird', 'Buildship',
        'Unit Testing', 'Widget Testing', 'Integration Testing',
        'Flutter Driver', 'Custom Linter',
      ],
    ),
    SkillCategory(
      title: 'Tools & Databases',
      icon: '🛠️',
      skills: [
        'Android Studio', 'Xcode', 'VS Code',
        'SQLite', 'SQFLite', 'Room', 'Isar', 'Rowy',
        'Git', 'GitLab', 'Bitbucket', 'JIRA', 'FlutterFlow',
      ],
    ),
  ];

  static const List<ProjectModel> projects = [
    ProjectModel(
      title: 'ABCD Payments',
      description:
          'Production FinTech super app powering UPI, BBPS, and insurance payments. Migrated architecture from Provider to Cubit, integrated NPCI Common Library features, and delivered BBPS modules with real-time NPCI compliance.',
      tech: ['Flutter', 'Cubit', 'NPCI SDK', 'Firebase', 'Dio'],
      platforms: ['Android', 'iOS'],
      achievements: [
        'Migrated Provider → Cubit improving scalability',
        'Integrated NPCI Common Library (Multi PSP, UPI Circle, Hello UPI)',
        'Silent SMS Verification for device binding',
        'BBPS modules with multi-biller support',
      ],
      accentColor: Color(0xFF02569B),
    ),
    ProjectModel(
      title: 'ABCD Super App',
      description:
          'Large-scale financial super app migrated from FlutterFlow to Flutter with responsive Web support across all modules. Led performance optimization reducing startup from 15s to 6s.',
      tech: ['Flutter', 'BLoC', 'Firebase', 'AWS', 'Flutter Web'],
      platforms: ['Android', 'iOS', 'Web'],
      achievements: [
        'FlutterFlow → Flutter migration (3.19.5 → 3.24.5)',
        'Web startup time 15s → 6s',
        'Led team of 7 Flutter developers',
        'Modular package architecture',
      ],
      accentColor: Color(0xFF0175C2),
    ),
    ProjectModel(
      title: 'Weld Configurator',
      description:
          'Flutter desktop app for industrial welding machine configuration with AES-256 encryption, FTDI hardware communication, and full CI/CD pipeline via GitHub Actions and Codemagic.',
      tech: ['Flutter Desktop', 'BLoC', 'AES-256', 'AWS Cognito', 'GitHub Actions'],
      platforms: ['Desktop'],
      achievements: [
        'AES-256 + FTDI secure hardware communication',
        'AWS Cognito + Remote Config integration',
        'Full CI/CD with GitHub Actions + Codemagic',
        'Comprehensive Unit, Widget & Integration tests',
      ],
      accentColor: Color(0xFFFFB400),
    ),
    ProjectModel(
      title: 'Native Mobile Apps',
      description:
          'Contributed to native Android and iOS apps including Delytix (Delivery Management) and My Charity Change. Built platform-specific features using Kotlin, Java, Swift, and Jetpack Compose.',
      tech: ['Kotlin', 'Java', 'Swift', 'Jetpack Compose'],
      platforms: ['Android', 'iOS'],
      achievements: [
        'Delytix delivery management with live tracking',
        'My Charity Change iOS app',
        'Jetpack Compose native UI',
        'Platform-specific integrations',
      ],
      accentColor: Color(0xFF3DDC84),
    ),
    ProjectModel(
      title: 'Flutter Plugins',
      description:
          'Developed, maintained, and published reusable Flutter packages to pub.dev to accelerate development across multiple production applications following Flutter best practices.',
      tech: ['Dart', 'Flutter', 'pub.dev', 'Platform Channels'],
      platforms: ['Android', 'iOS', 'Web'],
      achievements: [
        'Published packages to pub.dev',
        'Platform channel native bridges',
        'Used across multiple production apps',
        'Full documentation and examples',
      ],
      accentColor: Color(0xFF54C5F8),
    ),
  ];

  static const List<ExperienceModel> experience = [
    ExperienceModel(
      company: 'Alchemy Techsol India Pvt Ltd',
      role: 'Flutter Developer',
      duration: 'Aug 2025 – Present',
      location: 'Bengaluru',
      isCurrent: true,
      projects: [
        ExperienceProject(
          name: 'ABCD Payments',
          platforms: 'Android | iOS',
          bullets: [
            'Migrated architecture from Provider to Cubit (BLoC), improving code maintainability and scalability',
            'Revamped Device Binding with Silent SMS Verification and multi-SIM handling',
            'Integrated NPCI Common Library: Multi PSP, UPI Circle, Hello UPI Chatbot',
            'Developed BBPS modules with UI/UX improvements and NPCI compliance',
            'Collaborated with QA, Product & cross-functional teams for production releases',
          ],
        ),
      ],
    ),
    ExperienceModel(
      company: 'Soft Suave Technologies',
      role: 'Executive Software Engineer',
      duration: 'May 2022 – May 2025',
      location: 'Navalur, Chennai',
      projects: [
        ExperienceProject(
          name: 'ABCD Super App',
          platforms: 'Android | iOS | Web',
          bullets: [
            'Led migration from FlutterFlow to Flutter (3.19.5 → 3.24.5) with responsive Web support',
            'Designed modular reusable architecture using Flutter packages/plugins',
            'Reduced Web startup time from 15s to 6s via asset optimization and deferred loading',
            'Led a team of 7 Flutter developers with code reviews and development best practices',
          ],
        ),
        ExperienceProject(
          name: 'Weld Configurator',
          platforms: 'Windows Desktop',
          bullets: [
            'Built Flutter desktop app with backward compatibility from legacy software',
            'AES-256 encryption with FTDI communication for industrial welding machines',
            'Integrated AWS Cognito, Firebase Analytics, Crashlytics, Remote Config',
            'Automated CI/CD with GitHub Actions and Codemagic; full test coverage',
          ],
        ),
        ExperienceProject(
          name: 'Native Mobile Apps',
          platforms: 'Android | iOS',
          bullets: [
            'Contributed to Delytix (Delivery Management) and My Charity Change',
            'Built with Kotlin, Java, Swift, and Jetpack Compose',
          ],
        ),
        ExperienceProject(
          name: 'Flutter Plugin Development',
          platforms: 'Android | iOS | Web',
          bullets: [
            'Developed and published reusable Flutter packages to pub.dev',
            'Created platform channel bridges for native functionality',
          ],
        ),
      ],
    ),
  ];
}
