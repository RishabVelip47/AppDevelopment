import 'dart:io';

void main() {
  // Input
  stdout.write("Enter your name: ");
  String? name = stdin.readLineSync();

  stdout.write("Enter a number: ");
  int number = int.parse(stdin.readLineSync()!);

  // Output
  print("\nHello, $name!");
  print("You entered: $number\n");

  // For loop
  print("For loop (1 to $number):");
  for (int i = 1; i <= number; i++) {
    print(i);
  }

  // While loop
  print("\nWhile loop (countdown):");
  int count = number;
  while (count > 0) {
    print(count);
    count--;
  }

  // Do-while loop
  print("\nDo-while loop (runs at least once):");
  int x = 0;
  do {
    print("Value of x: $x");
    x++;
  } while (x < 3);
}
