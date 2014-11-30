#!/usr/bin/env python

import sys
import optparse
import traceback
import signal

import lba_snmp

def main():

    parser = optparse.OptionParser()
    parser.add_option(
        "-i",
        "--interval",
        dest="interval",
        help="Set interval in seconds between data updates",
        default=1
    )
    parser.add_option(
        "-m",
        "--mastersocket",
        dest="mastersocket",
        help="Sets the transport specification for the master agent's AgentX socket",
        default="/var/run/agentx/master"
    )
    parser.add_option(
        "-p",
        "--persistencedir",
        dest="persistencedir",
        help="Sets the path to the persistence directory",
        default="/var/lib/net-snmp"
    )
    (options, args) = parser.parse_args()

    def signal_handler(signal, frame):
        print 'You pressed Ctrl+C!'
        sys.exit(1)

    signal.signal(signal.SIGINT, signal_handler)

    try:
        agent = lba_snmp.LBAAgent(options.mastersocket, options.persistencedir)
        agent.start()
    except SystemExit:
        raise
    except:
        print traceback.format_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()

