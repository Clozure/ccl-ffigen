#!/bin/sh

set -e
rm -rf ./usr ./Applications ./Library ./System

if [ -z "${FFIGEN}" ]; then
    HERE=$(cd "$(dirname "$0")" && pwd)
    if [ -x "${HERE}/../../../ffigen5/ffigen5" ]; then
        FFIGEN="${HERE}/../../../ffigen5/ffigen5"
    elif [ -x "${HERE}/../../ffigen5/ffigen5" ]; then
        FFIGEN="${HERE}/../../ffigen5/ffigen5"
    else
        FFIGEN=ffigen5
    fi
fi

if [ -z "${FILTER_FFI}" ]; then
    HERE=$(cd "$(dirname "$0")" && pwd)
    if [ -x "${HERE}/../../../filter_ffi.py" ]; then
        FILTER_FFI="${HERE}/../../../filter_ffi.py"
    elif [ -x "${HERE}/../../filter_ffi.py" ]; then
        FILTER_FFI="${HERE}/../../filter_ffi.py"
    else
        echo "Cannot find filter_ffi.py" >&2
        exit 1
    fi
fi

if [ -z "${SDK}" ]; then
    SDK=$(xcrun --show-sdk-path)
fi
if [ -z "${TOOLCHAIN}" ]; then
    TOOLCHAIN=$(xcrun --show-toolchain-path)
fi
CLANG_VERSION=$(`xcrun --find clang` --version | head -n 1 | grep -o -E '[[:digit:]]*' | head -n 1)

platform_flags="-arch arm64 -isysroot ${SDK} -isystem ${TOOLCHAIN}/usr/lib/clang/${CLANG_VERSION}/include"

translate()
{
    includes=""
    other_flags=""

    while [ $# -gt 1 ]; do
        case "$1" in
            -include)
                includes="$includes -include $2"
                shift; shift
                ;;
            -*)
                other_flags="$other_flags $1"
                shift
                ;;
            *)
                ;;
        esac
    done
    output_dir=".`dirname $1`"
    mkdir -p "$output_dir"
    output_file="`basename $1 .h`.ffi"
    output_path="$output_dir/$output_file"
    echo $1 $other_flags $includes
    if ! "$FFIGEN" $platform_flags $other_flags -x c $includes "$1" -o "$output_path"; then
        echo "WARN: ffigen failed: $1" >&2
        rm -f "$output_path"
        exit 0
    fi
    if [ -f "$output_path" ]; then
        python3 $FILTER_FFI "$output_path"
    fi
}

