#!/bin/bash

# Script untuk build firmware muiti device untuk ulo builder
# BobbyUnkown https://github.com/bobbyunknown



chipsets=(
    "s905x"
)

rootfs=(
    "openwrt-23.05.5-armsr-armv8-generic-rootfs.tar.gz"
)


rootfs_size=1024

select_kernel() {
    local hipset=$1
    case $hipset in
        h5-*|h616-*|h618-*|h6-*)
            echo "6.6.6-AW64-DBAI"  # AllWinner
            ;;
        rk*)
            echo "5.10.160-rk35v-dbai"  # Rockchip
            ;;
        s905*)
            echo "6.1.66-DBAI"  # Amlogic
            ;;    
        *)
            echo "Kernel tidak ditemukan untuk hipset: $hipset" >&2
            return 1
            ;;
    esac
}

build_firmware() {
    local hipset=$1
    local rootfs=$2
    local kernel=$3
    
    echo "Memulai build untuk hipset $hipset dengan rootfs $rootfs dan kernel $kernel"
    
    if [ -z "$kernel" ]; then
        echo "ERROR: Kernel tidak valid untuk hipset $hipset"
        return 1
    fi
    
    sudo ./ulo -m $hipset -r $rootfs -k $kernel -s $rootfs_size
    
    if [ $? -eq 0 ]; then
        echo "Build berhasil untuk $hipset dengan rootfs $rootfs dan kernel $kernel"
    else
        echo "Build gagal untuk $hipset dengan rootfs $rootfs dan kernel $kernel"
    fi
    
    echo "-----------------------------"
}

for hipset in "${chipsets[@]}"; do
    for rootfs_file in "${rootfs[@]}"; do
        kernel=$(select_kernel $hipset)
        if [ $? -eq 0 ]; then
            build_firmware $hipset $rootfs_file $kernel
        else
            echo "Melewati build untuk $hipset karena kernel tidak valid"
        fi
    done
done

echo "Proses multi-build selesai"
