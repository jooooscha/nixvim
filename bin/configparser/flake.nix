{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, peotry2nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let

        pkgs = import nixpkgs { inherit system; };

        python-with-my-packages = pkgs.python3.withPackages (p: with p; [
          tree-sitter
          coloredlogs
          (
            buildPythonPackage rec {
              pname = "SLPP";
              version = "1.2.3";
              src = fetchPypi {
                inherit pname version;
                sha256 = "sha256-If3ZMoNICQxxpdMnc+juaKq4rX7MMi9eDMAQEUy1Scg=";
              };
              doCheck = false;
              propagatedBuildInputs = [
                six
              ];
            }
          )
        ]);

      in {

        packages = {
          configparser = pkgs.writeShellApplication {
            name = "configparser";
            runtimeInputs = let
              python-with-my-packages = pkgs.python3.withPackages (p: with p; [
                tree-sitter
                requests
                mistune
                beautifulsoup4
                coloredlogs
                (
                  buildPythonPackage rec {
                    pname = "SLPP";
                    version = "1.2.3";
                    src = fetchPypi {
                      inherit pname version;
                      sha256 = "sha256-If3ZMoNICQxxpdMnc+juaKq4rX7MMi9eDMAQEUy1Scg=";
                    };
                    doCheck = false;
                    propagatedBuildInputs = [
                      six
                    ];
                  }
                )
              ]);
            in [
              python-with-my-packages
              pkgs.gcc
              pkgs.nixfmt
            ];
            text = ''
              python ./main.py
            '';
          };
        };

        devShells.default =
          pkgs.mkShell {
            name = "Shell";
            packages = [
              python-with-my-packages
            ];
          };
      }
    );
}
