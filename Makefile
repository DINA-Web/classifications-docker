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

ul-biota:
	@echo "Packaging and uploading Dyntaxa biota dataset to Internet Archive"
	cd plutof-data/ && tar cvfz ../biota.tsv.gz biota.tsv && cd ..
	ia upload dw-classifications-data biota.tsv.gz --metadata="title:DINA-Web Classifications Data"
	rm biota.tsv.gz
	firefox https://archive.org/details/dw-classifications-data &

dl-biota:
	@echo "Downloading DINA-Web Classifications Datasets using wget"
	wget http://archive.org/download/dw-classifications-data/biota.tsv.gz -O biota.tsv.gz
	gunzip biota.tsv.gz
	mv biota.tsv plutof-data

dyntaxa-tree:
	./create_dyntaxa_tree.sh

data: dl-biota dyntaxa-tree
	@echo "Creating dyntaxa tree"
	python ./plutof-conf/csv_batch_upload.py -t 1 -r 1 -b http://localhost:7000 ./plutof-data/biota.tsv
	docker exec dwclassifications_web_1 sh -c "python manage.py populate_edge_list 1"
	docker exec dwclassifications_web_1 sh -c "python manage.py populate_pre_traversal"
	@echo "When browsing tree, clicking the root node doesn't list the children?"
	firefox http://localhost:7000/api/taxonomy/tree/1/

test:
	./plutof-conf/curl_test.sh

build-cli:
	@echo "builds cli"
	docker-compose build --no-cache cli

export-dyntaxa:
	docker-compose run cli

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
