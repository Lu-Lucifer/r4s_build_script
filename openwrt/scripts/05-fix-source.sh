#!/bin/bash

# apk-tools
curl -s $mirror/openwrt/patch/apk-tools/9999-hack-for-linux-pre-releases.patch > package/system/apk/patches/9999-hack-for-linux-pre-releases.patch

# libsodium - fix build with lto (GNU BUG - 89147)
sed -i "/CONFIGURE_ARGS/i\TARGET_CFLAGS += -ffat-lto-objects\n" feeds/packages/libs/libsodium/Makefile

# haproxy - fix build with quictls
sed -i '/USE_QUIC_OPENSSL_COMPAT/d' feeds/packages/net/haproxy/Makefile

# xdp-tools
rm -rf package/network/utils/xdp-tools
git clone https://$github/sbwml/package_network_utils_xdp-tools package/network/utils/xdp-tools

# fix gcc14
if [ "$USE_GCC14" = y ] || [ "$USE_GCC15" = y ]; then
    # linux-atm
    rm -rf package/network/utils/linux-atm
    git clone https://$github/sbwml/package_network_utils_linux-atm package/network/utils/linux-atm
    # glibc
    # Added the compiler flag -Wno-implicit-function-declaration to suppress
    # warnings about implicit function declarations during the build process.
    # This change addresses build issues in environments where some functions
    # are used without prior declaration.
    if [ "$ENABLE_GLIBC" = "y" ]; then
        # perl
        sed -i "/Target perl/i\TARGET_CFLAGS_PERL += -Wno-implicit-function-declaration -Wno-int-conversion\n" feeds/packages/lang/perl/Makefile
        sed -i '/HOST_BUILD_PARALLEL/aPKG_BUILD_FLAGS:=no-mold' feeds/packages/lang/perl/Makefile
        # lucihttp
        sed -i "/TARGET_CFLAGS/i\TARGET_CFLAGS += -Wno-implicit-function-declaration" feeds/luci/contrib/package/lucihttp/Makefile
        # rpcd
        sed -i "/TARGET_LDFLAGS/i\TARGET_CFLAGS += -Wno-implicit-function-declaration" package/system/rpcd/Makefile
        # ucode-mod-lua
        sed -i "/Build\/Configure/i\TARGET_CFLAGS += -Wno-implicit-function-declaration" feeds/luci/contrib/package/ucode-mod-lua/Makefile
        # luci-base
        sed -i "s/-DNDEBUG/-DNDEBUG -Wno-implicit-function-declaration/g" feeds/luci/modules/luci-base/src/Makefile
        # uhttpd
        sed -i "/Package\/uhttpd\/install/i\TARGET_CFLAGS += -Wno-implicit-function-declaration\n" package/network/services/uhttpd/Makefile
        # shadow
        sed -i '/TARGET_LDFLAGS/d' feeds/packages/utils/shadow/Makefile
        sed -i 's/libxcrypt/openssl/g' feeds/packages/utils/shadow/Makefile
    fi
fi

# fix gcc-15
if [ "$USE_GCC15" = y ]; then
    sed -i '/TARGET_CFLAGS/ s/$/ -Wno-error=unterminated-string-initialization/' package/libs/mbedtls/Makefile
    # elfutils
    curl -s $mirror/openwrt/patch/openwrt-6.x/gcc-15/elfutils/901-backends-fix-string-initialization-error-on-gcc15.patch > package/libs/elfutils/patches/901-backends-fix-string-initialization-error-on-gcc15.patch
    # libwebsockets
    mkdir -p feeds/packages/libs/libwebsockets/patches
    curl -s $mirror/openwrt/patch/openwrt-6.x/gcc-15/libwebsockets/901-fix-string-initialization-error-on-gcc15.patch > feeds/packages/libs/libwebsockets/patches/901-fix-string-initialization-error-on-gcc15.patch
    # libxcrypt
    mkdir -p feeds/packages/libs/libxcrypt/patches
    curl -s $mirror/openwrt/patch/openwrt-6.x/gcc-15/libxcrypt/901-fix-string-initialization-error-on-gcc15.patch > feeds/packages/libs/libxcrypt/patches/901-fix-string-initialization-error-on-gcc15.patch
fi

