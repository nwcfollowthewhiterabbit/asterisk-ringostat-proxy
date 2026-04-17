[global]
type=global
user_agent=Asterisk Docker Proxy

; ==========================================
; 1. TRANSPORT
; ==========================================
[transport-udp]
type=transport
protocol=udp
bind=0.0.0.0:5060
external_media_address=${PUBLIC_IP}
external_signaling_address=${PUBLIC_IP}

; ==========================================
; 2. OPERATOR TRUNK
; ==========================================
[operator_reg]
type=registration
transport=transport-udp
outbound_auth=operator_auth
server_uri=sip:${OPERATOR_REGISTRAR_HOST}:${OPERATOR_PORT}
client_uri=sip:${OPERATOR_USERNAME}@${OPERATOR_HOST}
outbound_proxy=${OPERATOR_OUTBOUND_PROXY}
retry_interval=60
forbidden_retry_interval=600
expiration=300
contact_user=${OPERATOR_USERNAME}

[operator_auth]
type=auth
auth_type=userpass
password=${OPERATOR_PASSWORD}
username=${OPERATOR_USERNAME}

[operator_aor]
type=aor
contact=sip:${OPERATOR_REGISTRAR_HOST}:${OPERATOR_PORT}
qualify_frequency=30

[operator]
type=endpoint
transport=transport-udp
context=from-operator
disallow=all
allow=alaw,ulaw
outbound_auth=operator_auth
aors=operator_aor
outbound_proxy=${OPERATOR_OUTBOUND_PROXY}
from_user=${OPERATOR_USERNAME}
from_domain=${OPERATOR_FROM_DOMAIN}
contact_user=${OPERATOR_USERNAME}
direct_media=no
rewrite_contact=yes
rtp_symmetric=yes
force_rport=yes

[operator-identify]
type=identify
endpoint=operator
match=${OPERATOR_MATCH_IPS}

; ==========================================
; 3. RINGOSTAT SIDE
; ==========================================
[myserver_auth]
type=auth
auth_type=userpass
password=${RINGOSTAT_PASSWORD}
username=${RINGOSTAT_USERNAME}

[myserver_aor]
type=aor
max_contacts=1
remove_existing=yes
qualify_frequency=30

[myserver]
type=endpoint
transport=transport-udp
context=from-myserver
disallow=all
allow=alaw,ulaw
auth=myserver_auth
aors=myserver_aor
direct_media=no
rewrite_contact=yes
rtp_symmetric=yes
force_rport=yes
