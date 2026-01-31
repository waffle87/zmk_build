#!/bin/sh
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
BOLD=$(tput bold)
NORMAL=$(tput sgr0)
set -e

ZMK_DIR=$HOME/git/zmk
source $ZMK_DIR/.venv/bin/activate

build() {
    printf "building ${GREEN}$1${NORMAL} for ${BLUE}$2${NORMAL}...\n"
    (cd $ZMK_DIR/app
        MODULE_CMD=""
        if [ "$3" ]; then
            MODULE_CMD="-DZMK_EXTRA_MODULES=$HOME/git/zmk_build/$3"
        fi
        west build -p -b $2 -- -DSHIELD=$1 \
            -DZMK_CONFIG=$HOME/git/zmk_build/config $MODULE_CMD
        cp build/zephyr/zmk.uf2 ~/$1.uf2
    )
    printf "${GREEN}complete${NORMAL}\n"
}

printf "${BOLD}firmware to build${NORMAL}...\n"
printf "(1) flake\t(2) revxlp\t(3) settings reset:\t"
read opt;
case $opt in
    1)
        build flake_dongle nice_nano "flake_dongle"
        build flake_left nice_nano "flake"
        build flake_right nice_nano "flake"
        ;;
    2)
        build revxlp xiao_ble "revxlp"
        ;;
    3)
        printf "${BOLD}select microcontroller${NORMAL}...\n"
        printf "(1) nice nano v2\t(2) xiao ble:\t"
        read val;
        case $val in
            1) MCU="nice_nano" ;;
            2) MCU="xiao_ble" ;;
            *) printf "${RED}invalid entry${NORMAL}\n" ;;
        esac
        build settings_reset $MCU
        ;;
    *) printf "${RED}invalid entry${NORMAL}\n" ;;
esac
