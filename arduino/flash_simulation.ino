//ゲンジボタルの発光シミュレーション。
//デフォルトで周期は6秒強、whileの中のtに加算する値を増やして周期調整。
//波形は正規分布で近似。

const int LED_PIN = 10;

void setup() {
 pinMode( LED_PIN, OUTPUT );
}

void loop() {
  float t = -15000;
  
  while (t <= 15000){
    analogWrite(LED_PIN, 255*exp(-pow(t, 2)/(2*pow(3000, 2))));
    t += 1;
    }
}
