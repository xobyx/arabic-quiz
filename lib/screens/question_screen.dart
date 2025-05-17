import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quiz_provider.dart';
import '../models/game_progress.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/animated_progress_bar.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';

class QuestionScreen extends StatefulWidget {
  final int stageId;
  final String stageName;
  final int? timeLimit;

  const QuestionScreen({
    Key? key,
    required this.stageId,
    required this.stageName,
    this.timeLimit,
  }) : super(key: key);

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> with TickerProviderStateMixin {
  int _selectedIndex = -1;
  bool _showFeedback = false;
  bool _isCorrect = false;
  int _remainingTime = 0;
  late AnimationController _timerController;
  late AnimationController _buttonController;
  late Animation<double> _buttonAnimation;
  Timer? _timer;
  bool _isButtonDisabled = false;
  late AnimationController _feedbackAnimationController;
  OverlayEntry? _overlayEntry;
  // Initialize with empty list instead of late
  List<AnimationController> _optionControllers = [];
  List<Animation<double>> _optionAnimations = [];

  @override
  void initState() {
    super.initState();
    
    // Button animation controller
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _buttonAnimation = CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeInOut,
    );
    
    // Initialize timer if time limit is set
    if (widget.timeLimit != null) {
      _remainingTime = widget.timeLimit!;
      _timerController = AnimationController(
        vsync: this,
        duration: Duration(seconds: widget.timeLimit!),
      );
      _timerController.reverse(from: 1.0);
      
      _startTimer();
    }
    
    // Feedback animation controller
    _feedbackAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    // Start the button animation
    _buttonController.forward();
    
    // We'll initialize option animations in didChangeDependencies
    // after we have access to the provider
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initOptionAnimations();
  }
  
