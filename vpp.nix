{ stdenv
, cmake
, ninja
, python3
, pkg-config
, dpdk
, libbpf
, libbsd
, libelf
, libnl
, libuuid
, mbedtls
, openssl
, rdma-core
, check
, subunit
, writeScript
, vppSource
}:
let
  version = "22.02";
  versionScript = writeScript "version" "echo ${version}-foo-bar";
in

stdenv.mkDerivation {
  pname = "vpp";
  inherit version;

  src = "${vppSource}/src";

  nativeBuildInputs = [
    cmake
    ninja
    (python3.withPackages (p: [ p.ply ]))
    pkg-config
  ];

  buildInputs = [
    dpdk # must be at least 21.11 TODO assert this
    libbpf
    libbsd
    libelf
    libnl
    libuuid
    mbedtls
    openssl
    rdma-core
  ];

  checkInputs = [
    check # surprise dep: cmake lists are not `find_package`ing it
    subunit
  ];

  doCheck = true;

  postPatch = ''
    cp ${versionScript} scripts/version

    # So much about -Wall
    sed -i \
        -e 's/cmake pkg/cmake/' \
        -e 's/-Wall/-Wall -Wno-stringop-overflow -Wno-unused-variable/' \
        CMakeLists.txt

    # this script produces impure results
    sed -i \
        -e 's/$(whoami)/itseme/' \
        -e 's/$(hostname)/mario/' \
        -e 's/^DATE_FMT.*$//' \
        -e 's/^VPP_BUILD_DATE=.*$/SOURCE_DATE_EPOCH="2022-01-01T00:00:00"/' \
        -e 's|$(git rev-parse[^)]\+)|/vpp-src|' \
        scripts/generate_version_h

    patchShebangs .
  '';

  cmakeFlags = [ "-DVPP_USE_SYSTEM_DPDK=1" ];
}
