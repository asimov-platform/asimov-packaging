{
  description = "ASIMOV CLI Flake with explicit per-platform packages";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";

  outputs = { self, nixpkgs, ... }:
    let
      pkgsFor = system: import nixpkgs { inherit system; };

      mkAsimov = { url, sha256, system, version }:
        let
          pkgs = pkgsFor system;
        in
        pkgs.stdenv.mkDerivation {
          pname = "asimov-cli";
          inherit version;

          src = pkgs.fetchurl {
            inherit url sha256;
          };

          nativeBuildInputs = [ pkgs.gzip ];
          phases = [ "unpackPhase" "installPhase" ];

          unpackPhase = ''
            cp $src asimov.gz
            gunzip asimov.gz
            chmod +x asimov
          '';

          installPhase = ''
            mkdir -p $out/bin
            mv asimov $out/bin/
          '';

          checkPhase = ''
            $out/bin/asimov --version
          '';
          doCheck = true;
        };

      version = "25.0.0-dev.4";

      asimov-x86_64-linux = mkAsimov {
        system = "x86_64-linux";
        url    = "https://github.com/asimov-platform/asimov-cli/releases/download/${version}/asimov-linux-x86-gnu.gz";
        sha256 = "6b6e54fd490e036d864158de7d4b19a248aaf64c926ff9d3daa9db0f463d6f9c";
        inherit version;
      };

      asimov-aarch64-linux = mkAsimov {
        system = "aarch64-linux";
        url    = "https://github.com/asimov-platform/asimov-cli/releases/download/${version}/asimov-linux-arm-gnu.gz";
        sha256 = "ef21144725eeccd0618357f0bb4936d1653a8968bfa8b530fa2490685470dc33";
        inherit version;
      };

      asimov-x86_64-darwin = mkAsimov {
        system = "x86_64-darwin";
        url    = "https://github.com/asimov-platform/asimov-cli/releases/download/${version}/asimov-macos-x86.gz";
        sha256 = "eaaa532d63de98905367816b5ec6fad87815d2911d6d57bf7ddeec446f36bec5";
        inherit version;
      };

      asimov-aarch64-darwin = mkAsimov {
        system = "aarch64-darwin";
        url    = "https://github.com/asimov-platform/asimov-cli/releases/download/${version}/asimov-macos-arm.gz";
        sha256 = "e67ec61334647909fa1d405498ca42a6e7a9a96471a435ec5bbb7dc784c08ce4";
        inherit version;
      };
    in
    {
      packages.x86_64-linux.default = asimov-x86_64-linux;
      packages.aarch64-linux.default = asimov-aarch64-linux;
      packages.x86_64-darwin.default = asimov-x86_64-darwin;
      packages.aarch64-darwin.default = asimov-aarch64-darwin;

      defaultPackage.x86_64-linux = asimov-x86_64-linux;
      defaultPackage.aarch64-linux = asimov-aarch64-linux;
      defaultPackage.x86_64-darwin = asimov-x86_64-darwin;
      defaultPackage.aarch64-darwin = asimov-aarch64-darwin;
    };
}