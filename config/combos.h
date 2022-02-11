// Copyright 2022 @waffle87
// SPDX-License-Identifier: MIT

compatible = "zmk,combos";
#define COMBO(name, keypress, keypos) \
  combo_##name { \
    timeout-ms = <50>; \
    bindings = <keypress>; \
    key-positions = <keypos>; \
  };
