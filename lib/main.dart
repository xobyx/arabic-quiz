import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/game_data.dart';
import 'models/game_progress.dart';
import 'models/quiz_provider.dart';
import 'screens/home_screen.dart';
import 'screens/question_screen.dart';
import 'screens/result_screen.dart';
import 'screens/stage_selection_screen.dart';
import 'package:google_fonts/google_fonts.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load stages data
  final stages = await GameData.loadStages();
  
  // Create game progress with loaded stages
  final gameProgress = GameProgress(stages: stages);
  
  // Load saved progress
  await gameProgress.loadProgress();
  
  runApp(MyApp(gameProgress: gameProgress));
}

class MyApp extends StatelessWidget {
  final GameProgress gameProgress;
  
  const MyApp({super.key, required this.gameProgress});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => QuizProvider()),
        ChangeNotifierProvider.value(value: gameProgress),
      ],
      child: MaterialApp(
        title: 'لعبة الاختبار العربية',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
          useMaterial3: true,
          textTheme: GoogleFonts.cairoTextTheme(Theme.of(context).textTheme),
          //fontFamily: 'Cairo',
          //textTheme: Theme.of(context).textTheme.apply(
            //fontFamily: 'Cairo',
            //bodyColor: Colors.black,
            //displayColor: Colors.black,
          
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/stages': (context) => const StageSelectionScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/question') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => QuestionScreen(
                stageId: args['stageId'],
                stageName: args['stageName'],
                timeLimit: args['timeLimit'],
              ),
            );
          } else if (settings.name == '/result') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => ResultScreen(
                stageId: args['stageId'],
                stageName: args['stageName'],
              ),
            );
          }
          return null;
        },
      ),
    );
  }
}
