#二重反対色性ニューロンの応答シミュレーション
import cv2
import numpy as np
import scipy.ndimage

#インカメラ(0番)から動画を取得
incom_cap = cv2.VideoCapture(0)

#データ型の確認
print(type(incom_cap))

#開けるかどうか確認
print(incom_cap.isOpened())

#受容野の大きさを決める
inside_ref = 23
outside_ref =46
key = 0
reseptor_1 = 2
reseptor_2 = 1
on_off = 1
magnification = 1

print("inside_ref =", inside_ref)
print("outside_ref =", outside_ref)


#動画をワンフレームずつ取得して表示
while(incom_cap.read()):
    #フレームの読み込み
    ret, frame = incom_cap.read()
    
    #float型に変換
    frame_float32 = frame.astype(np.float32)
    
    #色の抽出(反対色)
    oppornent_color = frame_float32[::, ::, reseptor_1] - frame_float32[::, ::, reseptor_2]
    
    #平均化(ガウスぼかし)・エッジ検出(中心周辺拮抗)
    center_surround =  (magnification*on_off*(-scipy.ndimage.gaussian_filter(oppornent_color, sigma=outside_ref, mode='reflect') + scipy.ndimage.gaussian_filter(oppornent_color, sigma=inside_ref, mode='reflect'))).clip(min=0, max=255)


    cv2.imshow("center_surround",  center_surround.astype(np.uint8))

    #escキーで終了
    key = cv2.waitKey(1)
    
    if key == 100 and inside_ref/outside_ref <= 1:
        inside_ref += 1
        print("inside_ref =", inside_ref)
        print("outside_ref =", outside_ref)
    elif key == 102 and inside_ref > 1:
        inside_ref += -1
        print("inside_ref =", inside_ref)
        print("outside_ref =", outside_ref)
    elif key == 114 and inside_ref/outside_ref <= 1:
        outside_ref += 1
        print("inside_ref =", inside_ref)
        print("outside_ref =", outside_ref)
    elif key == 101 and inside_ref/outside_ref <= 1:
        outside_ref += -1
        print("inside_ref =", inside_ref)
        print("outside_ref =", outside_ref)
    elif key == 116:
        on_off = -1*on_off
    elif key == 115 and magnification < 255:
        magnification += 1
    elif key == 119 and magnification > 1:
        magnification += -1
    elif key == 113:
        incom_cap.release()
        cv2.destroyAllWindows()
        break

