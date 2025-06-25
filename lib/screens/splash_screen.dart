// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> 
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;
  late AnimationController _backgroundController;
  
  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _progressFade;
  late Animation<Color?> _backgroundGradient;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimations();
    _checkAuthStatus();
  }

  void _initAnimations() {
    _logoController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _textController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _logoScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoRotation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    ));

    _textFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ));

    _textSlide = Tween<Offset>(
      begin: Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutBack,
    ));

    _progressFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeIn,
    ));

    _backgroundGradient = ColorTween(
      begin: Color(0xFF667EEA),
      end: Color(0xFF764BA2),
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() async {
    _backgroundController.repeat(reverse: true);
    
    await Future.delayed(Duration(milliseconds: 300));
    _logoController.forward();
    
    await Future.delayed(Duration(milliseconds: 800));
    _textController.forward();
    
    await Future.delayed(Duration(milliseconds: 500));
    _progressController.forward();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(Duration(milliseconds: 3000));
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkAuthStatus();

    await _logoController.reverse();
    await _textController.reverse();
    await _progressController.reverse();

    if (mounted) {
      if (authProvider.isAuthenticated) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF667EEA),
                  _backgroundGradient.value ?? Color(0xFF764BA2),
                  Color(0xFF6B73FF),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Responsive sizing berdasarkan screen height
                  double logoSize = constraints.maxHeight < 600 ? 80 : 120;
                  double titleSize = constraints.maxHeight < 600 ? 24 : 32;
                  double subtitleSize = constraints.maxHeight < 600 ? 12 : 16;
                  
                  return Column(
                    children: [
                      // Top decorative elements - Flexible height
                      Flexible(
                        flex: 2,
                        child: Container(
                          child: Stack(
                            children: [
                              // Floating circles decoration
                              Positioned(
                                top: 30,
                                right: 30,
                                child: _buildFloatingCircle(40, Colors.white.withOpacity(0.1)),
                              ),
                              Positioned(
                                top: 80,
                                left: 40,
                                child: _buildFloatingCircle(25, Colors.white.withOpacity(0.05)),
                              ),
                              Positioned(
                                top: 50,
                                left: 120,
                                child: _buildFloatingCircle(15, Colors.white.withOpacity(0.08)),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Main content - Fixed flex
                      Expanded(
                        flex: 4,
                        child: Center(
                          child: SingleChildScrollView( // Tambahkan scroll untuk safety
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min, // Penting untuk mencegah overflow
                              children: [
                                // Logo with animation
                                AnimatedBuilder(
                                  animation: _logoController,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: _logoScale.value,
                                      child: Transform.rotate(
                                        angle: _logoRotation.value * 0.1,
                                        child: Container(
                                          width: logoSize,
                                          height: logoSize,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.2),
                                                blurRadius: 20,
                                                offset: Offset(0, 10),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.explore,
                                                  size: logoSize * 0.4,
                                                  color: Color(0xFF667EEA),
                                                ),
                                                Text(
                                                  'LM',
                                                  style: TextStyle(
                                                    fontSize: logoSize * 0.13,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF667EEA),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                SizedBox(height: constraints.maxHeight < 600 ? 20 : 40),

                                // App name with animation
                                SlideTransition(
                                  position: _textSlide,
                                  child: FadeTransition(
                                    opacity: _textFade,
                                    child: Column(
                                      children: [
                                        Text(
                                          'LIWUMOKESA',
                                          style: TextStyle(
                                            fontSize: titleSize,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 2,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black.withOpacity(0.3),
                                                offset: Offset(0, 2),
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 16, 
                                            vertical: 6
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            'Tourism & Travel',
                                            style: TextStyle(
                                              fontSize: subtitleSize,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                SizedBox(height: constraints.maxHeight < 600 ? 20 : 50),

                                // Loading indicator with animation
                                FadeTransition(
                                  opacity: _progressFade,
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 30,
                                        height: 30,
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          strokeWidth: 3,
                                        ),
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        'Memuat pengalaman amazing...',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: constraints.maxHeight < 600 ? 11 : 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Bottom section - Flexible height
                      Flexible(
                        flex: 1,
                        child: Container(
                          alignment: Alignment.bottomCenter,
                          padding: EdgeInsets.only(bottom: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Discover Amazing Places',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: constraints.maxHeight < 600 ? 10 : 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Version 1.0.0',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: constraints.maxHeight < 600 ? 8 : 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingCircle(double size, Color color) {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            5 * (_backgroundController.value * 2 - 1),
          ),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
