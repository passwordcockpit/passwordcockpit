# Passwordcockpit

Passwordcockpit provides updated Docker images within [its Docker Hub organization](https://hub.docker.com/u/passwordcockpit).<br>
This reference setup guides users through the setup based on docker-compose (the installation of docker-compose is out of scope of this documentation, see the [official install instructions](https://docs.docker.com/compose/install/)).<br><br>
To start, just copy [`docker-compose.yml`](./docker-compose.yml) to a folder and run `docker-compose up`.

### Docker configurations
#### Volumes
- `/var/www/html/data`: contain attached files to passwords, important to map to make data persistent 
- `/etc/ssl/certs/passwordcockpit.crt`: SSL certificate file for HTTPS, used to overwrite the self-signed auto generated file, e.g. `./volumes/ssl_certificate/passwordcockpit.crt:/etc/ssl/certs/passwordcockpit.crt:ro`. **IMPORTANT: specify read-only to avoid the overwrite of your certificate by the container certificate**
- `/etc/ssl/private/passwordcockpit.key`: SSL certificate key file for HTTPS, used to overwrite the self-signed auto generated file, e.g. `./volumes/ssl_certificate/passwordcockpit.key:/etc/ssl/private/passwordcockpit.key:ro`. **IMPORTANT: specify read-only to avoid the overwrite of your certificate by the container certificate**

#### Environment variables
- `PASSWORDCOCKPIT_DATABASE_USERNAME`: Username for the database
- `PASSWORDCOCKPIT_DATABASE_PASSWORD`: Password for the database
- `PASSWORDCOCKPIT_DATABASE_HOSTNAME`: Hostname of the database server
- `PASSWORDCOCKPIT_DATABASE_DATABASE`: Name of the database
- `PASSWORDCOCKPIT_BLOCK_CIPHER`_KEY: Key for passwords and files encrypting, e.g. `Q7EeZaHdMV7PMBGrNRre27MFXLEKqMAS`
- `PASSWORDCOCKPIT_AUTHENTICATION_SECRET_KEY`: Key for JWT, e.g. `zfYKN7Z8XW8McgKaSD2uSNmQQ9dPmgTz`
- `PASSWORDCOCKPIT_BASEHOST`: Base host of the passwordcockpit service, e.g. `https://passwordcockpit.domain.com`
- `PASSWORDCOCKPIT_SWAGGER`: Enable swagger documentation, possible value: `enable` or `disable`. URL: PASSWORDCOCKPIT_BASEHOST/swagger
- `PASSWORDCOCKPIT_SSL`: Enable SSL, possible value: `enable` or `disable`. If enabled use port 443 if not, the port 80, the two ports cannot be opened at the same time. If enabled, the system generate a self-signed certificate, this can be replaced with volumes
- `PASSWORDCOCKPIT_AUTHENTICATION_TYPE`: Type of the authentication, possible value: `ldap` or `password`

##### Only for LDAP type
- `PASSWORDCOCKPIT_LDAP_HOST`: Hostname of the LDAP server
- `PASSWORDCOCKPIT_LDAP_PORT`: Port of the LDAP server
- `PASSWORDCOCKPIT_LDAP_USERNAME`: Username for LDAP, e.g. `uid=name,cn=users,dc=domain,dc=com`
- `PASSWORDCOCKPIT_LDAP_PASSWORD`: Password for LDAP
- `PASSWORDCOCKPIT_LDAP_BASEDN`: Base DN, e.g. `cn=users,dc=domain,dc=com`
- `PASSWORDCOCKPIT_LDAP_ACCOUNTFILTERFORMAT`: Filter for retrieving accounts, e.g. `(&(memberOf=cn=group_name,cn=groups,dc=domain,dc=com)(uid=%s))`
- `PASSWORDCOCKPIT_LDAP_BINDREQUIRESDN`: Bind requires DN, possible value: `true` or `false`