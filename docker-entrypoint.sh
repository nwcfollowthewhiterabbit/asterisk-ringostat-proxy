#!/usr/bin/env bash
set -euo pipefail

template_dir="/opt/asterisk/templates"
config_dir="/etc/asterisk"

required_vars=(
  PUBLIC_IP
  OPERATOR_HOST
  OPERATOR_PORT
  OPERATOR_USERNAME
  OPERATOR_PASSWORD
  OPERATOR_FROM_DOMAIN
  RINGOSTAT_USERNAME
  RINGOSTAT_PASSWORD
)

for var_name in "${required_vars[@]}"; do
  if [[ -z "${!var_name:-}" ]]; then
    echo "Missing required environment variable: ${var_name}" >&2
    exit 1
  fi
done

export RINGOSTAT_INBOUND_TARGET="${RINGOSTAT_INBOUND_TARGET:-}"
export OUTBOUND_STRIP_PREFIX="${OUTBOUND_STRIP_PREFIX:-}"
export OPERATOR_MATCH_IPS="${OPERATOR_MATCH_IPS:-}"
export RINGOSTAT_MATCH_IPS="${RINGOSTAT_MATCH_IPS:-}"
render_vars='${PUBLIC_IP} ${OPERATOR_HOST} ${OPERATOR_PORT} ${OPERATOR_USERNAME} ${OPERATOR_PASSWORD} ${OPERATOR_FROM_DOMAIN} ${OPERATOR_MATCH_IPS} ${OPERATOR_CALLERID} ${RINGOSTAT_USERNAME} ${RINGOSTAT_PASSWORD} ${RINGOSTAT_MATCH_IPS} ${RINGOSTAT_INBOUND_TARGET} ${OUTBOUND_STRIP_PREFIX}'

mkdir -p "${config_dir}" /var/log/asterisk /var/spool/asterisk /var/run/asterisk

for template in \
  asterisk.conf.tpl \
  modules.conf.tpl \
  pjsip.conf.tpl \
  extensions.conf.tpl \
  rtp.conf.tpl \
  logger.conf.tpl
do
  envsubst "${render_vars}" < "${template_dir}/${template}" > "${config_dir}/${template%.tpl}"
done

chown -R asterisk:asterisk /etc/asterisk /var/log/asterisk /var/spool/asterisk /var/run/asterisk

exec "$@"
