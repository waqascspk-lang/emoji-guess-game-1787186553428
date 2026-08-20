import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => GameProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emoji Guess Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const Home(),
        '/levels': (context) => const LevelSelect(),
        '/game': (context) => const Game(),
        '/results': (context) => const Results(),
      },
    );
  }
}

class Level {
  final int number;
  final List<String> emojis;
  final String word;
  final bool isUnlocked;

  Level({
    required this.number,
    required this.emojis,
    required this.word,
    this.isUnlocked = false,
  });
}

class GameState {
  final Level currentLevel;
  final List<String> guessedLetters;
  final String currentGuess;
  final bool isComplete;

  GameState({
    required this.currentLevel,
    this.guessedLetters = const [],
    this.currentGuess = '',
    this.isComplete = false,
  });

  GameState copyWith({
    Level? currentLevel,
    List<String>? guessedLetters,
    String? currentGuess,
    bool? isComplete,
  }) {
    return GameState(
      currentLevel: currentLevel ?? this.currentLevel,
      guessedLetters: guessedLetters ?? this.guessedLetters,
      currentGuess: currentGuess ?? this.currentGuess,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}

class GameProvider with ChangeNotifier {
  final List<Level> _levels = [
    Level(
      number: 1,
      emojis: ['🐱', '🥛', '🐟', '🐶'],
      word: 'CAT',
      isUnlocked: true,
    ),
    Level(
      number: 2,
      emojis: ['🐶', '💧', '🦴', '🐕'],
      word: 'DOG',
      isUnlocked: true,
    ),
    Level(
      number: 3,
      emojis: ['🏠', '🔑', '🚪', '🛋️'],
      word: 'HOUSE',
      isUnlocked: true,
    ),
    Level(
      number: 4,
      emojis: ['🚗', '🚦', '🛣️', '🚌'],
      word: 'CAR',
      isUnlocked: true,
    ),
    Level(
      number: 5,
      emojis: ['🍎', '🍊', '🍌', '🍇'],
      word: 'FRUIT',
      isUnlocked: true,
    ),
    Level(
      number: 6,
      emojis: ['⚽', '🏀', '🏈', '⚾'],
      word: 'SPORTS',
      isUnlocked: true,
    ),
    Level(
      number: 7,
      emojis: ['🖥️', '💻', '⌨️', '🖱️'],
      word: 'COMPUTER',
      isUnlocked: true,
    ),
    Level(
      number: 8,
      emojis: ['✈️', '🚂', '🚗', '🚌'],
      word: 'VEHICLES',
      isUnlocked: true,
    ),
    Level(
      number: 9,
      emojis: ['🌙', '⭐', '☄️', '🌌'],
      word: 'SPACE',
      isUnlocked: true,
    ),
    Level(
      number: 10,
      emojis: ['👨‍🍳', '🍳', '🍽️', '👨‍🍳'],
      word: 'CHEF',
      isUnlocked: true,
    ),
    Level(
      number: 11,
      emojis: ['📚', '📖', '🎓', '✏️'],
      word: 'SCHOOL',
      isUnlocked: true,
    ),
    Level(
      number: 12,
      emojis: ['🎵', '🎶', '🎸', '🎹'],
      word: 'MUSIC',
      isUnlocked: true,
    ),
  ];

  GameState? _currentState;

  List<Level> get levels => List.unmodifiable(_levels);
  GameState? get currentState => _currentState;
  int get totalLevels => _levels.length;
  int get completedLevels => _levels.where((level) => _isLevelCompleted(level.number)).length;

  bool _isLevelCompleted(int levelNumber) {
    final savedLevel = _levels.firstWhere(
      (level) => level.number == levelNumber,
      orElse: () => Level(number: 0, emojis: [], word: ''),
    );
    return savedLevel.isUnlocked;
  }

  void startLevel(int levelNumber) {
    final level = _levels.firstWhere((l) => l.number == levelNumber);
    _currentState = GameState(
      currentLevel: level,
      guessedLetters: [],
      currentGuess: '',
      isComplete: false,
    );
    notifyListeners();
  }

  void addLetterToGuess(String letter) {
    if (_currentState == null || _currentState!.isComplete) return;
    
    if (_currentState!.currentGuess.length < _currentState!.currentLevel.word.length) {
      final newGuess = _currentState!.currentGuess + letter;
      _currentState = _currentState!.copyWith(
        currentGuess: newGuess,
        guessedLetters: [..._currentState!.guessedLetters, letter],
      );
      
      if (newGuess.length == _currentState!.currentLevel.word.length) {
        checkGuess();
      }
      notifyListeners();
    }
  }

  void removeLastLetter() {
    if (_currentState == null || _currentState!.isComplete) return;
    
    if (_currentState!.currentGuess.isNotEmpty) {
      final newGuess = _currentState!.currentGuess.substring(0, _currentState!.currentGuess.length - 1);
      final newGuessedLetters = List<String>.from(_currentState!.guessedLetters);
      newGuessedLetters.removeLast();
      
      _currentState = _currentState!.copyWith(
        currentGuess: newGuess,
        guessedLetters: newGuessedLetters,
      );
      notifyListeners();
    }
  }

  void checkGuess() {
    if (_currentState == null) return;
    
    final isCorrect = _currentState!.currentGuess == _currentState!.currentLevel.word;
    
    if (isCorrect) {
      _currentState = _currentState!.copyWith(isComplete: true);
      _completeLevel(_currentState!.currentLevel.number);
    }
    
    notifyListeners();
  }

  void _completeLevel(int levelNumber) {
    final index = _levels.indexWhere((level) => level.number == levelNumber);
    if (index != -1) {
      _levels[index] = Level(
        number: _levels[index].number,
        emojis: _levels[index].emojis,
        word: _levels[index].word,
        isUnlocked: true,
      );
    }
    
    final nextIndex = _levels.indexWhere((level) => level.number == levelNumber + 1);
    if (nextIndex != -1) {
      _levels[nextIndex] = Level(
        number: _levels[nextIndex].number,
        emojis: _levels[nextIndex].emojis,
        word: _levels[nextIndex].word,
        isUnlocked: true,
      );
    }
  }

  void resetLevel() {
    if (_currentState == null) return;
    
    _currentState = _currentState!.copyWith(
      guessedLetters: [],
      currentGuess: '',
      isComplete: false,
    );
    notifyListeners();
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.emoji_emotions,
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 30),
              const Text(
                'Emoji Guess',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '4 Pictures 1 Word',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/levels');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF4A90E2),
                ),
                child: const Text(
                  'PLAY',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/levels');
                },
                child: const Text(
                  'SELECT LEVEL',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LevelSelect extends StatelessWidget {
  const LevelSelect({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Level'),
        backgroundColor: const Color(0xFF4A90E2),
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemCount: gameProvider.totalLevels,
            itemBuilder: (context, index) {
              final level = gameProvider.levels[index];
              final isCompleted = level.isUnlocked;
              
              return GestureDetector(
                onTap: isCompleted
                    ? () {
                        gameProvider.startLevel(level.number);
                        Navigator.pushNamed(context, '/game');
                      }
                    : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: isCompleted ? const Color(0xFF4A90E2) : Colors.grey[300],
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isCompleted)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 30,
                          )
                        else
                          const Icon(
                            Icons.lock,
                            color: Colors.grey,
                            size: 30,
                          ),
                        const SizedBox(height: 10),
                        Text(
                          'Level ${level.number}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isCompleted ? Colors.white : Colors.grey,
                          ),
                        ),
                        if (isCompleted)
                          Text(
                            level.emojis[0],
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class Game extends StatelessWidget {
  const Game({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<GameProvider>(
          builder: (context, gameProvider, child) {
            final currentState = gameProvider.currentState;
            return Text(
              currentState != null
                  ? 'Level ${currentState.currentLevel.number}'
                  : 'Game',
            );
          },
        ),
        backgroundColor: const Color(0xFF4A90E2),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<GameProvider>().resetLevel();
            },
          ),
        ],
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          final currentState = gameProvider.currentState;
          if (currentState == null) {
            return const Center(child: Text('No level selected'));
          }

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Emojis display
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              currentState.currentLevel.emojis[index],
                              style: const TextStyle(fontSize: 50),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                // Word to guess display
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      currentState.currentLevel.word.length,
                      (index) {
                        final letter = index < currentState.currentGuess.length
                            ? currentState.currentGuess[index]
                            : '';
                        
                        return Container(
                          width: 40,
                          height: 50,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: letter.isNotEmpty ? const Color(0xFF4A90E2) : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: letter.isNotEmpty ? const Color(0xFF4A90E2) : Colors.grey,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              letter.toUpperCase(),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: letter.isNotEmpty ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                // Keyboard
                Expanded(
                  flex: 2,
                  child: _buildKeyboard(context, gameProvider),
                ),
                
                // Complete message
                if (currentState.isComplete)
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          'CORRECT!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildKeyboard(BuildContext context, GameProvider gameProvider) {
    final currentState = gameProvider.currentState;
    if (currentState == null) return Container();

    final wordLetters = currentState.currentLevel.word.split('');
    final keyboardLetters = [
      'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
      'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T',
      'U', 'V', 'W', 'X', 'Y', 'Z'
    ];

    // Shuffle keyboard letters
    final shuffledLetters = List<String>.from(keyboardLetters)..shuffle();

    return Container(
      padding: const EdgeInsets.all(10),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: shuffledLetters.length,
        itemBuilder: (context, index) {
          final letter = shuffledLetters[index];
          final isUsed = currentState.guessedLetters.contains(letter);
          
          return ElevatedButton(
            onPressed: isUsed || currentState.isComplete
                ? null
                : () {
                    gameProvider.addLetterToGuess(letter);
                    if (currentState.currentGuess.length == 
                        currentState.currentLevel.word.length) {
                      gameProvider.checkGuess();
                    }
                  },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              backgroundColor: isUsed ? Colors.grey : const Color(0xFF4A90E2),
              foregroundColor: Colors.white,
            ),
            child: Text(
              letter,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }
}

class Results extends StatelessWidget {
  const Results({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
        backgroundColor: const Color(0xFF4A90E2),
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          final currentState = gameProvider.currentState;
          
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.emoji_events,
                  size: 100,
                  color: Colors.amber,
                ),
                const SizedBox(height: 30),
                const Text(
                  'Congratulations!',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 20),
                if (currentState != null)
                  Text(
                    'You completed Level ${currentState.currentLevel.number}',
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.black87,
                    ),
                  ),
                const SizedBox(height: 10),
                if (currentState != null)
                  Text(
                    'The word was: ${currentState.currentLevel.word}',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.grey,
                    ),
                  ),
                const SizedBox(height: 30),
                const Text(
                  'Total Completed:',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '${gameProvider.completedLevels} / ${gameProvider.totalLevels}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/levels');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    backgroundColor: const Color(0xFF4A90E2),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'BACK TO LEVELS',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}