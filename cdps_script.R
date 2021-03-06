library(tidyverse)
library(wesanderson)
library(childesr)

# Load all processed data ----

childes <- read_csv("processed_data/childes_utterance_stats.csv") %>% 
  mutate(db = "Words") %>% 
  select(-num_utterances) %>% 
  rename(In_DB = first_lang,
         Count = tokens)
many.babies <- read_csv("processed_data/many_babies.csv") %>% 
  mutate(db = "Babies") %>% 
  rename(In_DB = lang1) 

word.bank <- read_csv("processed_data/wordbank_data.csv") %>% 
  mutate(db = "WordBank") %>% 
  rename(In_DB = language,
         Count = n)

isbilen <- read_csv("raw_data/isbilen_tallies.csv") %>% 
  mutate(db = "Isbilen 2021") %>% 
  rename(In_DB = Language)

slobin <- read_csv("raw_data/slobin_tallies.csv") %>% 
  mutate(db = "Slobin 2014") %>% 
  rename(In_DB = Language)

kidd_garcia <- read_csv("raw_data/kidd_garcia_tallies.csv") %>% 
  mutate(db = "KiddGarcia 2021") %>% 
  rename(In_DB = Language)

all.db <- bind_rows(childes, many.babies, word.bank, isbilen, slobin, kidd_garcia)

# Match to language data ----

lang.key <- read_csv("processed_data/language_key.csv") %>% 
  distinct()
wals.info <- read_csv("processed_data/wals_info.csv") %>% 
  select(iso_code, Name, genus, family) %>% 
  arrange(Name) %>%  # Preserve only first combination to avoid duplicate matches
  distinct(iso_code, genus, family, .keep_all = TRUE)
all.db <- left_join(all.db, lang.key) %>% 
  select(-In_DB) %>% 
  filter(!(is.na(iso_code))) %>% 
  left_join(wals.info)

# Hand-coded languages not in WALS gotten from Glottolog

not.in.wals <- filter(all.db, is.na(genus)) %>% 
  select(-Name, -genus, -family)
not.wals.key <- read_csv("processed_data/not_in_wals.csv")
not.in.wals <- left_join(not.in.wals, not.wals.key)
all.db <- filter(all.db, !(is.na(genus))) %>% 
  bind_rows(not.in.wals)

# Recode family and genus data ----

recoded.db <- all.db %>% 
  mutate(family = ifelse(Name == "English", "English",
                         ifelse(family == "Indo-European", "Other Indo-European", "Non-Indo-European")),
         genus = ifelse(Name == "English", "English", 
                        ifelse(genus %in% c("English", "Germanic", "Romance"), genus, "Other")))


# Plot genus data ----

genus.db <- recoded.db %>% 
  group_by(db, genus) %>% 
  summarize(Count = sum(Count))
genus.db$genus <- factor(genus.db$genus, levels = c("Other", "Romance", "Germanic", "English"))
                           
genus.plot <- ggplot(genus.db, aes(x = db, y = Count, fill = genus, group = genus)) +
  geom_bar(stat = "identity", position = "fill") +
  scale_fill_manual(name = "Language Group", values = wes_palettes$Darjeeling1[c(1,2,3,5)]) +
  theme_minimal() +
  labs(y = "Proportion") +
  theme(panel.grid.major.x = element_blank(),
        axis.title.x = element_blank())
genus.plot
ggsave(plot = genus.plot, filename = "figures/genus_plot.png", dpi = 300, bg = "white", 
       width = 2000, height = 800, units = "px")   

# Do it with families now ----

family.db <- recoded.db %>% 
  group_by(db, family) %>% 
  summarize(Count = sum(Count))
family.db$family <- factor(family.db$family, levels = c("Non-Indo-European", "Other Indo-European", "English"))

family.plot <- ggplot(family.db, aes(x = db, y = Count, fill = family, group = family)) +
  geom_bar(stat = "identity", position = "fill") +
  scale_fill_manual(name = "Language Group", values = wesanderson::wes_palette("Darjeeling1", n = 4, type = "discrete")) +
  theme_minimal() +
  labs(y = "Proportion") +
  theme(panel.grid.major.x = element_blank(),
        axis.title.x = element_blank())

family.plot
ggsave(plot = family.plot, filename = "figures/family_plot.png", dpi = 300, bg = "white", 
       width = 2000, height = 800, units = "px") 

# Generate paper plot ----

paper.db <- recoded.db %>% 
  filter(db %in% c("Babies", "Words", "KiddGarcia 2021")) %>% 
  mutate(db = ifelse(db == "KiddGarcia 2021", "Articles", db)) %>% 
  group_by(db, genus) %>% 
  summarize(Count = sum(Count))
paper.db$genus <- factor(paper.db$genus, levels = c("Other", "Romance", "Germanic", "English"))
paper.db$db <- factor(paper.db$db, levels = c("Words", "Babies", "Articles"))

paper.plot <- ggplot(paper.db, aes(x = db, y = Count, fill = genus, group = genus)) +
  geom_bar(stat = "identity", position = "fill") +
  theme_minimal() +
  labs(y = "Proportion") +
  scale_fill_manual(name = "Language Group", values = wes_palettes$Darjeeling1[c(1,2,3,5)]) +
  theme(axis.title.x = element_blank(), panel.grid.major.x = element_blank())
paper.plot
ggsave(plot = paper.plot, filename = "figures/cdps_genus_small.png", dpi = 300, bg = "white", 
       width = 5, height = 2.5) 
ggsave(plot = paper.plot, filename =  "figures/cdps_genus.png", bg = "white", dpi = 1000,
       width = 7.47, height = 4.59)
ggsave(plot = paper.plot, filename =  "figures/cdps_genus.pdf", bg = "white", dpi = 1000,
       width = 7.47, height = 4.59)

# Print percentages of families per database ----

# Show number of CHILDES corpora

nrow(childesr::get_corpora())

paper.db %>% 
  group_by(db) %>% 
  mutate(Count = (Count / sum(Count)) * 100)
