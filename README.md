# Passwordcockpit

## General

Passwordcockpit is a self hosted open source password manager. It allows users to safely store, share and retrieve passwords, certificates, files and much more.

## Installation

Installation is done with `docker-compose`. To install it, please see the [official install instructions](https://docs.docker.com/compose/install/).<br>
Passwordcockpit docker images are provided within [its Docker Hub organization](https://hub.docker.com/u/passwordcockpit).<br>

To start, just copy [`docker-compose.yml`](./docker-compose.yml) to a folder, setup the configuration as shown below, and run `docker-compose up`.

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
- `PASSWORDCOCKPIT_AUTHENTICATION_SECRET_KEY`: Key for encrypting JSON Web Tokens, e.g. `zfYKN7Z8XW8McgKaSD2uSNmQQ9dPmgTz`
- `PASSWORDCOCKPIT_BASEHOST`: Base host of the Passwordcockpit service, e.g. `https://passwordcockpit.domain.com`
- `PASSWORDCOCKPIT_SWAGGER`: Enable swagger documentation, possible value: `enable` or `disable`. if enabled, documentation can be seen here: `PASSWORDCOCKPIT_BASEHOST/swagger`
- `PASSWORDCOCKPIT_SSL`: Enable SSL, possible value: `enable` or `disable`. If enabled the port 443 will be used, and the system will generate a self-signed certificate that can be replaced with what is specified in the volumes configuration. If disabled, the port 80 will be used. The two ports cannot be opened at the same time.
- `PASSWORDCOCKPIT_AUTHENTICATION_TYPE`: Type of the authentication, possible value: `ldap` or `password`

##### Only for LDAP type
- `PASSWORDCOCKPIT_LDAP_HOST`: Hostname of the LDAP server
- `PASSWORDCOCKPIT_LDAP_PORT`: Port of the LDAP server
- `PASSWORDCOCKPIT_LDAP_USERNAME`: Username for LDAP, e.g. `uid=name,cn=users,dc=domain,dc=com`
- `PASSWORDCOCKPIT_LDAP_PASSWORD`: Password for LDAP
- `PASSWORDCOCKPIT_LDAP_BASEDN`: Base DN, e.g. `cn=users,dc=domain,dc=com`
- `PASSWORDCOCKPIT_LDAP_ACCOUNTFILTERFORMAT`: Filter for retrieving accounts, e.g. `(&(memberOf=cn=group_name,cn=groups,dc=domain,dc=com)(uid=%s))`
- `PASSWORDCOCKPIT_LDAP_BINDREQUIRESDN`: Bind requires DN, possible value: `true` or `false`

### First steps

After the installation, navigate to `PASSWORDCOCKPIT_BASEHOST` and there will be a login page.<br>
the default admin user has the following credentials:
- username: `admin`
- password: `Admin123!`

## Technologies
The application itself follows the RESTFUL architecture. <br>
There are 3 levels of encryption:
- A PIN that the user can place on a password
- SSL encryption to transfer data to the server
- Database encryption for login informations, passwords and files.


### Frontend
Frontend has been developed using [`Ember.js`](https://emberjs.com/). <br>
The PIN encryption available to the user is made with Stanford Javascritp Crypto Library, using AES-CCM.
More information on the technologies used by the frontend [can be found here](https://github.com/passwordcockpit/frontend/blob/master/README.md).

### Backend
The server side of Passwordcockpit uses [`Zend Expressive`](https://docs.zendframework.com/zend-expressive/).
Login information are stored using [Bcrypt](https://en.wikipedia.org/wiki/Bcrypt) which uses OpenBSD. <br>
Password entitites and files are crypted with [Zend\Crypt](https://docs.zendframework.com/zend-crypt/), using sha-256.<br>
User session are handled with [JWT tokens](https://jwt.io/).

All encryptions are customizable with custom key to add cryptographic salt to hashes and thus mitigate rainbow tables.



