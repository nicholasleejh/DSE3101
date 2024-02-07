library(gtrendsR)
library(tidyverse)
library(httr)
library(jsonlite)
library(lubridate)

################################################################################
res = gtrends(keyword = "christmas",
              geo = c("SG", "JP", "KR"),
              time = "today 12-m")
plot(res)

#Queries by region
res[["interest_by_region"]] %>%
  mutate(location= fct_reorder(factor(location),hits)) %>%
  group_by(geo) %>% top_n(10,hits) %>%
  ggplot(aes(x= location,y= hits, fill= geo)) +
  geom_col(show.legend= FALSE) +
  coord_flip() +
  facet_wrap(~ geo, scales= "free")

# The most popular related topics in Singapore
res[["related_queries"]] %>%
  filter(related_queries == "top",geo == "SG") %>%
  mutate(subject= as.numeric(subject),
         value = fct_reorder(factor(value),subject)) %>%
  top_n(10, subject) %>%
  ggplot(aes(x= value, y= subject)) +
  geom_col() +
  coord_flip()

################################################################################
# Construct the resource URL
base_url = "http://api.open-notify.org"
endpoint = "/astros.json"
resource_url = paste0(base_url, endpoint)

# Send request
res = GET(resource_url)
res
res$status_code

# Get content as text
res_content = content(res, as = "text")
res_content

# Parse (JSON) text into table
res_list = fromJSON(res_content, flatten = TRUE)
res_list
res_list$people

# Convert table into tibble
df_astros = as_tibble(res_list$people)
df_astros

################################################################################
# Construct the resource URL
base_url = "https://api.data.gov.sg/v1"
endpoint = "/environment/pm25"
resource_url = paste0(base_url, endpoint)

# Store query parameters
query_params = list("date" = "2024-02-07")
# Make the request and specify the query parameters
res = GET(resource_url, query = query_params)

# Wrap data from the response
res_text = content(res, type = "text")

# Pass the JSON object to from JSON
res_list = fromJSON(res_text, flatten = TRUE)
class(res_list)

# Extract useful data
df_pm25 <- as_tibble(res_list$items)
str(df_pm25)

# Tidy up tibble
df_pm25 <-df_pm25 %>%
  mutate(timestamp = ymd_hms(timestamp, tz= Sys.timezone()),
         hour = hour(timestamp)) %>%
  select(-update_timestamp) %>%
  rename(west= 2, east= 3,central=4, south= 5,north= 6) %>%
  pivot_longer(west:north, names_to ="region", values_to= "pm25")
head(df_pm25)

################################################################################
# https://fred.stlouisfed.org/docs/api/fred/series_observations.html

# Set API key as envrionment variable (in console)
# Sys.setenv(FRED_KEY = "abcdefghijklmnopqrstuvwxyz0123456789")

# Get API key (in console)
# Sys.getenv("FRED_KEY")

base_url = "https://api.stlouisfed.org"
endpoint = "/fred/series/observations"
resource_url = paste0(base_url, endpoint)
query_params = list(api_key = Sys.getenv("FRED_KEY"),
                    series_id= "UNRATE",
                    file_type= "json")

# Request data from the server
res = GET(resource_url, query= query_params)
# Check status code
res$status_code

# Extract the contents into JSON text
res_list = content(res, type = "text") %>%
  fromJSON(flatten = TRUE)
# Convert data into tibble
unrate = as_tibble(res_list$observations)
unrate

# Clean up data
unrate = unrate %>%
  mutate(date = ymd(date), value = as.numeric(value)) %>%
  select(date, value)
tail(unrate)

# Graph it
ggplot(unrate, aes(x=date, y=value)) +
  geom_line(lwd = 1.5) +
  labs(x="", y="Percent",
       title="Unemploymentrate",
       caption="Source: U.S.Bureau ofLaborStatistics")

################################################################################
base_url = "https://api.stlouisfed.org"
endpoint = "/fred/series/observations"
resource_url = paste0(base_url, endpoint)
query_params = list(api_key=Sys.getenv("FRED_KEY"),
                    series_id="MEHOINUSA672N",
                    file_type="json")
res = GET(resource_url, query=query_params)
res$status_code

# Extract the contents into JSON text
res_list = content(res, type = "text") %>%
  fromJSON(flatten = TRUE)
# Convert data into tibble
income_df = as_tibble(res_list$observations)
income_df

# Clean up data & graph it
income_df %>%
  mutate(realtime_start=ymd(realtime_start), realtime_end=ymd(realtime_end), date=ymd(date), value=as.numeric(value)) %>%
  ggplot(aes(x=date, y=value)) +
  geom_line()

################################################################################
resource_url = "http://datamall2.mytransport.sg/ltaodataservice/CarParkAvailabilityv2"
res = GET(resource_url, add_headers(AccountKey = Sys.getenv("LTA_KEY"), accept = "application/json"))
res$status_code

res_list = content(res, type="text") %>%
  fromJSON(flatten=TRUE)

df = as_tibble(res_list$value)
df