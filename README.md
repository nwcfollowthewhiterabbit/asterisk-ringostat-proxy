# Asterisk Docker Proxy

Dockerized SIP/RTP transit proxy based on Asterisk 22 LTS for the scheme:

- Operator SIP trunk <-> Asterisk on VPS/VDS <-> Ringostat server

This project is tuned for a public VPS/VDS with a dedicated static public IP and `host network`.

## What is included

- Asterisk `22.9.0` by default, built from official source.
- `PJSIP` config with:
  - operator registration
  - `contact_user`
  - `rewrite_contact=yes`
  - `direct_media=no`
- Basic dialplan for forwarding:
  - inbound calls from operator to Ringostat
  - outbound calls from Ringostat to operator
- RTP range `10000-20000/udp`
- Host-side examples for `iptables` and `Fail2Ban`

## Important architecture note

For SIP/RTP, the cleanest Docker setup is `network_mode: host`.
That means:

- Asterisk listens on the VPS host IP directly.
- Firewall rules must be configured on the host OS.
- `Fail2Ban` should also run on the host OS, not inside the container.

## Quick start

1. Copy the env file:

```bash
cd /home/ubuntu/asterisk-docker-proxy
cp .env.example .env
```

2. Edit `.env` and set:

- `PUBLIC_IP`
- operator credentials and IPs
- `OPERATOR_CALLERID` if your operator requires a fixed caller ID on outbound calls
- Ringostat credentials and IPs

3. Start:

```bash
docker compose up -d --build
```

4. Check registration and endpoints:

```bash
docker exec -it asterisk-proxy asterisk -rx "pjsip show registrations"
docker exec -it asterisk-proxy asterisk -rx "pjsip show endpoints"
docker exec -it asterisk-proxy asterisk -rx "pjsip show contacts"
```

## Dialplan behavior

### Inbound calls from operator

Context: `from-operator`

- Inbound calls are sent to the Ringostat endpoint with `Dial(PJSIP/myserver,60)`.
- The called DID is not passed as `${EXTEN}` to Ringostat in the initial setup.
- Ringostat should bind calls for this SIP login to the configured phone number on its side.

### Outbound calls from Ringostat

Context: `from-myserver`

- Any `_X.` number is sent to the operator trunk.
- `OUTBOUND_STRIP_PREFIX` is optional and may need customization for your numbering plan.

## Software-only bring-up

If you want to focus only on the SIP/RTP software first, this project is already prepared for that workflow.

Minimum steps:

1. Fill in `.env` with the real public IP, operator credentials, and Ringostat credentials.
2. Start the container:

```bash
cd /home/ubuntu/asterisk-docker-proxy
sudo docker compose up -d --build
```

3. Verify that Asterisk is up:

```bash
sudo docker exec -it asterisk-proxy asterisk -rx "core show version"
sudo docker exec -it asterisk-proxy asterisk -rx "pjsip show registrations"
sudo docker exec -it asterisk-proxy asterisk -rx "pjsip show endpoints"
sudo docker exec -it asterisk-proxy asterisk -rx "pjsip show contacts"
```

4. Watch the live SIP log while testing a call:

```bash
sudo docker exec -it asterisk-proxy asterisk -rvvv
```

Inside the Asterisk CLI:

```text
pjsip set logger on
rtp set debug on
```

Firewall and hardening can be added later without changing the Asterisk config itself.

## Notes

- The current default source release is `22.9.0`, which was listed as the latest LTS on April 9, 2026.
- Asterisk `22.x` is an LTS branch and is fully supported through October 16, 2028.
- If your provider requires exact `From`, `Contact`, or DID formatting, we can tighten the dialplan and headers further once you share the operator-side SIP requirements.
