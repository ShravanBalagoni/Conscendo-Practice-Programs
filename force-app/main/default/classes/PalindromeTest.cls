@IsTest
private class PalindromeTest {

    @IsTest
    static void testSimplePalindromes() {
        System.assertEquals(true, Palindrome.isPalindrome(''), 'Empty string should be palindrome');
        System.assertEquals(true, Palindrome.isPalindrome('a'), 'Single character should be palindrome');
        System.assertEquals(true, Palindrome.isPalindrome('aa'), 'Two same chars should be palindrome');
        System.assertEquals(true, Palindrome.isPalindrome('racecar'), 'racecar is a palindrome');
        System.assertEquals(true, Palindrome.isPalindrome('madam'), 'madam is a palindrome');
    }

    @IsTest
    static void testNonPalindromes() {
        System.assertEquals(false, Palindrome.isPalindrome('ab'), 'ab is not palindrome');
        System.assertEquals(false, Palindrome.isPalindrome('abc'), 'abc is not palindrome');
        System.assertEquals(false, Palindrome.isPalindrome('palindrome'), 'palindrome is not palindrome');
    }

    @IsTest
    static void testCaseInsensitivity() {
        System.assertEquals(true, Palindrome.isPalindrome('RaceCar'), 'Case-insensitive palindrome should pass');
        System.assertEquals(true, Palindrome.isPalindrome('NoOn'), 'Mixed case palindrome should pass');
        System.assertEquals(false, Palindrome.isPalindrome('RaceCars'), 'Non-palindrome mixed case should fail');
    }

    @IsTest
    static void testIgnoreNonAlphanumeric() {
        System.assertEquals(true, Palindrome.isPalindrome('A man, a plan, a canal: Panama!'),
            'Should ignore spaces and punctuation');
        System.assertEquals(true, Palindrome.isPalindrome('No lemon, no melon'),
            'Should ignore spaces and punctuation');
        System.assertEquals(true, Palindrome.isPalindrome('12321'), 'Numeric palindrome should pass');
        System.assertEquals(true, Palindrome.isPalindrome('1 2 3 2 1'), 'Should ignore spaces in numbers');
        System.assertEquals(false, Palindrome.isPalindrome('123421'), 'Non-palindromic number should fail');
    }

    @IsTest
    static void testSpecialAndEdgeInputs() {
        // Only non-alphanumeric characters normalize to empty, which is palindrome
        System.assertEquals(true, Palindrome.isPalindrome('!!!'), 'Only punctuation normalizes to empty and should be palindrome');
        System.assertEquals(true, Palindrome.isPalindrome('   '), 'Only spaces normalize to empty and should be palindrome');
        System.assertEquals(true, Palindrome.isPalindrome('--__--'), 'Non-alphanumeric only should be palindrome');

        // Long-ish input to exercise loop
        String longPal = 'abc' + '123' + 'zZ' + '321' + 'CBA';
        System.assertEquals(true, Palindrome.isPalindrome(longPal), 'Constructed palindrome should pass');

        // Ensure constructor is covered (even though logic is static)
        Palindrome p = new Palindrome();
        System.assertNotEquals(null, p, 'Constructor should instantiate');
    }
}