translate ${SDK}/usr/include/ar.h
translate ${SDK}/usr/include/arpa/ftp.h
translate -include ${SDK}/usr/include/sys/types.h -include ${SDK}/usr/include/sys/socket.h -include ${SDK}/usr/include/netinet/in.h ${SDK}/usr/include/arpa/inet.h
translate ${SDK}/usr/include/arpa/nameser.h
translate ${SDK}/usr/include/arpa/nameser_compat.h
translate ${SDK}/usr/include/arpa/telnet.h
translate ${SDK}/usr/include/arpa/tftp.h
translate ${SDK}/usr/include/bitstring.h
translate ${SDK}/usr/include/bzlib.h
#translate ${SDK}/usr/include/c.h
translate ${SDK}/usr/include/com_err.h
translate ${SDK}/usr/include/crt_externs.h
translate ${SDK}/usr/include/ctype.h
translate ${SDK}/usr/include/curl/curl.h
translate ${SDK}/usr/include/curses.h
translate ${SDK}/usr/include/db.h
translate ${SDK}/System/Library/Frameworks/IOKit.framework/Headers/hidsystem/ev_keymap.h
translate ${SDK}/System/Library/Frameworks/IOKit.framework/Headers/hidsystem/IOHIDTypes.h
translate ${SDK}/System/Library/Frameworks/IOKit.framework/Headers/hidsystem/IOLLEvent.h
translate ${SDK}/System/Library/Frameworks/IOKit.framework/Headers/hidsystem/IOHIDShared.h
translate -include ${SDK}/usr/include/sys/cdefs.h ${SDK}/System/Library/Frameworks/IOKit.framework/Headers/hidsystem/event_status_driver.h
translate ${SDK}/usr/include/device/device_port.h
translate ${SDK}/usr/include/device/device_types.h
translate -include ${SDK}/usr/include/sys/types.h ${SDK}/usr/include/dirent.h
translate ${SDK}/usr/include/dispatch/dispatch.h
translate ${SDK}/usr/include/disktab.h
#translate ${SDK}/usr/include/DNSServiceDiscovery/DNSServiceDiscovery.h
translate ${SDK}/usr/include/dlfcn.h
translate ${SDK}/usr/include/err.h
translate ${SDK}/usr/include/errno.h
translate ${SDK}/usr/include/eti.h
translate ${SDK}/usr/include/fcntl.h
#translate ${SDK}/usr/include/float.h
translate ${SDK}/usr/include/fnmatch.h
translate ${SDK}/usr/include/form.h
translate ${SDK}/usr/include/fsproperties.h
translate ${SDK}/usr/include/fstab.h
translate -include ${SDK}/usr/include/sys/types.h ${SDK}/usr/include/fts.h
translate ${SDK}/usr/include/glob.h
translate -include ${SDK}/usr/include/sys/types.h ${SDK}/usr/include/grp.h
translate ${SDK}/usr/include/gssapi/gssapi_generic.h
translate -include ${SDK}/usr/include/gssapi/gssapi.h ${SDK}/usr/include/gssapi/gssapi_krb5.h
# can't find typedef of Str31
#translate -include ${SDK}/usr/include/sys/types.h ${SDK}/usr/include/hfs/hfs_encodings.h
translate -include ${SDK}/usr/include/sys/types.h ${SDK}/usr/include/hfs/hfs_format.h
translate -include ${SDK}/usr/include/sys/types.h ${SDK}/usr/include/hfs/hfs_mount.h
translate ${SDK}/usr/include/histedit.h
#translate ${SDK}/usr/include/httpd/httpd.h
translate -include ${SDK}/usr/include/sys/types.h ${SDK}/usr/include/ifaddrs.h
translate ${SDK}/usr/include/inttypes.h
#translate ${SDK}/usr/include/iodbcinst.h
#translate ${SDK}/usr/include/isofs/cd9660/cd9660_mount.h
#translate ${SDK}/usr/include/isofs/cd9660/cd9660_node.h
#translate ${SDK}/usr/include/isofs/cd9660/cd9660_rrip.h
#translate ${SDK}/usr/include/isofs/cd9660/iso.h
#translate ${SDK}/usr/include/isofs/cd9660/iso_rrip.h
#translate ${SDK}/usr/include/kerberosIV/des.h
#translate ${SDK}/usr/include/kerberosIV/krb.h
#translate ${SDK}/usr/include/krb.h
translate ${SDK}/usr/include/krb5.h
#translate ${SDK}/usr/include/kvm.h
translate ${SDK}/usr/include/lber.h
translate ${SDK}/usr/include/lber_types.h
translate ${SDK}/usr/include/ldap.h
translate ${SDK}/usr/include/libc.h
translate ${SDK}/usr/include/libgen.h
#translate ${SDK}/usr/include/libkern/libkern.h
translate ${SDK}/usr/include/libkern/OSReturn.h
translate ${SDK}/usr/include/libkern/OSTypes.h
translate ${SDK}/usr/include/limits.h
translate ${SDK}/usr/include/locale.h
translate ${SDK}/usr/include/mach/boolean.h
#translate ${SDK}/usr/include/mach/boot_info.h
translate ${SDK}/usr/include/mach/bootstrap.h
translate ${SDK}/usr/include/mach/clock.h
translate ${SDK}/usr/include/mach/clock_priv.h
translate ${SDK}/usr/include/mach/clock_reply.h
translate ${SDK}/usr/include/mach/clock_types.h
translate ${SDK}/usr/include/mach/error.h
translate ${SDK}/usr/include/mach/exception.h
translate ${SDK}/usr/include/mach/exception_types.h
translate ${SDK}/usr/include/mach/host_info.h
translate ${SDK}/usr/include/mach/host_priv.h
translate ${SDK}/usr/include/mach/host_reboot.h
translate ${SDK}/usr/include/mach/host_security.h
translate ${SDK}/usr/include/mach/kern_return.h
translate -include ${SDK}/usr/include/mach/vm_types.h ${SDK}/usr/include/mach/kmod.h
#translate ${SDK}/usr/include/mach/ledger.h
#translate ${SDK}/usr/include/mach/lock_set.h
translate ${SDK}/usr/include/mach/mach.h
translate ${SDK}/usr/include/mach/mach_error.h
translate ${SDK}/usr/include/mach/mach_host.h
translate ${SDK}/usr/include/mach/mach_init.h
translate ${SDK}/usr/include/mach/mach_interface.h
translate ${SDK}/usr/include/mach/mach_param.h
translate ${SDK}/usr/include/mach/mach_port.h
translate -include ${SDK}/usr/include/mach/message.h ${SDK}/usr/include/mach/mach_syscalls.h
translate ${SDK}/usr/include/mach/mach_time.h
translate ${SDK}/usr/include/mach/mach_traps.h
translate ${SDK}/usr/include/mach/mach_types.h
translate ${SDK}/usr/include/mach/machine.h
translate ${SDK}/usr/include/mach/memory_object_types.h
translate ${SDK}/usr/include/mach/message.h
translate ${SDK}/usr/include/mach/mig.h
translate ${SDK}/usr/include/mach/mig_errors.h
translate ${SDK}/usr/include/mach/ndr.h
translate ${SDK}/usr/include/mach/notify.h
translate ${SDK}/usr/include/mach/policy.h
translate ${SDK}/usr/include/mach/port.h
translate ${SDK}/usr/include/mach/port_obj.h
translate ${SDK}/usr/include/mach/processor.h
translate ${SDK}/usr/include/mach/processor_info.h
translate ${SDK}/usr/include/mach/processor_set.h
translate ${SDK}/usr/include/mach/rpc.h
translate ${SDK}/usr/include/mach/semaphore.h
translate ${SDK}/usr/include/mach/shared_region.h
translate ${SDK}/usr/include/mach/std_types.h
translate ${SDK}/usr/include/mach/sync.h
translate ${SDK}/usr/include/mach/sync_policy.h
#translate ${SDK}/usr/include/mach/syscall_sw.h
translate ${SDK}/usr/include/mach/task.h
translate ${SDK}/usr/include/mach/task_info.h
#translate ${SDK}/usr/include/mach/task_ledger.h
translate ${SDK}/usr/include/mach/task_policy.h
translate ${SDK}/usr/include/mach/task_special_ports.h
translate ${SDK}/usr/include/mach/thread_act.h
translate ${SDK}/usr/include/mach/thread_info.h
translate ${SDK}/usr/include/mach/thread_policy.h
translate ${SDK}/usr/include/mach/thread_special_ports.h
translate ${SDK}/usr/include/mach/thread_status.h
translate ${SDK}/usr/include/mach/thread_switch.h
translate ${SDK}/usr/include/mach/time_value.h
translate ${SDK}/usr/include/mach/vm_attributes.h
translate ${SDK}/usr/include/mach/vm_behavior.h
translate ${SDK}/usr/include/mach/vm_inherit.h
translate ${SDK}/usr/include/mach/vm_map.h
translate ${SDK}/usr/include/mach/machine/vm_param.h
translate ${SDK}/usr/include/mach/vm_prot.h
translate -include ${SDK}/usr/include/mach/mach_types.h ${SDK}/usr/include/mach/vm_region.h
translate ${SDK}/usr/include/mach/vm_statistics.h
translate ${SDK}/usr/include/mach/vm_sync.h
translate ${SDK}/usr/include/mach/vm_task.h
translate ${SDK}/usr/include/mach/vm_types.h
translate ${SDK}/usr/include/mach-o/arch.h
translate -D__private_extern__=extern ${SDK}/usr/include/mach-o/dyld.h
#translate -D__private_extern__=extern ${SDK}/usr/include/mach-o/dyld_debug.h
translate ${SDK}/usr/include/mach-o/fat.h
translate ${SDK}/usr/include/mach-o/getsect.h
translate ${SDK}/usr/include/mach-o/ldsyms.h
translate ${SDK}/usr/include/mach-o/loader.h
translate ${SDK}/usr/include/mach-o/nlist.h
translate ${SDK}/usr/include/mach-o/ranlib.h
translate ${SDK}/usr/include/mach-o/reloc.h
translate ${SDK}/usr/include/mach-o/stab.h
translate ${SDK}/usr/include/mach-o/swap.h
translate -include ${SDK}/usr/include/mach/machine/vm_types.h ${SDK}/usr/include/mach_debug/hash_info.h
translate ${SDK}/usr/include/mach_debug/ipc_info.h
translate ${SDK}/usr/include/mach_debug/mach_debug.h
translate ${SDK}/usr/include/mach_debug/mach_debug_types.h
translate ${SDK}/usr/include/mach_debug/page_info.h
translate ${SDK}/usr/include/mach_debug/vm_info.h
translate ${SDK}/usr/include/mach_debug/zone_info.h
translate ${SDK}/usr/include/malloc/malloc.h
translate ${SDK}/usr/include/math.h
translate ${SDK}/usr/include/memory.h
translate ${SDK}/usr/include/monitor.h
translate ${SDK}/usr/include/nameser.h
translate ${SDK}/usr/include/ncurses_dll.h
translate ${SDK}/usr/include/ndbm.h
translate -include ${SDK}/usr/include/sys/types.h -include ${SDK}/usr/include/sys/time.h ${SDK}/usr/include/net/bpf.h
translate -include ${SDK}/usr/include/sys/types.h ${SDK}/usr/include/net/ethernet.h
translate -include ${SDK}/usr/include/sys/types.h -include ${SDK}/usr/include/sys/socket.h ${SDK}/usr/include/net/if.h
translate -include ${SDK}/usr/include/sys/types.h -include ${SDK}/usr/include/sys/socket.h ${SDK}/usr/include/net/if_arp.h
translate -include ${SDK}/usr/include/sys/types.h ${SDK}/usr/include/net/if_dl.h
translate -include ${SDK}/usr/include/sys/types.h  ${SDK}/usr/include/net/if_llc.h
translate ${SDK}/usr/include/net/if_media.h
translate ${SDK}/usr/include/net/if_types.h
translate -include ${SDK}/usr/include/sys/types.h ${SDK}/usr/include/net/kext_net.h
translate -include ${SDK}/usr/include/sys/types.h ${SDK}/usr/include/net/pfkeyv2.h
#translate -include ${SDK}/usr/include/sys/types.h  ${SDK}/usr/include/net/radix.h
#translate -include ${SDK}/usr/include/sys/types.h ${SDK}/usr/include/net/route.h
#translate ${SDK}/usr/include/net/slcompress.h
#translate ${SDK}/usr/include/net/slip.h
#translate ${SDK}/usr/include/netat/adsp.h
#translate ${SDK}/usr/include/netat/appletalk.h
#translate ${SDK}/usr/include/netat/asp.h
#translate ${SDK}/usr/include/netat/at_aarp.h
#translate ${SDK}/usr/include/netat/at_ddp_brt.h
#translate ${SDK}/usr/include/netat/at_pat.h
#translate ${SDK}/usr/include/netat/at_pcb.h
#translate ${SDK}/usr/include/netat/at_snmp.h
#translate ${SDK}/usr/include/netat/at_var.h
#translate ${SDK}/usr/include/netat/atp.h
#translate ${SDK}/usr/include/netat/aurp.h
#translate ${SDK}/usr/include/netat/ddp.h
#translate ${SDK}/usr/include/netat/debug.h
#translate ${SDK}/usr/include/netat/ep.h
#translate ${SDK}/usr/include/netat/lap.h
#translate ${SDK}/usr/include/netat/nbp.h
#translate ${SDK}/usr/include/netat/pap.h
#translate ${SDK}/usr/include/netat/routing_tables.h
#translate ${SDK}/usr/include/netat/rtmp.h
#translate ${SDK}/usr/include/netat/sysglue.h
#translate ${SDK}/usr/include/netat/zip.h
#translate ${SDK}/usr/include/netccitt/dll.h
#translate ${SDK}/usr/include/netccitt/hd_var.h
#translate ${SDK}/usr/include/netccitt/hdlc.h
#translate ${SDK}/usr/include/netccitt/llc_var.h
#translate ${SDK}/usr/include/netccitt/pk.h
#translate ${SDK}/usr/include/netccitt/pk_var.h
#translate ${SDK}/usr/include/netccitt/x25.h
#translate ${SDK}/usr/include/netccitt/x25_sockaddr.h
#translate ${SDK}/usr/include/netccitt/x25acct.h
#translate ${SDK}/usr/include/netccitt/x25err.h
translate ${SDK}/usr/include/netdb.h
translate -include ${SDK}/usr/include/sys/types.h -include ${SDK}/usr/include/netinet/in.h -include ${SDK}/usr/include/netinet/in_systm.h  -include ${SDK}/usr/include/netinet/ip.h -include ${SDK}/usr/include/netinet/udp.h ${SDK}/usr/include/netinet/bootp.h
translate -include ${SDK}/usr/include/sys/types.h -include ${SDK}/usr/include/netinet/in.h  ${SDK}/usr/include/netinet/icmp6.h
translate -include ${SDK}/usr/include/sys/types.h -include ${SDK}/usr/include/netinet/in.h -include ${SDK}/usr/include/netinet/in_systm.h  -include ${SDK}/usr/include/netinet/ip.h -include ${SDK}/usr/include/netinet/ip_icmp.h ${SDK}/usr/include/netinet/icmp_var.h
translate -include ${SDK}/usr/include/sys/types.h -include ${SDK}/usr/include/sys/socket.h ${SDK}/usr/include/netinet/if_ether.h
translate -include ${SDK}/usr/include/sys/types.h -include ${SDK}/usr/include/netinet/in.h -include ${SDK}/usr/include/netinet/in_systm.h  -include ${SDK}/usr/include/netinet/ip.h -include ${SDK}/usr/include/netinet/ip_icmp.h ${SDK}/usr/include/netinet/icmp_var.h
translate -include ${SDK}/usr/include/sys/types.h -include ${SDK}/usr/include/sys/socket.h ${SDK}/usr/include/netinet/if_ether.h
translate -include ${SDK}/usr/include/sys/types.h -include ${SDK}/usr/include/netinet/in.h ${SDK}/usr/include/netinet/igmp.h
translate -include ${SDK}/usr/include/sys/types.h -include ${SDK}/usr/include/inttypes.h ${SDK}/usr/include/netinet/igmp_var.h
#translate ${SDK}/usr/include/netinet/in_pcb.h
#translate ${SDK}/usr/include/netinet/in_systm.h
#translate ${SDK}/usr/include/netinet/in_var.h
#translate ${SDK}/usr/include/netinet/ip.h
#translate ${SDK}/usr/include/netinet/ip6.h
#translate ${SDK}/usr/include/netinet/ip_fw.h
#translate ${SDK}/usr/include/netinet/ip_icmp.h
#translate ${SDK}/usr/include/netinet/ip_mroute.h
#translate ${SDK}/usr/include/netinet/ip_nat.h
#translate ${SDK}/usr/include/netinet/ip_proxy.h
#translate ${SDK}/usr/include/netinet/ip_state.h
#translate ${SDK}/usr/include/netinet/ip_var.h
translate -include ${SDK}/usr/include/sys/types.h ${SDK}/usr/include/netinet/tcp.h
#translate ${SDK}/usr/include/netinet/tcp_debug.h
#translate ${SDK}/usr/include/netinet/tcp_fsm.h
#translate ${SDK}/usr/include/netinet/tcp_seq.h
#translate ${SDK}/usr/include/netinet/tcp_timer.h
#translate ${SDK}/usr/include/netinet/tcp_var.h
#translate ${SDK}/usr/include/netinet/tcpip.h
translate -include ${SDK}/usr/include/sys/types.h  ${SDK}/usr/include/netinet/udp.h
#translate -include ${SDK}/usr/include/sys/types.h  ${SDK}/usr/include/netinet/udp_var.h
#translate ${SDK}/usr/include/netinet6/ah.h
#translate ${SDK}/usr/include/netinet6/esp.h
#translate ${SDK}/usr/include/netinet6/icmp6.h
#translate ${SDK}/usr/include/netinet6/in6.h
#translate ${SDK}/usr/include/netinet6/in6_gif.h
#translate ${SDK}/usr/include/netinet6/in6_ifattach.h
#translate ${SDK}/usr/include/netinet6/in6_pcb.h
#translate ${SDK}/usr/include/netinet6/in6_prefix.h
#translate ${SDK}/usr/include/netinet6/in6_var.h
#translate ${SDK}/usr/include/netinet6/ip6.h
#translate ${SDK}/usr/include/netinet6/ip6_fw.h
#translate ${SDK}/usr/include/netinet6/ip6_mroute.h
#translate ${SDK}/usr/include/netinet6/ip6_var.h
#translate ${SDK}/usr/include/netinet6/ip6protosw.h
#translate ${SDK}/usr/include/netinet6/ipcomp.h
#translate ${SDK}/usr/include/netinet6/ipsec.h
#translate ${SDK}/usr/include/netinet6/mip6.h
#translate ${SDK}/usr/include/netinet6/mip6_common.h
#translate ${SDK}/usr/include/netinet6/mld6_var.h
#translate ${SDK}/usr/include/netinet6/natpt_defs.h
#translate ${SDK}/usr/include/netinet6/natpt_list.h
#translate ${SDK}/usr/include/netinet6/natpt_log.h
#translate ${SDK}/usr/include/netinet6/natpt_soctl.h
#translate ${SDK}/usr/include/netinet6/natpt_var.h
#translate ${SDK}/usr/include/netinet6/nd6.h
#translate ${SDK}/usr/include/netinet6/pim6.h
#translate ${SDK}/usr/include/netinet6/pim6_var.h
#translate ${SDK}/usr/include/netinet6/udp6.h
#translate ${SDK}/usr/include/netinet6/udp6_var.h
#translate ${SDK}/usr/include/netinfo/_lu_types.h
#translate ${SDK}/usr/include/netinfo/lookup.h
#translate ${SDK}/usr/include/netinfo/lookup_types.h
#translate ${SDK}/usr/include/netinfo/ni.h
#translate ${SDK}/usr/include/netinfo/ni_prot.h
#translate ${SDK}/usr/include/netinfo/ni_util.h
#translate ${SDK}/usr/include/netinfo/nibind_prot.h
#translate ${SDK}/usr/include/netiso/argo_debug.h
#translate ${SDK}/usr/include/netiso/clnl.h
#translate ${SDK}/usr/include/netiso/clnp.h
#translate ${SDK}/usr/include/netiso/clnp_stat.h
#translate ${SDK}/usr/include/netiso/cltp_var.h
#translate ${SDK}/usr/include/netiso/cons.h
#translate ${SDK}/usr/include/netiso/cons_pcb.h
#translate ${SDK}/usr/include/netiso/eonvar.h
#translate ${SDK}/usr/include/netiso/esis.h
#translate ${SDK}/usr/include/netiso/iso.h
#translate ${SDK}/usr/include/netiso/iso_errno.h
#translate ${SDK}/usr/include/netiso/iso_pcb.h
#translate ${SDK}/usr/include/netiso/iso_snpac.h
#translate ${SDK}/usr/include/netiso/iso_var.h
#translate ${SDK}/usr/include/netiso/tp_clnp.h
#translate ${SDK}/usr/include/netiso/tp_events.h
#translate ${SDK}/usr/include/netiso/tp_ip.h
#translate ${SDK}/usr/include/netiso/tp_meas.h
#translate ${SDK}/usr/include/netiso/tp_param.h
#translate ${SDK}/usr/include/netiso/tp_pcb.h
#translate ${SDK}/usr/include/netiso/tp_seq.h
#translate ${SDK}/usr/include/netiso/tp_stat.h
#translate ${SDK}/usr/include/netiso/tp_states.h
#translate ${SDK}/usr/include/netiso/tp_timer.h
#translate ${SDK}/usr/include/netiso/tp_tpdu.h
#translate ${SDK}/usr/include/netiso/tp_trace.h
#translate ${SDK}/usr/include/netiso/tp_user.h
#translate ${SDK}/usr/include/netiso/tuba_table.h
#translate ${SDK}/usr/include/netkey/keydb.h
#translate ${SDK}/usr/include/netkey/keysock.h
#translate ${SDK}/usr/include/netns/idp.h
#translate ${SDK}/usr/include/netns/ns.h
#translate ${SDK}/usr/include/netns/ns_error.h
#translate ${SDK}/usr/include/netns/ns_if.h
#translate ${SDK}/usr/include/netns/ns_pcb.h
#translate ${SDK}/usr/include/netns/spidp.h
#translate ${SDK}/usr/include/netns/spp_debug.h
#translate ${SDK}/usr/include/netns/spp_var.h
#translate ${SDK}/usr/include/nfs/krpc.h
#translate ${SDK}/usr/include/nfs/nfs.h
#translate ${SDK}/usr/include/nfs/nfsdiskless.h
#translate ${SDK}/usr/include/nfs/nfsm_subs.h
#translate ${SDK}/usr/include/nfs/nfsmount.h
#translate ${SDK}/usr/include/nfs/nfsnode.h
#translate ${SDK}/usr/include/nfs/nfsproto.h
#translate ${SDK}/usr/include/nfs/nfsrtt.h
#translate ${SDK}/usr/include/nfs/nfsrvcache.h
#translate ${SDK}/usr/include/nfs/nqnfs.h
translate -include ${SDK}/usr/include/sys/types.h ${SDK}/usr/include/nfs/rpcv2.h
translate -include ${SDK}/usr/include/sys/types.h -include ${SDK}/usr/include/inttypes.h ${SDK}/usr/include/nfs/xdr_subs.h
#translate ${SDK}/usr/include/nlist.h
#translate ${SDK}/usr/include/NSSystemDirectories.h
#translate ${SDK}/usr/include/objc/objc-load.h
#translate ${SDK}/usr/include/objc/objc-runtime.h
#translate ${SDK}/usr/include/objc/objc.h
#translate ${SDK}/usr/include/objc/Object.h
#translate ${SDK}/usr/include/objc/Protocol.h
#translate ${SDK}/usr/include/objc/zone.h
#translate ${SDK}/usr/include/openssl/asn1.h
# translate ${SDK}/usr/include/openssl/asn1_mac.h
# translate ${SDK}/usr/include/openssl/bio.h
# translate ${SDK}/usr/include/openssl/blowfish.h
# translate ${SDK}/usr/include/openssl/bn.h
# translate ${SDK}/usr/include/openssl/buffer.h
# translate ${SDK}/usr/include/openssl/cast.h
# translate ${SDK}/usr/include/openssl/comp.h
# translate ${SDK}/usr/include/openssl/conf.h
# translate ${SDK}/usr/include/openssl/conf_api.h
# translate ${SDK}/usr/include/openssl/crypto.h
# translate ${SDK}/usr/include/openssl/des.h
# translate ${SDK}/usr/include/openssl/dh.h
# translate ${SDK}/usr/include/openssl/dsa.h
# translate ${SDK}/usr/include/openssl/dso.h
# translate ${SDK}/usr/include/openssl/e_os2.h
# translate ${SDK}/usr/include/openssl/ebcdic.h
# translate ${SDK}/usr/include/openssl/err.h
# translate ${SDK}/usr/include/openssl/evp.h
# translate ${SDK}/usr/include/openssl/hmac.h
# translate ${SDK}/usr/include/openssl/lhash.h
# translate ${SDK}/usr/include/openssl/md2.h
# translate ${SDK}/usr/include/openssl/md4.h
# translate ${SDK}/usr/include/openssl/md5.h
# translate ${SDK}/usr/include/openssl/mdc2.h
# translate ${SDK}/usr/include/openssl/obj_mac.h
# translate ${SDK}/usr/include/openssl/objects.h
# translate ${SDK}/usr/include/openssl/opensslconf.h
# translate ${SDK}/usr/include/openssl/opensslv.h
# translate ${SDK}/usr/include/openssl/pem.h
# translate ${SDK}/usr/include/openssl/pem2.h
# translate ${SDK}/usr/include/openssl/pkcs12.h
# translate ${SDK}/usr/include/openssl/pkcs7.h
# translate ${SDK}/usr/include/openssl/rand.h
# translate ${SDK}/usr/include/openssl/rc2.h
# translate ${SDK}/usr/include/openssl/rc4.h
# translate ${SDK}/usr/include/openssl/rc5.h
# translate ${SDK}/usr/include/openssl/ripemd.h
# translate ${SDK}/usr/include/openssl/rsa.h
# translate ${SDK}/usr/include/openssl/safestack.h
# translate ${SDK}/usr/include/openssl/sha.h
# translate ${SDK}/usr/include/openssl/ssl.h
# translate ${SDK}/usr/include/openssl/ssl2.h
# translate ${SDK}/usr/include/openssl/ssl23.h
# translate ${SDK}/usr/include/openssl/ssl3.h
# translate ${SDK}/usr/include/openssl/stack.h
# translate ${SDK}/usr/include/openssl/symhacks.h
# translate ${SDK}/usr/include/openssl/tls1.h
# translate ${SDK}/usr/include/openssl/tmdiff.h
# translate ${SDK}/usr/include/openssl/txt_db.h
# translate ${SDK}/usr/include/openssl/x509.h
# translate ${SDK}/usr/include/openssl/x509_vfy.h
# translate ${SDK}/usr/include/openssl/x509v3.h
translate -include ${SDK}/usr/include/security/pam_types.h ${SDK}/usr/include/security/openpam.h
translate ${SDK}/usr/include/security/openpam_attr.h
translate ${SDK}/usr/include/security/openpam_version.h
translate ${SDK}/usr/include/security/pam_appl.h
translate ${SDK}/usr/include/security/pam_constants.h
translate ${SDK}/usr/include/security/pam_modules.h
translate ${SDK}/usr/include/security/pam_types.h
translate ${SDK}/usr/include/paths.h
translate -include ${SDK}/usr/include/sys/types.h -include ${SDK}/usr/include/sys/time.h -include ${SDK}/usr/include/net/bpf.h -include ${SDK}/usr/include/stdio.h ${SDK}/usr/include/pcap-namedb.h
translate ${SDK}/usr/include/pcap.h
#translate ${SDK}/usr/include/pexpert/boot.h
#translate ${SDK}/usr/include/pexpert/pexpert.h
translate ${SDK}/usr/include/pexpert/protos.h
#translate ${SDK}/usr/include/profile/profile-internal.h
#translate ${SDK}/usr/include/profile/profile-kgmon.c
#translate ${SDK}/usr/include/profile/profile-mk.h
translate ${SDK}/usr/include/profile.h
#translate ${SDK}/usr/include/protocols/dumprestore.h
#translate ${SDK}/usr/include/protocols/routed.h
translate ${SDK}/usr/include/protocols/rwhod.h
#translate ${SDK}/usr/include/protocols/talkd.h
#translate ${SDK}/usr/include/protocols/timed.h
translate ${SDK}/usr/include/poll.h
translate ${SDK}/usr/include/pthread.h
translate ${SDK}/usr/include/pthread_impl.h
translate ${SDK}/usr/include/pwd.h
translate ${SDK}/usr/include/ranlib.h
translate -include ${SDK}/usr/include/sys/types.h  ${SDK}/usr/include/regex.h
#translate ${SDK}/usr/include/regexp.h
translate -include ${SDK}/usr/include/sys/types.h -include ${SDK}/usr/include/sys/socket.h -include ${SDK}/usr/include/netinet/in.h -include ${SDK}/usr/include/nameser.h  ${SDK}/usr/include/resolv.h
#translate ${SDK}/usr/include/rmd160.h
#translate ${SDK}/usr/include/rpc/auth.h
#translate ${SDK}/usr/include/rpc/auth_unix.h
#translate ${SDK}/usr/include/rpc/clnt.h
#translate ${SDK}/usr/include/rpc/pmap_clnt.h
#translate ${SDK}/usr/include/rpc/pmap_prot.h
#translate ${SDK}/usr/include/rpc/pmap_rmt.h
#translate ${SDK}/usr/include/rpc/rpc.h
#translate ${SDK}/usr/include/rpc/rpc_msg.h
#translate ${SDK}/usr/include/rpc/svc.h
#translate ${SDK}/usr/include/rpc/svc_auth.h
#translate ${SDK}/usr/include/rpc/types.h
translate -include ${SDK}/usr/include/rpc/types.h ${SDK}/usr/include/rpc/xdr.h
translate ${SDK}/usr/include/rpcsvc/bootparam_prot.h
translate ${SDK}/usr/include/rpcsvc/klm_prot.h
translate ${SDK}/usr/include/rpcsvc/mount.h
translate ${SDK}/usr/include/rpcsvc/nfs_prot.h
translate ${SDK}/usr/include/rpcsvc/nlm_prot.h
translate ${SDK}/usr/include/rpcsvc/rex.h
translate ${SDK}/usr/include/rpcsvc/rnusers.h
translate ${SDK}/usr/include/rpcsvc/rquota.h
translate ${SDK}/usr/include/rpcsvc/rstat.h
translate ${SDK}/usr/include/rpcsvc/rusers.h
translate ${SDK}/usr/include/rpcsvc/rwall.h
translate ${SDK}/usr/include/rpcsvc/sm_inter.h
translate ${SDK}/usr/include/rpcsvc/spray.h
translate ${SDK}/usr/include/rpcsvc/yp.h
#translate -include ${SDK}/usr/include/sys/types.h ${SDK}/usr/include/rpcsvc/yp_prot.h
translate -include ${SDK}/usr/include/sys/types.h ${SDK}/usr/include/rpcsvc/ypclnt.h
translate ${SDK}/usr/include/rpcsvc/yppasswd.h
translate ${SDK}/usr/include/rune.h
translate ${SDK}/usr/include/runetype.h
translate ${SDK}/usr/include/sched.h
translate ${SDK}/usr/include/semaphore.h
translate ${SDK}/usr/include/servers/bootstrap.h
translate ${SDK}/usr/include/servers/bootstrap_defs.h
translate ${SDK}/usr/include/servers/key_defs.h
translate ${SDK}/usr/include/servers/ls_defs.h
translate ${SDK}/usr/include/servers/netname.h
translate ${SDK}/usr/include/servers/netname_defs.h
translate -include ${SDK}/usr/include/inttypes.h ${SDK}/usr/include/servers/nm_defs.h
translate ${SDK}/usr/include/setjmp.h
translate ${SDK}/usr/include/sgtty.h
translate ${SDK}/usr/include/signal.h
translate ${SDK}/usr/include/sqlite3.h
translate ${SDK}/usr/include/sqlite3ext.h
#translate ${SDK}/usr/include/sqltypes.h
translate ${SDK}/usr/include/stab.h
#translate ${SDK}/usr/include/standards.h
#translate ${SDK}/usr/include/stdarg.h
#translate ${SDK}/usr/include/stdbool.h
translate ${SDK}/usr/include/stddef.h
translate ${SDK}/usr/include/stdint.h
translate ${SDK}/usr/include/stdio.h
translate ${SDK}/usr/include/stdlib.h
translate ${SDK}/usr/include/string.h
translate ${SDK}/usr/include/strings.h
translate ${SDK}/usr/include/struct.h
translate -include ${SDK}/usr/include/sys/types.h ${SDK}/usr/include/sys/acct.h
translate ${SDK}/usr/include/sys/attr.h
translate -include ${SDK}/usr/include/sys/types.h ${SDK}/usr/include/sys/buf.h
#translate ${SDK}/usr/include/sys/callout.h
translate ${SDK}/usr/include/sys/cdefs.h
#translate ${SDK}/usr/include/sys/clist.h
translate -include ${SDK}/usr/include/sys/types.h ${SDK}/usr/include/sys/conf.h
translate -include ${SDK}/usr/include/sys/types.h ${SDK}/usr/include/sys/dir.h
translate -include ${SDK}/usr/include/sys/types.h ${SDK}/usr/include/sys/dirent.h
translate -include ${SDK}/usr/include/sys/types.h ${SDK}/usr/include/sys/disk.h
#translate -include ${SDK}/usr/include/sys/types.h  ${SDK}/usr/include/sys/disklabel.h
#translate ${SDK}/usr/include/sys/disktab.h
translate ${SDK}/usr/include/sys/dkstat.h
#translate -include ${SDK}/usr/include/sys/types.h ${SDK}/usr/include/sys/dmap.h
translate -include ${SDK}/usr/include/sys/types.h  ${SDK}/usr/include/sys/domain.h
translate ${SDK}/usr/include/sys/errno.h
translate ${SDK}/usr/include/sys/ev.h
#translate ${SDK}/usr/include/sys/exec.h
translate ${SDK}/usr/include/sys/fcntl.h
translate ${SDK}/usr/include/sys/file.h
translate -include ${SDK}/usr/include/sys/types.h  ${SDK}/usr/include/sys/filedesc.h
translate ${SDK}/usr/include/sys/filio.h
translate -include ${SDK}/usr/include/sys/types.h  ${SDK}/usr/include/sys/gmon.h
translate ${SDK}/usr/include/sys/ioccom.h
translate ${SDK}/usr/include/sys/ioctl.h
translate ${SDK}/usr/include/sys/ioctl_compat.h
translate -include ${SDK}/usr/include/sys/types.h ${SDK}/usr/include/sys/ipc.h
#translate -include ${SDK}/usr/include/sys/types.h ${SDK}/usr/include/sys/kdebug.h
translate -include ${SDK}/usr/include/sys/types.h ${SDK}/usr/include/sys/kern_control.h
translate -include ${SDK}/usr/include/sys/types.h ${SDK}/usr/include/sys/kern_event.h
translate ${SDK}/usr/include/sys/kernel.h
#translate -include ${SDK}/usr/include/sys/types.h ${SDK}/usr/include/sys/ktrace.h
#translate ${SDK}/usr/include/sys/linker_set.h
translate ${SDK}/usr/include/sys/loadable_fs.h
translate -include ${SDK}/usr/include/sys/types.h ${SDK}/usr/include/sys/lock.h
translate -include ${SDK}/usr/include/sys/types.h -include ${SDK}/usr/include/sys/fcntl.h ${SDK}/usr/include/sys/lockf.h
translate -include ${SDK}/usr/include/sys/types.h ${SDK}/usr/include/sys/malloc.h
translate -include ${SDK}/usr/include/sys/types.h -include ${SDK}/usr/include/machine/param.h ${SDK}/usr/include/sys/mbuf.h
#translate -include ${SDK}/usr/include/sys/types.h  ${SDK}/usr/include/sys/md5.h
translate -include ${SDK}/usr/include/sys/types.h ${SDK}/usr/include/sys/mman.h
translate ${SDK}/usr/include/sys/mount.h
translate ${SDK}/usr/include/sys/msgbuf.h
#translate -include ${SDK}/usr/include/sys/types.h ${SDK}/usr/include/sys/mtio.h
#translate -include ${SDK}/usr/include/sys/types.h ${SDK}/usr/include/sys/namei.h
translate -include ${SDK}/usr/include/inttypes.h ${SDK}/usr/include/sys/netport.h
translate ${SDK}/usr/include/sys/param.h
translate ${SDK}/usr/include/sys/paths.h
translate -include ${SDK}/usr/include/sys/types.h -include ${SDK}/usr/include/sys/time.h ${SDK}/usr/include/sys/proc.h
translate -include ${SDK}/usr/include/sys/types.h  ${SDK}/usr/include/sys/protosw.h
translate -include ${SDK}/usr/include/sys/types.h ${SDK}/usr/include/sys/ptrace.h
translate ${SDK}/usr/include/sys/queue.h
translate -include ${SDK}/usr/include/sys/types.h ${SDK}/usr/include/sys/quota.h
#translate -include ${SDK}/usr/include/sys/types.h ${SDK}/usr/include/sys/random.h
translate ${SDK}/usr/include/sys/reboot.h
translate -include ${SDK}/usr/include/sys/types.h -include ${SDK}/usr/include/sys/time.h -include ${SDK}/usr/include/sys/resource.h ${SDK}/usr/include/sys/resourcevar.h
translate -include ${SDK}/usr/include/sys/types.h ${SDK}/usr/include/sys/select.h
translate -include ${SDK}/usr/include/sys/types.h ${SDK}/usr/include/sys/sem.h
translate ${SDK}/usr/include/sys/semaphore.h
translate ${SDK}/usr/include/sys/shm.h
translate -include ${SDK}/usr/include/sys/types.h -include ${SDK}/usr/include/sys/signal.h ${SDK}/usr/include/sys/signalvar.h
translate -include ${SDK}/usr/include/sys/types.h ${SDK}/usr/include/sys/socket.h
translate -include ${SDK}/usr/include/sys/types.h ${SDK}/usr/include/sys/socketvar.h
translate ${SDK}/usr/include/sys/sockio.h
translate ${SDK}/usr/include/sys/stat.h
translate -include ${SDK}/usr/include/sys/types.h ${SDK}/usr/include/sys/sys_domain.h
translate ${SDK}/usr/include/sys/syscall.h
translate ${SDK}/usr/include/sys/sysctl.h
translate ${SDK}/usr/include/sys/syslimits.h
translate ${SDK}/usr/include/sys/syslog.h
#translate ${SDK}/usr/include/sys/systm.h
translate ${SDK}/usr/include/sys/termios.h
translate ${SDK}/usr/include/sys/time.h
translate -include ${SDK}/usr/include/sys/types.h ${SDK}/usr/include/sys/timeb.h
translate ${SDK}/usr/include/sys/times.h
#translate ${SDK}/usr/include/sys/tprintf.h
translate ${SDK}/usr/include/sys/trace.h
translate -include ${SDK}/usr/include/sys/types.h ${SDK}/usr/include/sys/tty.h
translate ${SDK}/usr/include/sys/ttychars.h
translate ${SDK}/usr/include/sys/ttycom.h
translate ${SDK}/usr/include/sys/ttydefaults.h
translate ${SDK}/usr/include/sys/ttydev.h
#translate ${SDK}/usr/include/sys/types.h
#translate ${SDK}/usr/include/sys/ubc.h
translate -include ${SDK}/usr/include/sys/types.h -include ${SDK}/usr/include/sys/signal.h ${SDK}/usr/include/sys/ucontext.h
translate ${SDK}/usr/include/sys/ucred.h
#translate ${SDK}/usr/include/sys/uio.h
translate -include ${SDK}/usr/include/sys/types.h ${SDK}/usr/include/sys/un.h
translate ${SDK}/usr/include/sys/unistd.h
#translate -include ${SDK}/usr/include/sys/types.h ${SDK}/usr/include/sys/unpcb.h
translate ${SDK}/usr/include/sys/user.h
translate ${SDK}/usr/include/sys/utfconv.h
translate ${SDK}/usr/include/sys/utsname.h
#translate ${SDK}/usr/include/sys/ux_exception.h
translate ${SDK}/usr/include/sys/vadvise.h
translate ${SDK}/usr/include/sys/vcmd.h
#translate ${SDK}/usr/include/sys/version.h
translate -include ${SDK}/usr/include/sys/types.h -include ${SDK}/usr/include/sys/time.h -include ${SDK}/usr/include/sys/vmparam.h ${SDK}/usr/include/sys/vm.h
translate -include ${SDK}/usr/include/sys/types.h ${SDK}/usr/include/sys/vmmeter.h
translate -include ${SDK}/usr/include/sys/types.h -include ${SDK}/usr/include/sys/time.h ${SDK}/usr/include/sys/vmparam.h
#translate ${SDK}/usr/include/sys/vnioctl.h
translate -include ${SDK}/usr/include/sys/types.h ${SDK}/usr/include/sys/vnode.h
#translate -include ${SDK}/usr/include/sys/types.h -include ${SDK}/usr/include/sys/vnode.h ${SDK}/usr/include/sys/vnode_if.h
translate ${SDK}/usr/include/sys/wait.h
translate ${SDK}/usr/include/sysexits.h
translate ${SDK}/usr/include/syslog.h
translate ${SDK}/usr/include/tar.h
translate ${SDK}/usr/include/TargetConditionals.h
translate ${SDK}/usr/include/tcl.h
#translate ${SDK}/usr/include/tcpd.h
translate ${SDK}/usr/include/term.h
translate ${SDK}/usr/include/termios.h
translate ${SDK}/usr/include/time.h
translate ${SDK}/usr/include/ttyent.h
translate ${SDK}/usr/include/tzfile.h
#translate ${SDK}/usr/include/ufs/ffs/ffs_extern.h
#translate ${SDK}/usr/include/ufs/ffs/fs.h
#translate ${SDK}/usr/include/ufs/ufs/dinode.h
#translate ${SDK}/usr/include/ufs/ufs/dir.h
#translate ${SDK}/usr/include/ufs/ufs/inode.h
#translate ${SDK}/usr/include/ufs/ufs/lockf.h
#translate ${SDK}/usr/include/ufs/ufs/quota.h
#translate ${SDK}/usr/include/ufs/ufs/ufs_extern.h
#translate -include ${SDK}/usr/include/sys/types.h -include ${SDK}/usr/include/sys/mount.h ${SDK}/usr/include/ufs/ufs/ufsmount.h
translate ${SDK}/usr/include/ulimit.h
translate ${SDK}/usr/include/unctrl.h
translate ${SDK}/usr/include/unistd.h
translate ${SDK}/usr/include/util.h
translate -include ${SDK}/usr/include/sys/types.h ${SDK}/usr/include/utime.h
translate -include ${SDK}/usr/include/sys/types.h  ${SDK}/usr/include/utmp.h
#translate ${SDK}/usr/include/vfs/vfs_support.h
translate -include ${SDK}/usr/include/sys/types.h ${SDK}/usr/include/vis.h
translate ${SDK}/usr/include/zconf.h
translate ${SDK}/usr/include/zlib.h
