#include <Servo.h>

Servo pincher;

int openpinch = 0;
int closepinch = 50;

void setup() {
  pincher.attach(9);
  pincher.write(openpinch);
  Serial.begin(9600);
  while (Serial.available() <= 0) {
    delay(300);
  }
}

void loop() {
  if (Serial.available() > 0) {
    char serialchar = Serial.read();

    if (serialchar == 'o') {
      pincher.write(openpinch);
    }
    if (serialchar =='c') {
      pincher.write(closepinch);
    }
  }
}
