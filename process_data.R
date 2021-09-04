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

# Many Baby IDS ----

many.babies <- read_csv("raw_data/many_babies_raw.csv")

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
