{
  description = "Automatically swtich to tablet mode in xmonad-luca";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        xmonadctl = (pkgs.callPackage
          (pkgs.fetchFromGitHub {
            owner = "quoteme";
            repo = "xmonadctl";
            rev = "v1.0";
            sha256 = "1bjf3wnxsghfb64jji53m88vpin916yqlg3j0r83kz9k79vqzqxd";
          })
          { });
        myHaskellPackages = (hpkgs: with hpkgs; [ base ]);
        buildInputs = (with pkgs; [
          libinput
          xmonadctl
          (haskellPackages.ghcWithPackages myHaskellPackages)
        ]);
      in
      rec {
        defaultApp = apps.tabletmodehook;
        defaultPackage = packages.tabletmodehook;

        apps.tabletmodehook = {
          type = "app";
          program = "${defaultPackage}/bin/tabletmodehook";
        };

        packages.tabletmodehook = pkgs.stdenv.mkDerivation {
          name = "tabletmodehook";
          pname = "tabletmodehook";
          src = ./src;
					nativeBuildInputs = [ pkgs.makeWrapper ];
          buildInputs = buildInputs;
          buildPhase = ''
						mkdir build
						ln -sf $src/* build
						ghc -o tabletmodehook Main.hs
					'';
          installPhase = 
					''
						mkdir -p $out/bin
						cp tabletmodehook $out/bin
						wrapProgram $out/bin/tabletmodehook --prefix PATH : ${pkgs.lib.makeBinPath buildInputs}
						chmod +x $out/bin/tabletmodehook
					'';
        };

        # create a defualt devshell
        devShell = pkgs.mkShell {
          buildInputs = buildInputs;
        };
      }
    );
}
# vim: tabstop=2 shiftwidth=2 noexpandtab
