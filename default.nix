{
  pkgs ? import <nixpkgs> {},
}:

pkgs.mkShell {
  buildInputs = [
    pkgs.python311
    pkgs.openjdk17
  ];
}