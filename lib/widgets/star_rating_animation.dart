import 'package:flutter/material.dart';

class StarRatingAnimation extends StatefulWidget {
  final int stars;

  const StarRatingAnimation({Key? key, required this.stars}) : super(key: key);

  @override
  State<StarRatingAnimation> createState() => _StarRatingAnimationState();
}

class _StarRatingAnimationState extends State<StarRatingAnimation> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    
    // Create animation controllers for each star
    _controllers = List.generate(3, (index) {
      return AnimationController(
        duration: Duration(milliseconds: 500 + (index * 300)),
        vsync: this,
      );
    });
    
    // Create animations for each star
    _animations = _controllers.map((controller) {
      return CurvedAnimation(
        parent: controller,
        curve: Curves.elasticOut,
      );
    }).toList();
    
    // Start animations sequentially
    _startAnimations();
  }

  void _startAnimations() async {
    for (int i = 0; i < widget.stars; i++) {
      await Future.delayed(Duration(milliseconds: 300));
      _controllers[i].forward();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Transform.scale(
              scale: index < widget.stars ? _animations[index].value : 1.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(
                  Icons.star,
                  size: 40,
                  color: index < widget.stars ? Colors.amber : Colors.grey.withOpacity(0.3),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
