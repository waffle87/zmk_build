#!/bin/sh
ZMK_DIR=~/waffle_git/zmk
source $ZMK_DIR/.venv/bin/activate

build() {
    printf "building $1 for $2...\n"
    (cd $ZMK_DIR/app
        west build -p always -b $2 -- -DSHIELD=$1 \
            -DZMK_CONFIG="$HOME/waffle_git/zmk-build/config" \
            &> /dev/null

        read -p "flash? (y/n) " yn
        case $yn in
            [Yy]*)
                printf "enter bootloader...\n"
                mkdir tmp
                sleep 10
                doas mount /dev/sdb tmp
                doas cp build/zephyr/zmk.uf2 tmp
                doas umount /dev/sdb
                rmdir tmp
                ;;
            [Nn]*) cp build/zephyr/zmk.uf2 ~/$1.uf2 ;;
            * ) printf "invalid entry\n" ;;
        esac
    )
    printf "complete\n"
}

printf "firmware to build...\n"
printf "(1) corne\t(2) revxlp\t(3) sweep\t(4) settings reset:\t"
read opt;
case $opt in
    1)
        build corne_left nice_nano
        build corne_right nice_nano_v2
        ;;
    2)
        build revxlp seeeduino_xiao_ble
        ;;
    3)
        build splitkb_aurora_sweep_left nice_nano_v2
        build splitkb_aurora_sweep_right nice_nano_v2
        ;;
    4)
        printf "select microcontroller...\n"
        printf "(1) nice nano\t(2) nice nano v2\t(3) xiao ble:\t"
        read val;
        case $val in
            1) MCU="nice_nano" ;;
            2) MCU="nice_nano_v2" ;;
            3) MCU="seeeduino_xiao_ble" ;;
            *) printf "invalid entry\n" ;;
        esac
        build settings_reset $MCU
        ;;
    *) printf "invalid entry\n" ;;
esac
