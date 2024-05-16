{ lib, pkgs, helpers, config }:
let


  inherit (helpers.generator)
     mkLuaPlugin;

  inherit (lib.types)
    either
    int
    str
    attrsOf;

  name = "emmet";
  pluginUrl = "https://github.com/emmetio/emmet";

  # only needed when the name of the plugin does not match the
  # name in the 'require("<...>")' call. For example, the plugin 'comment-frame'
  # has to be called with 'require("nvim-comment-frame")'
  # in such a case add 'pluginName = "nvim-comment-frame"'
  # pluginName = ""

  inherit (helpers.custom_options)
    strOption
    attrsOfOption
    enumOption;

  eitherAttrsStrInt =
    let
      strInt = either str int;
    in either strInt (attrsOf (either strInt (attrsOf strInt)));

  moduleOptionsVim = {
    # add module options here
    mode = enumOption [ "i" "n" "v" "a" ] "n" "Mode where emmet will enable";
    leaderKey = strOption "<C-Y>" "Set leader key";
    settings = attrsOfOption (attrsOf eitherAttrsStrInt) {} "Emmet settings";
  };

in mkLuaPlugin {
  inherit name moduleOptionsVim pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    emmet-vim
  ];
  moduleOptionsVimPrefix = "user_emmet_";
  defaultRequire = false;
}
