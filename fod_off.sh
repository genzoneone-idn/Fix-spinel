#!/system/bin/sh
# Matikan mode FOD di layar sentuh:  su -c "sh /data/adb/modules/spinel_fod_fix/fod_off.sh"
MODDIR=${0%/*}
chmod 755 "$MODDIR/bin/fodctl"
"$MODDIR/bin/fodctl" 10 0
echo "fodctl exit=$? (0 = ok)"
dmesg | grep -iE 'xiaomi_touch_dev_ioctl|Mode:FOD' | tail -n 4
