## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 7,
  fig.height = 5
)
library(rbioanp)
library(dplyr)


## ----datasets-summary, echo=FALSE---------------------------------------------
data_summary <- data.frame(
  Dataset = c("anp_list", "anp_species_flora", "anp_species_fauna", "anp_species_occ", "anp_especies_distr"),
  `Rows` = c("287", "12,052", "6,420", "55,155", "183,558"),
  `Columns` = c("13", "5", "7", "11", "9"),
  `Primary Scope` = c(
    "Official protected areas registry (SINANPE)",
    "Standardized flora species inventory (APG)",
    "Standardized fauna species inventory",
    "Species occurrence records in ANPs",
    "Global biogeographic distribution (WCVP / WGSRPD L3)"
  ),
  check.names = FALSE
)
knitr::kable(data_summary, caption = "Table 1. Overview of datasets included in rbioanp.")


## ----anp-categories-----------------------------------------------------------
data(anp_list)

# Protected area categories and total extension
anp_summary <- anp_list %>%
  group_by(categoria) %>%
  summarise(
    `Count` = n(),
    `Total Area (ha)` = sum(extension_ha, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(`Total Area (ha)`))

knitr::kable(anp_summary, caption = "Table 2. Distribution of Peru's Protected Natural Areas by IUCN/SERNANP category.")


## ----flora-top-families-------------------------------------------------------
data(anp_species_flora)

top_flora_families <- anp_species_flora %>%
  count(familia, sort = TRUE) %>%
  head(10)

knitr::kable(top_flora_families, col.names = c("Family", "Species Count"), 
             caption = "Table 3. Top 10 most species-rich plant families in Peruvian ANPs.")


## ----fauna-groups-------------------------------------------------------------
data(anp_species_fauna)

fauna_groups <- anp_species_fauna %>%
  count(grupo, sort = TRUE)

knitr::kable(fauna_groups, col.names = c("Taxonomic Group", "Species Count"),
             caption = "Table 4. Fauna species breakdown by main taxonomic group.")


## ----occurrence-hotspots------------------------------------------------------
data(anp_species_occ)

# Summary of endemism and threat status
total_occ <- nrow(anp_species_occ)
endemic_count <- sum(anp_species_occ$endemica == TRUE, na.rm = TRUE)
threatened_count <- sum(anp_species_occ$amenazada == TRUE, na.rm = TRUE)
both_count <- sum(anp_species_occ$endemica == TRUE & anp_species_occ$amenazada == TRUE, na.rm = TRUE)

cat("Total Occurrence Records:", total_occ, "\n")
cat("Endemic Species Occurrences:", endemic_count, sprintf("(%.2f%%)\n", 100 * endemic_count / total_occ))
cat("Threatened Species Occurrences:", threatened_count, sprintf("(%.2f%%)\n", 100 * threatened_count / total_occ))
cat("Both Endemic & Threatened Occurrences:", both_count, "\n")

# Top 5 ANPs by occurrence richness
top_anps <- anp_species_occ %>%
  count(anp_nombre, sort = TRUE) %>%
  head(5)

knitr::kable(top_anps, col.names = c("Protected Natural Area", "Record Count"),
             caption = "Table 5. Top 5 protected natural areas with the highest occurrence record density.")


## ----biogeographic-distribution-----------------------------------------------
data(anp_especies_distr)

# Top native botanical regions for Peruvian ANP flora
top_regions <- anp_especies_distr %>%
  filter(occurrence_type == "native") %>%
  count(area, sort = TRUE) %>%
  head(10)

knitr::kable(top_regions, col.names = c("Botanical Area (WGSRPD L3)", "Native Species Count"),
             caption = "Table 6. Top 10 botanical areas sharing native flora species with Peruvian ANPs.")


## ----example-code, eval=FALSE-------------------------------------------------
# library(rbioanp)
# library(dplyr)
# 
# # Find endemic and threatened species in Tambopata National Reserve
# tambopata_priority <- anp_species_occ %>%
#   filter(
#     anp_nombre == "Tambopata",
#     endemica == TRUE,
#     amenazada == TRUE
#   ) %>%
#   select(especie, clase, familia, endemica, amenazada)
# 
# head(tambopata_priority)

