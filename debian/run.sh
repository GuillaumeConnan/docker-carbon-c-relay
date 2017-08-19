#!/usr/bin/env bash
set -e

CCR_VOLUME=${CCR_VOLUME:="/carbon-c-relay"}
CCR_CONFIGFILE=${CCR_CONFIGFILE:="$CCR_VOLUME/relay.conf"}

mkdir -p $CCR_VOLUME

# Config generation
if [ ! -f "$CCR_CONFIGFILE" ]
then
    # Statistics
    echo "statistics"                                                >  $CCR_CONFIGFILE
    echo "    submit every ${CCR_SUBMITEVERYSECONDS:=60} seconds"    >> $CCR_CONFIGFILE
    if ! [[ "${CCR_RESETCOUNTERS}" == "0" ]]
    then
        echo "    reset counters after interval"                     >> $CCR_CONFIGFILE
    fi
    if [ -n "$CCR_STATISTICSPREFIX" ]
    then
        echo "    prefix with $CCR_STATISTICSPREFIX"                 >> $CCR_CONFIGFILE
    fi
    echo "    ;"                                                     >> $CCR_CONFIGFILE

    # Destination
    echo "cluster destination"                                       >> $CCR_CONFIGFILE
    if [ -n "$CCR_DESTINATION" ]
    then
        echo "    ${CCR_DESTINATIONTYPE:=forward}"                   >> $CCR_CONFIGFILE
        echo "        $CCR_DESTINATION"                              >> $CCR_CONFIGFILE
    else
        echo "    file /dev/null"                                    >> $CCR_CONFIGFILE
    fi
    echo "    ;"                                                     >> $CCR_CONFIGFILE

    # Routing
    echo "match *"                                                   >> $CCR_CONFIGFILE
    echo "    send to destination"                                   >> $CCR_CONFIGFILE
    echo "    stop"                                                  >> $CCR_CONFIGFILE
    echo "    ;"                                                     >> $CCR_CONFIGFILE
fi

# Init
exec sudo -Eu relay /usr/local/bin/relay -f $CCR_CONFIGFILE                     \
                                         -w ${CCR_WORKERTHREADS:=2}             \
                                         -b ${CCR_SENDBATCHSIZE:=2500}          \
                                         -q ${CCR_QUEUESIZE:=25000}             \
                                         -L ${CCR_MAXSTALLS:=4}                 \
                                         -B ${CCR_LISTENBACKLOG:=32}            \
                                         -T ${CCR_CONNECTIONSTIMEOUT:=600}      \
                                         -H ${CCR_HOSTNAME:=$(hostname)}        \
                                         -O ${CCR_RULESBEFOREOPTIMISING:=50}
