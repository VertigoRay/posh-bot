
:bangbang: **Work in Progress**

This is a PowerShell Web Bot designed to work with MS Teams.

# Credentials

Credentials can be passed in via [docker secrets](https://docs.docker.com/engine/swarm/secrets/#about-secrets) (preferred) or environment variables.

## Credentials via Docker Secrets

Using [docker secrets](https://docs.docker.com/engine/swarm/secrets/#about-secrets) is the preferred method due to the security involved in the secrets. In order to use the secrets, first you need to set the secrets; like so:

```powershell
echo 'vertigion.com\poshweb' | docker secret create ad_user -
echo 'P@$$w0rd!' | docker secret create ad_pass -
```

Then, in your stack deploy YAML, do this:

```yml
secrets:
  - ad_user
  - ad_pass
```

## Credentials via Environment Variables

Unfortunately, [docker secrets](https://docs.docker.com/engine/swarm/secrets/#about-secrets) are only available to docker swarms. So, for testing purposes, I made environment variables available:

```yml
environment:
  - ad_user=vertigion.com\VertigoRay
  - ad_pass=P@$$w0rd!
```

# Environment Variables

Additionally, you'll want to set some of your AD settings:

- `AD_SEARCHBASE`: (*Optional*) The base OU to conduct searches in.
    - *Default*: Search the entire domain.
    - This is used as the `-SearchBase` parameter in AD commands; like: `Get-ADUser`.
- `AD_SERVER`: (**Required**) Your domain controller (and port if non-default).
    - **Required** because the container is not bound and won't be able to reliably find your domain without this.
    - This is used as the `-Server` parameter in AD commands; like: `Get-ADUser`.
- `WEBSERVER_HOST`: (*Optional*) The hostname that the web service will respond to.
    - *Default*: `*` (Respond to any hostname.)
- `WEBSERVER_PORT`: (*Optional*) 
    - *Default*: `8080` (Listen on port `8080`)
- `WEBSERVER_PROTOCOL`: (*Optional*) the protocol to work on.
    - *Default*: `http` (Respond to `http` requests only.)
    - Using `https` will require certificates that are not currently supported. My setup uses `https` via an nginx proxy; this service runs on `http`.

## Example of All Environment Variables

```yml
AD_SEARCHBASE='OU=Users,DC=vertigion,DC=com'
AD_SERVER=vertigion.com
WEBSERVER_HOST=posh.bot.vertigion.com
WEBSERVER_PORT=8080
WEBSERVER_PROTOCOL=http
```

# Usage

Entry Points:

- `/aduser/get_counts`