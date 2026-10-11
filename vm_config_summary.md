# Android Linux VM Configuration Summary

This document outlines the troubleshooting steps, system configurations, and optimization overrides applied to stabilize the Android Virtualization Framework (AVF / Debian) environment on the Pixel 10 following the October 2026 application update.

---

## 1. Graphical Subsystem Reversion
* **Issue:** The package update enabled the hardware-accelerated `gfxstream` renderer by default. This triggered an unhandled `invalid import ID` error during remote `xrdp` / graphic frame allocation, causing `crosvm` to throw an `ErrUnspec` panic and drop the virtual machine container entirely.
* **Fix Action:** Open the **Terminal app Settings**, navigate to **Advanced Settings**, and change the layout options from **GPU-accelerated renderer** to **Software renderer** (enabling CPU-bound drawing via Lavapipe).

## 2. Android Process & Power Lifecycle Overrides
Because production Android environments enforce aggressive background battery optimizations, several targeted configuration overrides were established via ADB to protect persistent remote `sshd` and `xrdp` connections:

### A. Phase out the Phantom Process Killer
* **Action:** Enable **Disable child process restrictions** under **Settings > System > Developer options > Apps**. This prevents Android from terminating background subprocesses spawned by the terminal engine.

### B. Pin the App Standby Bucket
* **Action:** Set the application's runtime management bucket to the highest priority to avoid idle throttling flags:
  ```bash
  ~/Downloads/platform-tools/adb shell am set-standby-bucket com.android.virtualization.terminal active
  ```

### C. Bypass Activity Background Suspension
* **Action:** Instruct the device window manager to ignore visibility changes so minimizing the app UI does not freeze the underlying virtualization loop:
  ```bash
  ~/Downloads/platform-tools/adb shell am set-inactive com.android.virtualization.terminal false
  ```

## 3. Display Sleep Adjustments (Workaround)
* **Issue:** Corporate device management policies explicitly block the standard **Stay awake** developer toggle, causing screen timeouts to disrupt high-volume, long-running terminal extractions (e.g., `tar xf`).
* **Temporary Maximum Timeout Extension:**
  ```bash
  ~/Downloads/platform-tools/adb shell settings put system screen_off_timeout 2147483647
  ```
* **Reversion String (Restore to 2 Minutes):**
  ```bash
  ~/Downloads/platform-tools/adb shell settings put system screen_off_timeout 120000
  ```

## 4. Cache, Memory, & IPC Diagnostics
* **Clear Lingering Unix Graphics Locks:** If initialization errors occur, clear corrupt socket descriptors from the temporary file pipe layout:
  ```bash
  rm -rf /tmp/.X11-unix
  rm -rf $TMPDIR/.X11-unix
  ```
* **Manual Hypervisor Hard Reset:** If the application front-end gets stuck displaying a persistent app logo or "starting" loop, manually terminate the lingering background daemons:
  ```bash
  ~/Downloads/platform-tools/adb shell pkill -9 virtmgr
  ~/Downloads/platform-tools/adb shell pkill -9 crosvm
  ~/Downloads/platform-tools/adb shell am force-stop com.android.virtualization.terminal
  ```

---

## 5. Architectural Baseline Reminders
When standing up a fresh environment image from scratch, remember to apply your verified workspace configurations:
* **Operating System:** Debian Linux guest framework.
* **Desktop Environment:** XFCE suite.
* **Storage Optimization:** Ensure you provision a dedicated **8 GB swapfile at `/mnt/backup`** to protect the environment against Out-Of-Memory limits during heavy file manipulation loops.
