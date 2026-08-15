import 'package:flutter/material.dart';

class PortfolioProvider extends ChangeNotifier {
  String _activeSection = 'hero';
  final ScrollController scrollController = ScrollController();

  String get activeSection => _activeSection;

  void setActiveSection(String section) {
    if (_activeSection != section) {
      _activeSection = section;
      notifyListeners();
    }
  }

  void scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
