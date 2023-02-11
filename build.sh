#!/bin/sh
ZSDK_VERSION=0.13.2
LINK=~/waffle_git/zmk/app/boards/shields/revxlp
CONFIG_DIR=~/waffle_git/zmk-build/config
ZMK_DIR=~/waffle_git/zmk

update() {
  (cd $ZMK_DIR ; git pull ; west update)
  wget "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${ZSDK_VERSION}/zephyr-toolchain-arm-${ZSDK_VERSION}-linux-x86_64-setup.run"
  chmod +x zephyr-toolchain-arm-${ZSDK_VERSION}-linux-x86_64-setup.run
  ./zephyr-toolchain-arm-${ZSDK_VERSION}-linux-x86_64-setup.run -- -d ~/.local/zephyr-sdk-${ZSDK_VERSION}
  rm zephyr-toolchain-arm-${ZSDK_VERSION}-linux-x86_64-setup.run
}

read -p "update? (y/n) " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
  update
fi

build() {
  (cd $ZMK_DIR/app
  west build -p -b $1 -- -DSHIELD=$2 -DZMK_CONFIG="$3" 1> /dev/null
  cp build/zephyr/zmk.uf2 ~/$2_$1.uf2
  )
}

flash() {
  read -p "flash? (y/n) " -n 1 -r
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    sleep 10
    sudo mount /dev/sdb /tmp/disk
    cp ~/$1.uf2 /tmp/disk/$2
    echo "success :^)"
    if (( $3 )); then
      sleep 30
      sudo mount /dev/sdb /tmp/disk
      cp ~/$4.uf2 /tmp/disk/$2
      echo "success :^)"
    fi
  fi
}

echo -e "\n"
PS3="choose keyboard to build: "
options=("corne" "revxlp" "settings reset" "quit")
select opt in "${options[@]}"
do
  case $opt in
    "corne")
      echo "building corne firmware..."
      build nice_nano corne_left $CONFIG_DIR
      build nice_nano_v2 corne_right $CONFIG_DIR
      flash corne_left_nice_nano NICENANO 2 corne_right_nice_nano_v2
      echo -e "\ncomplete :^)"
      break
      ;;
    "revxlp")
      echo "building revxlp firmware..."
      cp config/corne.keymap revxlp/revxlp.keymap
      cp util.h $ZMK_DIR/app/boards/shields
      if [ ! -L $LINK ]; then
        ln -s ~/waffle_git/zmk-build/revxlp $LINK
      fi
      build seeeduino_xiao_ble revxlp
      rm revxlp/revxlp.keymap
      rm $ZMK_DIR/app/boards/shields/util.h
      flash revxlp_seeduino_xiao_ble XIAO-SENSE
      echo -e "\ncomplete :^)"
      break
      ;;
    "settings reset")
      echo "building settings reset firmware..."
      build nice_nano settings_reset v1
      build nice_nano_v2 settings_reset v2
      build seeeduino_xiao_ble settings_reset xiao
      echo -e "\ncomplete :^)"
      break
      ;;
    "quit")
      break
      ;;
    *) echo "invalid option: $REPLY";;
  esac
done
