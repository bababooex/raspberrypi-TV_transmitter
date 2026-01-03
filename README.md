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
You also need to create videos and images folders in app folder and then put images and videos in them. Various formats of images and mp4 for video is supported.
# Usage
Basically same as in the original librpitx, with minor changes
```
//first you need to make the original files (no all are needed, but I am lazy to change it)
git clone https://github.com/bababooex/raspberrypi-TV_transmitter.git
cd raspberrypi-TV_transmitter
cd src
make
//make modified version of testrpitx
cd ..
cd app
make
//finally run script - needs sudo privileges
sudo ./menu.sh
```
# Warning
Like author says: "Rpitx is a software made for educational on RF system. It has not been tested for compliance with regulations governing transmission of radio signals. You are responsible for using your Raspberry Pi legally."
The same thing applies here! The transmission is not very stable, has alot of harmonics and it is definitelly not legal in this sense. The range can be few meters, so dont transmit on bad frequencies (FM, AIR etc.) or at least add a filter!
# External references
- https://github.com/bababooex/raspberrypi-subghz-ASK/tree/main - My previous code -> reusing script logic, no need to reimplement, just rewrite
- https://github.com/F5OEO/librpitx - The original librpitx, basically what I forked from
# TO DO
- fix video stability(, currently runs well with test pattern and image)
# Credits
Evariste Courjaud F5OEO
