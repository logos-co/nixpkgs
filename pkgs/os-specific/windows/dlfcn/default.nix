{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation rec {
  pname = "dlfcn";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "dlfcn-win32";
    repo = "dlfcn-win32";
    rev = "v${version}";
    sha256 = "sha256-ljVTMBiGp8TPufrQcK4zQtcVH1To4zcfBAbUOb+v910=";
  };

  nativeBuildInputs = [ cmake ];

  # CMake 3.30+ enforces a newer policy floor; upstream's CMakeLists.txt
  # still uses the old "cmake_minimum_required(VERSION 3.0)" semantics.
  # Pass a minimum policy version to allow configuration to proceed.
  cmakeFlags = [
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
  ];

  meta = with lib; {
    homepage = "https://github.com/dlfcn-win32/dlfcn-win32";
    description = "Set of functions that allows runtime dynamic library loading";
    license = licenses.mit;
    platforms = platforms.windows;
    maintainers = with maintainers; [ marius851000 ];
  };
}
