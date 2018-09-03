{ stdenv, fetchgit, libX11, libXinerama, libXft }:

let
  name = "dwm";

in
stdenv.mkDerivation {
  inherit name;

  ## own source prepatched etc
  src = fetchgit {
    url = "https://github.com/Thomashrb/dwm_patched.git";
    rev = "52879b5d499c38bdd521603e6e7bff6db6cd147f";
    sha256 = null;
  };

  buildInputs = [ libX11 libXinerama libXft ];

  prePatch = ''sed -i "s@/usr/local@$out@" config.mk'';

  buildPhase = "make";

}
