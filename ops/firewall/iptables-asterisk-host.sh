#!/usr/bin/env bash
set -euo pipefail

# Run this on the VPS host, not inside the container.
# Adjust the IPs before applying.

OPERATOR_IPS=(
  "198.51.100.10"
  "198.51.100.11"
)

RINGOSTAT_IPS=(
  "203.0.113.20"
)

for ip in "${OPERATOR_IPS[@]}"; do
  iptables -A INPUT -p udp -s "${ip}" --dport 5060 -j ACCEPT
done

for ip in "${RINGOSTAT_IPS[@]}"; do
  iptables -A INPUT -p udp -s "${ip}" --dport 5060 -j ACCEPT
done

iptables -A INPUT -p udp --dport 5060 -j DROP
iptables -A INPUT -p udp --dport 10000:20000 -j ACCEPT
