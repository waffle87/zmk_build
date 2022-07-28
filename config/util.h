// Copyright 2022 jack (@waffle87)
// SPDX-License-Identifier: MIT

#define COMBO(name, keypress, keypos) \
combo_##name { \
  timeout-ms = <50>; \
  bindings = <keypress>; \
  key-positions = <keypos>; \
};

#define HRML(k1,k2,k3,k4) &hm LALT k1 &hm LGUI k2 &hm LCTRL k3 &hm LSHFT k4
#define HRMR(k1,k2,k3,k4) &hm RSHFT k1 &hm RCTRL k2 &hm RGUI k3 &hm RALT k4
