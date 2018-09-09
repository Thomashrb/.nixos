{ stdenv, fetchgit, libX11, libXinerama, libXft }:

let
  name = "dwm";

in
stdenv.mkDerivation {
  inherit name;

  ## own source prepatched etc
  src = fetchgit {
    url = "https://github.com/Thomashrb/dwm_patched.git";
    rev = "3ee7e12c4d1e59e8456e0b0764b260968c2f1aa2";
    sha256 = null;
  };

  buildInputs = [ libX11 libXinerama libXft ];

  prePatch = ''sed -i "s@/usr/local@$out@" config.mk'';

  buildPhase = "make";

}
