#!/bin/sh
ZSDK_VERSION=0.13.2
WEST_CMD="west build -p -b"
LINK=~/waffle_git/zmk/app/boards/shields/revxlp
CONFIG_DIR=~/waffle_git/zmk-build/config
ZMK_DIR=~/waffle_git/zmk

update() {
  (cd ${ZMK_DIR} ; git pull ; west update)
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

echo -e "\n"
PS3="choose keyboard to build: "
options=("corne" "revxlp" "settings reset" "quit")
select opt in "${options[@]}"
do
  case $opt in
    "corne")
      echo "building corne firmware..."
      (cd ${ZMK_DIR}/app
      ${WEST_CMD} nice_nano -- -DSHIELD=corne_left -DZMK_CONFIG="${CONFIG_DIR}" 1> /dev/null
      cp ${ZMK_DIR}/app/build/zephyr/zmk.uf2 ~/corne_left.uf2
      ${WEST_CMD} nice_nano_v2 -- -DSHIELD=corne_right -DZMK_CONFIG="${CONFIG_DIR}" 1> /dev/null
      cp ${ZMK_DIR}/app/build/zephyr/zmk.uf2 ~/corne_right.uf2
      )
      echo "complete :^)"
      break
      ;;
    "revxlp")
      echo "building revxlp firmware..."
      cp config/corne.keymap revxlp/revxlp.keymap
      if ! [ -L $LINK]; then
        ln -s ~/waffle_git/zmk-build/revxlp $LINK
      fi
      (cd ${ZMK_DIR}/app
      ${WEST_CMD} seeeduino_xiao_ble -- -DSHIELD=revxlp 1> /dev/null
      cp ${ZMK_DIR}/app/build/zephyr/zmk.uf2 ~/revxlp.uf2
      )
      rm revxlp/revxlp.keymap
      echo "complete :^)"
      break
      ;;
    "settings reset")
      echo "building settings reset firmware..."
      (cd ${ZMK_DIR}/app
      ${WEST_CMD} nice_nano -- -DSHIELD=settings_reset &> /dev/null
      cp ${ZMK_DIR}/app/build/zephyr/zmk.uf2 ~/settings_reset_v1.uf2
      ${WEST_CMD} nice_nano_v2 -- -DSHIELD=settings_reset &> /dev/null
      cp ${ZMK_DIR}/app/build/zephyr/zmk.uf2 ~/settings_reset_v2.uf2
      ${WEST_CMD} seeeduino_xiao_ble -- -DSHIELD=settings_reset &> /dev/null
      cp ${ZMK_DIR}/app/build/zephyr/zmk.uf2 ~/settings_reset_xiao.uf2
      )
      echo "complete :^)"
      break
      ;;
    "quit")
      break
      ;;
    *) echo "invalid option: $REPLY";;
  esac
done
