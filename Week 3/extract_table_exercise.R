library(pdftools)
library(stringr)

txt = pdf_text("../data/wk3_cpi2023.pdf")
txt
page7 = txt[7] %>%
  str_split("\n", simplify=TRUE)

table1_headers = page7[5] %>%
  str_split("\\s{2,}", simplify=TRUE)
table1_headers[4] = str_c(table1_headers[4], " Accomodation")
table1_headers[5] = str_c(table1_headers[5], " OOA")
table1_headers[8] = str_c(table1_headers[8], " Other Goods")
table1_headers[9] = str_c(table1_headers[9], " & Gas")
table1_headers[10] = str_c(table1_headers[10], " Transport")
table1_headers[11] = str_c(table1_headers[11], "dation")
table1_headers

table1 = page7[9:22] %>%
  str_split("\\s{2,}", simplify=TRUE) %>%
  data.frame() %>%
  select(-1) %>%
  mutate_at(-1, parse_number) %>%
  setNames(table1_headers)

view(table1)



page8 = txt[8] %>%
  str_split("\n", simplify=TRUE)
  
table2 = page8[9:22] %>%
  str_split("\\s{3,}", simplify=TRUE) %>%
  data.frame() %>%
  mutate_at(-1, parse_number) %>%
  setNames(table1_headers)
view(table2)