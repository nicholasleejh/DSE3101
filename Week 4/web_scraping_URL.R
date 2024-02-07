library(zoo)
library(rvest)
library(tidyverse)
library(lubridate)
library(readr)

################################################################################
# Download directly
df_solar = read.csv("../data/SolarPVInstallationsbyURAPlanningRegion.csv")
head(df_solar)

# CSV from URL
url = "https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-states.csv"
df_covid = read_csv(url) %>%
  mutate(date = ymd(date),
         state = factor(state))
head(df_covid)

# Recover daily count from cumulative sums
df_covid = df_covid %>%
  group_by(state) %>%
  mutate(new_cases = cases - lag(cases),
         new_cases = replace_na(new_cases, 0)) %>%
  group_by(date) %>%
  summarise(total_new_cases = sum(new_cases))
tail(df_covid)

# 7 day moving average
df_7days_avg = df_covid %>%
  mutate(avg_7day = rollmean(total_new_cases, k=7, align='right', fill=0))
df_7days_avg

df_7days_avg %>%
  filter(date >= "2023-03-01", date <= "2023-03-07") # Filter out first 7 days of 0

################################################################################
wiki_url = "https://en.wikipedia.org/wiki/Women%27s_100_metres_world_record_progression"

# Find all HTML tables on the page
tables = read_html(wiki_url) %>%
  html_elements("table") # <table>

# Number of tables available
length(tables)

# Convert second table into tibble
records = tables[[2]] %>%
  html_table()
head(records)

# Use CSS selector to target table
records = read_html(wiki_url) %>%
  html_element("#mw-content-text > div.mw-content-ltr.mw-parser-output > table:nth-child(9)") %>%
  html_table()
head(records)

################################################################################
labour_url = "https://www.ncsl.org/research/labor-and-employment/national-employment-monthly-update.aspx"

labour_tables = read_html(labour_url) %>%
  # This doesn't work because it's an embedded table
  # html_element("#dnn_ctr5945_ModuleContent > div > div > div > div > table") %>%
  html_elements("table")
html_table(labour_tables[[1]])

################################################################################
sg_url = "https://en.wikipedia.org/wiki/Demographics_of_Singapore"

read_html(sg_url) %>%
  html_element("#mw-content-text > div.mw-content-ltr.mw-parser-output > table:nth-child(53)") %>%
  html_table()

read_html(sg_url) %>%
  html_element("#mw-content-text > div.mw-content-ltr.mw-parser-output > table:nth-child(126)") %>%
  html_table()

################################################################################
starwars_url = "https://rvest.tidyverse.org/articles/starwars.html"

#Extract the element named "section"
sections = read_html(starwars_url) %>%
  html_elements("section")

#Number of sections on the page
length(sections)

# Movie titles <h2>
sections %>%
  html_element("h2") %>%
  html_text2()

# Directors <span class="director">
sections %>%
  html_element(".director") %>%
  html_text2()

# Release date
sections %>%
  html_element("p") %>%
  html_text2() %>%
  str_remove("Released: ") %>%
  parse_date()

# Combine into a tibble
starwars_df = tibble(
  title = sections %>% html_element("h2") %>% html_text2(),
  release_date = sections %>% html_element("p") %>% html_text2() %>%
    str_remove("Released: ") %>% parse_date(),
  director = sections %>% html_element(".director") %>% html_text2()
)
starwars_df