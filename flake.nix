{
  description = "A neovim configuration system for NixOS";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  inputs.nmdSrc.url = "gitlab:rycee/nmd";
  inputs.nmdSrc.flake = false;

  inputs.vimExtraPlugins.url = "github:jooooscha/nixpkgs-vim-extra-plugins";

  outputs = { self, nixpkgs, nmdSrc, vimExtraPlugins, ... }@inputs: 
  let 
    system = "x86_64-linux";
    pkgs = import nixpkgs { 
      inherit system;
      overlays = [
        vimExtraPlugins.overlays.default
      ];
    };
  in {
    packages."x86_64-linux".docs = import ./docs {
      # pkgs = import nixpkgs {
      #   system = system;
      # };
      pkgs = pkgs;
      lib = nixpkgs.lib;
    };

    nixosModules.nixvim = import ./nixvim.nix { nixos = true; pkgs = pkgs; };
    homeManagerModules.nixvim = import ./nixvim.nix { homeManager = true; pkgs = pkgs; };

    # # This is a simple container for testing
    # nixosConfigurations.container = nixpkgs.lib.nixosSystem {
    #   system = "x86_64-linux";
    #   modules = [
    #     ({ pkgs, ... }: {
    #       boot.isContainer = true;
    #       system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;

    #       users.users.test = {
    #         isNormalUser = true;
    #         password = "";
    #       };

    #       imports = [ nixosModules.nixvim ];

    #       programs.nixvim = {
    #         enable = true;
    #         package = pkgs.neovim;
    #         colorschemes.tokyonight = { enable = true; };

    #         extraPlugins = [ pkgs.vimPlugins.vim-nix ];

    #         options = {
    #           number = true;
    #           mouse = "a";
    #           tabstop = 2;
    #           shiftwidth = 2;
    #           expandtab = true;
    #           smarttab = true;
    #           autoindent = true;
    #           cindent = true;
    #           linebreak = true;
    #           hidden = true;
    #         };

    #         maps.normalVisualOp."ç" = ":";
    #         maps.normal."<leader>m" = {
    #           silent = true;
    #           action = "<cmd>make<CR>";
    #         };

    #         plugins.lualine = {
    #           enable = true;
    #         };

    #         plugins.undotree.enable = true;
    #         plugins.gitgutter.enable = true;
    #         plugins.fugitive.enable = true;
    #         plugins.commentary.enable = true;
    #         plugins.startify = {
    #           enable = true;
    #           useUnicode = true;
    #         };
    #         plugins.goyo = {
    #           enable = true;
    #           showLineNumbers = true;
    #         };

    #         plugins.lsp = {
    #           enable = true;
    #           servers.clangd.enable = true;
    #         };

    #         plugins.telescope = {
    #           enable = true;
    #           extensions = { frecency.enable = true; };
    #         };

    #         plugins.nvim-autopairs = { enable = true; };

    #         globals = {
    #           vimsyn_embed = "l";
    #           mapleader = " ";
    #         };

    #         plugins.lspsaga.enable = true;

    #         plugins.treesitter.enable = true;
    #         plugins.ledger.enable = true;
    #       };
    #     })
    #   ];
    # };
  };
}
