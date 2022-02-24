#Arduinoとのシリアル通信
#蛍の発光測定用
import datetime
import time
import serial

count = 20000000 #測定が終わるまでの時間を指定。
led = 0

ser = serial.Serial('/dev/cu.usbmodem141101', 9600, timeout = 100) #ポートに合わせてここは変える。

path_1 = 'KATO_005_20200628_02.tsv' #保存するファイル。

with open(path_1, mode='w') as f: #書き込みモードで開く。
        f.write("date" + '\t' + "unix_time" + '\t' + "value" + '\t' + "led" + '\n') #１行目書き込み
        

for i in range(count):
    res = ser.read(1)
    n = int.from_bytes(res, 'little')
    dt_now = datetime.datetime.now()
    ut = time.time()
    
    if (n == 251):
        led = 1
        print("LIGHT_ON")
        with open(path_1, mode='a') as f:
            f.write(str(dt_now) + '\t' + str(ut) + '\t' + str(n) + '\t' + str(led) + '\n')
    elif (n == 252):
        led = 0
        print("LIGHT_OFF")
        with open(path_1, mode='a') as f:
            f.write(str(dt_now) + '\t' + str(ut) + '\t' + str(n) + '\t' + str(led) + '\n')
    
    
    if (i % 5 == 0):
        with open(path_1, mode='a') as f:
            f.write(str(dt_now) + '\t' + str(ut) + '\t' + str(n) + '\t' + str(led) + '\n')
        
        if (n > 12):
            print(dt_now, ut, n, led)
        
    time.sleep(0.0001)
    
ser.close()