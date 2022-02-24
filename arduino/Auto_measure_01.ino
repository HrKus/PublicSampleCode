#include <ir_Lego_PF_BitStreamEncoder.h>
#include <IRremote.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

const int LED_PIN = 10;
const int photocellPin = A5;
int first_count = 1; 
int intensity = 5;
int val = 0; 
int  msec = 200;
long start;
long now = 0;
long randNumber;
const int RECV_PIN = 7;
IRrecv irrecv(RECV_PIN);
decode_results results;

void setup(){
  Serial.begin(9600);
  irrecv.enableIRIn();
  irrecv.blink13(true);
  pinMode(LED_PIN, OUTPUT );
  pinMode(photocellPin, INPUT);
  randomSeed((unsigned int)time(NULL));
}

void loop(){
  
  val = analogRead(photocellPin);
      if (1023 - val > 250) {
        val =  773;
      } 
      
  randNumber = random(99999999);

  if (first_count == 1 && millis() > 600000) {
    Serial.write(253);
    first_count = 0;
    } 
  
 
  if (randNumber%90000 == 0 && millis() > 600000){
       analogWrite(LED_PIN, intensity);
       Serial.write(251);
       
       start = millis();
       
       while (millis() - start < msec){
        val = analogRead(photocellPin);
        if (1023 - val > 250) {
          val =  773;
          } 
        Serial.write(1023 - val);
        }
        
       analogWrite(LED_PIN, 0);
       Serial.write(252);
      }

  if (irrecv.decode(&results)){
    if (results.value == 16712445) {
      analogWrite(LED_PIN, intensity);
      Serial.write(251);
      
      start = millis();
      while (millis() - start < msec){
        val = analogRead(photocellPin);
        if (1023 - val > 250) {
          val =  773;
          } 
        Serial.write(1023 - val);
        }
        
      analogWrite(LED_PIN, 0);
      Serial.write(252);
      }  
      
  if (results.value == 16769055) {
      intensity += -1;
      }  
      
  if (results.value == 16748655) {
      intensity += 1;
      }  

  if (results.value == 16720605) {
      msec += 10;
      }  
      
  if (results.value == 16761405) {
      msec += -10;
      } 
      
  if (results.value == 16756815) {
      msec = 200;
      intensity = 1;
      } 
  
  irrecv.resume();
  } 

  Serial.write(1023 - val);
}

void sendIntData(int value) {
  Serial.write('H');
  Serial.write(lowByte(value));
  Serial.write(highByte(value));
}
