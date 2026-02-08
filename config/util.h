// Copyright 2025 jack@pngu.org
// SPDX-License-Identifier: MIT

// clang-format off
#define COMBO(name, keypress, keypos) \
combo_##name {                        \
   timeout-ms = <50>;                 \
   bindings = <keypress>;             \
   key-positions = <keypos>;          \
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
      #binding-cells = <2>;
      tapping-term-ms = <130>;
      quick-tap-ms = <160>;
      flavor = "tap-preferred";
      bindings = <&kp>, <&kp>;
    };

    pnp: play_next_prev {
      compatible = "zmk,behavior-tap-dance";
      #binding-cells = <0>;
      tapping-term-ms = <210>;
      bindings = <&kp C_PLAY>, <&kp C_NEXT>, <&kp C_PREV>;
    };
  };

  macros {
    updir: updir {
      compatible = "zmk,behavior-macro";
      #binding-cells = <0>;
      bindings = <&macro_tap &kp DOT &kp DOT &kp FSLH>;
    };
    leq: leq {
      compatible = "zmk,behavior-macro";
      #binding-cells = <0>;
      bindings = <&macro_tap &kp LT &kp EQUAL>;
    };
    geq: geq {
      compatible = "zmk,behavior-macro";
      #binding-cells = <0>;
      bindings = <&macro_tap &kp GT &kp EQUAL>;
    };
    pl_asgn: pl_asgn {
      compatible = "zmk,behavior-macro";
      #binding-cells = <0>;
      bindings = <&macro_tap &kp PLUS  &kp EQUAL>;
    };
    recall: recall {
      compatible = "zmk,behavior-macro";
      #binding-cells = <0>;
      bindings = <&macro_tap &kp DLLR  &kp UNDER>;
    };
  };
};
// clang-format on
