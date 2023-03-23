#!/bin/bash
##############################################
# Change permissions
##############################################
chown -R ${APACHE_RUN_USER}:${APACHE_RUN_GROUP} /var/www/html/data; \ 
chown -R ${APACHE_RUN_USER}:${APACHE_RUN_GROUP} /var/www/html/upload; \
chown  ${APACHE_RUN_USER}:${APACHE_RUN_GROUP} /var/www/html/public; \
chown  ${APACHE_RUN_USER}:${APACHE_RUN_GROUP} /var/www/html/public/index.html; \
chown -R ${APACHE_RUN_USER}:${APACHE_RUN_GROUP} /var/www/html/public/assets; \
chown -R ${APACHE_RUN_USER}:${APACHE_RUN_GROUP} /var/www/html/swagger; \
chmod -R 744 /var/www/html/data; \ 
chmod -R 744 /var/www/html/upload; \
chmod 744 /var/www/html/public; \
chmod 744 /var/www/html/public/index.html; \
chmod -R 744 /var/www/html/public/assets; \
chmod -R 744 /var/www/html/swagger

##############################################
# Update frontend files
##############################################
echo -e "\e[32mStart updating frontend files\e[0m"
sed -ri -e 's!PASSWORDCOCKPIT_BASEHOST!'${PASSWORDCOCKPIT_BASEHOST}'!g' public/index.html
sed -ri -e 's!PASSWORDCOCKPIT_BASEHOST!'${PASSWORDCOCKPIT_BASEHOST}'!g' public/assets/*.*
echo -e "\e[32mFrontend files updated\e[0m"

##############################################
# Enable swagger
##############################################
echo -e "\e[32mStart swagger part\e[0m"
if [ "${PASSWORDCOCKPIT_SWAGGER}" == "enable" ]; then
    PASSWORDCOCKPIT_SWAGGERBASEHOST=$(echo ${PASSWORDCOCKPIT_BASEHOST} |sed 's/https\?:\/\///')
	sed -ri -e "s!PASSWORDCOCKPIT_BASEHOST!$PASSWORDCOCKPIT_SWAGGERBASEHOST!g" swagger/swagger.json
	mv swagger public/swagger
else
	rm -rf swagger
fi
echo -e "\e[32mSwagger ok\e[0m"

##############################################
# Database
##############################################
echo -e "\e[32mCheck database connection\e[0m"
max_retries=10
try=0

while [ "$try" -lt "$max_retries" ]
do
	connection=$(vendor/bin/doctrine dbal:run-sql "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = '${PASSWORDCOCKPIT_DATABASE_DATABASE}'")
	# schema_name is unset or set to the empty string so connecting problem
	if [ -z "${connection}" ]; then
		echo -e "\e[31mRetrying connection...\e[0m"
		try=$((try+1))
		sleep 3s
		continue
	fi
	schema_exist=$(echo $connection | grep ${PASSWORDCOCKPIT_DATABASE_DATABASE} -c)
	# connection ok and schema exist
	if [ "$schema_exist" == "1" ]; then
		echo -e "\e[32mConnection ok\e[0m"
		echo -e "\e[32mSchema already exist\e[0m"
		# Tables exists
		number_of_tables=$(vendor/bin/doctrine dbal:run-sql "SELECT count(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = '${PASSWORDCOCKPIT_DATABASE_DATABASE}'" | tr -d -c 0-9)
		# Create the tables and popolate it
		vendor/bin/doctrine-migrations migrate
		vendor/bin/doctrine orm:generate-proxies
		echo -e "\e[32mDatabase created or updated\e[0m"
		if [ "$number_of_tables" == "0" ]; then
        sql=$(cat database/create-production-environment.sql | sed '/^--/d')
        vendor/bin/doctrine dbal:run-sql "$sql"
	            echo -e "\e[32mProduction data installed\e[0m"
		    if [ "${PASSWORDCOCKPIT_ADMIN_PASSWORD}" != "" ]; then
			bcrypted_admin_password=$(/usr/local/bin/php -r "echo password_hash('${PASSWORDCOCKPIT_ADMIN_PASSWORD}', PASSWORD_BCRYPT);")
			vendor/bin/doctrine dbal:run-sql "UPDATE user SET password = '$bcrypted_admin_password' WHERE user_id = 1"
			echo -e "\e[32mAdmin password modified\e[0m"
		    fi
		fi
		break
	fi
	# connection ok and schema not exist: error
	if [ "$schema_exist" == "0" ]; then
		echo -e "\e[32mConnection ok\e[0m"
		echo -e "\e[31mSchema not exist\e[0m"
		echo -e "\e[31mInstalling failed!\e[0m"
		exit 1
		break
	fi
done
# Connection error
if [ "$try" -gt "$max_retries" ]; then
	echo -e "\e[31mInstalling failed!\e[0m"
	exit 1
fi

echo -e "\e[32mPasswordcockpit ready\e[0m"

exec "$@"