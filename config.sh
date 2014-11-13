#
# Plik konfiguracyjny UberBackup
#

# Katalog główny gdzie zapisywać kopie
BACKUP_DIR="/mnt/backup/uberbackup"

# Ilość backupów trzymanych wstecz
KEEP="7"

# Gdzie wysyłać alerty z informacjami o backupach (puste = wszystko leci na stdout)
MAILTO=""

# Format katalogu zawierającego backup (format: man date)
NAME_FORMAT="%d-%m-%Y"

# Klucz SSH
SSH_KEY="/root/.ssh/id_rsa"

# Uzytkownik do pobierania backupu (musi laczyc sie po ssh powyzszym kluczem + miec dostep do sudo rsync bez hasła)
SSH_USER="uberbackup"


