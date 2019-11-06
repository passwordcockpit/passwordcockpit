#!/bin/bash

##############################################
# Configuration files
##############################################
echo >&2 "Start creating configuration files"
filename=config/autoload/db.local.php
if [ ! -e $filename ]; then
	{
		echo "<?php"
		echo "return ["
		echo "    'dbadapter' => ["
		echo "        'username' => '${PASSWORDCOCKPIT_DATABASE_USERNAME}',"
		echo "        'password' => '${PASSWORDCOCKPIT_DATABASE_PASSWORD}'," 
		echo "        'hostname' => '${PASSWORDCOCKPIT_DATABASE_HOSTNAME}',"
		echo "        'database' => '${PASSWORDCOCKPIT_DATABASE_DATABASE}'"
		echo "    ]"
		echo "];"
	} >> $filename
fi

filename=config/autoload/doctrine.local.php
if [ ! -e $filename ]; then
	{
		echo "<?php"
		echo "return ["
		echo "    'doctrine' => ["
		echo "        'connection' => ["
		echo "            'orm_default' => [" 
		echo "                'params' => ["
		echo "                    'url' =>"
		echo "                        'mysql://${PASSWORDCOCKPIT_DATABASE_USERNAME}:${PASSWORDCOCKPIT_DATABASE_PASSWORD}@${PASSWORDCOCKPIT_DATABASE_HOSTNAME}/${PASSWORDCOCKPIT_DATABASE_DATABASE}'"
		echo "                ]"
		echo "            ]"
		echo "        ]"
		echo "    ]"
		echo "];"
	} >> $filename
fi

filename=config/autoload/crypt.local.php
if [ ! -e $filename ]; then
	{
		echo "<?php"
		echo "return ["
		echo "    'block_cipher' => ["
		echo "        'key' => '${PASSWORDCOCKPIT_BLOCK_CIPHER_KEY}'"
		echo "    ]" 
		echo "];"
	} >> $filename
fi

if [ "${PASSWORDCOCKPIT_AUTHENTICATION_TYPE}" == "ldap" ]; then
	filename=config/autoload/authentication.local.php
	if [ ! -e $filename ]; then
		{
			echo "<?php"
			echo "return ["
			echo "    'authentication' => ["
			echo "        'secret_key' => '${PASSWORDCOCKPIT_AUTHENTICATION_SECRET_KEY}'"
			echo "    ]," 
			echo "    'dependencies' => ["
			echo "        'factories' => ["
			echo "            Zend\Authentication\Adapter\AdapterInterface::class =>"
			echo "                Authentication\Api\V1\Factory\Adapter\LdapAdapterFactory::class"
			echo "        ]"
			echo "    ]"
			echo "];"
		} >> $filename
	fi

	filename=config/autoload/ldap.local.php
	if [ ! -e $filename ]; then
		{
			echo "<?php"
			echo "return ["
			echo "    'ldap' => [["
			echo "        'host' => '${PASSWORDCOCKPIT_LDAP_HOST}',"
			echo "        'port' => ${PASSWORDCOCKPIT_LDAP_PORT},"
			echo "        'username' => '${PASSWORDCOCKPIT_LDAP_USERNAME}',"
			echo "        'password' => '${PASSWORDCOCKPIT_LDAP_PASSWORD}',"
			echo "        'baseDn' => '${PASSWORDCOCKPIT_LDAP_BASEDN}',"
			echo "        'accountFilterFormat' => '${PASSWORDCOCKPIT_LDAP_ACCOUNTFILTERFORMAT}',"
			echo "        'bindRequiresDn' => ${PASSWORDCOCKPIT_LDAP_BINDREQUIRESDN}"
			echo "    ]]" 
			echo "];"
		} >> $filename
	fi
elif [ "${PASSWORDCOCKPIT_AUTHENTICATION_TYPE}" == "password" ]; then
	filename=config/autoload/authentication.local.php
	if [ ! -e $filename ]; then
		{
			echo "<?php"
			echo "return ["
			echo "    'authentication' => ["
			echo "        'secret_key' => '${PASSWORDCOCKPIT_AUTHENTICATION_SECRET_KEY}'"
			echo "    ]" 
			echo "];"
		} >> $filename
	fi
fi

filename=config/constants.local.php
if [ ! -e $filename ]; then
	{
		echo "<?php"
		echo "define('SWAGGER_API_HOST', '${PASSWORDCOCKPIT_BASEHOST}');"
	} >> $filename
fi
echo >&2 "Configuration files created"


##############################################
# Update frontend files
##############################################
echo >&2 "Start updating frontend files"
sed -ri -e 's!PASSWORDCOCKPIT_BASEHOST!'${PASSWORDCOCKPIT_BASEHOST}'!g' public/index.html
sed -ri -e 's!PASSWORDCOCKPIT_BASEHOST!'${PASSWORDCOCKPIT_BASEHOST}'!g' public/assets/*.*
echo >&2 "Frontend files updated "


##############################################
# Database
##############################################
echo >&2 "Start configuring database"
# database schema
max_retries=10
try=0
until vendor/bin/doctrine orm:schema-tool:create || [ "$try" -gt "$max_retries" ]
do
	echo >&2 "retrying connection..."
	try=$((try+1))
	sleep 3s
done
if [ "$try" -gt "$max_retries" ]; then
	echo >&2 "Installing failed!"
	exit 1
fi
vendor/bin/doctrine orm:generate-proxies
echo >&2 "DB schema created"

vendor/bin/doctrine dbal:import database/create-production-environment.sql
echo >&2 "Production data installed"

echo >&2 "Database configured"

exec "$@"