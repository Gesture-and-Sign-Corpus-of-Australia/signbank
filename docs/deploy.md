# housekeeping

```
# CI/CD runner logs in as `deploy`
sudo adduser deploy
# the systemd Signbank service runs under this user
sudo adduser signbank
# the systemd minio service runs under this user
sudo groupadd -r minio-user
sudo useradd -M -r -g minio-user minio-user
```

## Dependencies
### Tailscale

Install Tailscale, optional but highly recommended, in your Tailscale dashboard there is an option to add a new linux server which generates an install-and-auth script for you.

### S3-compatible object storage

You can use any S3-compatible object storage that supports CORS; or you can run minio on the same server as Signbank
```
wget https://dl.min.io/server/minio/release/linux-amd64/archive/minio_20250203210304.0.0_amd64.deb -O minio.deb
```

The `minio-user` runs the minio systemd service and we store the files in its home directory
```
# chown minio-user:minio-user /mnt/disk1 /mnt/disk2 /mnt/disk3 /mnt/disk4
```

#### minio client

> See https://min.io/docs/minio/linux/reference/minio-mc.html

### Database
```
sudo apt install postgresql
```

Set the following settings in `/etc/postgresql/*/main/postgres.conf`:
```
listen_addresses = '*'
ssl = off
```

Add a line at the bottom of `/etc/postgresql/*/main/pg_hba.conf` to allow tailscale connections: (optional)
```
# allow all tailscale connections
host all all 100.64.0.0/10 trust
```

Restart tailscale:
```
sudo systemctl restart postgresql.service
```

Create a signbank postgres user:
```
sudo -u postgres psql template1
```
and run
```sql
CREATE USER signbank
WITH CREATEDB
PASSWORD 'signbank';
```

Create signbank database:
Access postgres as `signbank`
```
sudo -u signbank psql template1
```
and run
```
CREATE DATABASE signbank;
```


# Config files

The deploy user should have sudoers access to restart the server and copy a new deployment to the correct folders: 

## Secrets file

> `/etc/signbank/signbank.conf`
```
PHX_SERVER=true
PHX_HOST=auslan.org.au
PORT=8080
DATABASE_URL=ecto://signbank:signbank@localhost:5432/signbank
POOL_SIZE=10
SECRET_KEY_BASE=
RELEASE_COOKIE=

MEDIA_URL=https://media.auslan.org.au/signbank

S3_ACCESS_KEY_ID=<generate in Minio web console>
S3_SECRET_ACCESS_KEY=<generate in Minio web console>

S3_BUCKET=signbank
S3_REGION=us-east-1
S3_BASE_URL=https://media.auslan.org.au
POSTMARK_API_KEY=
MAIL_FROM=info@auslan.org.au
APPLICATION_NAME="Auslan Signbank"
```

> `/etc/default/minio`
```
MINIO_VOLUMES="/mnt/data"
MINIO_OPTS="--console-address :9001"
MINIO_ROOT_USER=sbadmin
MINIO_ROOT_PASSWORD="_avF7mudyMqT@figkzq8yDpRpaMkbp!oX67TjQJWNenB@xtEHgK"
```


The database referenced by `DATABASE_URL` should already exist before the first deploy.

## Sudoers config
`/etc/sudoers.d/signbank`, where `deploy` is the user you use for `STAGING_REMOTE_USER`.
```
%deploy ALL= NOPASSWD: /bin/systemctl daemon-reload
%deploy ALL= NOPASSWD: /bin/systemctl start signbank
%deploy ALL= NOPASSWD: /bin/systemctl stop signbank
%deploy ALL= NOPASSWD: /bin/systemctl restart signbank
%deploy ALL= NOPASSWD: /bin/mv /opt/signbank/*.service /etc/systemd/system --force
```

# CI secrets/variables

- `STAGING_REMOTE_HOST`: IP address of the server, must be provisioned manually
- `STAGING_REMOTE_USER`: the deploy username, must exist on the host already (we use `deploy`)
- `STAGING_SSH_PRIVATE_KEY`: full private key that is already authorized to SSH into the server
- `STAGING_REMOTE_TARGET`: home directory of the deploy user


# Dependencies

## Caddy (can use Nginx if preferred)
> To install Caddy follow https://caddyserver.com/docs/install#debian-ubuntu-raspbian

`/etc/caddy/Caddyfile`
```
import Caddyfile.d/*.caddyfile
```

`/etc/caddy/Caddyfile.d/web.caddyfile`
```
www.uat.auslan.org.au {
        redir https://uat.auslan.org.au{uri}
}

uat.auslan.org.au {
        reverse_proxy {
                to localhost:8080
        }
}
```

`/etc/caddy/Caddyfile.d/minio.caddyfile`
```
media.uat.auslan.org.au {
    handle_path /* {
        reverse_proxy :9000
    }
}

minio.uat.auslan.org.au {
    handle_path/* {
        reverse_proxy :9001
    }
}
```
