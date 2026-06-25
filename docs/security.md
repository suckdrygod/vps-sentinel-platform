# Security

This repository is designed to be safe around an existing production Komari deployment.

## Default behavior

By default, the platform:

- does not start the agent;
- does not enable SSH auto-ban;
- does not modify SSH server settings;
- does not modify firewall rules;
- does not modify `iptables` or `nftables`;
- does not install `fail2ban` or `sshguard`;
- does not execute remote commands;
- does not delete existing data.

## Manual-only security features

SSH Auth Guard and any ban behavior must be enabled manually by the operator. The safe install template printed by `./deploy/install.sh --print-agent-command` intentionally omits automatic ban flags.

Before enabling any ban behavior, confirm:

1. your own IP or management network is whitelisted;
2. nftables behavior has been tested on a disposable machine;
3. you have an out-of-band rescue path.

## Production isolation

The default backend port is `127.0.0.1:25874`, not the common production mapping. The Docker network is external and named by `VPS_SENTINEL_NETWORK`, so operators can decide how to attach reverse proxies.

## Rollback

`./deploy/install.sh --rollback` stops only containers created through this compose project and restores the last compose-file backup when available. It does not remove data volumes or alter firewall/system state.

