import 'package:flutter/foundation.dart';
import '../../data/models/panic_response.dart';

class GemmaModelService {
  bool _initialized = true;
  bool _isReady = true;

  bool get isInitialized => _initialized;
  bool get isReady => _isReady;

  Future<void> initialize() async {
    _initialized = true;
    _isReady = true;
  }

  Future<void> initializeModel() async {
    _initialized = true;
    _isReady = true;
  }

  Future<String> rewriteStructuredResponse({
    required String userMessage,
    required PanicResponse panicResponse,
  }) async {
    final c = panicResponse.response;
    return '''
I understand your situation: ${c.understandingUserQuery}

Please take heart in this biblical truth: ${c.biblicalExplanation}. Just as we see in scripture (${c.biblicalStoryExample}), God's love and support are ever-present. Keep these passages in mind: ${c.recommendedVerses.join(', ')}.

Let us pray: ${c.shortPrayer}
'''.trim();
  }

  Future<String> generateResponse(String prompt) async {
    debugPrint('Mock Gemma generating response...');
    
    final lowerPrompt = prompt.toLowerCase();
    
    // Check if it's a prayer points or journal reflection prompt
    if (lowerPrompt.contains('prayer points') || lowerPrompt.contains('daily prayer points') || lowerPrompt.contains('numbered lines')) {
      final emotion = _extractField(prompt, 'Detected emotional state').isEmpty 
          ? _extractField(prompt, 'Detected emotions')
          : _extractField(prompt, 'Detected emotional state');
      final verses = _extractVerses(prompt);
      final cleanEmotion = emotion.isNotEmpty ? emotion : 'peace';
      final cleanVerse = verses.isNotEmpty 
          ? verses.split('\n').first 
          : 'God is our refuge and strength';

      return '''
1. Lord, bring comfort and strength as they navigate feelings of $cleanEmotion today.
2. Grant them the grace to reflect on scripture: "$cleanVerse".
3. Guide their steps in hope and peace, trusting in Your faithful promises.
'''.trim();
    }
    
    // Check if it's a rewrite prompt
    if (lowerPrompt.contains('rewrite the following structured guidance')) {
      final userMessage = _extractUserProblem(prompt);
      final explanation = _extractField(prompt, 'Biblical Explanation');
      final story = _extractField(prompt, 'Biblical Story Example');
      final prayer = _extractField(prompt, 'Short Prayer');
      
      return '''
I understand you are facing challenges with "$userMessage". 

Please remember this biblical truth: $explanation. Just as shown in the biblical story of $story, God is always ready to guide and strengthen you.

Let us pray: $prayer
'''.trim();
    }
    
    // Default: guidance / panic prompt
    final userMessage = _extractUserProblem(prompt);
    final emotion = _extractField(prompt, 'Detected emotional state').isEmpty 
        ? _extractField(prompt, 'Detected emotion') 
        : _extractField(prompt, 'Detected emotional state');
    final verses = _extractVerses(prompt);
    
    final cleanEmotion = emotion.isNotEmpty ? emotion : 'peace';
    final cleanUserMessage = userMessage.isNotEmpty ? userMessage : 'your current struggle';
    final cleanVerses = verses.isNotEmpty 
        ? verses 
        : 'God is our refuge and strength, a very present help in trouble.';

    return '''
I hear that you are going through a difficult time with "$cleanUserMessage", and experiencing feelings of $cleanEmotion. It is completely natural to feel this way during such struggles.

In moments like these, we can turn to God's Word for strength. The scriptures remind us of His enduring love:

$cleanVerses

As we reflect on this truth, we are reminded that God is our refuge, a present help in times of trouble, and He will never leave you nor forsake you.

Dear Lord, thank You for being a source of comfort and guidance in all seasons of life. We pray that You grant peace and strength to this heart as they navigate these difficulties. Walk with them and fill them with Your grace. Amen.
'''.trim();
  }

  Future<String> generateFromPrompt(String prompt) async {
    return generateResponse(prompt);
  }

  String get modelPathOrEmpty => '';

  String _extractField(String prompt, String fieldName) {
    final regex = RegExp(fieldName + r':?\s*([^\n]+)', caseSensitive: false);
    final match = regex.firstMatch(prompt);
    if (match != null) {
      return match.group(1)!.trim().replaceAll('"', '');
    }
    return '';
  }

  String _extractUserProblem(String prompt) {
    final regex = RegExp(
      r'(?:User problem|User message|User context for today):\s*"?([^"\n\r]+)"?',
      caseSensitive: false,
    );
    final match = regex.firstMatch(prompt);
    if (match != null) {
      return match.group(1)!.trim();
    }
    return '';
  }

  String _extractVerses(String prompt) {
    final startIdx = prompt.indexOf('Relevant scripture text:');
    if (startIdx != -1) {
      final endIdx = prompt.indexOf('Based on these scriptures', startIdx);
      if (endIdx != -1) {
        return prompt.substring(startIdx + 'Relevant scripture text:'.length, endIdx).trim();
      }
      return prompt.substring(startIdx + 'Relevant scripture text:'.length).trim();
    }
    
    final altStartIdx = prompt.indexOf('Relevant Bible verses:');
    if (altStartIdx != -1) {
      final altEndIdx = prompt.indexOf('Generate exactly 3', altStartIdx);
      if (altEndIdx != -1) {
        return prompt.substring(altStartIdx + 'Relevant Bible verses:'.length, altEndIdx).trim();
      }
      return prompt.substring(altStartIdx + 'Relevant Bible verses:'.length).trim();
    }
    
    final thirdStartIdx = prompt.indexOf('Relevant verses:');
    if (thirdStartIdx != -1) {
      final thirdEndIdx = prompt.indexOf('Generate exactly 3', thirdStartIdx);
      if (thirdEndIdx != -1) {
        return prompt.substring(thirdStartIdx + 'Relevant verses:'.length, thirdEndIdx).trim();
      }
      return prompt.substring(thirdStartIdx + 'Relevant verses:'.length).trim();
    }
    
    return '';
  }
}
