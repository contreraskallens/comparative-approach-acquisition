library(tidyverse)
library(wesanderson)

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

all.db <- bind_rows(childes, many.babies, word.bank, isbilen, slobin)

# Match to language data ----

lang.key <- read_csv("processed_data/language_data.csv")

all.db <- left_join(all.db, lang.key) %>% 
  select(-In_DB) %>% 
  filter(!(is.na(Language)))

# Recode family and genus data ----

recoded.db <- all.db %>% 
  mutate(Family = ifelse(Family == "English", Family,
                         ifelse(Family == "Indo-European", "Other Indo-European", "Non-Indo-European")),
         Genus = ifelse(Genus %in% c("English", "Germanic", "Romance"), Genus, "Other"))

# Plot genus data ----

genus.db <- recoded.db %>% 
  group_by(db, Genus) %>% 
  summarize(Count = sum(Count))
genus.db$Genus <- factor(genus.db$Genus, levels = c("Other", "Romance", "Germanic", "English"))
                           
genus.plot <- ggplot(genus.db, aes(x = db, y = Count, fill = Genus, group = Genus)) +
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
  group_by(db, Family) %>% 
  summarize(Count = sum(Count))
family.db$Family <- factor(family.db$Family, levels = c("Non-Indo-European", "Other Indo-European", "English"))

family.plot <- ggplot(family.db, aes(x = db, y = Count, fill = Family, group = Family)) +
  geom_bar(stat = "identity", position = "fill") +
  scale_fill_manual(name = "Language Group", values = wesanderson::wes_palette("Darjeeling1", n = 4, type = "discrete")) +
  theme_minimal() +
  labs(y = "Proportion") +
  theme(panel.grid.major.x = element_blank(),
        axis.title.x = element_blank())

family.plot
ggsave(plot = family.plot, filename = "figures/family_plot.png", dpi = 300, bg = "white", 
       width = 2000, height = 800, units = "px") 

# Generate paper plot. DO THIS ONLY IF YOU HAVE KIDD & GARCIA DATA ----

kidd.garcia <- read_csv("raw_data/kidd_tallies.csv") %>% 
  mutate(db = "Articles")
  
paper.db <- bind_rows(recoded.db, kidd.garcia) %>% 
  filter(db %in% c("Babies", "Words", "Articles")) %>% 
  group_by(db, Family) %>% 
  summarize(Count = sum(Count))
paper.db$Family <- factor(paper.db$Family, levels = c("Non-Indo-European", "Other Indo-European", "English"))
paper.db$db <- factor(paper.db$db, levels = c("Words", "Babies", "Articles"))

paper.plot <- ggplot(paper.db, aes(x = db, y = Count, fill = Family, group = Family)) +
  geom_bar(stat = "identity", position = "fill") +
  theme_minimal() +
  labs(y = "Proportion") +
  scale_fill_manual(name = "Language Group", values = wesanderson::wes_palette("Darjeeling1", n = 4, type = "discrete")) +
  theme(axis.title.x = element_blank(), panel.grid.major.x = element_blank())
paper.plot
ggsave(plot = paper.plot, filename = "figures/cdps_family_small.png", dpi = 300, bg = "white", 
       width = 5, height = 2.5) 
ggsave(plot = paper.plot, filename =  "figures/cdps_family.png", bg = "white", dpi = 1000,
       width = 7.47, height = 4.59)
ggsave(plot = paper.plot, filename =  "figures/cdps_family.pdf", bg = "white", dpi = 1000,
       width = 7.47, height = 4.59)
