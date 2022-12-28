#!/bin/sh
ZSDK_VERSION=0.13.2
ZEN_BRANCH=Board-Corne-ish-Zen-dedicated-work-queue
LINK=~/waffle_git/zmk/app/boards/shields/revxlp
CONFIG_DIR=~/waffle_git/zmk-build/config
ZMK_DIR=~/waffle_git/zmk
UF2=~/*.uf2

update() {
  (cd ${ZMK_DIR} ; git pull ; west update)
  wget "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${ZSDK_VERSION}/zephyr-toolchain-arm-${ZSDK_VERSION}-linux-x86_64-setup.run"
  chmod +x zephyr-toolchain-arm-${ZSDK_VERSION}-linux-x86_64-setup.run
  ./zephyr-toolchain-arm-${ZSDK_VERSION}-linux-x86_64-setup.run -- -d ~/.local/zephyr-sdk-${ZSDK_VERSION}
  rm zephyr-toolchain-arm-${ZSDK_VERSION}-linux-x86_64-setup.run
}

test_uf2() {
  if test -f ${UF2}; then
    rm ${UF2}
  fi
}

read -p "update? (y/n) " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
  update
fi

echo -e "\n"
PS3="choose keyboard to build: "
options=("corne" "corne-ish zen" "revxlp" "settings reset" "quit")
select opt in "${options[@]}"
do
  case $opt in
    "corne")
      echo "building corne firmware..."
      test_uf2
      (cd ${ZMK_DIR}
      if [ $(git branch --show-current) == "${ZEN_BRANCH}"]; then
        git checkout main
        update
      fi)
      (cd ${ZMK_DIR}/app
      west build -p -b nice_nano -- -DSHIELD=corne_left -DZMK_CONFIG="${CONFIG_DIR}"
      cp ${ZMK_DIR}/app/build/zephyr/zmk.uf2 ~/corne_left.uf2
      west build -p -b nice_nano_v2 -- -DSHIELD=corne_right -DZMK_CONFIG="${CONFIG_DIR}"
      cp ${ZMK_DIR}/app/build/zephyr/zmk.uf2 ~/corne_right.uf2
      )
      break
      ;;
    "corne-ish zen")
      echo "building corne-ish zen firmware..."
      test_uf2
      cp config/corne.keymap config/corne-ish_zen.keymap
      (cd ${ZMK_DIR}
      if [[ $(git branch --show-current) = "main" ]]; then
        git checkout ${ZEN_BRANCH}
        update
      fi)
      (cd ${ZMK_DIR}/app
      west build -p -b corne-ish_zen_left -- -DZMK_CONFIG="${CONFIG_DIR}"
      cp ${ZMK_DIR}/app/build/zephyr/zmk.uf2 ~/corne-ish_zen_left.uf2
      west build -p -b corne-ish_zen_right -- -DZMK_CONFIG="${CONFIG_DIR}"
      cp ${ZMK_DIR}/app/build/zephyr/zmk.uf2 ~/corne-ish_zen_right.uf2
      )
      rm config/corne-ish_zen.keymap
      break
      ;;
    "revxlp")
      echo "building revxlp firmware..."
      test_uf2
      cp config/corne.keymap revxlp/revxlp.keymap
      if ! [ -L $LINK]; then
        ln -s ~/waffle_git/zmk-build/revxlp $LINK
      fi
      (cd ${ZMK_DIR}/app
      west build -p -b seeeduino_xiao_ble -- -DSHIELD=revxlp
      cp ${ZMK_DIR}/app/build/zephyr/zmk.uf2 ~/revxlp.uf2
      )
      rm revxlp/revxlp.keymap
      break
      ;;
    "settings reset")
      echo "building settings reset firmware..."
      test_uf2
      (cd ${ZMK_DIR}/app
      west build -p -b nice_nano -- -DSHIELD=settings_reset
      cp ${ZMK_DIR}/app/build/zephyr/zmk.uf2 ~/settings_reset_v1.uf2
      west build -p -b nice_nano_v2 -- -DSHIELD=settings_reset
      cp ${ZMK_DIR}/app/build/zephyr/zmk.uf2 ~/settings_reset_v2.uf2
      )
      break
      ;;
    "quit")
      break
      ;;
    *) echo "invalid option: $REPLY";;
  esac
done
