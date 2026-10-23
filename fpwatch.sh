#!/system/bin/sh
# Pantau BiometricScheduler: saat enroll atau autentikasi sidik jari dimulai/selesai,
# jalankan fpstate.sh on/off. Dijalankan otomatis oleh service.sh.
MODDIR=${0%/*}
LOG=/data/local/tmp/spinel-fod.log
echo "$(date '+%T') fpwatch start" >> "$LOG"
logcat -T 1 -v brief BiometricScheduler:D '*:S' 2>/dev/null | while read -r line; do
  case "$line" in
    *"[Started]"*FingerprintEnrollClient*|*"[Started]"*FingerprintAuthenticationClient*)
      sh "$MODDIR/fpstate.sh" on ;;
    *"[Finishing]"*FingerprintEnrollClient*|*"[Finishing]"*FingerprintAuthenticationClient*)
      sh "$MODDIR/fpstate.sh" off ;;
  esac
done
