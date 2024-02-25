#!/bin/sh
ZMK_DIR=~/waffle_git/zmk
RED=$(tput setaf 1)
YELLOW=$(tput setaf 3)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
BOLD=$(tput bold)
NORMAL=$(tput sgr0)
source $ZMK_DIR/.venv/bin/activate

build() {
    printf "building $GREEN$1$NORMAL for $BLUE$2$NORMAL...\n"
    (cd $ZMK_DIR/app
        west build -p always -b $2 -- -DSHIELD=$1 \
            -DZMK_CONFIG="$HOME/waffle_git/zmk-build/config" \
            &> /dev/null

        read -p "${BOLD}flash? (y/n) $NORMAL" yn
        case $yn in
            [Yy]*)
                printf "${YELLOW}enter bootloader$NORMAL...\n"
                sleep 5
                west flash
                ;;
            [Nn]*) cp build/zephyr/zmk.uf2 ~/$1.uf2 ;;
            * ) printf "${RED}invalid entry$NORMAL\n" ;;
        esac
    )
    printf "${GREEN}complete$NORMAL\n"
}

printf "${BOLD}firmware to build...$NORMAL\n"
printf "(1) corne\t(2) revxlp\t(3) sweep\t(4) settings reset:\t"
read opt;
case $opt in
    1)
        build corne_left nice_nano
        build corne_right nice_nano_v2
        ;;
    2)
        if [ ! -L $ZMK_DIR/app/boards/shields/revxlp ]; then
            ln -sv revxlp $ZMK_DIR/app/boards/shields/revxlp
        fi
        build revxlp seeeduino_xiao_ble
        ;;
    3)
        build splitkb_aurora_sweep_left nice_nano_v2
        build splitkb_aurora_sweep_right nice_nano_v2
        ;;
    4)
        printf "${BOLD}select microcontroller...$NORMAL\n"
        printf "(1) nice nano\t(2) nice nano v2\t(3) xiao ble:\t"
        read val;
        case $val in
            1) MCU="nice_nano" ;;
            2) MCU="nice_nano_v2" ;;
            3) MCU="seeeduino_xiao_ble" ;;
            *) printf "${RED}invalid entry$NORMAL\n" ;;
        esac
        build settings_reset $MCU
        ;;
    *) printf "${RED}invalid entry$NORMAL\n" ;;
esac
