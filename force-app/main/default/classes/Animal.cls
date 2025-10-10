public abstract class Animal {
    
    // Abstract methods (must be implemented by subclasses)
    public abstract void makeSound();
    public abstract void move();
    
    // Concrete method (shared behavior)
    public void sleep() {
        System.debug('Sleeping...');
    }
}
