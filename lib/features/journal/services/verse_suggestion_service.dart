import '../../../core/services/local_bible_service.dart';
import '../../../data/repositories/bible_repository.dart';
import '../models/verse_of_day.dart';

/// Maps emotional states to a rotating set of Bible verses.
///
/// Priority: local NLT dataset via [LocalBibleService] -> repository lookup ->
/// hard-coded fallback texts.
class VerseSuggestionService {
  VerseSuggestionService({
    required this.bibleRepo,
    required LocalBibleService localBible,
  }) : _localBible = localBible;

  final BibleRepository bibleRepo;
  final LocalBibleService _localBible;

  static const _emotionReferences = <String, List<String>>{
    'anxiety': ['Philippians 4:6', '1 Peter 5:7', 'Matthew 6:34'],
    'fear': ['Isaiah 41:10', 'Psalms 56:3', '2 Timothy 1:7'],
    'sadness': ['Psalms 34:18', 'John 14:27', 'Psalms 147:3'],
    'loneliness': ['Matthew 28:20', 'Deuteronomy 31:6', 'Psalms 139:7'],
    'anger': ['James 1:19', 'Ephesians 4:26', 'Proverbs 15:1'],
    'temptation': ['1 Corinthians 10:13', 'James 4:7', 'Psalms 119:11'],
    'guilt': ['1 John 1:9', 'Romans 8:1', 'Psalms 103:12'],
    'hopelessness': ['Jeremiah 29:11', 'Romans 15:13', 'Isaiah 40:31'],
    'confusion': ['Proverbs 3:5', 'James 1:5', 'Psalms 32:8'],
    'gratitude': ['Psalms 100:4', '1 Thessalonians 5:18', 'Colossians 3:15'],
    'joy': ['Psalms 32:11', 'Nehemiah 8:10', 'John 15:11'],
    'doubt': ['Mark 11:24', 'Mark 9:24', 'Hebrews 11:1'],
    'exhaustion': ['Isaiah 40:31', 'Matthew 11:28', 'Psalms 23:1'],
    'peace': ['Psalms 46:10', 'Philippians 4:7', 'John 16:33'],
    'grief': ['Romans 8:28', 'Psalms 30:5', 'Revelation 21:4'],
    'faithfulness': ['Lamentations 3:23', 'Hebrews 10:23', 'Psalms 89:1'],
    'endurance': ['Hebrews 12:1', 'Romans 5:3', 'Galatians 6:9'],
    'strength': ['Psalms 27:1', 'Philippians 4:13', 'Psalms 18:2'],
  };

  static const _fallbacks = <String, String>{
    'Philippians 4:6':
        'Be careful for nothing; but in every thing by prayer and supplication '
        'with thanksgiving let your requests be made known unto God.',
    'Isaiah 41:10':
        'Fear thou not; for I am with thee: be not dismayed; for I am thy God: '
        'I will strengthen thee; yea, I will help thee; yea, I will uphold thee '
        'with the right hand of my righteousness.',
    'Psalms 34:18':
        'The LORD is nigh unto them that are of a broken heart; and saveth such '
        'as be of a contrite spirit.',
    'Matthew 28:20':
        'Teaching them to observe all things whatsoever I have commanded you: '
        'and, lo, I am with you always, even unto the end of the world. Amen.',
    'James 1:19':
        'Wherefore, my beloved brethren, let every man be swift to hear, slow '
        'to speak, slow to wrath:',
    '1 Corinthians 10:13':
        'There hath no temptation taken you but such as is common to man: but '
        'God is faithful, who will not suffer you to be tempted above that ye '
        'are able; but will with the temptation also make a way to escape, that '
        'ye may be able to bear it.',
    '1 John 1:9':
        'If we confess our sins, he is faithful and just to forgive us our sins, '
        'and to cleanse us from all unrighteousness.',
    'Jeremiah 29:11':
        'For I know the thoughts that I think toward you, saith the LORD, '
        'thoughts of peace, and not of evil, to give you an expected end.',
    'Proverbs 3:5':
        'Trust in the LORD with all thine heart; and lean not unto thine own '
        'understanding.',
    'Psalms 100:4':
        'Enter into his gates with thanksgiving, and into his courts with '
        'praise: be thankful unto him, and bless his name.',
    'Psalms 32:11':
        'Be glad in the LORD, and rejoice, ye righteous: and shout for joy, '
        'all ye that are upright in heart.',
    'Mark 11:24':
        'Therefore I say unto you, What things soever ye desire, when ye pray, '
        'believe that ye receive them, and ye shall have them.',
    'Isaiah 40:31':
        'But they that wait upon the LORD shall renew their strength; they shall '
        'mount up with wings as eagles; they shall run, and not be weary; and '
        'they shall walk, and not faint.',
    'Psalms 46:10':
        'Be still, and know that I am God: I will be exalted among the heathen, '
        'I will be exalted in the earth.',
    'Romans 8:28':
        'And we know that all things work together for good to them that love '
        'God, to them who are the called according to his purpose.',
    'Lamentations 3:23':
        'They are new every morning: great is thy faithfulness.',
    'Hebrews 12:1':
        'Wherefore seeing we also are compassed about with so great a cloud of '
        'witnesses, let us lay aside every weight, and the sin which doth so '
        'easily beset us, and let us run with patience the race that is set '
        'before us.',
    'Psalms 27:1':
        'The LORD is my light and my salvation; whom shall I fear? the LORD is '
        'the strength of my life; of whom shall I be afraid?',
  };

  /// Returns a [VerseOfDay] for [emotion], rotating by the current date.
  Future<VerseOfDay> getVerseForEmotion(String emotion) async {
    return getVerseForEmotionOnDate(emotion, DateTime.now());
  }

  /// Returns a date-based verse rotation for [emotion].
  Future<VerseOfDay> getVerseForEmotionOnDate(String emotion, DateTime date) async {
    final resolvedEmotion =
        _emotionReferences.containsKey(emotion) ? emotion : 'peace';

    final refs = _emotionReferences[resolvedEmotion] ?? _emotionReferences['peace']!;
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    final idx = (dayOfYear + resolvedEmotion.hashCode.abs()) % refs.length;
    final reference = refs[idx];

    return _getVerseForReference(reference, resolvedEmotion);
  }

  Future<VerseOfDay> _getVerseForReference(String reference, String emotion) async {
    try {
      final localVerse = _localBible.getPassage(reference);
      return VerseOfDay(
        reference: localVerse.reference,
        text: localVerse.text,
        emotion: emotion,
      );
    } catch (_) {
      // Fall through to repository lookup.
    }

    String text;
    try {
      final match = RegExp(r'^(.+)\s+(\d+):(\d+)$').firstMatch(reference);
      if (match == null) {
        throw StateError('Unparseable reference: $reference');
      }
      final book = match.group(1)!;
      final chapter = int.parse(match.group(2)!);
      final verseNum = int.parse(match.group(3)!);

      final verse = bibleRepo.getVerse(BibleRepository.defaultTranslation, book, chapter, verseNum);
      text = verse?.text ?? _fallbacks[reference] ?? reference;
    } catch (_) {
      text = _fallbacks[reference] ?? reference;
    }

    return VerseOfDay(reference: reference, text: text, emotion: emotion);
  }
}
