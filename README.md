# Towards a Comparative Approach to Language Acquisition
Script for producing figures from Christiansen, Contreras Kallens &amp; Trecca (In Press) Towards A Comparative Approach to Language Acquisition. CDPS.

# Data origins

* `isbilen_tallies.csv`

	Hand-extracted from Isbilen (2021) meta analysis of auditory statistical learning studies

* `many_babies_raw.csv`

	From Many Babies Infant-directed speech preference data, MB1. Clone repository https://github.com/manybabies/mb1-analysis-public and rename `processed_data/01_merged_output.csv`. Tally is produced in `process_data.R`. Processed into `many_babies.csv`.

* wordbank_data.csv

	Used *wordbankr* package and processed in `process_data.R`.

* `childes_utterance_stats.csv`

	Used `childesr` package and processed in `process_data.R`.

* `slobin_tallies.csv`

	Hand-extracted from Slobin, D. I. (2014). Before the beginning: The development of tools of the trade. Journal of Child Language, 41(S1), 1-17.

* `language_data.csv`

	Hand-constructed using Glottolog. First column (`In_DB`) contains the unique reference of each item in each of the previous databases.

**Note that the data from Kidd & Garcia (2021) is not publicly available. Please request it to the authors.**

# Scripts

* `process_data.R`

	Reads and manipulates the data to generate a language by count dataframe. Generates `many_babies.csv`, `wordbank_data.csv` and `childes_utterance_stats.csv`.

* `cdps_script.R`

	Reads all previous databases and aggregates over the target grouping. 

	Generates:

	* A *Genus* plot (`genus_plot.png`) showing the proportions of items for English, Romance, Germanic and Other languages.
	* A *Family* plot (`family_plot.png`) showing the proportions of items for English, Other Indo-European and Non-Indo-European languages.
	* A *Paper* plot (**cdps_family**) using a *subset* of the databases, namely Childes, Many Babies and Kidd & Garcia, showing the proportion of items for English, Other Indo-European and Non-Indo-European languages. The version used in the paper is `cdps_family.pdf`. Also includes a smaller, web-friendlier version of the plot, `cdps_family_small.png`. **Note again that this plot can only be generated with the Kidd & Garcia (2021) data, which is not included in this repository**.