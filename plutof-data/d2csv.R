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

links <- tbl_df(read.csv(file = out)

# combine tree relations and node data into one dataset
nodes <- tbl_df(read.csv(file = paste0(base, "biota.csv"), 
 header = TRUE, sep = "\t", stringsAsFactors = FALSE, encoding = "utf8"))


#TODO: NA-värden i join-kolumn?
oops <- 
  nodes %>% mutate(IntId = as.numeric(Id)) %>%
  arrange(desc(is.na(IntId))) %>% 
  select(Id, IntId, ScientificName, everything())
oops

nodelink <- 
  nodes %>% mutate(Id = as.numeric(Id)) %>%
  filter(!is.na(Id)) %>%
  left_join(links, by = "Id") %>%
  select(Parent, Id, everything())

out <- paste0(base, "biota_2.csv")
write.csv(nodelink, file = out, row.names = FALSE)
nodelink <- tbl_df(read.csv(file = out))

tsv <- 
  nodelink %>% 
  select(taxon_id = Id, parent_taxon_id = Parent, 
         taxon_rank_id = CategoryId,
         epithet = ScientificName, author = Author, 
         code = Guid, CommonName) %>%
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
         author, year, code, vernacular_names, use_parentheses) #%>%
  # TODO: ask Kessy to support taxon_rank_id = 0 in the load script
  # the 200 below would require a rank_dict entry in csv_batch-upload.py which says 200:5
#  mutate(taxon_rank_id = ifelse(taxon_rank_id == 0, 200, taxon_rank_id)) %>%
  # should order by / arrange by the PlutoF order - join on the rank_dict and order on the right number (not left)
#  arrange(taxon_rank_id, taxon_id, parent_taxon_id)


# NOTE: translate dyntaxa ranks to plutof ranks

# this is copy/pasted from the csv_upload_batch.py script
rank_dict <-
  '{"1": "10", "2": "20", "3": "23", "4": "28", "5": "30", "6": "33", "7": "38",
  "8": "40", "9": "43", "10": "48", "11": "50", "12": "53", "13": "55",
  "14": "60", "15": "63", "16": "65", "17": "70", "18": "73", "19": "74",
  "20": "76", "21": "100", "22": "90", "25": "34", "27": "67", "28": "67",
  "29": "44", "30": "35", "31": "36", "32": "84", "33": "47", "35": "13",
  "37": "14", "38": "18", "39": "24", "41": "37", "44": "56", "49": "69",
  "50": "72"}'

enums <-
  '{"kingdom": "10", "phylum": "20", "subphylum": "23", "superclass": "28",
  "class": "30", "subclass": "33", "superorder": "38", "order": "40",
  "suborder": "43", "superfamily": "48", "family": "50", "subfamily": "53",
  "tribe": "55", "genus": "60", "subgenus": "63", "section": "65",
  "species": "70", "subspecies": "73", "variety": "74", "form": "76",
  "hybrid": "100", "cultivar": "90", "infraclass": "34", "group_genus": "67",
  "infraorder": "44", "division": "35", "subdivision": "36", "morph": "84",
  "subkingdom": "13", "infrakingdom": "14", "superphylum": "18",
  "infraphylum": "24", "infradivision": "37", "subtribe": "56",
  "aggregate": "69", "microspecies": "72", "section": "47"}'

pairs <- unlist(strsplit(rank_dict, ","))
re <- ".*\\s*\"(\\d+)\":\\s*\"(\\d+)\".*"
left <- as.numeric(gsub(re, "\\1", pairs))
right <- as.numeric(gsub(re, "\\2", pairs))

pairs <- unlist(strsplit(enums, ","))
re <- ".*\\s*\"(.+)\":\\s*\"(\\d+)\".*"
rank_desc <- gsub(re, "\\1", pairs)
rank_id <- as.numeric(gsub(re, "\\2", pairs))

pf_ranks <- 
  data_frame(taxon_rank_id = left, plutof_rank_id = right) %>% 
  right_join(data_frame(rank_desc, plutof_rank_id = rank_id))

# add biota rank
pf_ranks <- 
  data_frame(
    taxon_rank_id = 0, 
    plutof_rank_id = 5, 
    rank_desc = "superkingdom") %>% 
  bind_rows(pf_ranks)  

missing_ranks_report <- 
  plutof %>% 
  left_join(pf_ranks) %>%
#  filter(epithet == "Biota") 
  filter(is.na(plutof_rank_id)) %>% 
  distinct(taxon_rank_id, plutof_rank_id, rank_desc, taxon_id) %>%
  select(epithet, taxon_rank_id, plutof_rank_id, rank_desc, taxon_id)

res <-
  plutof %>% 
  left_join(pf_ranks) %>%
  filter(!is.na(plutof_rank_id))

# NOTE: DONT IGNORE: the first parent_id should be 1
#plutof$parent_taxon_id[which(is.na(plutof$parent_taxon_id))] <- 0
res[which(is.na(res$parent_taxon_id)), ]$parent_taxon_id <- 1


res <- 
  res %>%
  arrange(plutof_rank_id, taxon_id, parent_taxon_id) %>%
  select(-taxon_rank_id, -rank_desc) %>%
  rename(taxon_rank_id = plutof_rank_id) %>%
  select(taxon_id, parent_taxon_id, taxon_rank_id, everything())

# 3000188	0	40	Lepidoptera	Linnaeus	1758	3000188	fjärilar:swe	
# 2002975	3000188	48	Hesperioidea	Latreille	1809	2002975	tjockhuvudfjärilar:swe	

out <- paste0(base, "00.tsv")
write.table(res, file = out, sep = "\t", 
  row.names = FALSE, na = "", quote = FALSE)