fig_run:
	docker-compose up -d
fig_log:
	docker-compose logs --follow
fig_stop:
	docker-compose stop
fig_remove:
	docker-compose rm
fig_status:
	docker-compose ps
install:
	./00-install-dev.sh
up:
	docker-compose -f docker-compose.dev.yml up
down:
	docker-compose -f docker-compose.dev.yml down
rm:
	docker-compose -f docker-compose.dev.yml down --rmi all
api_cc:
	docker exec -it target_api_1 /bin/sh

rebuild_xml:
	cd api/node_modules/libxmljs && node-gyp rebuild

import:
	mysql -uroot -proot selenium_schema <dump/database.sql

export:
	mysqldump -uroot -proot --no-data test > dump/database.sql

update_dependences:
	npm i -g npm-check-updates
	npm-check-updates -u
	npm install

connect:
	psql \
   --host=website.cvwcqgex9vnj.us-east-1.rds.amazonaws.com \
   --port=5432 \
   --username website \
   --password PerSe12cel \
   --dbname=website

db_config:
	CREATE USER 'apiuser'@'localhost' IDENTIFIED BY 'lost2020';
	GRANT ALL PRIVILEGES ON *.* TO 'apiuser'@'localhost' WITH GRANT OPTION;
	CREATE USER 'apiuser'@'%' IDENTIFIED BY 'lost2020';
	GRANT ALL PRIVILEGES ON *.* TO 'apiuser'@'%' WITH GRANT OPTION;
	FLUSH PRIVILEGES;
db_file:
	sudo fs_usage | grep my.cnf
github:
	ssh-keygen -t rsa_py -b 4096 -C "user@pass"
github_cp:
	cat .ssh/id_rsa.pub

github_workouts: 
	ssh-agent bash -c 'ssh-add /home/ubuntu/id_rsa_py; git clone git@github.com:mbaglieri/david_bknd.git'

