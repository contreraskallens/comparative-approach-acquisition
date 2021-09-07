library(childesr)
library(tidyverse)
library(wordbankr)

# Get CHILDES data, summarize number of tokens and write to file to update language information manually ----

all_corpora <- get_corpora() # For reference

all_utterances <- get_utterances() # Commented out because it takes a while to run

utterance_stats <- all_utterances %>%
  filter(!(speaker_role %in% c("Investigator", "Uncertain", "Unidentified", "Narrator", "Informant"))) %>%
  mutate(first_lang = str_extract(language, "^.{3}")) %>%
  group_by(first_lang) %>%
  dplyr::summarize(tokens = sum(num_tokens, na.rm = TRUE), num_utterances = n()) %>%
  arrange(desc(tokens))

write_csv(x = utterance_stats, file = "processed_data/childes_utterance_stats.csv")

# Get wordbank data ----

wordbank <- wordbankr::get_administration_data()

# Tally language for each subject
wordbank.counts <- group_by(wordbank, language) %>% 
  tally()

write_csv(wordbank.counts, "processed_data/wordbank_data.csv")

# Many Babies IDS ----

many.babies <- read_csv("https://raw.githubusercontent.com/manybabies/mb1-analysis-public/master/processed_data/01_merged_ouput.csv")

# Get one entry per baby
baby.info <- many.babies %>% 
  group_by(lab, subid) %>%
  slice_head() %>%
  select(subid, lang1) 

# Tally languages

mb.languages <- baby.info %>%
  group_by(lang1) %>%
  tally(name = "Count")

write_csv(mb.languages, "processed_data/many_babies.csv")

# Build iso_code to Name, Genus and Family dataset from WALS raw data

wals.langs <- read_csv("raw_data/WALS/language.csv") %>% 
  select(pk, Name = name)
wals.id <- read_csv("raw_data/WALS/walslanguage.csv") %>% 
  select(pk, genus_pk, iso_codes)
wals.langs <- left_join(wals.langs, wals.id)
wals.genus <- read_csv("raw_data/WALS/genus.csv") %>% 
  select(genus_pk = pk, genus = name, family_pk)
wals.langs <- wals.langs %>% left_join(wals.genus)
wals.family <- read_csv("raw_data/WALS/family.csv") %>% 
  select(family_pk = pk, family = name)
wals.langs <- wals.langs %>% 
  left_join(wals.family) %>% 
  select(-pk, -genus_pk, -family_pk, iso_code = iso_codes) %>% 
  separate_rows(iso_code, sep = ", ") # Separate languages with multiple iso_codes into their own rows
write_csv(wals.langs,"processed_data/wals_info.csv")
