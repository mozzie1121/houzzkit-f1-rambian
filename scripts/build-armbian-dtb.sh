#!/usr/bin/env bash
#
# Generate the Armbian dtb for Houzzkit F1:
#   base = rk3568-jl-rm01-uart3m1.dtb (zigbee UART3 M1 enabled)
#   patch = enable UART2 (serial@fe660000) as standard serial console
#
# Usage:
#   bash build-armbian-dtb.sh [input.dtb] [output.dtb]
#
set -euo pipefail

SRC="${1:-/mnt/d/codex/houzzkit-f1-schematic/rk3568-jl-rm01-uart3m1.dtb}"
OUT="${2:-rk3568-jl-rm01.dtb}"
TMP="/tmp/rm01-armbian.dts"

dtc -I dtb -O dts "${SRC}" -o "${TMP}" 2>/dev/null

python3 - "${TMP}" <<'EOF'
import re, sys

path = sys.argv[1]
with open(path, encoding="utf-8") as f:
    data = f.read()

# Enable UART2 (serial@fe660000) for the Armbian debug console.
pattern = re.compile(
    r'(serial@fe660000 \{\n.*?\n\t\tstatus = )"disabled"',
    re.S,
)
new, n = pattern.subn(r'\1"okay"', data, count=1)
if n != 1:
    raise SystemExit("ERROR: serial@fe660000 node not found or already enabled")

# The ophub rk35xx kernel rknpu driver (v0.9.x) requests its IRQ by name
# ("npu_irq"). The HAOS vendor dtb lacks interrupt-names, so add it.
npupat = re.compile(
    r'(npu@fde40000 \{\n.*?\n\t\tinterrupts = <[^>]+>;)',
    re.S,
)
new, n2 = npupat.subn(r'\1\n\t\tinterrupt-names = "npu_irq";', new, count=1)
if n2 != 1:
    raise SystemExit("ERROR: npu@fde40000 interrupts property not found")

with open(path, "w", encoding="utf-8") as f:
    f.write(new)
print("patched serial@fe660000 -> okay, npu interrupt-names -> npu_irq")
EOF

dtc -I dts -O dtb -b 0 -@ "${TMP}" -o "${OUT}"
echo "DTB: ${OUT}"
sha256sum "${OUT}"
