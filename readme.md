# zmk_build
This repository contains my [ZMK](https://github.com/zmkfirmware/zmk) keymap configuration & keyboard code.

![keyboard](https://i.imgur.com/bCRPsDy.jpg)

## Building
GitHub actions is used to build externally maintained keyboards (such as those that are modules, or live in upstream ZMK), and keyboards maintained within this repository can be built locally as modules. The ['build.sh'](build.sh) script simplifies running long `west` commands.

## Layout & Features
The layout used across my ZMK keyboards matches near identically to that of my QMK keyboards, found [here](https://git.pngu.org/qmk_me/about/#layout). Urob's [zmk-helpers](https://github.com/urob/zmk-helpers) & [zmk-unicode](https://github.com/urob/zmk-unicode) modules are used to assist in configuring ZMK's Devicetree-oriented features.
