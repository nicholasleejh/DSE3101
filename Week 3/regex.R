library(readr)
library(stringr)
txt = read_file("../data/wk3_nasa.txt")
txt

str_extract_all(txt, "[0-9]+") # numbers with 2 or more digits
str_extract_all(txt, "\\$[,0-9]+") # comma or 0-9
str_extract_all(txt, "\\([0-9]+\\)")
str_extract_all(txt, "\\(\\d\\)") # \\d any digit

str_split(txt, "\\n")
str_split(txt, "\\n")[[1]][3:11]

items = str_extract_all(txt, "\\(\\d\\).+\\.")[[1]] # (digit)__________.
items

for_items = str_match(items, "For\\s(.+),\\s\\$") # For ________ $
for_items
for_items[1]
for_items[, 2]
for_items = for_items[, 2]
for_items

money = str_match(items, "\\$([,\\d]+)")
money
money = money[, 2]
money
money = as.numeric(str_replace_all(money, ",", ""))
money

data.frame(purpose=for_items, amount=money)
