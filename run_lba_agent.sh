#
# Little Big Adventure SNMP Agent 
#
# Copyright (c) 2014 Matheus Marchini <mmarchini@inf.ufrgs.br>
# Licensed under the GNU Public License (GPL) version 3
#

#
# Esse script foi adaptado a partir do script run_threading_agent.sh
# criado por Pieter Hollants <pieter@hollants.com> e disponibilizado
# nos exemplos do python-netsnmpagent.
# 
# O objetivo desse script é facilitar a execução do Net-SNMP com a 
# MIB customizada desenvolvida. 
#

# Color macros
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NO_COLOR='\033[0m' # No Color

set -u
set -e

# Find path to snmpd executable
SNMPD_BIN=""
for DIR in /usr/local/sbin /usr/sbin
do
	if [ -x $DIR/snmpd ] ; then
		SNMPD_BIN=$DIR/snmpd
		break
	fi
done
if [ -z "$SNMPD_BIN" ] ; then
	echo "snmpd executable not found -- net-snmp not installed?"
	exit 1
fi

# Make sure we leave a clean system upon exit
cleanup() {
    echo ""
    echo "* Cleaning up..."
	if [ -n "$TMPDIR" -a -d "$TMPDIR" ] ; then
		# Terminate snmpd, if running
		if [ -n "$SNMPD_PIDFILE" -a -e "$SNMPD_PIDFILE" ] ; then
			PID="$(cat $SNMPD_PIDFILE)"
			if [ -n "$PID" ] ; then
                echo "* Parando o processo ${RED}snmpd${NO_COLOR} (${GREEN}$PID${NO_COLOR})"
				kill -TERM "$PID"
			fi
		fi

        echo -e "* Removendo os arquivos da pasta temporária (${GREEN}$TMPDIR${NO_COLOR})"
		# Clean up temporary directory
		rm -rf "$TMPDIR"
	fi
    echo -e "* Clean up realizado com sucesso!"

	# Make sure echo is back on
	stty echo
}
trap cleanup EXIT INT

echo -e "* Preparando o agente ${RED}snmpd${NO_COLOR} ..."

# Create a temporary directory
TMPDIR="$(mktemp --directory --tmpdir lba_agent.XXXXXXXXXX)"
SNMPD_CONFFILE=$TMPDIR/snmpd.conf
SNMPD_PIDFILE=$TMPDIR/snmpd.pid

# Create a minimal snmpd configuration for our purposes
cat <<EOF >>$SNMPD_CONFFILE
[snmpd]
rocommunity public 127.0.0.1
rwcommunity simple 127.0.0.1
agentaddress localhost:5555
informsink localhost:5556
smuxsocket localhost:5557
master agentx
agentXSocket $TMPDIR/snmpd-agentx.sock

[snmp]
persistentDir $TMPDIR/state
EOF
touch $TMPDIR/mib_indexes

# Start a snmpd instance for testing purposes, run as the current user and
# and independent from any other running snmpd instance
$SNMPD_BIN -r -LE warning -C -c$SNMPD_CONFFILE -p$SNMPD_PIDFILE

# Give the user guidance
echo ""
echo "* O agente SNMP está rodando no endereço localhost, na porta 5555."
echo "  É possível testar o agente usando os seguintes comandos:"
echo -e "${CYAN}"
echo "    cd `pwd`"
echo "    snmpwalk -v 2c -c public -M+. localhost:5555 LBA-MIB::lbaHeroStats"
echo "    snmpget -v 2c -c public -M+. localhost:5555 LBA-MIB::lbaGameRunning.0"
echo "    snmpset -v 2c -c public -M+. localhost:5555 LBA-MIB::lbaBehaviourCurrent.0 i 1"
echo -e "${NO_COLOR}"
echo -e "* Agora, rode o ${GREEN}TwinEngine${NO_COLOR} para que o agente possa obter e manipular os dados do jogo. "
echo ""

# Workaround to have CTRL-C not generate any visual feedback (we don't do any
# input anyway)
stty -echo

# Now start the threading agent
echo "* Starting the threading agent..."
echo ""
echo ""
lba-snmp -m $TMPDIR/snmpd-agentx.sock -p $TMPDIR/
