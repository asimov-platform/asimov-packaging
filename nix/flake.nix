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
        asimov  = "25.0.0-dev.4";
        module  = "25.0.0-dev.2";
        dataset = "25.0.0-dev.5";
      };

      urls = {
        "x86_64-linux" = {
          asimov  = "https://github.com/asimov-platform/asimov-cli/releases/download/${versions.asimov}/asimov-linux-x86-gnu.gz";
          module  = "https://github.com/asimov-platform/asimov-module-cli/releases/download/${versions.module}/module-cli-linux-x86-gnu.gz";
          dataset = "https://github.com/asimov-platform/asimov-dataset-cli/releases/download/${versions.dataset}/asimov-linux-x86-gnu.gz";
        };
        "aarch64-linux" = {
          asimov  = "https://github.com/asimov-platform/asimov-cli/releases/download/${versions.asimov}/asimov-linux-arm-gnu.gz";
          module  = "https://github.com/asimov-platform/asimov-module-cli/releases/download/${versions.module}/module-cli-linux-arm-gnu.gz";
          dataset = "https://github.com/asimov-platform/asimov-dataset-cli/releases/download/${versions.dataset}/asimov-linux-arm-gnu.gz";
        };
        "x86_64-darwin" = {
          asimov  = "https://github.com/asimov-platform/asimov-cli/releases/download/${versions.asimov}/asimov-macos-x86.gz";
          module  = "https://github.com/asimov-platform/asimov-module-cli/releases/download/${versions.module}/module-cli-macos-x86.gz";
          dataset = "https://github.com/asimov-platform/asimov-dataset-cli/releases/download/${versions.dataset}/asimov-macos-x86.gz";
        };
        "aarch64-darwin" = {
          asimov  = "https://github.com/asimov-platform/asimov-cli/releases/download/${versions.asimov}/asimov-macos-arm.gz";
          module  = "https://github.com/asimov-platform/asimov-module-cli/releases/download/${versions.module}/module-cli-macos-arm.gz";
          dataset = "https://github.com/asimov-platform/asimov-dataset-cli/releases/download/${versions.dataset}/asimov-macos-arm.gz";
        };
      };

      hashes = {
        "x86_64-linux" = {
          asimov  = "0c30685a1b814364c17a70b629e3b94a24bec0c66c1943bd324cf56b57980326";
          module  = "d8cb3ad98499d42ec4f89c6669264935a41b0583f6e3995b7e1382b73b654af6";
          dataset = "abbcf6612278381d079e85b658cced97b47f71652437fa39e6eb8dc2423d6d6d";
        };
        "aarch64-linux" = {
          asimov  = "2761b82936598588b7266d6d63abd1271e57d087c14f382f1ab15e523973c3e5";
          module  = "b90bc4cda8f648b5d0f7863f141c9a314b4410edf40fd7b0f5a20c4c9aa01b30";
          dataset = "83deb2d62df03a24e5f3965a9a137efe423714c9d852763f6223ff4dc96d33c0";
        };
        "x86_64-darwin" = {
          asimov  = "f2620190d96c1d929ce1c43d6e7f6ba751b32b3000d6419c5f032e4e23a2dc3e";
          module  = "18b26b321279923109b5dc81d7c8cb3cb5db7179a5db6e27601849add9195c37";
          dataset = "ea11d213dc01c99171e456de94958acc37abe84992b1c234b48e75a85ad6497d";
        };
        "aarch64-darwin" = {
          asimov  = "c89a0660b1d091c332f6cf1611fe6f9021c8ed48948f2c43e2b05dfeb7afc8de";
          module  = "39d3c86b017c0b51a263f946f44d398161f44920e3b224e8c718cca3f7cbd57d";
          dataset = "cf4f4b1058db1f5238df985b3958e596c6eea84c3f92f0d8f0f5a489174eefbf";
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
          mkdir -p $out/${if name == "asimov" then "bin" else "libexec"}
          mv ${name} $out/${if name == "asimov" then "bin" else "libexec"}/${name}
        '';
        checkPhase = ''
          ${if name == "asimov" then "$out/bin/asimov --version" else ""}
        '';
        doCheck = name == "asimov";
      };

      perPlatform = system: let
        pkgs = pkgsFor system;
        bins = [ "asimov" "module" "dataset" ];
        derivations = map (n: mkBin { name = if n == "module" then "asimov-module" else if n == "dataset" then "asimov-dataset" else "asimov"; system = system; }) bins;
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
