import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/theme_provider.dart';
import '../utils/responsive_util.dart';
import '../widgets/custom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _heroController;
  late AnimationController _floatingController;
  late AnimationController _pulseController;
  late Animation<double> _heroFadeAnimation;
  late Animation<Offset> _heroSlideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _heroController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _heroFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _heroController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _heroSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _heroController,
            curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _heroController.forward();
  }

  @override
  void dispose() {
    _heroController.dispose();
    _floatingController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = ResponsiveUtil.isMobile(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.getBackgroundColor(context),
      body: Stack(
        children: [
          // Animated background
          _buildAnimatedBackground(themeProvider),

          // Main content
          SingleChildScrollView(
            child: Column(
              children: [
                const CustomNavBar(currentRoute: '/'),
                _buildHeroSection(size, isMobile, themeProvider),
                _buildFeaturedSection(isMobile, themeProvider),
                _buildFooter(isMobile, themeProvider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground(ThemeProvider themeProvider) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _floatingController,
        builder: (context, child) {
          return CustomPaint(
            painter: BackgroundPainter(
              _floatingController.value,
              themeProvider.isDarkMode,
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroSection(
    Size size,
    bool isMobile,
    ThemeProvider themeProvider,
  ) {
    return Container(
      padding: ResponsiveUtil.getResponsivePadding(context),
      child: FadeTransition(
        opacity: _heroFadeAnimation,
        child: SlideTransition(
          position: _heroSlideAnimation,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: isMobile ? 40 : 60),

                // Animated sketch icon
                _buildSketchIcon(isMobile, themeProvider),
                SizedBox(height: isMobile ? 30 : 50),

                // Main title with stagger animation
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 30 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    'VISUAL',
                    style: TextStyle(
                      fontSize: isMobile ? 48 : 96,
                      fontWeight: FontWeight.w900,
                      height: 0.9,
                      letterSpacing: isMobile ? 4 : 8,
                      color: themeProvider.getTextColor(context),
                    ),
                  ),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 30 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
                    ).createShader(bounds),
                    child: Text(
                      'STORIES',
                      style: TextStyle(
                        fontSize: isMobile ? 48 : 96,
                        fontWeight: FontWeight.w900,
                        height: 0.9,
                        letterSpacing: isMobile ? 4 : 8,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: isMobile ? 20 : 30),

                // Subtitle with typewriter effect
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(opacity: value, child: child);
                  },
                  child: Text(
                    'Hand-drawn sketches by Sagar Kalel',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 20,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 2,
                      color: themeProvider.getSecondaryTextColor(context),
                    ),
                  ),
                ),

                SizedBox(height: isMobile ? 40 : 60),

                // CTA Button with pulse
                _buildCTAButton(isMobile),

                SizedBox(height: isMobile ? 20 : 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSketchIcon(bool isMobile, ThemeProvider themeProvider) {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatingController, _pulseController]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            math.sin(_floatingController.value * 2 * math.pi) * 10,
          ),
          child: Transform.scale(
            scale: 1.0 + (_pulseController.value * 0.05),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.asset(
                "assets/images/sagar_arts_logo.jpeg",
                width: isMobile ? 100 : 140,
                height: isMobile ? 100 : 140,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCTAButton(bool isMobile) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(scale: _pulseAnimation.value, child: child);
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/gallery'),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 36 : 52,
              vertical: isMobile ? 18 : 22,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
              ),
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B6B).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'EXPLORE GALLERY',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: isMobile ? 8 : 12),
                Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: isMobile ? 18 : 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedSection(bool isMobile, ThemeProvider themeProvider) {
    return Container(
      padding: ResponsiveUtil.getResponsivePadding(context),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Column(
              children: [
                Text(
                  'FEATURED WORKS',
                  style: TextStyle(
                    fontSize: isMobile ? 28 : 42,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3,
                    color: themeProvider.getTextColor(context),
                  ),
                ),
                SizedBox(height: isMobile ? 10 : 16),
                Container(
                  width: isMobile ? 60 : 80,
                  height: 3,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isMobile ? 40 : 60),
          _buildFeaturedGrid(isMobile, themeProvider),
        ],
      ),
    );
  }

  Widget _buildFeaturedGrid(bool isMobile, ThemeProvider themeProvider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = ResponsiveUtil.getGridColumns(context);
        final spacing = isMobile ? 16.0 : 24.0;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: List.generate(3, (index) {
            return _buildFeaturedCard(
              index,
              (constraints.maxWidth - (spacing * (columns - 1))) / columns,
              isMobile,
              themeProvider,
            );
          }),
        );
      },
    );
  }

  Widget _buildFeaturedCard(
    int index,
    double width,
    bool isMobile,
    ThemeProvider themeProvider,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 200)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        width: width,
        height: width * 1.2,
        decoration: BoxDecoration(
          color: themeProvider.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: themeProvider.getBorderColor(context),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                themeProvider.isDarkMode ? 0.2 : 0.05,
              ),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Image.asset(
            index == 0
                ? "assets/images/sketch1.jpeg"
                : index == 1
                ? "assets/images/sketch2_alt1.jpeg"
                : "assets/images/sketch7.jpg",
            fit: BoxFit.cover,
            width: width,
            height: width * 1.2,
            errorBuilder: (context, error, stackTrace) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_outlined,
                  size: isMobile ? 40 : 60,
                  color: themeProvider.getSecondaryTextColor(context),
                ),
                const SizedBox(height: 16),
                Text(
                  'Sketch ${index + 1}',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    color: themeProvider.getSecondaryTextColor(context),
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(bool isMobile, ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.only(top: 80),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: isMobile ? 30 : 40,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: themeProvider.getBorderColor(context),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Text(
            '© 2026 Sagar Kalel. All rights reserved.',
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              color: themeProvider.getSecondaryTextColor(context),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final double animationValue;
  final bool isDarkMode;

  BackgroundPainter(this.animationValue, this.isDarkMode);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Create floating gradient circles
    for (int i = 0; i < 3; i++) {
      final offset = Offset(
        size.width * (0.2 + i * 0.3),
        size.height * (0.3 + math.sin(animationValue * 2 * math.pi + i) * 0.1),
      );

      paint.shader = RadialGradient(
        colors: [
          (i.isEven ? const Color(0xFFFF6B6B) : const Color(0xFFFFE66D))
              .withOpacity(isDarkMode ? 0.03 : 0.05),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: offset, radius: 200));

      canvas.drawCircle(offset, 200, paint);
    }
  }

  @override
  bool shouldRepaint(BackgroundPainter oldDelegate) =>
      animationValue != oldDelegate.animationValue ||
      isDarkMode != oldDelegate.isDarkMode;
}
