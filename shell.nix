let
  pkgs = import <nixpkgs> { config = {}; overlays = []; };
in
pkgs.mkShell {
  packages = with pkgs; [
    R
  ];
}
