/// Generates personalised prayer-starter sentences from a list of emotion labels.
///
/// All computation is synchronous and fully offline — no network or AI service
/// required.
class PrayerGeneratorService {
  static const Map<String, List<String>> _templates = {
    'anxiety': [
      'Lord, I release my worries to You — You carry what I cannot hold.',
      'Father, fill my restless mind with Your peace that surpasses understanding.',
      'Help me trust that You are in control of every detail I am anxious about.',
    ],
    'fear': [
      'Lord, I choose to stand on Your promise: "Fear thou not; for I am with thee."',
      'Father, be my courage when I feel too afraid to move forward.',
      'Remove every fear that is keeping me from stepping into Your purpose for me.',
    ],
    'sadness': [
      'Lord, You are close to the broken-hearted — draw near to me now.',
      'Father, comfort me in this sorrow and remind me that weeping endures only for a night.',
      'Turn my mourning into dancing as only You can.',
    ],
    'loneliness': [
      'Lord, remind my heart that You promised to be with me always, even to the end of the age.',
      'Father, in this lonely moment, let Your presence fill every empty space.',
      'Help me find true belonging in You before I look for it in others.',
    ],
    'anger': [
      'Lord, guard my tongue and help me be slow to speak and slow to wrath.',
      'Father, show me the root beneath my anger and bring healing there.',
      'Give me a spirit of patience and help me respond with grace rather than reaction.',
    ],
    'temptation': [
      'Lord, You promised to always provide a way of escape — show me that way today.',
      'Father, strengthen me to flee from what harms me and run toward what is good.',
      'Renew my desire for You so that it outweighs any lesser longing I feel.',
    ],
    'guilt': [
      'Lord, thank You that if I confess my sins You are faithful and just to forgive.',
      'Father, I receive Your forgiveness and refuse to carry what You have already removed.',
      'Help me walk in freedom rather than being paralysed by past mistakes.',
    ],
    'hopelessness': [
      'Lord, You know the plans You have for me — plans for a future and a hope.',
      'Father, reignite even a small spark of hope in my heart today.',
      'Remind me that Your best gifts often arrive after my darkest seasons.',
    ],
    'confusion': [
      'Lord, grant me wisdom — You give it generously to all who ask.',
      'Father, make my path clear and give me the discernment to recognise Your voice.',
      'Help me stop leaning on my own understanding and trust You with every step.',
    ],
    'doubt': [
      'Lord, I believe — help my unbelief.',
      'Father, strengthen my faith where it has grown thin.',
      'Remind me of the times You came through for me when I doubted before.',
    ],
    'exhaustion': [
      'Lord, I am weary — be my strength to renew and soar again.',
      'Father, as I rest in You, restore what ministry and life have taken from me.',
      'Help me wait upon You so that I do not run ahead of Your provision.',
    ],
    'gratitude': [
      'Lord, thank You — I enter Your presence with thanksgiving in my heart.',
      'Father, open my eyes today to see every blessing I have been overlooking.',
      'Let my gratitude overflow into generosity toward the people around me.',
    ],
    'joy': [
      'Lord, thank You for this gladness — let it be an overflow of my life in You.',
      'Father, deepen this joy so that circumstances cannot take it away.',
      'Help me share this joy as a witness of Your goodness to those around me.',
    ],
    'reflection': [
      'Lord, I come still and quiet, ready to hear whatever You want to say to me.',
      'Father, search my heart today and reveal anything that needs Your attention.',
      'Help me slow down enough to notice where You are already at work in my life.',
    ],
  };

  static const List<String> _defaultPrayers = [
    'Lord, guide my steps today.',
    'Father, let Your will be done in my life.',
    'Help me to honour You in all that I do this day.',
  ];

  /// Returns up to three prayer-starter sentences relevant to [emotions].
  ///
  /// If [emotions] is empty or contains unrecognised labels, returns the
  /// default prayers.
  List<String> generatePrayerPoints(List<String> emotions) {
    final prayers = <String>[];

    for (final emotion in emotions) {
      final list = _templates[emotion];
      if (list != null && prayers.length < 3) {
        // Take only the first unused prayer from this emotion's templates.
        for (final prayer in list) {
          if (!prayers.contains(prayer)) {
            prayers.add(prayer);
            break;
          }
        }
      }
      if (prayers.length >= 3) break;
    }

    if (prayers.isEmpty) return _defaultPrayers;

    // Pad to exactly three if we have fewer.
    if (prayers.length < 3) {
      for (final prayer in _defaultPrayers) {
        if (!prayers.contains(prayer)) {
          prayers.add(prayer);
        }
        if (prayers.length >= 3) break;
      }
    }

    return prayers;
  }
}
