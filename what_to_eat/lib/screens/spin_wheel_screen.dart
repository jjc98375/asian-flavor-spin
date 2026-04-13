import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import '../models/cuisine.dart';
import 'dish_selection_screen.dart';

class SpinWheelScreen extends StatefulWidget {
  const SpinWheelScreen({super.key});

  @override
  State<SpinWheelScreen> createState() => _SpinWheelScreenState();
}

class _SpinWheelScreenState extends State<SpinWheelScreen> {
  final StreamController<int> _controller = StreamController<int>();
  bool _isSpinning = false;
  int _selectedIndex = 0;
  Cuisine? _resultCuisine;

  static const List<Cuisine> _cuisines = Cuisine.values;

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  void _spin() {
    if (_isSpinning) return;
    final index = Random().nextInt(_cuisines.length);
    setState(() {
      _isSpinning = true;
      _resultCuisine = null;
      _selectedIndex = index;
    });
    _controller.add(index);
  }

  void _onAnimationEnd() {
    setState(() {
      _isSpinning = false;
      _resultCuisine = _cuisines[_selectedIndex];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F5),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Title
            Text(
              'What to Eat?',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Spin the wheel and find out!',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            // Fortune Wheel
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth == 0 || constraints.maxHeight == 0) {
                      return const SizedBox.shrink();
                    }
                    final size = constraints.maxWidth < constraints.maxHeight
                        ? constraints.maxWidth
                        : constraints.maxHeight;
                    return Center(
                      child: SizedBox(
                        width: size,
                        height: size,
                        child: FortuneWheel(
                          selected: _controller.stream,
                          animateFirst: false,
                          duration: const Duration(seconds: 4),
                          onAnimationEnd: _onAnimationEnd,
                          indicators: const [
                            FortuneIndicator(
                              alignment: Alignment.topCenter,
                              child: TriangleIndicator(
                                color: Color(0xFF2D2D2D),
                                width: 24,
                                height: 24,
                              ),
                            ),
                          ],
                          items: _cuisines.map((cuisine) {
                            return FortuneItem(
                              style: FortuneItemStyle(
                                color: cuisine.color,
                                borderColor: Colors.white,
                                borderWidth: 3,
                                textStyle: const TextStyle(
                                  fontSize: 28,
                                ),
                              ),
                              child: Text(cuisine.flag),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Result or Spin button
            if (_resultCuisine != null) ...[
              _ResultCard(
                cuisine: _resultCuisine!,
                onLetGo: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          DishSelectionScreen(cuisine: _resultCuisine!),
                    ),
                  );
                },
                onSpinAgain: _spin,
              ),
            ] else ...[
              _SpinButton(onTap: _isSpinning ? null : _spin),
            ],
            const SizedBox(height: 20),
            // Cuisine chips
            _CuisineChips(cuisines: _cuisines),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SpinButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _SpinButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 56,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: onTap != null
                ? const LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFDA77F2)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            color: onTap == null ? const Color(0xFFCCCCCC) : null,
            borderRadius: BorderRadius.circular(28),
            boxShadow: onTap != null
                ? [
                    BoxShadow(
                      color: const Color(0xFFFF6B6B).withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              onTap != null ? 'TAP TO SPIN' : 'SPINNING...',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final Cuisine cuisine;
  final VoidCallback onLetGo;
  final VoidCallback onSpinAgain;

  const _ResultCard({
    required this.cuisine,
    required this.onLetGo,
    required this.onSpinAgain,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cuisine.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: cuisine.color.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Text(cuisine.flag, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cuisine.displayName,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: cuisine.color,
                            ),
                      ),
                      Text(
                        'Your cuisine is selected!',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onLetGo,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: cuisine.color,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      "Let's go!",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onSpinAgain,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.refresh_rounded,
                  size: 16,
                  color: const Color(0xFF999999),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Spin again',
                  style: TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CuisineChips extends StatelessWidget {
  final List<Cuisine> cuisines;

  const _CuisineChips({required this.cuisines});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: cuisines.map((cuisine) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: cuisine.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: cuisine.color.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(cuisine.flag,
                      style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    cuisine.displayName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: cuisine.color,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
