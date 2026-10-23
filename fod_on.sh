#!/system/bin/sh
# Aktifkan mode FOD di layar sentuh:  su -c "sh /data/adb/modules/spinel_fod_fix/fod_on.sh"
MODDIR=${0%/*}
. "$MODDIR/config.sh"
chmod 755 "$MODDIR/bin/fodctl"
"$MODDIR/bin/fodctl" 10 "${FOD_MODE_VALUE:-3}"
echo "fodctl exit=$? (0 = ok)"
dmesg | grep -iE 'xiaomi_touch_dev_ioctl|Mode:FOD' | tail -n 4
