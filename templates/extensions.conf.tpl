[general]
static=yes
writeprotect=yes

[globals]
OPERATOR_CALLERID=${OPERATOR_CALLERID}
OUTBOUND_STRIP_PREFIX=${OUTBOUND_STRIP_PREFIX}
RINGOSTAT_INBOUND_TARGET=${RINGOSTAT_INBOUND_TARGET}

[from-operator]
exten => _X.,1,NoOp(Inbound from operator to Ringostat: ${EXTEN})
 same => n,Set(TARGET=${IF($["${RINGOSTAT_INBOUND_TARGET}" = ""]?${EXTEN}:${RINGOSTAT_INBOUND_TARGET})})
 same => n,Set(__SIPADDHEADER01=X-Orig-DID: ${EXTEN})
 same => n,Dial(PJSIP/${TARGET}@myserver,60)
 same => n,Hangup()

exten => s,1,NoOp(Inbound from operator without called number)
 same => n,Set(TARGET=${IF($["${RINGOSTAT_INBOUND_TARGET}" = ""]?${OPERATOR_USERNAME}:${RINGOSTAT_INBOUND_TARGET})})
 same => n,Dial(PJSIP/${TARGET}@myserver,60)
 same => n,Hangup()

[from-myserver]
exten => _X.,1,NoOp(Outbound from Ringostat to operator: ${EXTEN})
 same => n,Set(DIALNUM=${IF($["${OUTBOUND_STRIP_PREFIX}" = ""]?${EXTEN}:${EXTEN:${LEN(${OUTBOUND_STRIP_PREFIX})}})})
 same => n,ExecIf($["${OPERATOR_CALLERID}" != ""]?Set(CALLERID(num)=${OPERATOR_CALLERID}))
 same => n,Dial(PJSIP/${DIALNUM}@operator,60)
 same => n,Hangup()
