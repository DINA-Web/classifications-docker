ID = 5000013

all: dl tsv

dl:
	@echo "Downloading from Dyntaxa for ID = $(ID)"
	python dyntaxa.py --id $(ID)

attribs:
	@echo "Extracting taxon attribs"
	@cp $(ID).xml dyntaxa.xml
	@./d2csv.sh $(ID)
	@cp $(ID).csv attribs.csv

tsv: attribs
	@echo "Creating tsv"
	@Rscript ./d2csv.R
	@rm attribs.csv dyntaxa.xml tree.csv dyntaxa.csv $(ID).csv

clean:
	@rm dyntaxa.tsv
