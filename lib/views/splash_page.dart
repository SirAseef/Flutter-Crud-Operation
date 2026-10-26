import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

// SplashPage app ki starting screen hai jo app open hone par show hoti hai.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  // SplashPage ki state create karta hai.
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  // Timer ko store karta hai taake baad mein usay cancel bhi kar sakein.
  late final Timer _timer;

  @override
  void initState() {
    super.initState();

    // Screen load hone ke baad 1600 milliseconds yani 1.6 seconds ka timer start hota hai.
    _timer = Timer(const Duration(milliseconds: 1600), () {
      // Check karta hai ke SplashPage abhi screen par active hai ya nahi.
      // Agar active hai to GetX ki madad se Home screen par navigate karta hai.
      // offAllNamed('/home') purani navigation history ko remove kar deta hai.
      if (mounted) Get.offAllNamed('/home');
    });
  }

  @override
  void dispose() {
    // Agar screen timer complete hone se pehle close ho jaye,
    // to timer cancel kar dete hain taake unwanted navigation na ho.
    _timer.cancel();

    // Parent class ka dispose method call karke resources release karte hain.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Current app theme se primary color hasil karta hai.
    // Isi color ko gradient aur decorative effects mein use kiya gaya hai.
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      // DecoratedBox screen ke background par decoration apply karta hai.
      body: DecoratedBox(
        decoration: BoxDecoration(
          // LinearGradient background mein multiple colors ka smooth transition banata hai.
          gradient: LinearGradient(
            colors: [
              const Color(0xFF0F172A), // Background ka pehla dark blue color.
              const Color(0xFF111827), // Background ka doosra dark color.
              primary.withValues(
                alpha: 0.9,
              ), // Theme ka primary color 90% opacity ke saath.
            ],

            // Gradient top-left corner se start hota hai.
            begin: Alignment.topLeft,

            // Gradient bottom-right corner ki taraf jata hai.
            end: Alignment.bottomRight,
          ),
        ),

        // Stack multiple widgets ko ek doosre ke upar display karta hai.
        child: Stack(
          children: [
            // Pehla decorative circle screen ke upper-right area mein show hota hai.
            Positioned(
              top: -60, // Circle ka kuch hissa screen se bahar rahega.
              right: -30,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape:
                      BoxShape.circle, // Container ko circular shape deta hai.
                  color: Colors.white.withValues(
                    alpha: 0.08, // White color ko 8% opacity deta hai.
                  ),
                ),
              ),
            ),

            // Doosra decorative circle screen ke lower-left area mein show hota hai.
            Positioned(
              bottom: -40, // Circle ka kuch hissa screen se bahar rahega.
              left: -20,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary.withValues(
                    alpha: 0.22, // Primary color ko 22% opacity deta hai.
                  ),
                ),
              ),
            ),

            // SafeArea content ko mobile ke status bar aur system areas se safe rakhta hai.
            SafeArea(
              child: LayoutBuilder(
                // Available screen ki height aur width ki information deta hai.
                builder: (context, constraints) => SingleChildScrollView(
                  // Agar content screen mein fit na ho to scrolling allow hoti hai.
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      // Content ki minimum height available screen ke barabar rakhta hai.
                      minHeight: constraints.maxHeight,
                    ),

                    // Main content ko horizontal aur vertical center mein rakhta hai.
                    child: Center(
                      child: TweenAnimationBuilder<double>(
                        // Animation 0.92 scale se start hokar 1.0 par finish hoti hai.
                        // Is se content chhota start hota hai aur smoothly apni original size par aata hai.
                        tween: Tween<double>(begin: 0.92, end: 1),

                        // Animation 700 milliseconds tak chalti hai.
                        duration: const Duration(milliseconds: 700),

                        // Animation ko smooth aur halka bounce effect deta hai.
                        curve: Curves.easeOutBack,

                        // Har animation frame par updated scale value milti hai.
                        builder: (context, scale, child) {
                          // Child widget ko current scale ke mutabiq resize karta hai.
                          return Transform.scale(scale: scale, child: child);
                        },

                        // Yeh child animation ke andar display hone wala main content hai.
                        child: Column(
                          // Column sirf utni height leti hai jitni uske children ko chahiye.
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // App logo ke liye rounded square container banata hai.
                            Container(
                              width: 116,
                              height: 116,
                              decoration: BoxDecoration(
                                // Logo container mein white gradient apply karta hai.
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0.26),
                                    Colors.white.withValues(alpha: 0.08),
                                  ],
                                ),

                                // Logo container ke corners ko round karta hai.
                                borderRadius: BorderRadius.circular(32),

                                // Logo ke around halka white border banata hai.
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  width: 1.2,
                                ),

                                // Logo ke around glowing shadow effect banata hai.
                                boxShadow: [
                                  BoxShadow(
                                    color: primary.withValues(alpha: 0.6),
                                    blurRadius: 30, // Shadow ko soft aur blurred banata hai.
                                    spreadRadius:
                                        1, // Shadow ko thora expand karta hai.
                                  ),
                                ],
                              ),

                              // Inventory ya products ko represent karne wala icon show karta hai.
                              child: const Icon(
                                Icons.inventory_2_rounded,
                                size: 56,
                                color: Colors.white,
                              ),
                            ),

                            // Logo aur app title ke darmiyan 28 pixels ki spacing deta hai.
                            const SizedBox(height: 28),

                            // App ka naam screen par show karta hai.
                            Text(
                              'Easy CRUD',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight
                                        .w800, // Text ko bold banata hai.
                                    color: Colors.white,
                                    letterSpacing: 0.5, // Letters ke darmiyan spacing deta hai.
                                  ),
                            ),

                            // App title aur subtitle ke darmiyan spacing deta hai.
                            const SizedBox(height: 8),

                            // App ke purpose ko short line mein explain karta hai.
                            Text(
                              'Your products, organized.',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 15,
                                letterSpacing: 0.2,
                              ),
                            ),

                            // Subtitle aur loading indicator ke darmiyan spacing deta hai.
                            const SizedBox(height: 30),

                            // Loading indicator ki width 180 pixels set karta hai.
                            SizedBox(
                              width: 180,
                              child: ClipRRect(
                                // Loading bar ke corners ko round karta hai.
                                borderRadius: BorderRadius.circular(50),

                                // Horizontal loading/progress indicator show karta hai.
                                child: LinearProgressIndicator(
                                  minHeight: 6, // Progress bar ki height set karta hai.
                                  // Progress bar ke background ka halka white color.
                                  backgroundColor: Colors.white.withValues(
                                    alpha: 0.18,
                                  ),

                                  // Progress indicator ko white color deta hai.
                                  // value specify nahi ki gayi, is liye indicator continuously animate hota hai.
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