  void _initOptionAnimations() {
    try {
      // Get access to the provider
      final quizProvider = Provider.of<QuizProvider>(context, listen: false);
      final currentQuestion = quizProvider.getCurrentQuestion();
      
      // Dispose previous controllers if they exist
      for (var controller in _optionControllers) {
        controller.dispose();
      }
      
      // Create new controllers and animations
      _optionControllers = List.generate(
        currentQuestion.options.length,
        (index) => AnimationController(
          vsync: this,
          duration: Duration(milliseconds: 400 + (index * 100)),
        ),
      );
      
      _optionAnimations = _optionControllers.map((controller) {
        return CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        );
      }).toList();
      
      // Start the animations
      for (var controller in _optionControllers) {
        controller.forward();
      }
    } catch (e) {
      // Handle the case where we can't get the provider or question yet
      // Just leave the lists empty - we'll check their length in build()
      print("Error initializing option animations: $e");
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
          _timerController.value = _remainingTime / widget.timeLimit!;
          
          // Make timer pulse when it's running low
          if (_remainingTime <= 5) {
            _buttonController.forward();
            _buttonController.reverse();
          }
        } else {
          _timer?.cancel();
          // Time's up - move to next question
          final quizProvider = Provider.of<QuizProvider>(context, listen: false);
          _nextQuestion(quizProvider);
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _buttonController.dispose();
    
    if (widget.timeLimit != null) {
      _timerController.dispose();
    }
    
    // Dispose option controllers
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    
    _feedbackAnimationController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _checkAnswer(int index, QuizProvider quizProvider) {
    if (_showFeedback || _isButtonDisabled) return; // Prevent multiple selections
    
    setState(() {
      _isButtonDisabled = true;
    });
    
    final isCorrect = quizProvider.isCorrectAnswer(index);
    
    setState(() {
      _selectedIndex = index;
      _showFeedback = true;
      _isCorrect = isCorrect;
    });
    
    // Vibration feedback would be added here in a real app
    
    // Play feedback animation
    if (isCorrect) {
      _playCorrectAnimation();
    } else {
      _playIncorrectAnimation();
    }
    
    // Automatically move to next question after delay
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        _nextQuestion(quizProvider);
      }
    });
  }
  
  void _playCorrectAnimation() {
    _feedbackAnimationController.reset();
    
    _removeOverlay(); // Remove any existing overlay
    
    // Create and insert overlay with Lottie animation
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: SizedBox(
              width: 400,
              height: 400,
              child: Lottie.asset(
                'assets/animations/correct_answer.json',
                controller: _feedbackAnimationController,
                onLoaded: (composition) {
                  _feedbackAnimationController.duration = composition.duration;
                  _feedbackAnimationController.forward().then((_) {
                    Future.delayed(const Duration(milliseconds: 300), () {
                      _removeOverlay();
                    });
                  });
                },
              ),
            ),
          ),
        ),
      ),
    );
    
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _playIncorrectAnimation() {
    _feedbackAnimationController.reset();
    
    _removeOverlay(); // Remove any existing overlay
    
    // Create and insert overlay with Lottie animation
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: SizedBox(
              width: 400,
              height: 400,
              child: Lottie.asset(
                'assets/animations/incorrect_answer.json',
                controller: _feedbackAnimationController,
                onLoaded: (composition) {
                  _feedbackAnimationController.duration = composition.duration;
                  _feedbackAnimationController.forward().then((_) {
                    Future.delayed(const Duration(milliseconds: 300), () {
                      _removeOverlay();
                    });
                  });
                },
              ),
            ),
          ),
        ),
      ),
    );
    
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _nextQuestion(QuizProvider quizProvider) {
    // Store the selected index before resetting it
    final selectedIndex = _selectedIndex;
    
    setState(() {
      _showFeedback = false;
      _selectedIndex = -1;
      _isButtonDisabled = false;
    });
    
    // Use the stored index for scoring
    quizProvider.answerQuestion(selectedIndex);
    
    // Reset timer for next question if applicable
    if (widget.timeLimit != null && quizProvider.currentQuestionIndex < quizProvider.totalQuestions - 1) {
      _remainingTime = widget.timeLimit!;
      _timerController.value = 1.0;
      _timerController.reverse(from: 1.0);
      
      // Reset and restart option animations
      _initOptionAnimations();
    } else if (_timer != null) {
      _timer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, child) {
        // Check if quiz is complete
        if (quizProvider.isQuizComplete) {
          // Navigate to results screen
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(
              context,
              '/result',
              arguments: {
                'stageId': widget.stageId,
                'stageName': widget.stageName,
              },
            );
          });
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple.shade700),
            )
          );
        }

        final currentQuestion = quizProvider.getCurrentQuestion();
        final questionNumber = quizProvider.currentQuestionIndex + 1;
        final totalQuestions = quizProvider.totalQuestions;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Text(
              'المرحلة: ${widget.stageName}',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            actions: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Colors.purple.shade800.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${quizProvider.score}',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.purple.shade800,
                  Colors.purple.shade600,
                  Colors.deepPurple.shade400,
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Progress indicator
                    Row(
                      children: [
                        Text(
                          'السؤال $questionNumber من $totalQuestions',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AnimatedProgressBar(
                            value: questionNumber / totalQuestions,
                            height: 10,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor: Colors.amber,
                            borderRadius: 5,
                          ),
                        ),
                      ],
                    ),
                    
                    // Timer if applicable
                    if (widget.timeLimit != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Row(
                          children: [
                            ScaleTransition(
                              scale: _remainingTime <= 5 ? _buttonAnimation : const AlwaysStoppedAnimation(1.0),
                              child: Icon(
                                Icons.timer,
                                size: 20,
                                color: _remainingTime <= 5 ? Colors.red : Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '$_remainingTime ثانية',
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _remainingTime <= 5 ? Colors.red : Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AnimatedProgressBar(
                                value: _remainingTime / (widget.timeLimit ?? 1),
                                height: 10,
                                backgroundColor: Colors.white.withOpacity(0.3),
                                valueColor: _remainingTime <= 5 ? Colors.red : Colors.green,
                                borderRadius: 5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: 30),
                    
                    // Question card
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            children: [
                              // Decorative elements
                              Positioned(
                                right: -20,
                                top: -20,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.purple.shade100.withOpacity(0.3),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: -30,
                                bottom: -30,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.purple.shade200.withOpacity(0.3),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              // Question content
                              Center(
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Text(
                                    currentQuestion.questionText,
                                    style: GoogleFonts.cairo(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple.shade900,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Answer options
                    Expanded(
                      flex: 3,
                      child: _optionControllers.isNotEmpty 
                        ? ListView.builder(
                            itemCount: currentQuestion.options.length,
                            itemBuilder: (context, index) {
                              final option = currentQuestion.options[index];
                              final isSelected = _selectedIndex == index;
                              final isCorrectAnswer = currentQuestion.correctAnswerIndex == index;
                              
                              // Determine button styles based on selection and feedback state
                              Color buttonColor;
                              IconData? buttonIcon;
                              
                              if (_showFeedback) {
                                if (isCorrectAnswer) {
                                  buttonColor = Colors.green;
                                  buttonIcon = Icons.check_circle;
                                } else if (isSelected) {
                                  buttonColor = Colors.red;
                                  buttonIcon = Icons.cancel;
                                } else {
                                  buttonColor = Colors.white;
                                  buttonIcon = null;
                                }
                              } else {
                                buttonColor = isSelected ? Colors.purple.shade700 : Colors.white;
                                buttonIcon = null;
                              }
                              
                              return SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(1, 0),
                                  end: Offset.zero,
                                ).animate(_optionAnimations[index]),
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Material(
                                    color: buttonColor,
                                    borderRadius: BorderRadius.circular(15),
                                    elevation: 3,
                                    child: InkWell(
                                      onTap: _showFeedback || _isButtonDisabled
                                          ? null
                                          : () => _checkAnswer(index, quizProvider),
                                      borderRadius: BorderRadius.circular(15),
                                      splashColor: Colors.purple.withOpacity(0.3),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16.0,
                                          horizontal: 20.0,
                                        ),
                                        child: Row(
                                          children: [
                                            if (buttonIcon != null)
                                              Icon(
                                                buttonIcon,
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                            Expanded(
                                              child: Text(
                                                option,
                                                style: GoogleFonts.cairo(
                                                  fontSize: 18,
                                                  color: isSelected || (_showFeedback && isCorrectAnswer)
                                                      ? Colors.white
                                                      : Colors.purple.shade900,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                    ),
                    
                    const SizedBox(height: 10),
                    
                    // Feedback message with animation
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: _showFeedback ? 70 : 0,
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: _showFeedback
                          ? Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _isCorrect 
                                  ? Colors.green.withOpacity(0.8)
                                  : Colors.red.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _isCorrect ? Icons.check_circle : Icons.cancel,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    _isCorrect ? 'إجابة صحيحة! 👏' : 'إجابة خاطئة! 😔',
                                    style: GoogleFonts.cairo(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}