# fix gcc-15.0.1 C23
if [ "$USE_GCC15" = y ]; then
    # gmp
    mkdir -p package/libs/gmp/patches
    curl -s $mirror/openwrt/patch/openwrt-6.x/gcc-15-c23/gmp/001-fix-build-with-gcc-15.patch > package/libs/gmp/patches/001-fix-build-with-gcc-15.patch
    # htop - 24.10-NEXT
    HTOP_VERSION=3.4.1
    HTOP_HASH=af9ec878f831b7c27d33e775c668ec79d569aa781861c995a0fbadc1bdb666cf
    sed -ri "s/(PKG_VERSION:=)[^\"]*/\1$HTOP_VERSION/;s/(PKG_HASH:=)[^\"]*/\1$HTOP_HASH/" feeds/packages/admin/htop/Makefile
    # libtirpc
    sed -i '/TARGET_CFLAGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/libs/libtirpc/Makefile
    # libsepol
    sed -i '/HOST_MAKE_FLAGS/i TARGET_CFLAGS += -std=gnu17\n' package/libs/libsepol/Makefile
    # tree
    sed -i '/MAKE_FLAGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/utils/tree/Makefile
    # gdbm
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/libs/gdbm/Makefile
    # libical
    sed -i '/CMAKE_OPTIONS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/libs/libical/Makefile
    # libconfig
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' package/feeds/packages/libconfig/Makefile
    # lsof
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/utils/lsof/Makefile
    # screen
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/utils/screen/Makefile
    # ppp
    sed -i '/CONFIGURE_VARS/i \\nTARGET_CFLAGS += -std=gnu17\n' package/network/services/ppp/Makefile
    # vim
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/utils/vim/Makefile
    # mtd
    sed -i '/target=/i TARGET_CFLAGS += -std=gnu17\n' package/system/mtd/Makefile
    # libselinux
    sed -i '/MAKE_FLAGS/i TARGET_CFLAGS += -std=gnu17\n' package/libs/libselinux/Makefile
    # avahi
    sed -i '/TARGET_CFLAGS +=/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/libs/avahi/Makefile
    # bash
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/utils/bash/Makefile
    # xl2tpd
    sed -i '/ifneq (0,0)/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/net/xl2tpd/Makefile
    # dnsmasq
    sed -i '/MAKE_FLAGS/i TARGET_CFLAGS += -std=gnu17\n' package/network/services/dnsmasq/Makefile
    # bluez
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/utils/bluez/Makefile
    # e2fsprogs
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' package/utils/e2fsprogs/Makefile
    # f2fs-tools
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' package/utils/f2fs-tools/Makefile
    # krb5
    sed -i '/CONFIGURE_VARS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/net/krb5/Makefile
    # parted
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/utils/parted/Makefile
    # iperf3
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/net/iperf3/Makefile
    # db
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/libs/db/Makefile
    # python3
    sed -i '/TARGET_CONFIGURE_OPTS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/lang/python/python3/Makefile
    # uwsgi
    sed -i '/MAKE_VARS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/net/uwsgi/Makefile
    # perl
    sed -i '/Target perl/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/lang/perl/Makefile
    # rsync
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/net/rsync/Makefile
    # shine
    sed -i '/Build\/InstallDev/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/sound/shine/Makefile
    # jq
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/utils/jq/Makefile
fi

# ksmbd luci
sed -i 's/0666/0644/g;s/0777/0755/g' feeds/luci/applications/luci-app-ksmbd/htdocs/luci-static/resources/view/ksmbd.js

# ksmbd tools
sed -i 's/0666/0644/g;s/0777/0755/g' feeds/packages/net/ksmbd-tools/files/ksmbd.config.example
sed -i 's/bind interfaces only = yes/bind interfaces only = no/g' feeds/packages/net/ksmbd-tools/files/ksmbd.conf.template

# vim - fix E1187: Failed to source defaults.vim
pushd feeds/packages
    curl -s $mirror/openwrt/patch/vim/0001-vim-fix-renamed-defaults-config-file.patch | patch -p1
popd

# perf
curl -s $mirror/openwrt/patch/openwrt-6.x/musl/990-add-typedefs-for-Elf64_Relr-and-Elf32_Relr.patch > toolchain/musl/patches/990-add-typedefs-for-Elf64_Relr-and-Elf32_Relr.patch
curl -s $mirror/openwrt/patch/openwrt-6.x/perf/Makefile > package/devel/perf/Makefile

# kselftests-bpf
curl -s $mirror/openwrt/patch/packages-patches/kselftests-bpf/Makefile > package/devel/kselftests-bpf/Makefile

# sms-tools
mkdir -p feeds/packages/utils/sms-tool/patches
curl -s $mirror/openwrt/patch/packages-patches/sms-tools/900-fix-incompatible-pointer-type-error-for-signal-function.patch > feeds/packages/utils/sms-tool/patches/900-fix-incompatible-pointer-type-error-for-signal-function.patch

# bcm53xx
if [ "$platform" = "bcm53xx" ]; then
    # mtd
    sed -i 's/=1 -Wall/=1 -Wall -Wno-implicit-function-declaration/g' package/system/mtd/Makefile
    # uwsgi
    sed -i '/MAKE_VARS+=/iTARGET_CFLAGS += -Wno-incompatible-pointer-types\n' feeds/packages/net/uwsgi/Makefile
    # libsoxr
    sed -i '/CMAKE_INSTALL/iPKG_BUILD_FLAGS:=no-lto no-mold\n' feeds/packages/libs/libsoxr/Makefile
    # wsdd2
    sed -i '/Build\/Compile/iTARGET_CFLAGS += -Wno-error -Wno-int-conversion\n' feeds/packages/net/wsdd2/Makefile
fi
