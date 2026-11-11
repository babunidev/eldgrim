#!/bin/bash
# One-time install of Eldgrim's wake path. Run with sudo from your own account:
#   sudo agent/systemd/install-wake.sh
# Copies the helper and units into root-owned locations. After this, root never
# executes files from the repository or your home directory.
set -euo pipefail

[ "$(id -u)" -eq 0 ] || { echo "Run with sudo." >&2; exit 1; }
USER_NAME="${SUDO_USER:?Run with sudo from the account that runs Eldgrim}"
USER_HOME=$(getent passwd "$USER_NAME" | cut -d: -f6)
USER_UID=$(id -u "$USER_NAME")
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT="$(cd "$HERE/.." && pwd)"
RUNTIME="$USER_HOME/.local/share/eldgrim"

render() {
  sed -e "s|@USER@|$USER_NAME|g" -e "s|@HOME@|$USER_HOME|g" \
      -e "s|@UID@|$USER_UID|g" -e "s|@AGENT@|$AGENT|g" "$1"
}

install -d -o root -g root -m 0755 /usr/local/libexec/eldgrim
render "$HERE/eldgrim-wake-helper" > /usr/local/libexec/eldgrim/eldgrim-wake-helper
chown root:root /usr/local/libexec/eldgrim/eldgrim-wake-helper
chmod 0755 /usr/local/libexec/eldgrim/eldgrim-wake-helper

for unit in eldgrim-daily.service eldgrim-arm.path eldgrim-arm.service; do
  render "$HERE/$unit" > "/etc/systemd/system/$unit"
  chown root:root "/etc/systemd/system/$unit"
  chmod 0644 "/etc/systemd/system/$unit"
done

# Remove the earlier user-owned wake script and staged copies that root used to run.
rm -f "$RUNTIME/bin/eldgrim-wake.sh"
rmdir "$RUNTIME/bin" 2>/dev/null || true
rm -rf "$RUNTIME/systemd"
rm -f "$USER_HOME/.config/systemd/user/eldgrim-daily.service"
# Earlier root runs may have left root-owned files in Eldgrim's data; give them back.
[ -d "$RUNTIME" ] && chown -R "$USER_NAME": "$RUNTIME"

systemctl daemon-reload
systemctl enable --now eldgrim-arm.path
/usr/local/libexec/eldgrim/eldgrim-wake-helper arm || echo "No valid next moment saved yet; the timer arms after the next run."
systemctl list-timers eldgrim-daily.timer --no-pager || true
echo "Installed. Eldgrim's code runs as $USER_NAME; root runs only /usr/local/libexec/eldgrim/eldgrim-wake-helper."
