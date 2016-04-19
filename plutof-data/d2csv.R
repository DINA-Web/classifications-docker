library("xml2")
library("dplyr")
library("purrr")

base <- "~/repos/dina-web/dw-classifications/plutof-data/"
header <- readLines(paste0(base, "header.xml"))
footer <- readLines(paste0(base, "0.xml"), warn = FALSE)[-c(1:5)]
doc <- paste(collapse = "\n", c(header, footer))

# parse Dyntaxa XML tree using xpath expressions for nodes and their parents
xml <- read_xml(doc)
ns <- xml_ns(xml)
taxa <- xml_find_all(xml, "//a:Taxon/a:Id/..", ns)

xml2int <- function(x) 
  as.numeric(xml_text(x))

get_taxon_id <- function(xml) 
  xml2int(xml_find_all(xml, "./a:Id", ns))

ids <- map(taxa, get_taxon_id)

get_parent <- function(xml) 
  xml2int(xml_find_all(xml, "../../../a:Taxon/a:Id", ns))

parents <- map(taxa, get_parent)

links <-
  data_frame(
    Id = as.numeric(ids), 
    Parent = as.numeric(parents)) %>%
  distinct 

out <- paste0(base, "biota-tree.csv")
write.csv(links, file = out, row.names = FALSE)

links <- read.csv(file = out)

# combine tree relations and node data into one dataset
nodes <- tbl_df(read.csv(file = paste0(base, "biota.tsv"), 
 header = TRUE, sep = "\t", stringsAsFactors = FALSE, encoding = "utf8"))


#TODO: NA-värden i join-kolumn?

nodelink <- 
  nodes %>% mutate(Id = as.numeric(Id)) %>%
  left_join(links, by = "Id") %>%
  select(Parent, Id, everything())

out <- paste0(base, "biota_2.csv")
write.csv(nodelink, file = out, row.names = FALSE)

tsv <- 
  nodelink %>%
  select(taxon_id = Id, parent_taxon_id = Parent, taxon_rank_id = CategoryId, 
         epithet = ScientificName, author = Author, code = Guid, CommonName) %>%
  mutate(CommonName = trimws(CommonName)) %>%
  mutate(use_parentheses = ifelse(grepl("(", author, fixed = TRUE), 1, NA)) %>%
  mutate(year = as.integer(gsub(".*?(\\d{1,4}).*", "\\1", perl = TRUE, author))) %>%
  mutate(vernacular_names = ifelse(is.na(CommonName) | CommonName == "", NA, paste0(CommonName, ":swe")))

v <- gsub("[()\\]\\[]", "", tsv$author, perl = TRUE)
a <- gsub(",*\\s*\\[*\\d{4}\\]*", "", v, perl = TRUE)
tsv$author <- a

plutof <- 
  tsv %>%
  select(taxon_id, parent_taxon_id, taxon_rank_id, epithet, 
         author, year, code, vernacular_names, use_parentheses) %>%
  # TODO: ask Kessy to support taxon_rank_id = 0 in the load script
  mutate(taxon_rank_id = ifelse(taxon_rank_id == 0, 1, taxon_rank_id)) %>%
  arrange(taxon_rank_id, taxon_id, parent_taxon_id)

# 3000188	0	40	Lepidoptera	Linnaeus	1758	3000188	fjärilar:swe	
# 2002975	3000188	48	Hesperioidea	Latreille	1809	2002975	tjockhuvudfjärilar:swe	

plutof$parent_taxon_id[which(is.na(plutof$parent_taxon_id))] <- 0

out <- paste0(base, "0.tsv")
write.table(plutof, file = out, sep = "\t", 
            row.names = FALSE, na = "", quote = FALSE)