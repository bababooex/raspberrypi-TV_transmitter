#!/bin/bash
#Script uses whiptail to create "user friendly" interface
#Video currently doesnt run very well, so needs update
# === File configuration and size ===
TV_SCRIPT="./testrpitx"
IMAGE_DIR="./images"
VIDEO_DIR="./videos"
TEMP_DIR="/tmp/tv_image.gray"
# should be left alone, otherwise will not be really stable and make errors
WIDTH=52
HEIGHT=625
# ===================================

if [[ $EUID -ne 0 ]]; then
  whiptail --msgbox "This program must be run as sudo!" 10 50
  exit 1
fi

if ! command -v magick &>/dev/null; then
  echo "Missing dependency: ImageMagick"
  exit 1
elif ! command -v ffmpeg &>/dev/null; then
  echo "Missing dependency: ffmpeg"
  exit 1 
fi

whiptail --msgbox "This program can cause interference!\nUse with caution!" 10 50

while true; do
  CHOICE=$(whiptail --title "Experimental TV transmitter" \
    --menu "Select an option:" 20 60 10 \
    "1" "Transmit test pattern" \
    "2" "Transmit grayscale image" \
    "3" "Transmit grayscale video" \
    "4" "Exit" \
    3>&1 1>&2 2>&3)

  case "$CHOICE" in

  "1")
      FREQ=$(whiptail --inputbox \
      "Enter transmit frequency (Hz):" \
      10 50 "194000000" \
      3>&1 1>&2 2>&3)

      if [ -z "$FREQ" ]; then
        whiptail --msgbox "Going back to menu!" 10 50
        continue
      fi
        whiptail --msgbox "Transmitting test pattern!\nPress Ctrl+C to stop." 10 50
        "$TV_SCRIPT" --pattern --freq "$FREQ" || whiptail --msgbox "Error running transmitter script."
        whiptail --msgbox "Going back to menu!" 10 50
      ;;
  "2")
    if [[ ! -d "$IMAGE_DIR" ]]; then
      whiptail --msgbox "Image directory not found: $IMAGE_DIR" 10 50
      continue
    fi

    IMAGE_MENU=""
    for f in "$IMAGE_DIR"/*.{png,jpg,jpeg,bmp}; do
      [[ -e "$f" ]] || continue
      b=$(basename "$f")
      IMAGE_MENU+=" $b $b"
    done

    if [[ -z "$IMAGE_MENU" ]]; then
      whiptail --msgbox "No image files found." 10 50
      continue
    fi

    IMAGE=$(whiptail --title "Select Image" \
      --menu "Choose image to transmit:" 20 60 10 \
      $IMAGE_MENU 3>&1 1>&2 2>&3)

    [[ -z "$IMAGE" ]] && continue

    magick convert "$IMAGE_DIR/$IMAGE" \
      -resize ${WIDTH}x${HEIGHT}! \
      -colorspace Gray \
      -depth 8 \
      "$TEMP_DIR"

    FREQ=$(whiptail --inputbox \
      "Enter transmit frequency (Hz):" \
      10 50 "194000000" \
      3>&1 1>&2 2>&3)

    if [ -z "$FREQ" ]; then
        whiptail --msgbox "Going back to menu!" 10 50
        continue
    fi
       whiptail --msgbox "Transmitting image!\nPress Ctrl+C to stop." 10 50
       "$TV_SCRIPT" --image "$TEMP_DIR" --freq "$FREQ" || whiptail --msgbox "Error running transmitter script."
       rm -f /tmp/tv_image.gray
       whiptail --msgbox "Going back to menu!" 10 50
      ;;
  "3")
    if [[ ! -d "$VIDEO_DIR" ]]; then
      whiptail --msgbox "Video directory not found: $VIDEO_DIR" 10 50
      continue
    fi

    VIDEO_MENU=""
    for f in "$VIDEO_DIR"/*.mp4; do
      [[ -e "$f" ]] || continue
      b=$(basename "$f")
      VIDEO_MENU+=" $b $b"
    done

    if [[ -z "$VIDEO_MENU" ]]; then
      whiptail --msgbox "No video files found." 10 50
      continue
    fi

    VIDEO=$(whiptail --title "Select Video" \
      --menu "Choose video to transmit:" 20 60 10 \
      $VIDEO_MENU 3>&1 1>&2 2>&3)

    [[ -z "$VIDEO" ]] && continue

    FREQ=$(whiptail --inputbox \
      "Enter transmit frequency (Hz):" \
      10 50 "194000000" \
      3>&1 1>&2 2>&3)


    if [ -z "$FREQ" ]; then
        whiptail --msgbox "Going back to menu!" 10 50
        continue
    fi
       whiptail --msgbox "Transmitting video!\nPress Ctrl+C to stop." 10 50

    ffmpeg -i "$VIDEO_DIR/$VIDEO" \
      -vf scale=${WIDTH}:${HEIGHT},format=gray \
      -pix_fmt gray \
      -f rawvideo pipe:1 | "$TV_SCRIPT" --video - --freq "$FREQ" || whiptail --msgbox "Error running transmitter script."

       whiptail --msgbox "Going back to menu!" 10 50
      ;;
    "4")
      whiptail --msgbox "Good bye!" 10 50
      break
      ;;

    *)
      whiptail --msgbox "Good bye!" 10 50
      break
      ;;
  esac
done
