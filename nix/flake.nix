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
        asimov         = "25.0.0-dev.4";
        asimov-module  = "25.0.0-dev.3";
        asimov-dataset = "25.0.0-dev.6";
      };

      urls = {
        x86_64-linux = {
          asimov         = "https://github.com/asimov-platform/asimov-cli/releases/download/${versions.asimov}/asimov-linux-x86-gnu.gz";
          asimov-module  = "https://github.com/asimov-platform/asimov-module-cli/releases/download/${versions.asimov-module}/asimov-module-cli-linux-x86-gnu.gz";
          asimov-dataset = "https://github.com/asimov-platform/asimov-dataset-cli/releases/download/${versions.asimov-dataset}/asimov-dataset-cli-linux-x86-gnu.gz";
        };
        aarch64-linux = {
          asimov         = "https://github.com/asimov-platform/asimov-cli/releases/download/${versions.asimov}/asimov-linux-arm-gnu.gz";
          asimov-module  = "https://github.com/asimov-platform/asimov-module-cli/releases/download/${versions.asimov-module}/asimov-module-cli-linux-arm-gnu.gz";
          asimov-dataset = "https://github.com/asimov-platform/asimov-dataset-cli/releases/download/${versions.asimov-dataset}/asimov-dataset-cli-linux-arm-gnu.gz";
        };
        x86_64-darwin = {
          asimov         = "https://github.com/asimov-platform/asimov-cli/releases/download/${versions.asimov}/asimov-macos-x86.gz";
          asimov-module  = "https://github.com/asimov-platform/asimov-module-cli/releases/download/${versions.asimov-module}/asimov-module-cli-macos-x86.gz";
          asimov-dataset = "https://github.com/asimov-platform/asimov-dataset-cli/releases/download/${versions.asimov-dataset}/asimov-dataset-cli-macos-x86.gz";
        };
        aarch64-darwin = {
          asimov         = "https://github.com/asimov-platform/asimov-cli/releases/download/${versions.asimov}/asimov-macos-arm.gz";
          asimov-module  = "https://github.com/asimov-platform/asimov-module-cli/releases/download/${versions.asimov-module}/asimov-module-cli-macos-arm.gz";
          asimov-dataset = "https://github.com/asimov-platform/asimov-dataset-cli/releases/download/${versions.asimov-dataset}/asimov-dataset-cli-macos-arm.gz";
        };
      };

      hashes = {
        x86_64-linux = { # 6b6e54fd490e036d864158de7d4b19a248aaf64c926ff9d3daa9db0f463d6f9c
          asimov         = "6b6e54fd490e036d864158de7d4b19a248aaf64c926ff9d3daa9db0f463d6f9c";
          asimov-module  = "dc0c2951287df99aa20d50e2525395c62de1c2cbc716c075b9fff5003cbaa4d3";
          asimov-dataset = "f154eac9ae686cfea8d5e72b5ca96c45f77ac50e7585ca09c53e4306954044e5";
        };
        aarch64-linux = { # ef21144725eeccd0618357f0bb4936d1653a8968bfa8b530fa2490685470dc33
          asimov         = "ef21144725eeccd0618357f0bb4936d1653a8968bfa8b530fa2490685470dc33";
          asimov-module  = "be254a76dbe1a529c98dc244a1fa7dffca046817590295f08c5a605761dde55b";
          asimov-dataset = "73c35e9a608b22ae8c041e3322757eb37aedd5af2072ed867d0819509ad893b7";
        };
        x86_64-darwin = {
          asimov         = "eaaa532d63de98905367816b5ec6fad87815d2911d6d57bf7ddeec446f36bec5";
          asimov-module  = "d87085a6c955e0de0190988e365905148013d0257cb745908a70adb1ee619b3a";
          asimov-dataset = "89c952284188d493d62b0acec6c67313b1a3d05cca16042e4510173cafeebfb0";
        };
        aarch64-darwin = {
          asimov         = "e67ec61334647909fa1d405498ca42a6e7a9a96471a435ec5bbb7dc784c08ce4";
          asimov-module  = "33d613fb703ca893cecb4b47dd4b8ff627dafd5b7968ff81545a1af57db7aa96";
          asimov-dataset = "d2f99004bf815f339f2e27f3f6b4f85f682ce48a4ca0cdb8a5614a07a0afd549";
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
