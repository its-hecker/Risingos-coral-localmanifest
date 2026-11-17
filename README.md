# RisingOS 9 / Android 17 — Google Pixel 4 XL (coral)

This repository describes the coral bring-up using the previously working
InfinityX Android 17 device, vendor and kernel sources.

## Status

- RisingOS upstream: `RisingOS-Revived/android`, branch `seventeen`
- Target device: Google Pixel 4 XL / coral
- Maintainer: Hecker
- The three RisingOS device/vendor/kernel repositories must be populated before `repo sync` can use this manifest.
- No successful RisingOS build or boot has been verified yet.

## 1. Copy and adapt the source repositories

On a Linux machine with `git`, `git-lfs`, `python3`, sufficient free disk space,
and authentication to push to its-hecker's GitHub repositories:

```bash
git clone https://github.com/its-hecker/Risingos-coral-localmanifest.git
PUBLISH=1 bash Risingos-coral-localmanifest/port-from-infinity.sh
```

The script copies the `cnb-Latest-stable` branches from:

- `infinity_cnb_android_device_google_coral` to `risingos-coral-dt`
- `infinity_cnb_proprietary_vendor_google_coral` to `risingos-coral-vendor`
- `infinity_cnb_kernel_google_msm-4.14` to `risingos-coral-kernel`

It keeps the InfinityX repositories read-only, uses `Hecker` as the author of
the RisingOS adaptation commit, and will not force-push into a populated target.

The vendor repository uses an **external Git LFS endpoint** configured by its
existing `.lfsconfig`. The script preserves the configuration and copies Git
pointers, not a new copy of all binary LFS payloads to GitHub. The endpoint must
remain accessible for syncing the resulting vendor checkout.

Set `PUBLISH=0` (the default) to prepare local copies without pushing. The
script refuses to overwrite an existing directory in
`$HOME/risingos-coral-seed`.

## 2. Initialize RisingOS on a fresh build machine

```bash
mkdir -p ~/risingos-coral
cd ~/risingos-coral
repo init -u https://github.com/RisingOS-Revived/android -b seventeen --git-lfs
git clone https://github.com/its-hecker/Risingos-coral-localmanifest.git .repo/local_manifests
repo sync -c --fail-fast --no-clone-bundle --no-tags -j4
```

Only run this after all three target repositories have been populated.

## 3. First build

```bash
cd ~/risingos-coral
source build/envsetup.sh
riseup coral userdebug
rise b
```

If the product selection or compilation fails, preserve the complete output
and address the actual RisingOS-specific incompatibility before flashing.
The source carries over the InfinityX 3D Face Unlock, Motion Sense, Google
Camera, Lunaris Dolby, vendor blobs, and floral kernel implementation, but none
are certified working on RisingOS until tested.

The `coral.xml` manifest also supplies `ElmyraService` from LineageOS
`lineage-24.0` and the optional Lunaris Dolby tree. This is an experimental
port; retain a known-working ROM and recovery.
