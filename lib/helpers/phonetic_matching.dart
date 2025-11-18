// this implementation was created with the help of Claude AI.
// I tried to import the soundex or phonetics dart package but they were outdated
// Claude helped me recreate the implementation for homophone matching with regex
// The comments are all mine so that I could understand what's happening step by step

/*
Example - "FOUR" vs "FOR":

FOUR: F-O-U-R → F-0-0-6 → F-6 → F600
FOR: F-O-R → F-0-6 → F-6 → F600
Both get the same code! 
*/

class PhoneticsHelper {
  static String soundex(String word) {
    if (word.isEmpty) return '';

    // remove non-letters (i.e. 'it's' should equal 'its' in
    // pronunciation matching)
    word = word.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    if (word.isEmpty) return '';

    final first = word[0];

    // Replace similar consonants with the same digit
    word = word.replaceAllMapped(RegExp(r'[BFPV]'), (_) => '1');
    word = word.replaceAllMapped(RegExp(r'[CGJKQSXZ]'), (_) => '2');
    word = word.replaceAllMapped(RegExp(r'[DT]'), (_) => '3');
    word = word.replaceAllMapped(RegExp(r'[L]'), (_) => '4');
    word = word.replaceAllMapped(RegExp(r'[MN]'), (_) => '5');
    word = word.replaceAllMapped(RegExp(r'[R]'), (_) => '6');
    word = word.replaceAll(RegExp(r'[AEIOUHWY]'), '0');

    // Remove duplicate consecutive digits
    word = word.replaceAll(RegExp(r'(\d)\1+'), r'\1');

    // Remove zeros - which are vowels or vowel sounds
    // vowels can be pronounced many different ways and are
    // often the cause for a 'mismatch' i.e. 'for' vs 'four' sound the same
    word = word.replaceAll('0', '');

    // Return first letter + 3 digits from conversion
    // pad with 0's for consistent length
    return ('$first${word.substring(1)}000').substring(0, 4);
  }

  static bool soundsLike(String word1, String word2) {
    return soundex(word1) == soundex(word2);
  }
}
