{
  lib,
  stdenv,
  autoreconfHook,
  fetchFromGitHub,
  libiconv,
  readline,
  windows,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "unixodbc";
  version = "2.3.14";

  src = fetchFromGitHub {
    owner = "lurcher";
    repo = "unixODBC";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2WhUnpiNTtsoOJ4rvdxaadcW1ROWfdoSVA8Crj8rpo8=";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isMinGW [
    # MSYS2 depends on these on MinGW; keep them conditional to avoid changing unix builds.
    libiconv
    readline
    # Provide libpthread.a / winpthreads for MinGW. unixODBC's build system uses -pthread
    # which otherwise resolves to -lpthread and fails the link.
    windows.pthreads
  ];

  preConfigure = lib.optionalString stdenv.hostPlatform.isMinGW ''
    # Prefer winpthreads on MinGW (MSYS2 depends on libwinpthread).
    export PTHREAD_LIBS="-lwinpthread"
    export PTHREAD_CFLAGS=""
  '';

  configureFlags = [
    "--disable-gui"
    "--sysconfdir=/etc"
  ]
  ++ lib.optionals stdenv.hostPlatform.isMinGW [
    # Align with MSYS2 mingw-w64-unixodbc PKGBUILD intent.
    "--enable-iconv=yes"
    "--enable-static"
    "--enable-shared"
  ];

  meta = {
    changelog = "https://github.com/lurcher/unixODBC/releases/tag/v${finalAttrs.version}";
    description = "ODBC driver manager for Unix";
    homepage = "https://www.unixodbc.org/";
    license = lib.licenses.lgpl2;
    maintainers = with lib.maintainers; [ hythera ];
    # MSYS2 packages unixODBC for MinGW; enable it for nixpkgs Windows targets as well.
    platforms = lib.platforms.unix ++ lib.platforms.windows;
  };
})
