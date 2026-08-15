import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';
import 'utils/scroll_controller_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PortfolioApp());
}

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PortfolioProvider(),
      child: MaterialApp(
        title: 'Kalirajan K | Flutter Developer',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        builder: (context, child) => ResponsiveBreakpoints.builder(
          child: child!,
          breakpoints: const [
            Breakpoint(start: 0, end: 480, name: MOBILE),
            Breakpoint(start: 481, end: 1024, name: TABLET),
            Breakpoint(start: 1025, end: double.infinity, name: DESKTOP),
          ],
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
