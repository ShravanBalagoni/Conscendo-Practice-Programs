public with sharing class PalindromeEx {
    
    public static void checkPalindrome(String str){
        String normalizedStr = str.replaceAll('[^a-zA-Z0-9]', '').toLowerCase();
        Integer left = 0;
        Integer right = normalizedStr.length() - 1;
        while (left < right) {
            if (normalizedStr.charAt(left) != normalizedStr.charAt(right)) {
                System.debug('The string is not a palindrome.');
                return;
            }
            left++;
            right--;
        }
        System.debug('The string is a palindrome.');
    }
}