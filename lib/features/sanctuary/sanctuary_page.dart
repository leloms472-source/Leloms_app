import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/sanctuary_provider.dart';

class SanctuaryPage extends StatefulWidget {
  const SanctuaryPage({super.key});

  @override
  State<SanctuaryPage> createState() => _SanctuaryPageState();
}

class _SanctuaryPageState extends State<SanctuaryPage>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _treeController;
  late AnimationController _particleController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _treeGrowthAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _treeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();

    _particleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    _treeGrowthAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _treeController, curve: Curves.easeOutCubic),
    );
  }

  void _onPetCat() {
    context.read<SanctuaryProvider>().petCat();
    _bounceController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _treeController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title: const Text('Mi Santuario'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSkyBackground(),
            _buildTreeSection(),
            _buildCatSection(),
            _buildInteractionButtons(),
            _buildStatsGrid(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSkyBackground() {
    return Container(
      height: 200,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E293B),
            Color(0xFF151B2E),
          ],
        ),
      ),
      child: Stack(
        children: [
          ...List.generate(20, (index) {
            final random = Random(index);
            return Positioned(
              top: random.nextDouble() * 150,
              left: random.nextDouble() * MediaQuery.of(context).size.width,
              child: AnimatedBuilder(
                animation: _particleController,
                builder: (context, child) {
                  final opacity = (sin(
                          _particleController.value * 2 * pi +
                              index * 1.5) +
                          1) /
                      2 *
                      0.5;
                  return Container(
                    width: 2,
                    height: 2,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: opacity),
                      shape: BoxShape.circle,
                    ),
                  );
                },
              ),
            );
          }),
          Positioned(
            top: 140,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.dark.withValues(alpha: 0.8),
                    AppColors.dark,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreeSection() {
    return Consumer<SanctuaryProvider>(
      builder: (context, sanctuary, child) {
        return AnimatedBuilder(
          animation: _treeGrowthAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _treeGrowthAnimation.value,
              child: Column(
                children: [
                  SizedBox(
                    height: 180,
                    child: CustomPaint(
                      size: const Size(double.infinity, 180),
                      painter: _TreePainter(
                        stage: sanctuary.treeStage,
                        progress: sanctuary.treeProgress,
                        isWatered: sanctuary.isTreeWatered,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Árbol del Conocimiento',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightText.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sanctuary.treeStageName,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTreeProgress(sanctuary),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTreeProgress(SanctuaryProvider sanctuary) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: sanctuary.treeProgress,
              backgroundColor: AppColors.darkCard,
              valueColor: AlwaysStoppedAnimation<Color>(
                  _getTreeColor(sanctuary.treeStage)),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${sanctuary.totalXp} XP totales',
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTreeColor(TreeStage stage) {
    switch (stage) {
      case TreeStage.seed:
        return AppColors.pharmacologyOrange;
      case TreeStage.sprout:
        return AppColors.biochemistryGreen;
      case TreeStage.sapling:
        return AppColors.success;
      case TreeStage.young:
        return AppColors.biochemistryGreen;
      case TreeStage.mature:
        return AppColors.success;
      case TreeStage.ancient:
        return AppColors.gold;
    }
  }

  Widget _buildCatSection() {
    return Consumer<SanctuaryProvider>(
      builder: (context, sanctuary, child) {
        return GestureDetector(
          onTap: _onPetCat,
          child: AnimatedBuilder(
            animation: _bounceAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, -_bounceAnimation.value * 15),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: _buildCatContent(sanctuary.catMood),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCatContent(CatMood mood) {
    IconData icon;
    Color iconColor = Colors.white;

    switch (mood) {
      case CatMood.happy:
        icon = Icons.pets_rounded;
        break;
      case CatMood.sleeping:
        icon = Icons.nights_stay_rounded;
        break;
      case CatMood.eating:
        icon = Icons.restaurant_rounded;
        break;
      case CatMood.playing:
        icon = Icons.sports_esports_rounded;
        break;
      case CatMood.idle:
        icon = Icons.pets_rounded;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 50, color: iconColor),
        const SizedBox(height: 4),
        Text(
          _getCatMoodText(mood),
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _getCatMoodText(CatMood mood) {
    switch (mood) {
      case CatMood.idle:
        return 'Leloms te mira';
      case CatMood.happy:
        return '¡Leloms es feliz!';
      case CatMood.sleeping:
        return 'Leloms duerme...';
      case CatMood.eating:
        return 'Leloms come';
      case CatMood.playing:
        return 'Leloms juega';
    }
  }

  Widget _buildInteractionButtons() {
    return Consumer<SanctuaryProvider>(
      builder: (context, sanctuary, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.pan_tool_alt_rounded,
                label: 'Acariciar',
                color: AppColors.secondary,
                onTap: _onPetCat,
              ),
              _buildActionButton(
                icon: Icons.restaurant_rounded,
                label: 'Alimentar',
                color: AppColors.pharmacologyOrange,
                onTap: sanctuary.feedCat,
              ),
              _buildActionButton(
                icon: Icons.sports_esports_rounded,
                label: 'Jugar',
                color: AppColors.success,
                onTap: sanctuary.playWithCat,
              ),
              _buildActionButton(
                icon: Icons.water_drop_rounded,
                label: 'Regar',
                color: AppColors.cyan,
                onTap: sanctuary.waterTree,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.15),
              border: Border.all(
                color: color.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: AppColors.lightText.withValues(alpha: 0.7),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Consumer<SanctuaryProvider>(
      builder: (context, sanctuary, child) {
        final stats = [
          {'icon': Icons.pets_rounded, 'value': '${sanctuary.petCount}', 'label': 'Caricias', 'color': AppColors.secondary},
          {'icon': Icons.restaurant_rounded, 'value': '${sanctuary.feedCount}', 'label': 'Comidas', 'color': AppColors.pharmacologyOrange},
          {'icon': Icons.sports_esports_rounded, 'value': '${sanctuary.playCount}', 'label': 'Juegos', 'color': AppColors.success},
          {'icon': Icons.auto_stories_rounded, 'value': '${sanctuary.totalXp}', 'label': 'XP', 'color': AppColors.primary},
        ];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
            children: stats
                .map((s) => Container(
                      decoration: BoxDecoration(
                        color: AppColors.darkCard,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(s['icon'] as IconData,
                              color: s['color'] as Color, size: 22),
                          const SizedBox(height: 6),
                          Text(
                            s['value'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: s['color'] as Color,
                            ),
                          ),
                          Text(
                            s['label'] as String,
                            style: const TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        );
      },
    );
  }
}

class _TreePainter extends CustomPainter {
  final TreeStage stage;
  final double progress;
  final bool isWatered;

  _TreePainter({
    required this.stage,
    required this.progress,
    required this.isWatered,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final groundY = size.height - 10;

    // Ground
    final groundPaint = Paint()
      ..color = AppColors.darkCard
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, groundY, size.width, 10),
        const Radius.circular(4),
      ),
      groundPaint,
    );

    if (stage == TreeStage.seed) {
      _drawSeed(canvas, centerX, groundY);
    } else {
      _drawTrunk(canvas, centerX, groundY);
      _drawFoliage(canvas, centerX, groundY);
      if (isWatered) _drawSparkles(canvas, centerX, groundY);
    }
  }

  void _drawSeed(Canvas canvas, double x, double groundY) {
    final seedPaint = Paint()
      ..color = AppColors.pharmacologyOrange
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, groundY - 8), width: 14, height: 18),
      seedPaint,
    );

    final glowPaint = Paint()
      ..color = AppColors.pharmacologyOrange.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(x, groundY - 8), 20, glowPaint);
  }

  void _drawTrunk(Canvas canvas, double x, double groundY) {
    final trunkHeight = _getTrunkHeight();
    final trunkWidth = _getTrunkWidth();
    final trunkPaint = Paint()
      ..color = const Color(0xFF8B6914)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(x - trunkWidth / 2, groundY)
      ..lineTo(x - trunkWidth / 3, groundY - trunkHeight)
      ..lineTo(x + trunkWidth / 3, groundY - trunkHeight)
      ..lineTo(x + trunkWidth / 2, groundY)
      ..close();
    canvas.drawPath(path, trunkPaint);

    if (stage.index >= TreeStage.young.index) {
      // Branches
      // Left branch
      canvas.drawLine(
        Offset(x - trunkWidth / 4, groundY - trunkHeight * 0.6),
        Offset(x - trunkWidth * 1.2, groundY - trunkHeight * 0.7),
        Paint()
          ..color = const Color(0xFF6B4E0A)
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke,
      );
      // Right branch
      canvas.drawLine(
        Offset(x + trunkWidth / 4, groundY - trunkHeight * 0.5),
        Offset(x + trunkWidth * 1.2, groundY - trunkHeight * 0.6),
        Paint()
          ..color = const Color(0xFF6B4E0A)
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke,
      );
    }
  }

  void _drawFoliage(Canvas canvas, double x, double groundY) {
    final trunkHeight = _getTrunkHeight();
    final foliageSize = _getFoliageSize();
    final leafColor = _getLeafColor();

    final leafPaint = Paint()
      ..color = leafColor
      ..style = PaintingStyle.fill;

    final topY = groundY - trunkHeight;

    if (stage == TreeStage.sprout) {
      // Simple leaves
      final path = Path()
        ..moveTo(x, topY - foliageSize)
        ..quadraticBezierTo(
            x - foliageSize / 2, topY - foliageSize / 3, x, topY + 5)
        ..quadraticBezierTo(
            x + foliageSize / 2, topY - foliageSize / 3, x, topY - foliageSize);
      canvas.drawPath(path, leafPaint);
    } else {
      // Full foliage circle
      canvas.drawCircle(Offset(x, topY - foliageSize / 2), foliageSize / 2, leafPaint);

      if (stage.index >= TreeStage.young.index) {
        // Additional foliage for larger trees
        canvas.drawCircle(
            Offset(x - foliageSize / 2, topY - foliageSize / 4),
            foliageSize / 3,
            leafPaint);
        canvas.drawCircle(
            Offset(x + foliageSize / 2, topY - foliageSize / 4),
            foliageSize / 3,
            leafPaint);
      }

      if (stage == TreeStage.ancient) {
        // Golden glow for ancient tree
        final glowPaint = Paint()
          ..color = AppColors.gold.withValues(alpha: 0.15)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
        canvas.drawCircle(
            Offset(x, topY - foliageSize / 2), foliageSize, glowPaint);
      }
    }
  }

  void _drawSparkles(Canvas canvas, double x, double groundY) {
    final sparklePaint = Paint()
      ..color = AppColors.cyan.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(x - 15, groundY - 5), 2, sparklePaint);
    canvas.drawCircle(Offset(x + 12, groundY - 8), 2.5, sparklePaint);
    canvas.drawCircle(Offset(x - 8, groundY - 12), 1.5, sparklePaint);
  }

  double _getTrunkHeight() {
    switch (stage) {
      case TreeStage.seed: return 0;
      case TreeStage.sprout: return 20;
      case TreeStage.sapling: return 40;
      case TreeStage.young: return 60;
      case TreeStage.mature: return 80;
      case TreeStage.ancient: return 100;
    }
  }

  double _getTrunkWidth() {
    switch (stage) {
      case TreeStage.seed: return 0;
      case TreeStage.sprout: return 6;
      case TreeStage.sapling: return 10;
      case TreeStage.young: return 14;
      case TreeStage.mature: return 18;
      case TreeStage.ancient: return 22;
    }
  }

  double _getFoliageSize() {
    switch (stage) {
      case TreeStage.seed: return 0;
      case TreeStage.sprout: return 20;
      case TreeStage.sapling: return 40;
      case TreeStage.young: return 60;
      case TreeStage.mature: return 80;
      case TreeStage.ancient: return 100;
    }
  }

  Color _getLeafColor() {
    switch (stage) {
      case TreeStage.seed:
        return AppColors.pharmacologyOrange;
      case TreeStage.sprout:
        return const Color(0xFF4ADE80);
      case TreeStage.sapling:
        return const Color(0xFF22C55E);
      case TreeStage.young:
        return const Color(0xFF16A34A);
      case TreeStage.mature:
        return const Color(0xFF15803D);
      case TreeStage.ancient:
        return AppColors.gold;
    }
  }

  @override
  bool shouldRepaint(covariant _TreePainter oldDelegate) {
    return oldDelegate.stage != stage ||
        oldDelegate.progress != progress ||
        oldDelegate.isWatered != isWatered;
  }
}
