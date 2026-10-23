#!/system/bin/sh
# Posisi dan ukuran sensor dari HyperOS stock (pojok kiri atas, layar 1080x2392).
# Pusat sensor = (449+91.5, 2083+91.5) = sekitar (540, 2174). Kosongkan untuk tidak mengubah.
FOD_XY="449,2083"
FOD_WH="183,183"

# Cadangan major:minor jika file dev di sysfs tidak terbaca (dari /proc/devices: 502 disp_feature)
FALLBACK_MAJOR=502
FALLBACK_MINOR=0

# 1 = kirim "mode FOD aktif" ke layar sentuh saat boot (di stock dikirim framework tiap autentikasi).
# Jika lingkaran menyala sendiri atau baterai boros, set 0 lalu pakai fod_on.sh / fod_off.sh manual.
FOD_AUTO_ENABLE=0
FOD_MODE_VALUE=3

# Status FodEngine (libmifpext.so): extCmd cmd 4 = status sidik jari. Nilai 1, 3, 5 membuat HAL
# menyalakan lhbm; 0 = idle. Coba 3 atau 5 jika 1 tidak bekerja saat enroll.
FP_STATE_VALUE=1
# Nomor transaksi extCmd pada service IXiaomiFingerprint (metode pertama = 1)
EXT_TXN=1
# 1 = jalankan pemantau enroll/autentikasi otomatis saat boot
FP_WATCH=1

# 1 = setenforce 0 saat boot (HANYA untuk tes sementara, kembali normal setelah reboot)
TEST_PERMISSIVE=0
