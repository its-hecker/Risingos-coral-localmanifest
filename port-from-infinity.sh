#!/usr/bin/env bash
set -euo pipefail

ROOT="${RISING_SEED_DIR:-$HOME/risingos-coral-seed}"
PUBLISH="${PUBLISH:-0}"

command -v git >/dev/null || { echo "git is required" >&2; exit 1; }
command -v python3 >/dev/null || { echo "python3 is required" >&2; exit 1; }
git lfs version >/dev/null 2>&1 || { echo "git-lfs is required for vendor blobs" >&2; exit 1; }

mkdir -p "$ROOT"

copy_tree() {
    local key="$1" from="$2" to="$3"
    local dir="$ROOT/$key"
    if [[ -e "$dir" ]]; then
        echo "Refusing to overwrite: $dir" >&2
        exit 1
    fi
    git clone --single-branch --branch cnb-Latest-stable \
        "https://github.com/its-hecker/$from.git" "$dir"
    git -C "$dir" switch -c rising-seventeen
    git -C "$dir" remote rename origin infinity-readonly
    git -C "$dir" remote add rising "https://github.com/its-hecker/$to.git"
}

copy_tree dt infinity_cnb_android_device_google_coral risingos-coral-dt
copy_tree vendor infinity_cnb_proprietary_vendor_google_coral risingos-coral-vendor
copy_tree kernel infinity_cnb_kernel_google_msm-4.14 risingos-coral-kernel

python3 - "$ROOT/dt" <<'PY'
from pathlib import Path
import sys

base = Path(sys.argv[1])
products = base / "AndroidProducts.mk"
s = products.read_text()
old = "    $(LOCAL_DIR)/lineage_coral.mk \\\n    $(LOCAL_DIR)/lineage_flame.mk"
assert s.count(old) == 1, "Unexpected AndroidProducts.mk layout"
products.write_text(s.replace(old, "    $(LOCAL_DIR)/lineage_coral.mk"))

product = base / "lineage_coral.mk"
s = product.read_text()
changes = {
    "INFINITY_BUILD := coral\n": "",
    'INFINITY_MAINTAINER := "Hecker"': "RISING_MAINTAINER := Hecker\nTARGET_ENABLE_BLUR := true",
    "WITH_GAPPS := true": "WITH_GMS := true",
    "vendor/infinity/config/common_full_phone.mk": "vendor/lineage/config/common_full_phone.mk",
    "ro.infinity.soc=": "ro.rising.chipset=",
    "ro.infinity.camera=": "ro.rising.camera=",
}
for old, new in changes.items():
    assert old in s, f"Unexpected source: {old}"
    s = s.replace(old, new, 1)
marker = "# Inherit some common Lineage stuff."
assert marker in s
rising_properties = (
    "PRODUCT_BUILD_PROP_OVERRIDES += \\\n"
    "    RisingChipset=\"Qualcomm Snapdragon 855\" \\\n"
    "    RisingMaintainer=\"Hecker\"\n\n"
)
s = s.replace(marker, rising_properties + marker, 1)
product.write_text(s)
print("Adapted coral device configuration for RisingOS 9.")
PY

git -C "$ROOT/dt" add AndroidProducts.mk lineage_coral.mk
git -C "$ROOT/dt" -c user.name=Hecker \
    -c user.email=118846180+its-hecker@users.noreply.github.com \
    commit -m "rising: adapt InfinityX coral device product to RisingOS 9"

echo "Prepared separate sources in $ROOT"
if [[ "$PUBLISH" == 1 ]]; then
    for key in dt vendor kernel; do
        if [[ "$key" == vendor ]]; then
            # Vendor LFS objects remain on the pre-existing external LFS server.
            # Do not attempt to upload them to GitHub LFS via the pre-push hook.
            git -C "$ROOT/$key" -c core.hooksPath=/dev/null push --set-upstream rising HEAD:refs/heads/main
        else
            git -C "$ROOT/$key" push --set-upstream rising HEAD:refs/heads/main
        fi
    done
    echo "Published all three RisingOS repositories."
else
    echo "No repos pushed. Use PUBLISH=1 with authenticated GitHub access."
fi
