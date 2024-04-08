#!/bin/sh
ZMK_DIR=~/git/zmk
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
BOLD=$(tput bold)
NORMAL=$(tput sgr0)
source $ZMK_DIR/.venv/bin/activate
set -e

build() {
    printf "building ${GREEN}$1${NORMAL} for ${BLUE}$2${NORMAL}...\n"
    (cd $ZMK_DIR/app
        MODULE_CMD=""
        if [ "$3" ]; then
            MODULE_CMD="-DZMK_EXTRA_MODULES=$HOME/git/zmk-build/$3"
        fi
        west build -p always -b $2 -- -DSHIELD=$1 \
            -DZMK_CONFIG=$HOME/git/zmk-build/config $MODULE_CMD

        read -p "${BOLD}flash? (y/n) ${NORMAL}" yn
        case $yn in
            [Yy]*)
                printf "${YELLOW}enter bootloader${NORMAL}...\n"
                sleep 5
                udisksctl mount -b /dev/sdb
                west flash
                ;;
            [Nn]*) cp build/zephyr/zmk.uf2 ~/$1.uf2 ;;
            * ) printf "${RED}invalid entry${NORMAL}\n" ;;
        esac
    )
    printf "${GREEN}complete${NORMAL}\n"
}

printf "${BOLD}firmware to build${NORMAL}...\n"
printf "(1) corne\t(2) corne-ish zen\t(3) revxlp\t(4) sweep\t(5) settings reset:\t"
read opt;
case $opt in
    1)
        build corne_left nice_nano
        build corne_right nice_nano_v2
        ;;
    2)
        build corneish_zen_v1_left
        build corneish_zen_v1_right
        ;;
    3)
        build revxlp seeeduino_xiao_ble "revxlp"
        ;;
    4)
        build splitkb_aurora_sweep_left nice_nano_v2
        build splitkb_aurora_sweep_right nice_nano_v2
        ;;
    5)
        printf "${BOLD}select microcontroller${NORMAL}...\n"
        printf "(1) nice nano\t(2) nice nano v2\t(3) xiao ble:\t"
        read val;
        case $val in
            1) MCU="nice_nano" ;;
            2) MCU="nice_nano_v2" ;;
            3) MCU="seeeduino_xiao_ble" ;;
            *) printf "${RED}invalid entry${NORMAL}\n" ;;
        esac
        build settings_reset $MCU
        ;;
    *) printf "${RED}invalid entry${NORMAL}\n" ;;
esac
