#!/system/bin/sh
# Atur status FodEngine lewat service IXiaomiFingerprint (extCmd):  fpstate.sh on | off
# on : mode FOD layar sentuh aktif + gxzwAnim=1 (cmd 1) + status FP=autentikasi (cmd 4)
# off: kebalikannya
MODDIR=${0%/*}
. "$MODDIR/config.sh"
LOG=/data/local/tmp/spinel-fod.log
SVC=vendor.xiaomi.hardware.fingerprintextension.IXiaomiFingerprint/default
ext() { service call "$SVC" "${EXT_TXN:-1}" i32 "$1" i32 "$2" >/dev/null 2>&1; }
chmod 755 "$MODDIR/bin/fodctl" 2>/dev/null
case "$1" in
  on)
    "$MODDIR/bin/fodctl" 10 "${FOD_MODE_VALUE:-3}"
    ext 1 1
    ext 4 "${FP_STATE_VALUE:-1}"
    echo "$(date '+%T') fpstate on (fp=${FP_STATE_VALUE:-1})" >> "$LOG"
    ;;
  off)
    ext 4 0
    ext 1 0
    "$MODDIR/bin/fodctl" 10 0
    echo "$(date '+%T') fpstate off" >> "$LOG"
    ;;
  *) echo "pakai: fpstate.sh on|off"; exit 1 ;;
esac
