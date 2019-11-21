<style>
table {
  font-size: 0.8em
}
thead{
    background-color: #fefefe;
}
</style>

<p align="center" style="padding-top:30px"><img src="https://raw.githubusercontent.com/passwordcockpit/frontend/master/public/assets/images/logo.svg?sanitize=true" width="400"></p>

<p align="center">Passwordcockpit is a simple, free and open source self hosted password manager for team based on PHP and MySQL, which runs on a docker service. It allows users with any kind of device to safely store, share and retrieve passwords, certificates, files and much more.</p>

<p align="center">
<img alt="GitHub release (latest by date)" src="https://img.shields.io/github/v/release/passwordcockpit/passwordcockpit">
<img alt="GitHub License" src="https://img.shields.io/github/license/passwordcockpit/passwordcockpit">
</p>


# Index
- [Using it](#-using-it)
- [Permissions](#-permissions)
- [Authentication](#-authentication)
- [Encryption](#-encryption)
- [Available docker configurations](#-available-docker-configurations)
- [Architecture and technologies](#-architecture-and-technologies)
- [Security](#-security)
- [Vulnerability](#-vulnerability)
- [Contribute](#-contribute)
- [Screenshots](#-screenshots)


# Using it
Installation is done with `docker-compose`. To install it, please see the [official install instructions](https://docs.docker.com/compose/install/).<br>
Passwordcockpit docker images are provided within [its Docker Hub organization](https://hub.docker.com/u/passwordcockpit).<br><br>
To start, just copy [`docker-compose.yml`](./docker-compose.yml) to a folder, setup the configuration as shown in the "Available docker configurations" chapter, and run `docker-compose up`.<br><br>
When the service is up, navigate to `PASSWORDCOCKPIT_BASEHOST` (e.g. `https://passwordcockpit.domain.com`) and login.<br><br>
The default username is `admin` and if is not set `PASSWORDCOCKPIT_ADMIN_PASSWORD`, the system generate the default password: `Admin123!`


# Permissions
## Global permissions
Each user can have following permissions:<br><br>
⚫️ Nothing (a normal user)<br>
👥 Create and manage users<br>
📁 Create folders<br>
🗄 Access to all directiories<br>
📊 Can view log

## Folder permissions
Each folder has a list of associated users with their permission:<br><br>
⛔️ No access (If a user is not assigned to a folder cann't access)<br>
👁 Read (If a user is assigned to a folder, can read selected folder's password)<br>
✏️ Manage (The user can add, modify and delete passwords inside the folder)<br><br>
Users can be associated to a folder even if they do not have permission of parent folder.


# Authentication
Authentication can be executed with password stored in the database or with LDAP.

## LDAP
To use LDAP, users must exist in Passwordcockpit. The match of PASSWORDCOCKPIT_LDAP_ACCOUNTFILTERFORMAT is done with the username.

When LDAP is enabled, it is no longer possible to modify the profile data because they will be synchronized at each login.


# Encryption
There are 3 levels of encryption:
- Password PIN
- SSL encryption to transfer data to the server
- Database encryption for login informations, passwords and files.

## Password PIN
Password can be crypted with a personal PIN to hide it from users with permission "Access to all directiories" and users assigned to the same directory.


# Available docker configurations
| Container volume | Description |
| - | - |
| `/var/www/html/data`  | Contain attached files to passwords, important to map to make data persistent. |
| `/etc/ssl/certs/passwordcockpit.crt`  | SSL certificate file for HTTPS, used to overwrite the self-signed auto generated file, e.g. `./volumes/ssl_certificate/passwordcockpit.crt:/etc/ssl/certs/passwordcockpit.crt:ro`. **IMPORTANT: specify read-only to avoid the overwrite of your certificate by the container certificate**  |
| `/etc/ssl/private/passwordcockpit.key`  | SSL certificate key file for HTTPS, used to overwrite the self-signed auto generated file, e.g. `./volumes/ssl_certificate/passwordcockpit.key:/etc/ssl/private/passwordcockpit.key:ro`. **IMPORTANT: specify read-only to avoid the overwrite of your certificate by the container certificate** |

| Environment variable | Description | Example |
| - | - | - |
| `PASSWORDCOCKPIT_DATABASE_USERNAME`  | Username for the database  | `username` |
| `PASSWORDCOCKPIT_DATABASE_PASSWORD`  | Password for the database  | `password`  |
| `PASSWORDCOCKPIT_DATABASE_HOSTNAME`  | Hostname of the database server  | `mysql` |
| `PASSWORDCOCKPIT_DATABASE_DATABASE`  | Name of the database  | `passwordcockpit`  |
| `PASSWORDCOCKPIT_BLOCK_CIPHER_KEY`  | Key for passwords and files encrypting. **IMPORTANT: don't lose this key, without this you will not be able to decrypt passwords and files**  | `Q7EeZaHdMV7PMBGrNRre27MFXLEKqMAS`  |
| `PASSWORDCOCKPIT_AUTHENTICATION_SECRET_KEY`  | Key for encrypting JSON Web Tokens  | `zfYKN7Z8XW8McgKaSD2uSNmQQ9dPmgTz`  |
| `PASSWORDCOCKPIT_BASEHOST`  | Base host of the Passwordcockpit service  | `https://passwordcockpit.domain.com`  |
| `PASSWORDCOCKPIT_SWAGGER`  | Enable swagger documentation, possible value: `enable` or `disable`. If enabled, documentation can be seen here: `PASSWORDCOCKPIT_BASEHOST/swagger`  | `enable` |
| `PASSWORDCOCKPIT_SSL`  | Enable SSL, possible value: `enable` or `disable`. If enabled the port 443 will be used, and the system will generate a self-signed certificate that can be replaced with what is specified in the volumes configuration. If disabled, the port 80 will be used. The two ports cannot be opened at the same time.  | `enable`  |
| `PASSWORDCOCKPIT_ADMIN_PASSWORD`  | Admin password to log in passwordcockpit  | `username` |
| `PASSWORDCOCKPIT_AUTHENTICATION_TYPE`  | Type of the authentication, possible value: `ldap` or `password`  | `password`  |

| LDAP variables (only necessary if LDAP is enabled) | Description | Example |
| - | - | - |
| `PASSWORDCOCKPIT_LDAP_HOST`  | Hostname of the LDAP server  | `ldap`  |
| `PASSWORDCOCKPIT_LDAP_PORT`  | Port of the LDAP server  | `389` |
| `PASSWORDCOCKPIT_LDAP_USERNAME`  | Username for LDAP  | `uid=name,cn=users,dc=domain,dc=com`  |
| `PASSWORDCOCKPIT_LDAP_PASSWORD`  | Password for LDAP  | `password`  |
| `PASSWORDCOCKPIT_LDAP_BASEDN`  | Base DN  | `cn=users,dc=domain,dc=com`  |
| `PASSWORDCOCKPIT_LDAP_ACCOUNTFILTERFORMAT`  | Filter for retrieving accounts  | `(&(memberOf=cn=group_name,cn=groups,dc=domain,dc=com)(uid=%s))`  |
| `PASSWORDCOCKPIT_LDAP_BINDREQUIRESDN`  | Bind requires DN, possible value: `true` or `false`  | `true`  |


# Architecture and technologies

<p align="center"><img src="architecture.svg" width="500"></p>
The application itself follows the RESTful architecture.
To make the deploy easier in production, the frontend and backend have been built and merged in a single docker image.

## Frontend
The frontend is maintained on [passwordcockpit/frontend](https://github.com/passwordcockpit/frontend).
Frontend has been developed using [`Ember.js`](https://emberjs.com/) and [`Bootstrap`](https://getbootstrap.com/). <br>
The PIN password encryption is made with [`Stanford Javascritp Crypto Library`](https://github.com/bitwiseshiftleft/sjcl), using AES-CCM.

## Backend
The backend is maintained on [passwordcockpit/backend](https://github.com/passwordcockpit/backend).
The server side is based on PHP Standard Recommendation (PSR) uses [`Zend Expressive`](https://docs.zendframework.com/zend-expressive/) and [`Doctrine`](https://www.doctrine-project.org/).<br>
HAL is used to give a consistent and easy way to hyperlink between resources.<br>
Login information are stored using `Bcrypt`.<br>
Password entitites and files are crypted with [`Zend\Crypt`](https://docs.zendframework.com/zend-crypt/), using sha-256.<br>
User session are handled with [`JWT tokens`](https://jwt.io/), encrypted with HS256.<br>
All listed encryptions are customizable with a custom key, adding cryptographic salt to hashes to mitigate rainbow tables.
All API are documented with [`Swagger`](https://swagger.io/).

## Database
Database uses [`mysql`](https://www.mysql.com/).


# Security
To ensure the security to your Passwordcockpit instance:
- Enable SSL (https) or put the service behind a reverseproxy with SSL.
- Set your `PASSWORDCOCKPIT_BLOCK_CIPHER_KEY` and `PASSWORDCOCKPIT_AUTHENTICATION_SECRET_KEY`.
- Set your `PASSWORDCOCKPIT_ADMIN_PASSWORD`.


# Vulnerability
If you have found a vulnerability in the project, please write privately to security@passwordcockpit.com. Thanks!


# Contribute
In this [`readme`](./develop/README.md) you can find the procedure to prepare the development environment.

## Screenshots

### Login page

### /folders

### /folders/1

### /folders/1/password/1

### /manage-profile

### /users

### /users/1





