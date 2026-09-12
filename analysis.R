# Loading Libraries
library(ggplot2)
library(dplyr)
library(tidyr)
getwd()
# Loading Dataset
netflix <- read.csv("data/netflix_titles.csv", stringsAsFactors = FALSE)

# Inspect data
if (interactive()) {
  View(netflix)
}
str(netflix)
summary(netflix)

# Histogram of release year
ggplot(netflix, aes(x = release_year)) +
  geom_histogram(binwidth = 3, fill = "blue", colour = "black") +
  scale_x_continuous(breaks = seq(1920, 2025, by = 10)) +
  labs(
    title = "Distribution of Netflix Content by Release Year",
    x = "Release Year",
    y = "Count"
  ) + 
  theme_minimal()

ggsave("images/histogram.png")


# Movies vs TV Shows 
ggplot(netflix, aes(x = type)) +
  geom_bar(fill = "steelblue", colour = "black") +
  geom_text(stat = "count", aes(label = after_stat(count)), vjust = -0.5) +
  labs(title = "Movies vs TV Shows",
       x = "Content Type",
       y = "Count"
  ) + 
  theme_minimal()

ggsave("images/movies_vs_tv.png")

# Count content per year 
year_data <- netflix %>% 
  group_by(release_year) %>%
  summarise(count = n(), .groups = "drop")

ggplot(year_data, aes(x = release_year, y = count)) +
  geom_line(color = "blue", linewidth =  1) +
  scale_x_continuous(breaks = seq(1920, 2025, by = 10)) +
  labs(
    title = "Titles by Release Year",
    x = "Release Year",
    y = "Number of Titles"
  ) +
  theme_minimal()

ggsave("images/growth_over_time.png")

# Movies vs TV per year
type_year <- netflix %>%
  count(release_year, type, name = "count") %>%
  complete(
    release_year = seq(
      min(netflix$release_year),
      max(netflix$release_year)
    ),
    type,
    fill = list(count = 0)
  )

ggplot(netflix, aes(x = type, y = release_year, fill = type)) +
  geom_violin() +
  geom_boxplot(width = 0.2, alpha = 0.5) +
  scale_y_continuous(breaks = seq(1920, 2025, by = 10)) +
  labs(
    title = "Distribution of Release Years by Content Type",
    x = "Content Type",
    y = "Release Year"
  ) +
  guides(fill = "none") +
  theme_minimal()

ggsave("images/distribution_content_type.png")

type_year_plot <- ggplot(
  type_year,
  aes(x = release_year, y = count, colour = type)
) + 
  geom_line(linewidth = 1) +
  scale_x_continuous(breaks = seq(1920, 2020, by = 10)) +
  labs(
    title = "Movies and TV Shows by Release Year",
    x = "Release Year",
    y = "Number of Titles",
    colour = "Content Type",
    colour = "Content Type",
    caption = paste(
      "Historical Netflix dataset through September 2021; 2021 is incomplete.",
      "Counts relect original release years, not catalogue growth.",
      sep = "\n"
    )
  ) + 
  theme_minimal()

print(type_year_plot)

ggsave(
  "images/movies_vs_tv_growth.png",
  plot = type_year_plot,
  width = 10,
  height = 6,
  dpi = 300,
  bg = "white"
)

# Top categories: each title can belong to multiple categories
netflix_categories <- netflix %>% 
  separate_rows(listed_in, sep = ",") %>%
  mutate(listed_in = trimws(listed_in)) %>%
  filter(!is.na(listed_in), listed_in != "")

top_categories <- netflix_categories %>% 
  count(listed_in, sort = TRUE) %>% 
  slice_head(n = 10)

category_plot <- ggplot(
  top_categories,
  aes(x = reorder(listed_in, n), y = n)
) + 
  geom_col(fill = "steelblue") + 
  coord_flip() +
  labs(
    title = "Top 10 Categories in the Netflix Dataset",
    subtitle = "Titles can appear in more than one category",
    x = NULL,
    y = "Number of Titles",
    caption = "Historical dataset with recorded additions through September 2021"
  ) + 
  theme_minimal(base_size = 12)

print(category_plot)

ggsave(
  "images/genres.png",
  plot = category_plot,
  width = 10,
  height = 6,
  dpi = 300,
  bg = "white"
  
)

# Country analysis
netflix_country <- netflix %>%
  filter(!is.na(country), country != "") %>%
  separate_rows(country, sep = ", ")

netflix_country$country <- trimws(netflix_country$country)

top_countries <- netflix_country %>%
  count(country) %>%
  arrange(desc(n)) %>%
  head(5)

country_year <- netflix_country %>% 
  filter(country %in% top_countries$country) %>%
  group_by(release_year, country) %>%
  summarise(count = n(), .groups = "drop")

ggplot(country_year, aes(x = release_year, y = count, colour = country)) +
  geom_line(linewidth = 1.2) +
  scale_x_continuous(breaks = seq(1920, 2025, by = 10)) +
  labs(
    title = "Titles by Release Year for Top Credited Countries",
    x = "Release Year",
    y = "Number of Titles",
    colour = "Country"
  ) +
  theme_minimal()

ggsave("images/country_growth.png")




