# Towards a Comparative Approach to Language Acquisition
Script for producing figures from Christiansen, Contreras Kallens &amp; Trecca (In Press). *Towards A Comparative Approach to Language Acquisition*. *Current Directions in Psychological Science*. Also included are extra figures that include additional data to demonstrate the dominance of English in language acquisition research

# Data sources

* `isbilen_tallies.csv`

	Extracted from Isbilen (2021) meta analysis of auditory statistical learning studies

* `kidd_garcia_tallies.csv`
	
	Extracted from Kidd & Garcia (2021). How diverse is child language acquisition?. See Appendix A https://psyarxiv.com/jpeyq.

* `many_babies.csv`

	From Many Babies Infant-directed speech preference data, MB1. `process_data.R` gets the data directly from the Many Babies MB1 repository, https://github.com/manybabies/mb1-analysis-public and rename, and tallies the number of babies by language.

* `wordbank_data.csv`

	Used *wordbankr* package and processed in `process_data.R`.

* `childes_utterance_stats.csv`

	Used `childesr` package and processed in `process_data.R`.

* `slobin_tallies.csv`

	Hand-extracted from Slobin, D. I. (2014). Before the beginning: The development of tools of the trade. Journal of Child Language, 41(S1), 1-17.

* `language_key.csv`

	Hand-constructed pairing of languages and iso_codes for matching with WALS data. First column (`In_DB`) contains the unique reference of each item in each of the previous databases, second column (`iso_code`) contains the closest matching iso code for the respective language. In the cases where exact matches were not available (e.g., specific dialects), we used the closest available language relative. Because the analyses use only coarse-grained Genus and Family, this fuzzy matching does not affect the outcome.

* `wals_info.csv`
	Correspondence of iso_code to WALS data about Name, Genus and Family built in `process_data.R` using the files in `raw_data/WALS`. Using WALS release v2020.1, https://github.com/cldf-datasets/wals/releases.

* `not_in_wals.csv`

	Hand-constructed key for the handful of languages where no dialect relative was available in WALS. Includes iso code, name, and genus and family matched using Glottolog.

# Scripts

* `process_data.R`

	Reads and manipulates the data to generate a language by count dataframe. Generates `many_babies.csv`, `wordbank_data.csv`, `childes_utterance_stats.csv` and `wals_info.csv`.

* `cdps_script.R`

	Reads all previous databases and aggregates over the target grouping. 

	Generates:

	* A *Genus* plot (`genus_plot.png`) showing the proportions of items for English, Romance, Germanic and Other languages.
	* A *Family* plot (`family_plot.png`) showing the proportions of items for English, Other Indo-European and Non-Indo-European languages.
	* A *Paper* plot (**cdps_family**) using a *subset* of the databases, namely Childes, Many Babies and Kidd & Garcia 2021, showing the proportion of items for English, Germanic, Romance and Other genera. The version used in the paper is `cdps_family.pdf`. Also includes a smaller, web-friendlier version of the plot, `cdps_family_small.png`.