#!/usr/bin/env bash
#
# Apply the houzzkit-f1 device overlay onto an amlogic-s9xxx-armbian checkout.
#
# Usage:
#   bash apply-overlay.sh <upstream-checkout> <this-repo>
#
set -euo pipefail

UPSTREAM="${1:?missing upstream checkout path}"
OVERLAY="${2:?missing overlay repo path}"

echo "==> device files (different-files)"
cp -avf "${OVERLAY}/overlay/different-files/." \
       "${UPSTREAM}/build-armbian/armbian-files/different-files/"

echo "==> platform files (dtb / bootfs)"
if [[ -d "${OVERLAY}/overlay/platform-files" ]]; then
	cp -avf "${OVERLAY}/overlay/platform-files/." \
	       "${UPSTREAM}/build-armbian/armbian-files/platform-files/"
fi

echo "==> common files"
if [[ -d "${OVERLAY}/overlay/common-files" ]]; then
	cp -avf "${OVERLAY}/overlay/common-files/." \
	       "${UPSTREAM}/build-armbian/armbian-files/common-files/"
fi

echo "==> register device in model_database.conf"
DB="${UPSTREAM}/build-armbian/armbian-files/common-files/etc/model_database.conf"
if ! grep -qE ":[[:space:]]*houzzkit-f1[[:space:]]*:" "${DB}"; then
	cat "${OVERLAY}/overlay/model_database.row" >> "${DB}"
else
	echo "houzzkit-f1 already registered, skip."
fi

echo "==> overlay applied"
