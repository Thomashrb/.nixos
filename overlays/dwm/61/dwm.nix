{ stdenv, fetchgit, libX11, libXinerama, libXft }:

let
  name = "dwm";

in
stdenv.mkDerivation {
  inherit name;

  ## own source prepatched etc
  src = fetchgit {
    url = "https://github.com/Thomashrb/dwm_patched.git";
    rev = "e047be4914c44b0ca52a4b6f3a021c70dc5c3b2b";
    sha256 = null;
  };

  buildInputs = [ libX11 libXinerama libXft ];

  prePatch = ''sed -i "s@/usr/local@$out@" config.mk'';

  buildPhase = "make";

}
