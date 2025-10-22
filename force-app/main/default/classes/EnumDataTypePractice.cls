public enum StatusType {
    NEW,
    IN_PROGRESS,
    COMPLETED,
    CANCELLED
}

public class EnumDataTypePractice {
    public static void process(StatusType st) {
        if (st == StatusType.COMPLETED) {
            // Handle completed status
            System.debug('Status is COMPLETED');
        } else if (st == StatusType.CANCELLED) {
            // Handle cancelled status
            System.debug('Status is CANCELLED');
        } else {
            // Handle other statuses
            System.debug('Status is ' + st);
        }
    }

    // Usage example
    public static void exampleUsage() {
        StatusType s = StatusType.IN_PROGRESS;
        process(s);

        // Converting from string
        String input = 'NEW';
        try {
            StatusType s2 = StatusType.valueOf(input);
            System.debug('Converted Status: ' + s2);
        } catch (IllegalArgumentException e) {
            System.debug('Invalid status string: ' + input);
        }

        // Looping through all enum values
        for (StatusType val : StatusType.values()) {
            System.debug('Enum value: ' + val.name());
        }
    }
}
