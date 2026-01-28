English | [中文](README.md)

# Time Screen - Minimalist Flip Clock Screensaver

![Sample Image](示例图片.png)

Time Screen is a screensaver running on Windows that replicates the classic macOS flip clock effect.
It features a minimalist black background, bold large font time display, and smooth flip animation, making your screen both beautiful and practical when idle.

## ✨ Features

- **Classic Flip**: Restores macOS style flip clock animation, accurate to the second.
- **Immersive Experience**: Automatically runs in full screen, hiding the taskbar and window borders.
- **Minimalist Design**: Pure black background with no distracting elements, displaying the date at the bottom.
- **Accidental Touch Prevention**:
  - **Double Click to Exit**: Prevents the screensaver from exiting due to slight mouse movements; requires a double click anywhere on the screen to exit.
  - **Single Click Ignored**: Single clicking the screen will not exit the screensaver.
- **Font Optimization**: Optimized font rendering for Windows, clear and rounded.

## 📦 Download and Installation

1.  **Download**:
    - Go to the [Releases](https://github.com/hongguilong/timescreen/releases) page to download the latest archive.
    - Or directly download the `TimeScreen.scr` file.

2.  **Installation**:
    - Locate the downloaded `TimeScreen.scr` file.
    - **Right-click** the file and select **"Install"** from the menu.
    - The Windows "Screen Saver Settings" window will open with "Time Screen" automatically selected.

3.  **Configuration**:
    - In the "Screen Saver Settings" window, set the "Wait" time (e.g., 5 minutes).
    - Click "OK" or "Apply" to save the settings.

## 🗑️ Uninstall Instructions

1.  Open Windows "Screen Saver Settings".
2.  Switch the screensaver to another one (e.g., "None").
3.  Delete the previously downloaded `TimeScreen.scr` file and related dependency files.

## 🛠️ FAQ

- **Q: Cannot start after installation?**
  - A: Please ensure you have placed all dependency files (such as `.dll` files) in the same directory as `TimeScreen.scr`. It is recommended to keep the complete directory structure after extraction.

- **Q: How to exit the screensaver?**
  - A: Please **double click** anywhere on the screen. Moving the mouse or single clicking will not exit (accidental touch prevention design).

---

_(For Developers: This project is built with Flutter. Source code is available in this repository. Use `flutter run -d windows` to develop.)_
