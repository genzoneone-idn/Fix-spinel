#!/system/bin/sh
# Jalankan SETELAH mencoba enroll:  su -c "sh /data/adb/modules/spinel_fod_fix/collect.sh"
OUT=/sdcard/fod_collect.txt
{
  echo "== getenforce =="; getenforce
  echo "== node =="; ls -lZ /dev/mi_display
  echo "== dmesg (fod/hbm/xiaomi-fp/avc) =="; dmesg | grep -iE 'xiaomi-fp|mi_disp|local_hbm|fod|xiaomi_touch|MI_TP|avc: denied' | tail -n 150
  echo "== logcat (HAL/udfps/avc) =="; logcat -d | grep -iE 'FingerprintODMHalSession|odm-fp-daemon|extCmd|FodEngine|fingerprintCondition|checkFodTouch|lhbm|UdfpsDisplayMode|avc: denied|enroll' | tail -n 150
} > "$OUT" 2>&1
echo "tersimpan di $OUT"
