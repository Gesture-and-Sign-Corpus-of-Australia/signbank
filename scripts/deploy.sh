#!/usr/bin/env sh

echo "=== Making sure we're in ~/..."
cd ~
echo "=== Untarring..."
tar -xvf build.tar
echo "=== Making directories..."
sudo mkdir -p /etc/systemd/system
sudo rm -r /opt/signbank
sudo mkdir -p /opt/signbank
echo "=== Moving services to /etc/systemd/system..."
sudo mv -f ~/_build/dev/rel/signbank/*.service /etc/systemd/system
echo "=== Moving signbank to our /opt/ directory..."
sudo mv -f ~/_build/dev/rel/signbank/* /opt/signbank

echo "=== Restarting daemons..."
sudo systemctl daemon-reload
echo "=== Restarting existing signbank application..."
sudo systemctl restart signbank
