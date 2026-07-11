import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_typography.dart';
import 'features/auth/splash_page.dart';
import 'providers/user_provider.dart';
import 'providers/sanctuary_provider.dart' show SanctuaryProvider, TreeStage;
import 'providers/study_provider.dart';
import 'providers/achievement_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/challenge_provider.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final themeProvider = ThemeProvider();
  await themeProvider.initialize();

  final notificationService = NotificationService();
  await notificationService.initialize();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(LelomsApp(themeProvider: themeProvider));
}

class LelomsApp extends StatelessWidget {
  final ThemeProvider themeProvider;
  const LelomsApp({super.key, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => SanctuaryProvider()),
        ChangeNotifierProvider(create: (_) => StudyProvider()),
        ChangeNotifierProvider(create: (_) => AchievementProvider()),
        ChangeNotifierProvider<ChallengeProvider>(create: (_) {
          final cp = ChallengeProvider();
          cp.initialize();
          return cp;
        }),
      ],
      child: _AchievementListener(
        child: Consumer<ThemeProvider>(
          builder: (context, theme, child) {
            return MaterialApp(
              title: 'LELOMS',
              debugShowCheckedModeBanner: false,
              theme: _buildDarkTheme(),
              darkTheme: _buildDarkTheme(),
              themeMode: theme.themeMode,
              home: const SplashPage(),
            );
          },
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.tertiary,
        surface: AppColors.darkCard,
        error: AppColors.error,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.dark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.titleLarge,
        iconTheme: IconThemeData(color: AppColors.lightText),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 2,
        shadowColor: AppColors.overlay.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkCard,
        indicatorColor: AppColors.primary.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.all(AppTypography.labelMedium),
      ),
    );
  }
}

class _AchievementListener extends StatefulWidget {
  final Widget child;
  const _AchievementListener({required this.child});

  @override
  State<_AchievementListener> createState() => _AchievementListenerState();
}

class _AchievementListenerState extends State<_AchievementListener> {
  int _lastXpCheck = 0;
  int _lastStreakCheck = 0;
  TreeStage _lastTreeStageCheck = TreeStage.seed;
  String? _lastUnlockedId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = context.read<UserProvider>();
    _lastXpCheck = user.currentXp;
    _lastStreakCheck = user.streak;
  }

  void _onAchievementUnlocked(AchievementProvider achievements) {
    final last = achievements.lastUnlocked;
    if (last != null && last.id.name != _lastUnlockedId) {
      _lastUnlockedId = last.id.name;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.emoji_events_rounded, color: AppColors.gold),
              const SizedBox(width: 12),
              Expanded(child: Text('${last.title}: ${last.description}', style: const TextStyle(color: Colors.white))),
            ]),
            backgroundColor: AppColors.darkCard,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 3),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final sanctuary = context.watch<SanctuaryProvider>();
    final achievements = context.read<AchievementProvider>();

    _onAchievementUnlocked(achievements);

    if (user.currentXp != _lastXpCheck) {
      _lastXpCheck = user.currentXp;
      if (user.currentXp >= 100) achievements.tryUnlock(AchievementId.firstXp);
      if (user.currentXp >= 1000) achievements.tryUnlock(AchievementId.xpCollector);
      if (user.currentXp >= 5000) achievements.tryUnlock(AchievementId.xpHunter);
    }

    if (user.streak != _lastStreakCheck) {
      _lastStreakCheck = user.streak;
      if (user.streak >= 3) achievements.tryUnlock(AchievementId.firstStreak);
      if (user.streak >= 7) achievements.tryUnlock(AchievementId.weekStreak);
      if (user.streak >= 30) achievements.tryUnlock(AchievementId.monthStreak);
    }

    if (sanctuary.treeStage != _lastTreeStageCheck) {
      _lastTreeStageCheck = sanctuary.treeStage;
      if (sanctuary.treeStage == TreeStage.mature) {
        achievements.tryUnlock(AchievementId.treeGrower);
      }
      if (sanctuary.treeStage == TreeStage.ancient) {
        achievements.tryUnlock(AchievementId.ancientTree);
      }
    }

    return widget.child;
  }
}
