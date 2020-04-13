//MOTION SENSOR READING

int pwm = 6;
int sensor_pin = A1;
double output_value;
double pwmValue = 0;
char mode =  'T';
double percentage;

int maxSensorVal = 900;
int minSensorVal = 500;
int maxSpeedMotor = 60;
int minSpeedMotor = 30;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
}

void loop() {
  static char mode;
  // put your main code here, to run repeatedly:
  output_value = analogRead(sensor_pin);
  output_value = map(output_value, maxSensorVal, minSensorVal, 0, 100);
  if (mode == 'Q') {
    pwmValue = map(output_value, 0, 100, maxSpeedMotor, minSpeedMotor);
    analogWrite(pwm, pwmValue);
  }
  else if (mode == 'W') {
    pwmValue = minSpeedMotor + ((maxSpeedMotor - minSpeedMotor) * percentage / 100);
    analogWrite(pwm, pwmValue);
  } else {
    analogWrite(pwm, 0);
  }
  if (Serial.available()) {
    char c = Serial.read();
    if (c == 'W') {
      mode = c;
      percentage = Serial.parseFloat();
    } else
    if (c == 'Q') {
      mode = c;
    }
    if (c == 'T') {
      mode = c;
    }
  }
  if (mode == 'Q') {
  Serial.println(String(output_value) + ";" + String(pwmValue));
  } else {
  Serial.println(String(output_value) + ";" + String(percentage));
  }
  delay(500);
}
