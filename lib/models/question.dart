class Question {
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final String? explanation;
  
  // To track randomized options
  List<int> _originalToCurrentMapping = [];
  
  Question({
    required this.questionText, 
    required this.options, 
    required this.correctAnswerIndex,
    this.explanation,
  }) {
    _resetMapping();
  }
  
  // Reset the mapping of original indexes to current indexes
  void _resetMapping() {
    _originalToCurrentMapping = List.generate(options.length, (index) => index);
  }
  
  // Get the current correct answer index (after randomization)
  int get currentCorrectAnswerIndex {
    return _originalToCurrentMapping.indexOf(correctAnswerIndex);
  }
  
  // Randomize the answer options
  void randomizeOptions() {
    // Create a list of (current index, option text) pairs
    final List<MapEntry<int, String>> optionEntries = [];
    for (int i = 0; i < options.length; i++) {
      optionEntries.add(MapEntry(i, options[i]));
    }
    
    // Shuffle the entries
    optionEntries.shuffle();
    
    // Update the mapping
    for (int newIndex = 0; newIndex < optionEntries.length; newIndex++) {
      final originalIndex = optionEntries[newIndex].key;
      _originalToCurrentMapping[newIndex] = originalIndex;
    }
    
    // Update the options list
    final List<String> newOptions = optionEntries.map((e) => e.value).toList();
    options.clear();
    options.addAll(newOptions);
  }
}