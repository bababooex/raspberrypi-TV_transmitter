# raspberrypi-TV_transmitter
Experimentation with transmitting analog video with raspberry pi gpio. Credit goes to Evariste Courjaud F5OEO, I just added script for using the analog tv function from librpitx and modified original testrpitx code, nothing too special.
# Requirements
The script requires ffmpeg for video and ImageMagick for image conversion, you can install them by running:
```
//recommend updating just to be safe
sudo apt update
//for ImageMagick
sudo apt install imagemagick
//for ffmpeg
sudo apt install ffmpeg
```
# Usage
Basically same as in the original librpitx, with minor changes
```
git clone https://github.com/bababooex/raspberrypi-TV_transmitter/
cd librpitx/src
make
```

# External references
- https://github.com/bababooex/raspberrypi-subghz-ASK/tree/main - My previous code -> reusing script logic, no need to reimplement, just rewrite
- https://github.com/F5OEO/librpitx - The original librpitx, basically what I forked from

