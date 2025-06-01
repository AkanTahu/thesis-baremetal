#!/bin/bash
USER="$(whoami)"
set -e

PROJECT_DIR="/home/$USER/thesis-baremetal/python-frs"

echo "==[ Setup Python Virtual Environment di $PROJECT_DIR ]=="
cd "$PROJECT_DIR"

# Cek apakah python3.9 sudah ada
if ! command -v python3.9 &> /dev/null; then
    echo "Python 3.9 tidak ditemukan! Pastikan sudah menjalankan first-setup.sh"
    exit 1
fi

# Buat virtual environment jika belum ada
if [ ! -d "venv" ]; then
    python3.9 -m venv venv
    echo "Virtual environment dibuat."
else
    echo "Virtual environment sudah ada."
fi

# Aktifkan virtual environment
source venv/bin/activate

sudo chown -R www-data:www-data /home/$USER/thesis-baremetal/shared-storage
sudo chmod -R 775 /home/$USER/thesis-baremetal/shared-storage

# Upgrade pip
pip install --upgrade pip

# Install requirements
if [ -f requirements.txt ]; then
    pip install -r requirements.txt
else
    echo "requirements.txt tidak ditemukan! Silakan buat terlebih dahulu."
    deactivate
    exit 1
fi

echo "==[ Setup selesai! ]=="
echo "Aktifkan venv dengan: source venv/bin/activate"
