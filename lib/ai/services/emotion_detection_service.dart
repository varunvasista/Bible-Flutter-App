/// AI-oriented emotional theme detector for journal input.
///
/// This class lives in the AI module to keep inference/analysis concerns
/// separate from feature UI code.
class EmotionDetectionService {
  static const Map<String, String> _keywords = {
    'anxious': 'anxiety',
    'anxiety': 'anxiety',
    'worried': 'anxiety',
    'worry': 'anxiety',
    'stressed': 'anxiety',
    'stress': 'anxiety',
    'nervous': 'anxiety',
    'overwhelmed': 'anxiety',
    'restless': 'anxiety',
    'afraid': 'fear',
    'fear': 'fear',
    'fearful': 'fear',
    'scared': 'fear',
    'terror': 'fear',
    'terrified': 'fear',
    'panic': 'fear',
    'sad': 'sadness',
    'sadness': 'sadness',
    'depressed': 'sadness',
    'depression': 'sadness',
    'unhappy': 'sadness',
    'grief': 'sadness',
    'grieving': 'sadness',
    'crying': 'sadness',
    'cry': 'sadness',
    'weeping': 'sadness',
    'heartbroken': 'sadness',
    'hurt': 'sadness',
    'lonely': 'loneliness',
    'loneliness': 'loneliness',
    'alone': 'loneliness',
    'abandoned': 'loneliness',
    'isolated': 'loneliness',
    'forsaken': 'loneliness',
    'angry': 'anger',
    'anger': 'anger',
    'frustrated': 'anger',
    'frustration': 'anger',
    'furious': 'anger',
    'irritated': 'anger',
    'mad': 'anger',
    'bitter': 'anger',
    'tempted': 'temptation',
    'temptation': 'temptation',
    'tempting': 'temptation',
    'sin': 'temptation',
    'sinful': 'temptation',
    'lust': 'temptation',
    'addicted': 'temptation',
    'addiction': 'temptation',
    'guilty': 'guilt',
    'guilt': 'guilt',
    'shame': 'guilt',
    'ashamed': 'guilt',
    'shameful': 'guilt',
    'regret': 'guilt',
    'regretful': 'guilt',
    'hopeless': 'hopelessness',
    'hopelessness': 'hopelessness',
    'helpless': 'hopelessness',
    'worthless': 'hopelessness',
    'meaningless': 'hopelessness',
    'pointless': 'hopelessness',
    'despair': 'hopelessness',
    'confused': 'confusion',
    'confusion': 'confusion',
    'unsure': 'confusion',
    'uncertain': 'confusion',
    'lost': 'confusion',
    'unclear': 'confusion',
    'doubt': 'doubt',
    'doubting': 'doubt',
    'doubts': 'doubt',
    'unbelief': 'doubt',
    'tired': 'exhaustion',
    'exhausted': 'exhaustion',
    'exhaustion': 'exhaustion',
    'weary': 'exhaustion',
    'burnt out': 'exhaustion',
    'drained': 'exhaustion',
    'burnout': 'exhaustion',
    'grateful': 'gratitude',
    'gratitude': 'gratitude',
    'thankful': 'gratitude',
    'thankfulness': 'gratitude',
    'blessed': 'gratitude',
    'blessing': 'gratitude',
    'thank': 'gratitude',
    'joy': 'joy',
    'joyful': 'joy',
    'happy': 'joy',
    'happiness': 'joy',
    'excited': 'joy',
    'cheerful': 'joy',
    'rejoice': 'joy',
    'celebrate': 'joy',
  };

  List<String> detectEmotions(String text) {
    final lower = text.toLowerCase();
    final found = <String>[];

    for (final entry in _keywords.entries) {
      if (lower.contains(entry.key) && !found.contains(entry.value)) {
        found.add(entry.value);
      }
    }

    return found.isEmpty ? ['peace'] : found;
  }

  /// Returns the single most prominent emotion detected in [text].
  String detectPrimaryEmotion(String text) => detectEmotions(text).first;
}
