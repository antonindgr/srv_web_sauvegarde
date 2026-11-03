#!/bin/bash
# /usr/local/sbin/sauvegarde.sh
# Sauvegarde de srv-web : configuration + site web
set -euo pipefail
umask 077

DEST=/var/backups/srv-web
GARDER=7
JOURNAL=/var/log/sauvegarde.log
DATE=$(date +%Y-%m-%d_%H-%M-%S)
ARCHIVE="$DEST/srv-web_$DATE.tar.gz"

trap 'echo "$(date "+%F %T") ECHEC ligne $LINENO" >> "$JOURNAL"' ERR

mkdir -p "$DEST"

# 1. Créer l'archive
tar -czf "$ARCHIVE" -C / \
    etc/ssh/sshd_config.d \
    etc/nginx \
    etc/fail2ban/jail.local \
    etc/ufw \
    etc/ssl/certs/srv-web.crt \
    etc/ssl/private/srv-web.key \
    var/www/html

# 2. Vérifier que l'archive est lisible
tar -tzf "$ARCHIVE" > /dev/null

# 3. Ne garder que les 7 plus récentes
ls -1t "$DEST"/srv-web_*.tar.gz | tail -n +$((GARDER + 1)) | xargs -r rm --

# 4. Écrire dans le journal
echo "$(date "+%F %T") OK $ARCHIVE ($(du -h "$ARCHIVE" | cut -f1))" >> "$JOURNAL"
