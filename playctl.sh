#!/bin/bash

COMMAND=$1
PORT=9000
ROOT_DIR=`dirname $0`

if [ ! -z "$3" ]; then
	PORT=$3;
fi

echo com $COMMAND
echo port $PORT

# stage the play app - param name of play project to package
function stage {
	./sbt stage
}

function debug_port {
	DEBUG_PORT=$(($PORT+1000))
	export SBT_EXTRA_PARAMS="-Xdebug -Xrunjdwp:transport=dt_socket,address=$DEBUG_PORT,server=y,suspend=n"
}

function start_app {
	debug_port
	stage 
	mkdir -p logs

	if [ -f "logs/application.log"  ]; then
		kill_app
	fi

	nohup ./target/start -Dhttp.port=$PORT > "logs/application.log" 2>&1 &

  	while [ -z "`grep 'Listening for HTTP on port' logs/application.log`"  ]
	do
        	echo "Waiting for app..."
        	sleep 5
	done
}

function kill_app {
	if [ -f RUNNING_PID ]; then
		kill `cat RUNNING_PID`
		`rm -f "logs/application.log"` 
		`rm -f "RUNNING_PID"`
	fi
}

function app_dir {
        cd $ROOT_DIR
}

case "$COMMAND" in 
	'start')
		app_dir
		start_app
		;;
	'stop')
		app_dir
		kill_app
		;;
	*)
		echo "Usage $0 {app_ROOT_DIR app_name | [start|stop] [port] }"
		;;
esac
exit 0 
