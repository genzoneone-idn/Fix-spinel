#!/system/bin/sh
MODDIR=${0%/*}
. "$MODDIR/config.sh"
LOG=/data/local/tmp/spinel-fod.log
NODE=/dev/mi_display/disp_feature
log() { echo "$(date '+%F %T') $*" >> "$LOG"; }

while [ "$(getprop sys.boot_completed)" != "1" ]; do sleep 2; done
sleep 8
: > "$LOG"
log "start v0.2 selinux=$(getenforce) android=$(getprop ro.build.version.release)"

CHANGED=0

# 1. Buat node display bila hilang (di HyperOS stock node sudah ada, jadi bagian ini dilewati)
if [ ! -e "$NODE" ]; then
  DEVF=/sys/devices/virtual/mi_display/disp_feature/dev
  if [ -r "$DEVF" ]; then MM=$(cat "$DEVF"); else MM="${FALLBACK_MAJOR}:${FALLBACK_MINOR}"; fi
  MAJ=${MM%%:*}; MIN=${MM##*:}
  log "node hilang, buat mknod c $MAJ $MIN"
  mkdir -p /dev/mi_display
  mknod "$NODE" c "$MAJ" "$MIN" 2>>"$LOG"
  chown root:graphics "$NODE"
  chmod 0666 "$NODE"
  chcon u:object_r:vendor_displayfeature_device:s0 "$NODE" 2>>"$LOG"
  CHANGED=1
else
  log "node sudah ada"
fi

# 2. Posisi dan ukuran sensor (hanya diubah jika berbeda)
if [ -n "$FOD_XY" ] && [ "$(getprop persist.vendor.sys.fp.fod.location.X_Y)" != "$FOD_XY" ]; then
  resetprop persist.vendor.sys.fp.fod.location.X_Y "$FOD_XY"; CHANGED=1
  log "set X_Y=$FOD_XY"
fi
if [ -n "$FOD_WH" ] && [ "$(getprop persist.vendor.sys.fp.fod.size.width_height)" != "$FOD_WH" ]; then
  resetprop persist.vendor.sys.fp.fod.size.width_height "$FOD_WH"; CHANGED=1
  log "set width_height=$FOD_WH"
fi

# 3. Tes permisif (opsional)
[ "$TEST_PERMISSIVE" = "1" ] && setenforce 0 && log "setenforce 0"

# 4. Restart HAL hanya jika ada perubahan
if [ "$CHANGED" = "1" ]; then
  log "restart vendor.fps_hal"
  stop vendor.fps_hal; sleep 2; start vendor.fps_hal
  sleep 4
fi

# 4b. Aktifkan mode FOD di layar sentuh (mode 10, nilai 3), meniru yang dikirim framework HyperOS
if [ "$FOD_AUTO_ENABLE" = "1" ]; then
  chmod 755 "$MODDIR/bin/fodctl"
  "$MODDIR/bin/fodctl" 10 "$FOD_MODE_VALUE"
  log "fodctl 10 $FOD_MODE_VALUE exit=$? (0 = ok)"
  dmesg | grep -iE 'xiaomi_touch_dev_ioctl|Mode:FOD' | tail -n 4 >> "$LOG"
fi

# 4c. Pemantau enroll/autentikasi: nyalakan status FP hanya saat dibutuhkan
if [ "$FP_WATCH" = "1" ]; then
  nohup sh "$MODDIR/fpwatch.sh" >/dev/null 2>&1 &
  log "fpwatch dijalankan"
fi

# 5. Diagnosa
log "--- node ---"
ls -lZ /dev/mi_display 2>&1 >> "$LOG"
P=$(pidof android.hardware.biometrics.fingerprint-service.odm)
log "--- HAL pid=$P fd ---"
ls -l /proc/$P/fd 2>/dev/null | grep -E 'mi_display|xiaomi-fp|tee|fod' >> "$LOG"
log "--- service ---"
service list 2>/dev/null | grep -i fingerprint >> "$LOG"
cp "$LOG" /sdcard/spinel-fod.log 2>/dev/null
log "selesai"
