/// Utility class for normalising, tokenising, stemming and parsing text.
///
/// All methods are static — no instantiation needed.
class TextProcessingService {
  TextProcessingService._();

  // ── Stopwords ─────────────────────────────────────────────────────────────

  static const Set<String> stopwords = {
    'i', 'a', 'an', 'the', 'is', 'am', 'are', 'was', 'were', 'be', 'been',
    'being', 'have', 'has', 'had', 'do', 'does', 'did', 'will', 'would',
    'could', 'should', 'may', 'might', 'must', 'can', 'feel', 'feeling',
    'felt', 'just', 'very', 'so', 'too', 'really', 'get', 'got', 'like',
    'me', 'my', 'you', 'your', 'we', 'our', 'they', 'their', 'it', 'its',
    'this', 'that', 'these', 'those', 'and', 'or', 'but', 'not', 'no',
    'from', 'to', 'for', 'in', 'on', 'at', 'by', 'with', 'about', 'of',
    'up', 'out', 'if', 'as', 'into', 'through', 'before', 'after', 'each',
    'more', 'other', 'some', 'than', 'then', 'when', 'where', 'who', 'how',
    'all', 'any', 'both', 'because', 'due', 'seeking', 'biblical', 'guidance',
    'since', 'while', 'during', 'such', 'what', 'which', 'there', 'here',
    'also', 'even', 'still', 'well', 'back', 'only', 'thing', 'things',
    'want', 'go', 'going', 'know', 'try', 'make', 'see', 'him', 'her',
    'them', 'his', 'she', 'he', 'one', 'two', 'come',
    'help', 'need', 'please', 'never', 'always', 'much', 'many', 'every',
    'around', 'again', 'today', 'now',
  };

  // ── Canonical token map ───────────────────────────────────────────────────
  // Maps common variant forms to canonical emotional-vocabulary tokens so that
  // "anxious" matches an "anxiety" emotion tag, etc.

  static const Map<String, String> _canonical = {
    'anxious': 'anxiety',
    'anxiously': 'anxiety',
    'anxiousness': 'anxiety',
    'anxieties': 'anxiety',
    'afraid': 'fear',
    'fearful': 'fear',
    'fearfully': 'fear',
    'scared': 'fear',
    'frightened': 'fear',
    'terrified': 'terror',
    'depressed': 'depression',
    'depressing': 'depression',
    'lonely': 'loneliness',
    'alone': 'loneliness',
    'isolated': 'loneliness',
    'abandoned': 'loneliness',
    'angry': 'anger',
    'angrily': 'anger',
    'furious': 'anger',
    'grieving': 'grief',
    'grieve': 'grief',
    'doubting': 'doubt',
    'doubts': 'doubt',
    'guilty': 'guilt',
    'hopeless': 'hopelessness',
    'ashamed': 'shame',
    'shameful': 'shame',
    'stressed': 'stress',
    'stressful': 'stress',
    'worrying': 'worry',
    'worried': 'worry',
    'overwhelmed': 'overwhelm',
    'overwhelming': 'overwhelm',
    'exhausted': 'exhaustion',
    'confused': 'confusion',
    'confusing': 'confusion',
    'tempted': 'temptation',
    'sinful': 'sin',
    'regretful': 'regret',
    'heartbroken': 'heartbreak',
    'worthless': 'worthlessness',
    'faithful': 'faith',
    'prayerful': 'prayer',
    'praying': 'prayer',
    'trusting': 'trust',
    'trusted': 'trust',
    'peaceful': 'peace',
    'forgiving': 'forgiveness',
    'forgiven': 'forgiveness',
    'healed': 'healing',
    'heals': 'healing',
    'weary': 'weariness',
    'brokenhearted': 'heartbreak',
    'suffering': 'suffer',
    'hurting': 'hurt',
    'struggling': 'struggle',
    'struggles': 'struggle',
    'mourning': 'grief',
    'crying': 'grief',
    'hopeful': 'hope',
    'uncertain': 'uncertainty',
    'unsure': 'uncertainty',
    'failing': 'failure',
    'failed': 'failure',
    'rejected': 'rejection',
    'unloved': 'love',
    'unworthy': 'worthlessness',
  };

  // ── Public API ────────────────────────────────────────────────────────────

