{ stdenv, fetchgit, libX11, libXinerama, libXft }:

let
  name = "dwm";

in
stdenv.mkDerivation {
  inherit name;

  ## own source prepatched etc
  src = fetchgit {
    url = "https://github.com/Thomashrb/dwm_patched.git";
    rev = "bcaa6d8c45fbfe350e52cca17552e423f69ec3f6";
    sha256 = null;
  };

  buildInputs = [ libX11 libXinerama libXft ];

  prePatch = ''sed -i "s@/usr/local@$out@" config.mk'';

  buildPhase = "make";

}
