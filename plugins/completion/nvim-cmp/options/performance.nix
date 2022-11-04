{ lib, ... }:

with lib;
with types;

mkOption {
  default = null;
  type = types.nullOr (types.submodule (_: {
    options = {
      debounce = mkOption {
        type = types.nullOr types.int;
        default = null;
      };
      throttle = mkOption {
        type = types.nullOr types.int;
        default = null;
      };
    };
  }));
}
