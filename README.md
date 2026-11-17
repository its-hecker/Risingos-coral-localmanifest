# RisingOS Android 17 — Google Pixel 4 XL (coral)

Maintainer: **Hecker**  
Upstream: [RisingOS-Revived/android](https://github.com/RisingOS-Revived/android), branch `seventeen`.

## Source import status

The three coral source repositories have been populated from the known-working
InfinityX `cnb-Latest-stable` branches. The original InfinityX repositories
were not modified.

| Component | RisingOS repository | Source |
|---|---|---|
| Device tree | [risingos-coral-dt](https://github.com/its-hecker/risingos-coral-dt) | infinity_cnb_android_device_google_coral |
| Vendor | [risingos-coral-vendor](https://github.com/its-hecker/risingos-coral-vendor) | infinity_cnb_proprietary_vendor_google_coral |
| Kernel | [risingos-coral-kernel](https://github.com/its-hecker/risingos-coral-kernel) | infinity_cnb_kernel_google_msm-4.14 |

The device tree has been adapted for RisingOS with `RISING_MAINTAINER=Hecker`,
`WITH_GMS=true`, and LineageOS-based product configuration. Device-specific
Pixel 4 XL camera, 3D Face Unlock, Motion Sense, and other compatibility files
were copied, though functionality on RisingOS remains **untested**.

The kernel copy preserves the `KernelSU` submodule reference and the full
audio driver tree. It still requires the submodule source to be accessible
when checked out.

The vendor repository retains the original external Git LFS configuration
(`https://lfs.undocumented.software/lfs/blobs.git/info/lfs`). Its availability
remains a dependency for fetching the actual proprietary binary files.

The original `port-from-infinity.sh` is retained as an archival source-import
recipe. **Do not rerun it on the now-populated RisingOS repositories**.

## First RisingOS checkout

```bash
mkdir -p ~/risingos-coral
cd ~/risingos-coral
repo init -u https://github.com/RisingOS-Revived/android -b seventeen --git-lfs
git clone https://github.com/its-hecker/Risingos-coral-localmanifest.git .repo/local_manifests
repo sync -c --fail-fast --no-clone-bundle --no-tags -j4
```

## First compilation attempt

```bash
cd ~/risingos-coral
source build/envsetup.sh
riseup coral userdebug
rise b
```

The local manifest also adds Lunaris Dolby and ElmyraService. This is
currently **a source port, not a validated booting ROM**. Resolve any
RisingOS-specific build, HAL, SELinux, partition, or runtime issues before
considering a release.
