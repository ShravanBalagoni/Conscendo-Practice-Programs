// Anonymous Apex script to exercise Palindrome.isPalindrome(String)
// Run via: VS Code "SFDX: Execute Anonymous Apex with Currently Selected Text" or Salesforce CLI:
//   sf apex run --file scripts/apex/runPalindrome.apex --target-org <alias>
// This script assumes a global/public static method: Palindrome.isPalindrome(String): Boolean

List<String> samples = new List<String>{
    'madam',
    'racecar',
    'hello',
    'A man, a plan, a canal: Panama',
    'No lemon, no melon',
    '',
    null,
    'Was it a car or a cat I saw?'
};

System.debug('--- Palindrome checks start ---');
for (String s : samples) {
    Boolean result;
    try {
        result = Palindrome.isPalindrome(s);
    } catch (Exception e) {
        System.debug(LoggingLevel.ERROR, 'Error checking "' + s + '": ' + e.getMessage());
        continue;
    }
    System.debug('Input: ' + s + ' => isPalindrome = ' + String.valueOf(result));
}
System.debug('--- Palindrome checks end ---');
