<p align="center" style="padding-top:30px"><img src="https://raw.githubusercontent.com/passwordcockpit/frontend/master/public/assets/images/logo.svg?sanitize=true" width="400"></p>

<p align="center">Passwordcockpit is a simple, free, open source, self hosted, web based password manager for teams. It is made in PHP, Javascript, MySQL and it run on a docker service. It allows users with any kind of device to safely store, share and retrieve passwords, certificates, files and much more.</p>

<p align="center">
    <img alt="GitHub license" src="https://img.shields.io/github/license/passwordcockpit/passwordcockpit">
    <img alt="GitHub last release" src="https://img.shields.io/github/v/release/passwordcockpit/passwordcockpit?sort=semver">
    <img alt="Docker pulls" src="https://img.shields.io/docker/pulls/passwordcockpit/passwordcockpit">
</p>


# Index
- [Index](#index)
- [Usage](#usage)
- [Permissions](#permissions)
  - [Global permissions](#global-permissions)
  - [Folder permissions](#folder-permissions)
- [Authentication](#authentication)
  - [LDAP](#ldap)
- [Encryption](#encryption)
  - [Password PIN](#password-pin)
- [Available docker configurations](#available-docker-configurations)
- [Architecture and technologies](#architecture-and-technologies)
  - [Frontend](#frontend)
  - [Backend](#backend)
  - [Database](#database)
- [Security](#security)
- [Vulnerabilities](#vulnerabilities)
- [Contribute](#contribute)
  - [Screenshots](#screenshots)
    - [Passwords manager](#passwords-manager)
    - [Users manager](#users-manager)
    - [Mobile design](#mobile-design)


# Usage
Installation is done with `docker-compose`. Please check out the [official install instructions](https://docs.docker.com/compose/install/) for more information.<br>
Passwordcockpit docker images are provided within [its Docker Hub organization](https://hub.docker.com/u/passwordcockpit).<br><br>
To start, just copy [`docker-compose.yml`](https://github.com/passwordcockpit/passwordcockpit/blob/master/docker-compose.yml) to a folder and setup the configuration as shown in the "Available docker configurations" chapter. Finally run `docker-compose up` from terminal.<br><br>
When the service is up, navigate to `PASSWORDCOCKPIT_BASEHOST` (e.g. `https://passwordcockpit.com`) and login.<br><br>
The default username is `admin`. The system generate the default password: `Admin123!`, this can be overridden by specifying the `PASSWORDCOCKPIT_ADMIN_PASSWORD` variable.


# Permissions
## Global permissions
Each user can have following permissions:<br><br>
⚫️ Nothing (a normal user)<br>
👥 Create and manage users<br>
📁 Create folders<br>
🗄 Access to all directories<br>
📊 Can view log

## Folder permissions
Each folder has a list of associated users with their permissions:<br><br>
⛔️ No access (A user cannot access a folder to which is not assigned)<br>
👁 Read (A user can read the passwords from a folder to which he is associated)<br>
✏️ Manage (The user can add, modify and delete passwords inside the folder)<br><br>
Users can be associated to a folder even if they do not have permission from the parent folder.

# Authentication
Authentication can be done with database stored password or LDAP.

## LDAP
To use LDAP, users must exist in Passwordcockpit. The match of `PASSWORDCOCKPIT_LDAP_ACCOUNTFILTERFORMAT` is done with the username.

When LDAP is enabled it is no longer possible to modify the profile data, since they will be synchronized at each login.

# Encryption
There are 3 levels of encryption:
- Password PIN
- SSL encryption for transfering data to the server
- Database encryption for login informations, passwords and files.

## Password PIN
A password can be crypted with a personal PIN in order to hide it from users with "Access to all directiories" permission and from users assigned to the same directory.

# Available docker configurations
| Container volume                       | Description                                                                                                                                                                                                                                                                                       | Example                              |
| -------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | - |
| `/var/www/html/upload`                 | Contains passwords attached files. It is important to map for making data persistent.                                                                                                                                                                                                             | `./volumes/upload`                             |
| `/etc/ssl/certs/passwordcockpit.crt`   | SSL certificate file for HTTPS, used to overwrite the self-signed auto generated file. **IMPORTANT: specify read-only to avoid the overwrite of your certificate by the container certificate**       | `./volumes/ssl_certificate/passwordcockpit.crt:/etc/ssl/certs/passwordcockpit.crt:ro` |
| `/etc/ssl/private/passwordcockpit.key` | SSL certificate key file for HTTPS, used to overwrite the self-signed auto generated file. **IMPORTANT: specify read-only to avoid the overwrite of your certificate by the container certificate** | `./volumes/ssl_certificate/passwordcockpit.key:/etc/ssl/private/passwordcockpit.key:ro` |

| Environment variable                        | Description                                                                                                                                                                                                                                                                                                   | Example                              |
| ------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------ |
| `PASSWORDCOCKPIT_DATABASE_USERNAME`         | Username for the database                                                                                                                                                                                                                                                                                     | `username`                           |
| `PASSWORDCOCKPIT_DATABASE_PASSWORD`         | Password for the database                                                                                                                                                                                                                                                                                     | `password`                           |
| `PASSWORDCOCKPIT_DATABASE_HOSTNAME`         | Hostname of the database server                                                                                                                                                                                                                                                                               | `mysql`                              |
| `PASSWORDCOCKPIT_DATABASE_DATABASE`         | Name of the database                                                                                                                                                                                                                                                                                          | `passwordcockpit`                    |
| `PASSWORDCOCKPIT_BLOCK_CIPHER_KEY`          | Key for passwords and files encryption. **IMPORTANT: do not lose this key, without it you will not be able to decrypt passwords and files**                                                                                                                                                                   | `Q7EeZaHdMV7PMBGrNRre27MFXLEKqMAS`   |
| `PASSWORDCOCKPIT_AUTHENTICATION_SECRET_KEY` | Key for encrypting JSON Web Tokens                                                                                                                                                                                                                                                                            | `zfYKN7Z8XW8McgKaSD2uSNmQQ9dPmgTz`   |
| `PASSWORDCOCKPIT_BASEHOST`                  | Base host of the Passwordcockpit service                                                                                                                                                                                                                                                                      | `https://passwordcockpit.com` |
| `PASSWORDCOCKPIT_SWAGGER`                   | Enable swagger documentation, possible values: `enable` or `disable`. If enabled, documentation can be seen here: `PASSWORDCOCKPIT_BASEHOST/swagger`                                                                                                                                                          | `enable`                             |
| `PASSWORDCOCKPIT_SSL`                       | Enable SSL, possible values: `enable` or `disable`. If enabled the port 443 will be used, the system will generate a self-signed certificate that can be replaced with the one specified in the volumes configuration. If disabled the port 80 will be used. The two ports cannot be opened at the same time. | `enable`                             |
| `PASSWORDCOCKPIT_ADMIN_PASSWORD`            | Admin password to log into passwordcockpit                                                                                                                                                                                                                                                                    | `Password123!`                           |
| `PASSWORDCOCKPIT_AUTHENTICATION_TYPE`       | Type of the authentication, possible values: `ldap` or `password`                                                                                                                                                                                                                                             | `password`                           |

| LDAP variables (only necessary if LDAP is enabled) | Description                                                | Example                                                          |
| -------------------------------------------------- | ---------------------------------------------------------- | ---------------------------------------------------------------- |
| `PASSWORDCOCKPIT_LDAP_HOST`                        | Hostname of the LDAP server                                | `ldap`                                                           |
| `PASSWORDCOCKPIT_LDAP_PORT`                        | Port of the LDAP server                                    | `389`                                                            |
| `PASSWORDCOCKPIT_LDAP_USERNAME`                    | Username for LDAP                                          | `uid=name,cn=users,dc=passwordcockpit,dc=com`                             |
| `PASSWORDCOCKPIT_LDAP_PASSWORD`                    | Password for LDAP                                          | `password`                                                       |
| `PASSWORDCOCKPIT_LDAP_BASEDN`                      | Base DN                                                    | `cn=users,dc=passwordcockpit,dc=com`                                      |
| `PASSWORDCOCKPIT_LDAP_ACCOUNTFILTERFORMAT`         | Filter to retrieve accounts, it match the `username`                              | `(&(memberOf=cn=group_name,cn=groups,dc=passwordcockpit,dc=com)(uid=%s))` |
| `PASSWORDCOCKPIT_LDAP_BINDREQUIRESDN`              | Bind if DN is required, possible values: `true` or `false` | `true`                                                           |

# Available translations
Password cockpit is translated into:
- English
- Italiano


# Architecture and technologies

<p align="center"><img src="https://raw.githubusercontent.com/passwordcockpit/passwordcockpit/master/assets/architecture.svg?sanitize=true" width="500"></p>
The application itself follows the RESTful architecture.<br>
To ease deployment into production, frontend and backend have been built and merged in a single docker image.

## Frontend
The frontend is maintained on [passwordcockpit/frontend](https://github.com/passwordcockpit/frontend).
Frontend has been developed using [`Ember.js`](https://emberjs.com/) and [`Bootstrap`](https://getbootstrap.com/). <br>
The PIN password encryption is made with [`Stanford Javascritp Crypto Library`](https://github.com/bitwiseshiftleft/sjcl), using AES-CCM.

## Backend
The backend is maintained on [passwordcockpit/backend](https://github.com/passwordcockpit/backend).<br>
The server side application logic is based on PHP Standard Recommendation (PSR) using [`Zend Expressive`](https://docs.zendframework.com/zend-expressive/) and [`Doctrine`](https://www.doctrine-project.org/).<br>
HAL is used as a JSON specification to give a consistent and easy way to hyperlink between resources.<br>
Login information are stored using `Bcrypt`.<br>
Password entitites and files are crypted with [`Zend\Crypt`](https://docs.zendframework.com/zend-crypt/), using sha-256.<br>
User sessions are handled with [`JWT tokens`](https://jwt.io/), encrypted with HS256.<br>
All listed encryptions are customizable with a custom key, adding cryptographic salt to hashes to mitigate rainbow tables.<br>
All API are documented with [`Swagger`](https://swagger.io/).

## Database
Database uses [`mysql`](https://www.mysql.com/).

# Security
To ensure the security to your Passwordcockpit instance:
- Enable SSL (https) or put the service behind a reverseproxy with SSL.
- Set your `PASSWORDCOCKPIT_BLOCK_CIPHER_KEY` and `PASSWORDCOCKPIT_AUTHENTICATION_SECRET_KEY`.
- Set your `PASSWORDCOCKPIT_ADMIN_PASSWORD`.
- Disable Swagger.


# Vulnerabilities
If you find any vulnerability within the project, you are welcome to drop us a private message to: security@passwordcockpit.com. Thanks!

# Contribute
[`Here`](https://github.com/passwordcockpit/passwordcockpit/blob/master/develop/README.md) you can find the steps to prepare the development environment.

# Screenshots
## Passwords manager
<p align="center"><img src="https://raw.githubusercontent.com/passwordcockpit/passwordcockpit/master/assets/passwordcockpit-screenshot-1.jpg" width="600"></p>

## Users manager
<p align="center"><img src="https://raw.githubusercontent.com/passwordcockpit/passwordcockpit/master/assets/passwordcockpit-screenshot-2.jpg" width="600"></p>

## Mobile design
<p align="center"><img src="https://raw.githubusercontent.com/passwordcockpit/passwordcockpit/master/assets/passwordcockpit-screenshot-3.jpg" width="300"></p>



