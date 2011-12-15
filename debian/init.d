#! /bin/sh
### BEGIN INIT INFO
# Provides:          rump
# Required-Start:    $remote_fs $syslog $network
# Required-Stop:     $remote_fs $syslog $network
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start rump at boot time
# Description:       Controls the rump server
### END INIT INFO

# Author: Teemu Matilainen <teemu.matilainen@reaktor.fi>

# Do NOT "set -e"

# PATH should only include /usr/* if it runs after the mountnfs.sh script
PATH=/sbin:/usr/sbin:/bin:/usr/bin
DESC="rump server"
NAME=rump
SCRIPTNAME=/etc/init.d/$NAME

# Read configuration variable file if it is present
[ -r /etc/default/$NAME ] && . /etc/default/$NAME

PIDFILE="$RUMP_DIR/$NAME.pid"
DAEMON=/usr/bin/daemon
DAEMON_ARGS="--name=$NAME --inherit --output=$RUMP_LOG --pidfile=$PIDFILE --chdir=$RUMP_DIR"

# Exit if the package is not installed
[ -x "$DAEMON" ] || exit 0
[ -x "$RUMP" ] || exit 0

# Load the VERBOSE setting and other rcS variables
. /lib/init/vars.sh

# Define LSB log_* functions.
# Depend on lsb-base (>= 3.2-14) to ensure that this file is present
# and status_of_proc is working.
. /lib/lsb/init-functions

#
# Function that starts the daemon/service
#
do_start()
{
	# Prepare runtime directory
	mkdir -p $RUMP_DIR > /dev/null 2>&1
	chown -R $RUMP_USER "$RUMP_DIR"
	ln -sfT "$RUMP_LOG_DIR" "$RUMP_DIR/log"

	# Return
	#   0 if daemon has been started
	#   1 if daemon was already running
	#   2 if daemon could not be started
	$DAEMON $DAEMON_ARGS --running && return 1

	# --user in daemon doesn't prepare environment variables like HOME, USER, LOGNAME or USERNAME,
	# so we let su do so for us now
	su -l $RUMP_USER --shell=/bin/sh -c "$DAEMON $DAEMON_ARGS -- $RUMP $RUMP_ARGS" || return 2
}

#
# Function that stops the daemon/service
#
do_stop()
{
	# Return
	#   0 if daemon has been stopped
	#   1 if daemon was already stopped
	#   2 if daemon could not be stopped
	#   other if a failure occurred
	$DAEMON $DAEMON_ARGS --running || return 1
	$DAEMON $DAEMON_ARGS --stop || return 2
	# Many daemons don't delete their pidfiles when they exit.
	rm -f $PIDFILE
	return 0
}

case "$1" in
  start)
	[ "$VERBOSE" != no ] && log_daemon_msg "Starting $DESC" "$NAME"
	do_start
	case "$?" in
		0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
		2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
	esac
	;;
  stop)
	[ "$VERBOSE" != no ] && log_daemon_msg "Stopping $DESC" "$NAME"
	do_stop
	case "$?" in
		0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
		2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
	esac
	;;
  status)
       status_of_proc -p "$PIDFILE" "$DAEMON" "$NAME" && exit 0 || exit $?
       ;;
  restart|force-reload)
	#
	# If the "reload" option is implemented then remove the
	# 'force-reload' alias
	#
	log_daemon_msg "Restarting $DESC" "$NAME"
	do_stop
	case "$?" in
	  0|1)
		do_start
		case "$?" in
			0) log_end_msg 0 ;;
			1) log_end_msg 1 ;; # Old process is still running
			*) log_end_msg 1 ;; # Failed to start
		esac
		;;
	  *)
		# Failed to stop
		log_end_msg 1
		;;
	esac
	;;
  *)
	echo "Usage: $SCRIPTNAME {start|stop|status|restart|force-reload}" >&2
	exit 3
	;;
esac

:
