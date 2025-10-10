public class Dog extends Animal implements IAnimal  {
    public void makeSound() {
        System.debug('Woof Woof!');
    }
    
    public void move() {
        System.debug('Dog runs on 4 legs.');
    }
}