# Samsung APK Downloader
_Licensed under the terms of the GNU General Public License v3.0._

## What does it do?
This bash script allows you to download APKs directly from Samsung's servers (similar to the Galaxy Store) for the specified device and sdk level, so
you can manually update samsung apps.

## How to use?
On a Linux or WSL system, run:

```
./samsung-apk-downloader.sh <package> <model> <sdk>
```

You can also run the script without any arguments, so it will ask you for the details:
```
./samsung-apk-downloader.sh
Enter package name (Samsung apps only): 
Enter your device model (SM-XXXXX format): 
Enter your android version (SDK format - 19 30 34 etc.):
```

## Credits:
- **[@david-lev](https://github.com/david-lev)** for the original [python script](https://github.com/david-lev/SamsungApkDownloader)