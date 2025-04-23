{
  description = "ASIMOV CLI Flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";

  outputs = { self, nixpkgs, ... }:
    let
      pkgsFor = system: import nixpkgs { inherit system; };

      platforms = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      versions = {
        asimov         = "25.0.0-dev.3";
        asimov-module  = "25.0.0-dev.2";
        asimov-dataset = "25.0.0-dev.5";
      };

      urls = {
        "x86_64-linux" = {
          asimov         = "https://github.com/asimov-platform/asimov-cli/releases/download/${versions.asimov}/asimov-linux-x86-gnu.gz";
          asimov-module  = "https://github.com/asimov-platform/asimov-module-cli/releases/download/${versions.asimov-module}/module-cli-linux-x86-gnu.gz";
          asimov-dataset = "https://github.com/asimov-platform/asimov-dataset-cli/releases/download/${versions.asimov-dataset}/asimov-linux-x86-gnu.gz";
        };
        "aarch64-linux" = {
          asimov         = "https://github.com/asimov-platform/asimov-cli/releases/download/${versions.asimov}/asimov-linux-arm-gnu.gz";
          asimov-module  = "https://github.com/asimov-platform/asimov-module-cli/releases/download/${versions.asimov-module}/module-cli-linux-arm-gnu.gz";
          asimov-dataset = "https://github.com/asimov-platform/asimov-dataset-cli/releases/download/${versions.asimov-dataset}/asimov-linux-arm-gnu.gz";
        };
        "x86_64-darwin" = {
          asimov         = "https://github.com/asimov-platform/asimov-cli/releases/download/${versions.asimov}/asimov-macos-x86.gz";
          asimov-module  = "https://github.com/asimov-platform/asimov-module-cli/releases/download/${versions.asimov-module}/module-cli-macos-x86.gz";
          asimov-dataset = "https://github.com/asimov-platform/asimov-dataset-cli/releases/download/${versions.asimov-dataset}/asimov-macos-x86.gz";
        };
        "aarch64-darwin" = {
          asimov         = "https://github.com/asimov-platform/asimov-cli/releases/download/${versions.asimov}/asimov-macos-arm.gz";
          asimov-module  = "https://github.com/asimov-platform/asimov-module-cli/releases/download/${versions.asimov-module}/module-cli-macos-arm.gz";
          asimov-dataset = "https://github.com/asimov-platform/asimov-dataset-cli/releases/download/${versions.asimov-dataset}/asimov-macos-arm.gz";
        };
      };

      hashes = {
        "x86_64-linux" = { # 6b6e54fd490e036d864158de7d4b19a248aaf64c926ff9d3daa9db0f463d6f9c
          asimov         = "d8cb3ad98499d42ec4f89c6669264935a41b0583f6e3995b7e1382b73b654af6";
          asimov-module  = "d8cb3ad98499d42ec4f89c6669264935a41b0583f6e3995b7e1382b73b654af6";
          asimov-dataset = "abbcf6612278381d079e85b658cced97b47f71652437fa39e6eb8dc2423d6d6d";
        };
        "aarch64-linux" = { # ef21144725eeccd0618357f0bb4936d1653a8968bfa8b530fa2490685470dc33
          asimov         = "83deb2d62df03a24e5f3965a9a137efe423714c9d852763f6223ff4dc96d33c0";
          asimov-module  = "b90bc4cda8f648b5d0f7863f141c9a314b4410edf40fd7b0f5a20c4c9aa01b30";
          asimov-dataset = "83deb2d62df03a24e5f3965a9a137efe423714c9d852763f6223ff4dc96d33c0";
        };
        "x86_64-darwin" = {
          asimov         = "eaaa532d63de98905367816b5ec6fad87815d2911d6d57bf7ddeec446f36bec5";
          asimov-module  = "18b26b321279923109b5dc81d7c8cb3cb5db7179a5db6e27601849add9195c37";
          asimov-dataset = "ea11d213dc01c99171e456de94958acc37abe84992b1c234b48e75a85ad6497d";
        };
        "aarch64-darwin" = {
          asimov         = "e67ec61334647909fa1d405498ca42a6e7a9a96471a435ec5bbb7dc784c08ce4";
          asimov-module  = "39d3c86b017c0b51a263f946f44d398161f44920e3b224e8c718cca3f7cbd57d";
          asimov-dataset = "cf4f4b1058db1f5238df985b3958e596c6eea84c3f92f0d8f0f5a489174eefbf";
        };
      };

      mkBin = { name, system }: let
        pkgs = pkgsFor system;
      in pkgs.stdenv.mkDerivation {
        pname = name;
        version = versions.${name};
        src = pkgs.fetchurl {
          url = urls.${system}.${name};
          sha256 = hashes.${system}.${name};
        };
        nativeBuildInputs = [ pkgs.gzip ];
        phases = [ "unpackPhase" "installPhase" ];
        unpackPhase = ''
          cp $src ${name}.gz
          gunzip ${name}.gz
          chmod +x ${name}
        '';
        installPhase = ''
          mkdir -p $out/bin
          mv ${name} $out/bin/${name}
        '';
        checkPhase = ''
          $out/bin/${name} --version
        '';
        doCheck = true;
      };

      perPlatform = system: let
        pkgs = pkgsFor system;
        derivations = map (name: mkBin { inherit name system; }) [ "asimov" "asimov-module" "asimov-dataset" ];
      in {
        default = pkgs.buildEnv {
          name = "asimov-cli";
          paths = derivations;
        };
      };

    in {
      packages = builtins.listToAttrs (map (system: {
        name = system;
        value = perPlatform system;
      }) platforms);

      defaultPackage = {
        x86_64-linux  = self.packages.x86_64-linux.default;
        aarch64-linux = self.packages.aarch64-linux.default;
        x86_64-darwin = self.packages.x86_64-darwin.default;
        aarch64-darwin = self.packages.aarch64-darwin.default;
      };
    };
}
