public with sharing class Palindrome {
    // Constructor
    public Palindrome() {
        // Initialization logic if needed
    }

    // Method to check if a string is a palindrome
    public static Boolean isPalindrome(String input) {
        // Normalize the string: remove non-alphanumeric characters and convert to lowercase
        String normalizedInput = input.replaceAll('[^a-zA-Z0-9]', '').toLowerCase();

        // Initialize pointers
        Integer left = 0;
        Integer right = normalizedInput.length() - 1;

        // Check characters from both ends towards the center
        while (left < right) {
            if (normalizedInput.charAt(left) != normalizedInput.charAt(right)) {
                return false;
            }
            left++;
            right--;
        }

        return true;
    }
}
