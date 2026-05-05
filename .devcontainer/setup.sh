#!/usr/bin/env bash
set -euo pipefail

# Start gnome-keyring so Copilot CLI can store tokens securely.
# Idempotent: uses a shared env-file per UID so all terminals reuse the same daemon.
if ! grep -q "copilot-keyring-env" ~/.bashrc 2>/dev/null; then
  cat >> ~/.bashrc <<'KEYRING'

# --- gnome-keyring bootstrap ---
_KEYRING_ENV="/tmp/.copilot-keyring-env-$(id -u)"
if [ ! -f "$_KEYRING_ENV" ]; then
  # Start D-Bus session
  eval "$(dbus-launch --sh-syntax)" 2>/dev/null || true
  export DBUS_SESSION_BUS_ADDRESS

  # Start gnome-keyring daemon
  _GKD_OUT=$(/usr/bin/gnome-keyring-daemon --start --daemonize --components=secrets 2>/dev/null || true)
  export GNOME_KEYRING_CONTROL
  GNOME_KEYRING_CONTROL=$(echo "$_GKD_OUT" | grep -o 'GNOME_KEYRING_CONTROL=[^ ]*' | cut -d= -f2 || true)

  # Create/unlock the default collection using gnome-keyring's internal D-Bus API.
  # This bypasses the GUI prompter requirement and works in headless containers.
  python3 - <<'PYEOF' 2>/dev/null || true
import sys
try:
    import jeepney
    from jeepney.io.blocking import open_dbus_connection
except ImportError:
    sys.exit(0)

def _addr(iface):
    return jeepney.DBusAddress('/org/freedesktop/secrets',
                               bus_name='org.freedesktop.secrets', interface=iface)

SERVICE  = 'org.freedesktop.Secret.Service'
INTERNAL = 'org.gnome.keyring.InternalUnsupportedGuiltRiddenInterface'

def open_session(conn):
    # 'plain' mode is acceptable here: dbus-launch creates a per-user private
    # Unix socket, so only processes already running as this user can reach it.
    # Those processes have full filesystem/memory access anyway.
    msg = jeepney.new_method_call(_addr(SERVICE), 'OpenSession', 'sv', ('plain', ('s', '')))
    return conn.send_and_get_reply(msg).body[1]

def read_alias(conn, alias):
    msg = jeepney.new_method_call(_addr(SERVICE), 'ReadAlias', 's', (alias,))
    return conn.send_and_get_reply(msg).body[0]

def set_alias(conn, alias, path):
    conn.send_and_get_reply(jeepney.new_method_call(_addr(SERVICE), 'SetAlias', 'so', (alias, path)))

def try_unlock(conn, path, session):
    empty = (session, b'', b'', 'text/plain')
    msg = jeepney.new_method_call(_addr(INTERNAL), 'UnlockWithMasterPassword',
                                  'o(oayays)', (path, empty))
    return conn.send_and_get_reply(msg).body == ()

def create_unlocked(conn, session):
    empty = (session, b'', b'', 'text/plain')
    msg = jeepney.new_method_call(_addr(INTERNAL), 'CreateWithMasterPassword',
                                  'a{sv}(oayays)', ({}, empty))
    return conn.send_and_get_reply(msg).body[0]

try:
    conn    = open_dbus_connection(bus='SESSION')
    session = open_session(conn)
    path    = read_alias(conn, 'default')
    if path == '/':
        set_alias(conn, 'default', create_unlocked(conn, session))
    elif not try_unlock(conn, path, session):
        # Old collection locked with unknown password – replace it
        set_alias(conn, 'default', create_unlocked(conn, session))
except Exception:
    pass
PYEOF

  # Save env for all future terminal sessions in this container lifetime.
  # Use a temp file + atomic rename to avoid TOCTOU symlink attacks,
  # and restrict permissions so other users cannot read the D-Bus address.
  _KEYRING_TMP=$(mktemp "/tmp/.copilot-keyring-tmp-$(id -u)-XXXXXX")
  chmod 600 "$_KEYRING_TMP"
  printf 'DBUS_SESSION_BUS_ADDRESS=%s\nGNOME_KEYRING_CONTROL=%s\n' \
    "$DBUS_SESSION_BUS_ADDRESS" "$GNOME_KEYRING_CONTROL" > "$_KEYRING_TMP"
  mv -f "$_KEYRING_TMP" "$_KEYRING_ENV"
fi
# shellcheck source=/dev/null
. "$_KEYRING_ENV" 2>/dev/null || true
export GNOME_KEYRING_CONTROL DBUS_SESSION_BUS_ADDRESS
# --- end gnome-keyring bootstrap ---
KEYRING
fi

if ! grep -q "Copilot CLI Sandbox" ~/.bashrc 2>/dev/null; then
  cat >> ~/.bashrc <<'EOF'

echo ""
echo "  Velkommen til Copilot CLI Sandbox"
echo ""
echo "  1. Kjør:   copilot"
echo "  2. Følg device-login i nettleseren"
echo "  3. Vibe code i vei!"
echo ""
echo "  Trygg sone: AI-en kan ikke se eller endre filer på din egen maskin."
echo "  Nullstille alt: Cmd/Ctrl+Shift+P -> 'Dev Containers: Rebuild Container Without Cache'"
echo ""
EOF
fi
