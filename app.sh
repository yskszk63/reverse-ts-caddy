#!/bin/bash

[ -n "$TS_API_CLIENT_ID" -a -n "$TS_API_CLIENT_SECRET" ] || {
    echo '`TS_API_CLIENT_ID` or `TS_API_CLIENT_SECRET` not specified. Exit.' >&2
    exit 1
}

export TS_STATE_DIR=/var/lib/tailscale
export TS_SOCKET=/var/run/tailscale/tailscaled.sock
export TS_AUTH_KEY="$(get-authkey -tags "$AUTHKEY_TAG" -ephemeral)"
if [[ -n "$TS_HOSTNAME" ]]; then
    export TS_EXTRA_ARGS="$TS_EXTRA_ARGS --hostname $TS_HOSTNAME"
    unset TS_HOSTNAME
fi
containerboot &

retry=0
retry_max=20
sleep 0.1
until tailscale --socket $TS_SOCKET status > /dev/null || [[ retry -eq $retry_max ]]; do
    echo '##' $retry / $retry_max
    : $(( retry++ ))
    sleep 0.5
done
trap 'tailscale --socket $TS_SOCKET logout' EXIT

dnsname=$(tailscale --socket $TS_SOCKET status --json |jq .Self.DNSName -r|sed -e's/\.$//')
[[ -n "$dnsname" ]] || {
    echo 'Failed to get DNSName.' >&2
    exit 1
}
caddy reverse-proxy --from "$dnsname" --to example.com --change-host-header &

wait
