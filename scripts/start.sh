#!/bin/bash
set -e

SH_INCLUDE="/usr/local/bin/_include.sh"
SH_CONFIGURE_SSL="/usr/local/bin/_configure_ssl.sh"
SH_CONFIGURE_PRIMARY="/usr/local/bin/_configure_primary.sh"
SH_CONFIGURE_READ_REPLICA="/usr/local/bin/_configure_read_replica.sh"

source "$SH_INCLUDE"

echo ""
log_hl "Version: $_RLWY_RELEASE_VERSION"
log_warn "This is an ALPHA version of the Railway Postgres image."
log_warn "DO NOT USE THIS VERSION UNLESS ADVISED BY RAILWAY STAFF."
log_warn ""
log_warn "This version must only be used with direct support from"
log_warn "Railway. If we did not ask you to use this version,"
log_warn "please do not."
log_warn ""
log_warn "If you choose to use this version WITHOUT BEING ADVISED"
log_warn "OR ASKED TO by the Railway team:"
log_warn ""
log_warn "  You accept that you are doing so at your own risk,"
log_warn "  and Railway is not responsible for any data loss"
log_warn "  or corruption that may occur as a result of"
log_warn "  ignoring this warning."
echo ""

if [ ! -z "$DEBUG_MODE" ]; then
  log "Starting in debug mode! Postgres will not run."
  log "The container will stay alive and be shell-accessible."
  trap "echo Shutting down; exit 0" SIGTERM SIGINT SIGKILL
  sleep infinity &
  wait
fi

if [ -z "$RAILWAY_VOLUME_NAME" ]; then
  log_err "\
Missing RAILWAY_VOLUME_NAME! Please ensure that you have a volume attached \
to your service."
  exit 1
fi

if [ -z "$RAILWAY_VOLUME_MOUNT_PATH" ]; then
  log_err "\
Missing RAILWAY_VOLUME_MOUNT_PATH! Please ensure that you have a volume \
attached to your service."
  exit 1
fi

if [ -z "$RAILWAY_PG_INSTANCE_TYPE" ]; then
  log_err "RAILWAY_PG_INSTANCE_TYPE is required to use this image."
  exit 1
fi

# PGDATA dir
PGDATA="${RAILWAY_VOLUME_MOUNT_PATH}/pgdata"
mkdir -p "$PGDATA"
sudo chown -R postgres:postgres "$PGDATA"
sudo chmod 700 "$PGDATA"

# Certs dir
SSL_CERTS_DIR="${RAILWAY_VOLUME_MOUNT_PATH}/certs"
mkdir -p "$SSL_CERTS_DIR"
sudo chown -R postgres:postgres "$SSL_CERTS_DIR"
sudo chmod 700 "$SSL_CERTS_DIR"

# Repmgr dir
REPMGR_DIR="${RAILWAY_VOLUME_MOUNT_PATH}/repmgr"
mkdir -p "$REPMGR_DIR"
sudo chown -R postgres:postgres "$REPMGR_DIR"
sudo chmod 700 "$REPMGR_DIR"

PG_CONF_FILE="${PGDATA}/postgresql.conf"
REPMGR_CONF_FILE="${REPMGR_DIR}/repmgr.conf"
READ_REPLICA_MUTEX="${REPMGR_DIR}/rrmutex"

case "$RAILWAY_PG_INSTANCE_TYPE" in
"READREPLICA")
  if ! [[ "$OUR_NODE_ID" =~ ^[0-9]+$ ]] || [ "$OUR_NODE_ID" -lt 2 ]; then
    log_err "\
OUR_NODE_ID is required in READREPLICA mode. It must be an integer ≥2. \
The primary node is always 'node1' and subsequent nodes must be numbered \
starting from 2. (received OUR_NODE_ID='$OUR_NODE_ID')\
"
    exit 1
  fi
  log_hl "Running as READREPLICA (nodeid=$OUR_NODE_ID)"

  # Configure as read replica if not already done
  if [ -f "$READ_REPLICA_MUTEX" ]; then
    log "READREPLICA is configured."
  else
    source "$SH_CONFIGURE_READ_REPLICA"
  fi
  ;;
"PRIMARY")
  log_hl "Running as PRIMARY (nodeid=1)"

  # Configure as primary if not already done
  if grep -q \
    "include 'postgresql.replication.conf'" "$PG_CONF_FILE" 2>/dev/null; then
    log "PRIMARY is configured."
  else
    source "$SH_CONFIGURE_PRIMARY"
  fi
  ;;
*) ;;
esac

source "$SH_CONFIGURE_SSL"
/usr/local/bin/docker-entrypoint.sh "$@"
