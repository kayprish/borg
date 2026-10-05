{
  pkgs ? import <nixpkgs> { },
}:

let
  inherit (pkgs) lib;
  python = pkgs.python3Packages;

  # These releases are not yet available in nixpkgs.
  fromPyPI =
    pname: version: hash:
    python.buildPythonPackage {
      inherit pname version;
      src = pkgs.fetchPypi { inherit pname version hash; };
      pyproject = true;
      build-system = with python; [
        setuptools
        setuptools-scm
        wheel
      ];
      pythonImportsCheck = [ pname ];
    };

  borghash = fromPyPI "borghash" "0.2.0" "sha256-gfpsBWNmuxGFY7VxfGqEKWFRwM5dPtQgrN6fOs1Ptvk=";
  borgstore =
    (fromPyPI "borgstore" "0.6.1" "sha256-7/rjRrLlgT9Xv2zpkMjgr3ZbNj17ClFHqKWFyTzZzrw=")
    .overridePythonAttrs
      {
        dependencies = with python; [
          requests
          blake3
        ];
      };
  shtab = fromPyPI "shtab" "1.11.0" "sha256-V9+KZGSEs/AFF6QpNLFzVU+CeXane2Bc62oaDmSekmY=";
in
python.buildPythonApplication rec {
  pname = "borgbackup";
  version = "2.0.0b23";
  src = lib.cleanSource ./.;
  pyproject = true;

  # Nix sources do not contain Git metadata for setuptools-scm.
  env.SETUPTOOLS_SCM_PRETEND_VERSION = version;

  build-system = with python; [
    setuptools
    setuptools-scm
    wheel
    cython
    pkgconfig
  ];
  nativeBuildInputs = [ pkgs.pkg-config ];
  buildInputs = [
    pkgs.openssl
    pkgs.lz4
  ]
  ++ lib.optional pkgs.stdenv.hostPlatform.isLinux pkgs.acl;

  dependencies =
    with python;
    [
      borghash
      borgstore
      shtab
      msgpack
      packaging
      platformdirs
      jsonargparse
      pyyaml
      blake3
    ]
    ++ lib.optional (lib.versionOlder python.python.version "3.14") backports-zstd;

  makeWrapperArgs = [ "--prefix PATH : ${lib.makeBinPath [ pkgs.openssh ]}" ];
  pythonImportsCheck = [ "borg.archiver" ];

  meta = {
    description = "Deduplicating archiver with compression and authenticated encryption";
    homepage = "https://www.borgbackup.org/";
    license = lib.licenses.bsd3;
    mainProgram = "borg";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
