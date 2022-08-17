{ lib, pkgs, config, ... }@attrs:
let
  helpers = import ../helpers.nix { inherit lib config; };
in with helpers; with lib;
mkPlugin attrs {
  name = "asyncrun";
  description = "Enable asyncrun.vim";
  extraPlugins = [ pkgs.vimPlugins.asyncrun-vim ];
}
