ME=$(USER)
all: build init up

clean: stop rm
#	sudo chown -R $(ME):$(ME) ./plutof-taxonomy-module
#	sudo chown -R $(ME):$(ME) ./pg-init

init:
	@echo "Installing db schema and running tests"
	docker-compose up -d db es
	sleep 10
	docker-compose up -d web
	docker exec dwclassifications_web_1 make install
	docker exec dwclassifications_web_1 python manage.py collectstatic --noinput
	docker exec dwclassifications_web_1 sh -c "cat /code/add_oauth2_client.py | python manage.py shell"
#	docker exec dwclassifications_web_1 make test 2>&1 | tee -a tests.log
	docker-compose stop

data:
	@echo "Pls use these credentials to upload data, a manual mod of the upload script is req for now..."
	PGPASSWORD=taxonomy psql -h localhost -U taxonomy taxonomy -c "select name, client_id, client_secret from oauth2_client;"
	python ./plutof-conf/csv_batch_upload.py -t 1 -r 1 -b http://localhost:7000 ./plutof-data/lepidoptera.tsv
	docker exec dwclassifications_web_1 sh -c "python manage.py populate_edge_list 1"
	docker exec dwclassifications_web_1 sh -c "python manage.py populate_pre_traversal"
	@echo "When browsing tree, clicking the root node doesn't list the children?"
	firefox http://localhost:7000/api/taxonomy/tree/1/

test:
	./plutof-conf/curl_test.sh
	
build:
	@echo "Pulling latest sources from the Pluto-F Taxonomy module"
	git clone --depth=1 https://github.com/TU-NHM/plutof-taxonomy-module
	docker-compose build --no-cache web

up:
	docker-compose up -d db es
	sleep 10
	docker-compose up -d web
	sleep 5
	firefox http://localhost:7000

stop:
	docker-compose stop

rm:
	docker-compose rm -vf
	rm -rf plutof-taxonomy-module
