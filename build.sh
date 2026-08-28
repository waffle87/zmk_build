#!/bin/sh

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
BOLD=$(tput bold)
NORMAL=$(tput sgr0)

set -e

ZMK_DIR="${HOME}/git/zmk"
MODULES_DIR="${HOME}/git/zmk_build/modules"
CONFIG_DIR="${HOME}/git/zmk_build/config"
BUILD_DIR="${HOME}/git/zmk_build"

if [ ! -d "$ZMK_DIR" ]; then
    printf "${RED}Error: ZMK directory not found at $ZMK_DIR${NORMAL}\n"
    exit 1
fi

if [ ! -f "$ZMK_DIR/.venv/bin/activate" ]; then
    printf "${RED}Error: Python virtual environment not found${NORMAL}\n"
    exit 1
fi

source "$ZMK_DIR/.venv/bin/activate"

build() {
    local shield=$1
    local board=$2
    local keyboard_module=$3

    printf "building ${GREEN}${shield}${NORMAL} for ${BLUE}${board}${NORMAL}...\n"

    (
        cd "$ZMK_DIR/app" || exit 1

        BASE_MODULES=""
        if [ -d "$MODULES_DIR" ]; then
            for module_dir in "$MODULES_DIR"/*; do
                if [ -d "$module_dir" ]; then
                    if [ -z "$BASE_MODULES" ]; then
                        BASE_MODULES="$module_dir"
                    else
                        BASE_MODULES="$BASE_MODULES;$module_dir"
                    fi
                fi
            done
        fi

        KEYBOARD_MODULE=""
        if [ -n "$keyboard_module" ]; then
            KEYBOARD_MODULE=";${BUILD_DIR}/${keyboard_module}"
        fi

        west build -p -b "$board" -- \
                   -DSHIELD="$shield" \
                   -DZMK_CONFIG="$CONFIG_DIR" \
                   -DZMK_EXTRA_MODULES="${BASE_MODULES}${KEYBOARD_MODULE}"

        cp build/zephyr/zmk.uf2 "${BUILD_DIR}/${shield}_${board}.uf2"
    )

    printf "${GREEN}complete${NORMAL}\n"
}

printf "${BOLD}firmware to build${NORMAL}...\n"
printf "(1) flake\t(2) revxlp\t(3) settings reset:\t"
read -r opt

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
        build sweeq_left nice_nano "sweeq"
        build sweeq_right nice_nano "sweeq"
        ;;
    4)
        printf "${BOLD}select microcontroller${NORMAL}...\n"
        printf "(1) nice nano\t(2) xiao ble:\t"
        read -r val
        case $val in
            1) MCU="nice_nano" ;;
            2) MCU="xiao_ble" ;;
            *) printf "${RED}invalid entry${NORMAL}\n" ;;
        esac
        build settings_reset $MCU
        ;;
    *)
        printf "${RED}invalid entry${NORMAL}\n"
        exit 1
        ;;
esac
