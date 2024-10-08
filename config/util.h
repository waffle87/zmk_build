// Copyright 2024 jack@pngu.org
// SPDX-License-Identifier: MIT

// clang-format off
#define COMBO(name, keypress, keypos) \
combo_##name {                        \
   timeout-ms = <50>;                 \
   bindings = <keypress>;             \
   key-positions = <keypos>;          \
};

#define TAP_DANCE(name, keypress1, keypress2) \
td_##name: name {                             \
  compatible = "zmk,behavior-tap-dance";      \
  label = ###name;                            \
  #binding-cells = <0>;                       \
  tapping-term-ms = <200>;                    \
  bindings = <keypress1>, <keypress2>;        \
};

#define HRML(k1,k2,k3,k4) &hm LALT k1 &hm LGUI k2 &hm LCTRL k3 &hm LSHFT k4
#define HRMR(k1,k2,k3,k4) &hm RSHFT k1 &hm RCTRL k2 &hm RGUI k3 &hm RALT k4

&lt {
  tapping-term-ms = <100>;
};

/ {
  behaviors {
    hm: homerow_mods {
      compatible = "zmk,behavior-hold-tap";
      label = "HOMEROW_MODS";
      #binding-cells = <2>;
      tapping-term-ms = <130>;
      quick-tap-ms = <160>;
      flavor = "tap-preferred";
      bindings = <&kp>, <&kp>;
    };

    pnp: play_next_prev {
      compatible = "zmk,behavior-tap-dance";
      label = "PLAY_NEXT_PREV";
      #binding-cells = <0>;
      tapping-term-ms = <210>;
      bindings = <&kp C_PLAY>, <&kp C_NEXT>, <&kp C_PREV>;
    };
    TAP_DANCE(cbrkt,     &kp LBRC, &kp RBRC)
    TAP_DANCE(brkt,      &kp LBKT, &kp RBKT)
    TAP_DANCE(min_dash,  &kp MINUS, &emdash)
  };

  macros {
    updir: updir {
      label = "UP_DIR";
      compatible = "zmk,behavior-macro";
      #binding-cells = <0>;
      bindings = <&macro_tap &kp DOT &kp DOT &kp FSLH>;
    };
    emdash: emdash {
      label = "EM_DASH";
      compatible = "zmk,behavior-macro";
      #binding-cells = <0>;
      bindings = <&macro_press &kp LSHFT &kp LCTRL>,
                 <&macro_tap &kp U &kp N2 &kp N0 &kp N1 &kp N4>,
                 <&macro_release &kp LSHFT &kp LCTRL>;
    };
  };
};
// clang-format on
