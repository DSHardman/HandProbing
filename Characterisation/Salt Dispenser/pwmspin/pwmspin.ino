int PWM_out_pin = 2;

void setup() {
  pinMode(PWM_out_pin, OUTPUT);
  analogWrite(PWM_out_pin, 0);
  Serial.begin(9600);
}

void loop() {
  if (Serial.available()) {
    int integerVariable = Serial.parseInt();
    Serial.println(integerVariable);
    analogWrite(PWM_out_pin, integerVariable);
    delay(1000);
    Serial.parseInt();
  }
}