  /// Lowercases [text] and replaces everything except letters, digits, and
  /// spaces with a space, then collapses runs of whitespace.
  static String normalizeText(String text) => text
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  /// Splits normalised [text] into tokens, discarding tokens of ≤ 2 chars.
  static List<String> tokenize(String text) =>
      normalizeText(text).split(' ').where((t) => t.length > 2).toList();

  /// Removes [stopwords] from [tokens].
  static List<String> removeStopWords(List<String> tokens) =>
      tokens.where((t) => !stopwords.contains(t)).toList();

  /// Applies [_canonical] normalisation to a single token (if a mapping
  /// exists) and returns the canonical form; otherwise returns [token].
  static String canonicalize(String token) => _canonical[token] ?? token;

  /// Full pipeline: normalise → tokenise → remove stopwords → canonicalise.
  ///
  /// Returns the resulting tokens as a [Set<String>].
  static Set<String> process(String text) =>
      removeStopWords(tokenize(text)).map(canonicalize).toSet();

  /// Returns process([text]) **plus** the simple-stem forms of each token,
  /// giving broader recall for partial morphological variants.
  static Set<String> processWithStems(String text) {
    final base = process(text);
    return {...base, ...base.map(stem)};
  }

  // ── Stemming ──────────────────────────────────────────────────────────────

  /// Lightweight English suffix stripper (longest-match first).
  ///
  /// Applied after [canonicalize], so it only needs to cover forms that the
  /// canonical map does not already handle.
  static String stem(String word) {
    if (word.length <= 4) return word;
    // Longest suffixes first.
    if (word.endsWith('nesses')) return word.substring(0, word.length - 4);
    if (word.endsWith('fulness')) return word.substring(0, word.length - 4);
    if (word.endsWith('ousness')) return word.substring(0, word.length - 4);
    if (word.endsWith('iveness')) return word.substring(0, word.length - 4);
    if (word.endsWith('ational')) {
      return '${word.substring(0, word.length - 7)}ate';
    }
    if (word.endsWith('tional')) {
      return '${word.substring(0, word.length - 6)}tion';
    }
    if (word.endsWith('ness')) return word.substring(0, word.length - 4);
    if (word.endsWith('ment')) return word.substring(0, word.length - 4);
    if (word.endsWith('tion')) return word.substring(0, word.length - 3);
    if (word.endsWith('ful')) return word.substring(0, word.length - 3);
    if (word.endsWith('less')) return word.substring(0, word.length - 4);
    if (word.endsWith('ous')) return word.substring(0, word.length - 3);
    if (word.endsWith('ive')) return word.substring(0, word.length - 3);
    if (word.endsWith('ing')) return word.substring(0, word.length - 3);
    if (word.endsWith('ity')) return word.substring(0, word.length - 3);
    if (word.endsWith('ied')) return '${word.substring(0, word.length - 3)}y';
    if (word.endsWith('ies')) return '${word.substring(0, word.length - 3)}y';
    if (word.endsWith('ated')) return word.substring(0, word.length - 2);
    if (word.endsWith('ed')) return word.substring(0, word.length - 2);
    if (word.endsWith('al')) return word.substring(0, word.length - 2);
    if (word.endsWith('ly')) return word.substring(0, word.length - 2);
    if (word.endsWith('er')) return word.substring(0, word.length - 2);
    if (word.endsWith('est')) return word.substring(0, word.length - 3);
    if (word.endsWith('es') && word.length > 5) {
      return word.substring(0, word.length - 2);
    }
    if (word.endsWith('s') && word.length > 4) {
      return word.substring(0, word.length - 1);
    }
    return word;
  }

  // ── Verse reference parsing ───────────────────────────────────────────────

  /// Parses a verse reference string like "Philippians 4:6", "1 John 1:9",
  /// or "Philippians 4:6-7" into its components.
  ///
  /// Returns null when the string is not a recognisable reference.
  static ({String book, int chapter, int verse})? parseVerseRef(String ref) {
    // Greedy book capture, then space, then chapter:verse (optional -end)
    final match = RegExp(r'^(.+)\s+(\d+):(\d+)').firstMatch(ref.trim());
    if (match == null) return null;
    final book = match.group(1)!.trim();
    final chapter = int.tryParse(match.group(2)!);
    final verse = int.tryParse(match.group(3)!);
    if (chapter == null || verse == null || chapter == 0 || verse == 0) {
      return null;
    }
    return (book: book, chapter: chapter, verse: verse);
  }
}
