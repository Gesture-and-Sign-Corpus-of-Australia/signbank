The deploy user should have sudoers access to restart the server and copy a new deployment to the correct folders: 

# Secrets file
> `/etc/signbank/signbank.conf`

```
PHX_SERVER=true
PHX_HOST=auslan.org.au
PORT=8080
DATABASE_URL=ecto://signbank:signbank@localhost:5432/signbank
POOL_SIZE=10
SECRET_KEY_BASE=
RELEASE_COOKIE=
MEDIA_URL=<s3_files_base_url>
S3_ACCESS_KEY_ID=
S3_SECRET_ACCESS_KEY=
S3_BUCKET=
S3_REGION=
S3_BASE_URL=<s3_api_url>
POSTMARK_API_KEY=
MAIL_FROM=info@auslan.org.au
APPLICATION_NAME="Auslan Signbank"
```

The database referenced by `DATABASE_URL` should already exist before the first deploy.

# Sudoers config
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
