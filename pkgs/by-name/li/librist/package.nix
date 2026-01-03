{
  stdenv,
  lib,
  fetchFromGitLab,
  meson,
  ninja,
  pkg-config,
  cjson,
  cmocka,
  mbedtls,
  windows,
}:

stdenv.mkDerivation rec {
  pname = "librist";
  version = "0.2.11";

  src = fetchFromGitLab {
    domain = "code.videolan.org";
    owner = "rist";
    repo = "librist";
    rev = "v${version}";
    hash = "sha256-xWqyQl3peB/ENReMcDHzIdKXXCYOJYbhhG8tcSh36dY=";
  };

  # avoid rebuild on Linux for now
  patches = lib.optionals stdenv.hostPlatform.isDarwin [
    # https://code.videolan.org/rist/librist/-/issues/192
    ./no-brew-darwin.diff
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  mesonFlags = lib.optionals stdenv.hostPlatform.isMinGW [
    # Enable the MinGW+winpthreads path. Without this, librist forces
    # HAVE_PTHREADS=0 on Windows and builds its internal pthread/time shims,
    # which then conflict with winpthreads (and with deps like mbedtls that
    # include <pthread.h>).
    "-Dhave_mingw_pthreads=true"
  ];

  buildInputs = [
    cjson
    cmocka
    mbedtls
  ] ++ lib.optionals stdenv.hostPlatform.isMinGW [
    # librist uses pthreads on MinGW when available (MSYS2 depends on libwinpthread).
    # Also avoids conflicts with librist's internal pthread shim when a dependency
    # (e.g. mbedtls) includes <pthread.h>.
    windows.pthreads
  ];

  env.NIX_LDFLAGS = lib.optionalString stdenv.hostPlatform.isMinGW "-lpthread";

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  meta = {
    description = "Library that can be used to easily add the RIST protocol to your application";
    homepage = "https://code.videolan.org/rist/librist";
    license = with lib.licenses; [
      bsd2
      mit
      isc
    ];
    maintainers = with lib.maintainers; [ raphaelr ];
    platforms = lib.platforms.all;
  };
}
