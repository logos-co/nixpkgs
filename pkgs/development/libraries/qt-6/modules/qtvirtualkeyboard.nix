{
  qtModule,
  qtbase,
  qtdeclarative,
  qtsvg,
  hunspell,
  pkg-config,
  lib,
  pkgsBuildBuild,
  stdenv,
}:

qtModule {
  pname = "qtvirtualkeyboard";
  propagatedBuildInputs = [
    qtbase
    qtdeclarative
    qtsvg
    hunspell
  ];
  nativeBuildInputs = [ pkg-config ];

  # Cross: QtVirtualKeyboard is a QtQuick module; ensure Qt::Quick is discoverable
  # and that host-side Qml/Quick tools are available.
  cmakeFlags = [
    "-DQt6Quick_DIR=${qtdeclarative}/lib/cmake/Qt6Quick"
  ]
  ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    "-DQt6QmlTools_DIR=${pkgsBuildBuild.qt6.qtdeclarative}/lib/cmake/Qt6QmlTools"
    "-DQt6QuickTools_DIR=${pkgsBuildBuild.qt6.qtdeclarative}/lib/cmake/Qt6QuickTools"
  ];
}
