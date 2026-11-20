#!/bin/sh
#
# Wait for the ZFS kernel module to be available, then import all pools.
#
# The `zfs` module is loaded on boot by snapd (via the kernel-module-load
# plug), but snapcraft has no way to express an ordering dependency from an
# app's systemd unit against snapd's module-load unit. Polling for the
# control device /dev/zfs is the robust, confinement-friendly equivalent.

set -eu

# Give the module up to ~30s to finish loading before giving up.
i=0
while [ ! -e /dev/zfs ]; do
	if [ "$i" -ge 60 ]; then
		echo "itrue-zfs: timed out waiting for /dev/zfs (is the zfs module loaded?)" >&2
		exit 1
	fi
	i=$((i + 1))
	sleep 0.5
done

exec "$SNAP/usr/sbin/zpool" import -a
