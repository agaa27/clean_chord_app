import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'core/progression/progression.dart';
import 'core/profile/profile.dart';
import 'features/home/pages/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init progression engine (tidak berubah)
  await ProgressionService.instance.init();

  // Init profile engine (baru, terpisah)
  await ProfileService.instance.init();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Clean Chord',
      theme: AppTheme.darkTheme,
      home: const SplashPage(),
      builder: (context, child) {
        precacheImage(const AssetImage('assets/images/iconapp.png'), context);
        precacheImage(const AssetImage('assets/images/man.jpg'), context);
        precacheImage(const AssetImage('assets/images/woman.jpg'), context);
        return child!;
      },
    );
  }
}
