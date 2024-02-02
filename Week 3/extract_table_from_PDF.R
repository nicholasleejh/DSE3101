library(pdftools)
library(tidyverse)

txt = pdf_text("../data/wk3_pnas.pdf")
txt
tables = txt[2] # Second page
tables

# Vector of each line in page 2
tabs = str_split(tables, "\n", simplify=TRUE) %>%
  # Trim leading spaces
  str_trim()
tabs

### TABLE 1 ###
tabs[3] # Table 1 group headers
names1 = tabs[3] %>%
  # Remove ", _"
  str_replace_all(",\\s.", "") %>%
  # Split when there are 2 or more spaces
  str_split("\\s{2,}", simplify=TRUE)
names1

tabs[5] # Table 1 column headers
names2 = tabs[5] %>%
  str_split("\\s+", simplify=TRUE)
names2

names3 = str_c(rep(names1, each=3), names2[-1], sep="_")
names3

colnames = c(names2[1], names3) %>%
  str_to_lower() %>%
  str_replace_all("\\s", "_")
colnames

table_s1 = tabs[7:16] %>%
  str_split("\\s{2,}", simplify=TRUE) %>%
  data.frame() %>%
  setNames(colnames) %>%
  # Convert cols into numeric except col 1
  mutate_at(-1, parse_number)
table_s1
str(table_s1)


### TABLE 2 ###
names4 = tabs[24] %>%
  str_replace_all(",\\s.", "") %>%
  str_split("\\s{2,}", simplify=TRUE)

names5 = tabs[26] %>%
  str_split("\\s{2,}", simplify=TRUE)

names6 = str_c(rep(names4, each=3), names5[-1], sep="_")

colnames2 = c(names5[1], names6) %>%
  str_to_lower() %>%
  str_replace_all("\\s", "_")

table_s2 = tabs[28:30] %>%
  str_split("\\s{2,}", simplify=TRUE) %>%
  data.frame() %>%
  setNames(colnames2) %>%
  mutate_at(-1, parse_number)
table_s2