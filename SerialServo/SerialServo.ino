#include <Servo.h>

Servo pincher;

int openpinch = 90;
int closepinch = 20;
int currentstate;

void setup() {
  pincher.attach(9);
  pincher.write(openpinch);
  currentstate = openpinch;
  Serial.begin(9600);
  while (Serial.available() <= 0) {
    delay(300);
  }
}

void loop() {
  if (Serial.available() > 0) {
    char serialchar = Serial.read();

    if (serialchar == 'o') {
      if (currentstate != openpinch) {
        for (int i=closepinch; i<openpinch; i+=1) {
          pincher.write(i);
          delay(20);
        }
        currentstate = openpinch;
      }
    }
    if (serialchar =='c') {
      if (currentstate != closepinch) {
        for (int i=openpinch; i>closepinch; i-=1) {
          pincher.write(i);
          delay(20);
        }
        currentstate = closepinch;
      }
    }
  }
}
