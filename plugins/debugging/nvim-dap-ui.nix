{ pkgs, lib, helpers, ... }:

with lib;

let
  inherit (helpers.generator)
     mkLuaPlugin;

  name = "nvim-dap-ui";
  pluginUrl = "https://github.com/rcarriga/nvim-dap-ui";

  cfg = config.programs.nixneovim.plugins.${name};

  moduleOptions = with helpers; {
    # add module options here
  };
  pluginOptions = helpers.convertModuleOptions cfg moduleOptions;

in mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    nvim-dap-ui
  ];
  extraConfigLua = "require('dapui').setup ${toLuaObject pluginOptions}";
  defaultRequire = false;
}
