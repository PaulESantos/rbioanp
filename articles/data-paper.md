# rbioanp: A Comprehensive Biodiversity and Biogeographic Database of Peru's State-Protected Natural Areas

## Abstract

Peru is recognized as one of the world’s 17 megadiverse countries,
harboring exceptional levels of species richness, endemism, and
ecosystem diversity. The National System of State-Protected Natural
Areas (*Sistema Nacional de Áreas Naturales Protegidas por el Estado* -
SINANPE), managed by the National Service of Natural Protected Areas
(*Servicio Nacional de Áreas Naturales Protegidas por el Estado* -
SERNANP), covers over 30 million hectares across terrestrial, Andean,
Amazonian, and marine-coastal biomes.

This Data Paper presents `rbioanp`, an R package that consolidates,
standardizes, and enriches curated biodiversity datasets from Peru’s
protected areas available via the **bioANP platform**. The package
integrates five primary datasets encompassing:

1.  Spatial and administrative metadata for **287 Protected Natural
    Areas (ANPs)**.
2.  A taxonomic inventory of **12,052 flora species** standardized
    according to the Angiosperm Phylogeny Group (APG) classification.
3.  A taxonomic inventory of **6,420 fauna species** (vertebrates and
    invertebrates) aligned with international taxonomic databases.
4.  An occurrence database containing **55,155 species occurrence
    records** across 75 protected areas, complete with national endemism
    and threat status flags.
5.  A global biogeographic distribution database of **183,558 records**
    mapped using the World Geographic Scheme for Recording Plant
    Distributions (WGSRPD Level 3) standard via `wcvpmatch` and the
    World Checklist of Vascular Plants (WCVP).

------------------------------------------------------------------------

## 1. Introduction & Context

Peru’s protected areas form the cornerstone of biodiversity conservation
in the Tropical Andes and Amazon basin. However, accessing, harmonizing,
and analyzing official biodiversity monitoring datasets from protected
areas has historically presented technical challenges due to fragmented
data sources, non-standardized taxonomy, and varying administrative
reporting formats.

The `rbioanp` package bridges this gap by providing an R-native
ecosystem for biodiversity informatics, macroecology, and conservation
decision-making in Peru.

------------------------------------------------------------------------

## 2. Dataset Architecture & Description

`rbioanp` provides five core datasets stored as tidy `tbl_df` objects:

| Dataset | Rows | Columns | Primary Scope |
|:---|:---|:---|:---|
| anp_list | 287 | 13 | Official protected areas registry (SINANPE) |
| anp_species_flora | 12,052 | 5 | Standardized flora species inventory (APG) |
| anp_species_fauna | 6,420 | 7 | Standardized fauna species inventory |
| anp_species_occ | 55,155 | 11 | Species occurrence records in ANPs |
| anp_especies_distr | 183,558 | 9 | Global biogeographic distribution (WCVP / WGSRPD L3) |

Table 1. Overview of datasets included in rbioanp. {.table}

------------------------------------------------------------------------

## 3. Exploratory Data Analysis & Biological Insights

### 3.1 Protected Natural Area Network (`anp_list`)

The `anp_list` dataset documents 287 protected areas spanning 30,342,335
hectares.

``` r

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
```

| categoria                      | Count | Total Area (ha) |
|:-------------------------------|------:|----------------:|
| RESERVAS NACIONALES            |    45 |     11044283.97 |
| PARQUES NACIONALES             |    15 |     10394644.34 |
| AREAS DE CONSERVACION REGIONAL |    36 |      3967814.14 |
| RESERVAS COMUNALES             |    11 |      2327192.85 |
| RESERVAS PAISAJÍSTICAS         |     2 |       711818.48 |
| ZONAS RESERVADAS               |     8 |       588302.67 |
| AREAS DE CONSERVACION PRIVADA  |   146 |       414135.49 |
| BOSQUES DE PROTECCION          |     6 |       389986.99 |
| SANTUARIOS NACIONALES          |     9 |       317366.47 |
| COTOS DE CAZA                  |     2 |       124735.00 |
| SANTUARIOS HISTORICOS          |     4 |        41279.38 |
| REFUGIO DE VIDA SILVESTRE      |     3 |        20775.11 |

Table 2. Distribution of Peru’s Protected Natural Areas by IUCN/SERNANP
category. {.table}

### 3.2 Flora Diversity & Taxonomic Composition (`anp_species_flora`)

The flora inventory includes 12,052 unique plant species across 321
families.

``` r

data(anp_species_flora)

top_flora_families <- anp_species_flora %>%
  count(familia, sort = TRUE) %>%
  head(10)

knitr::kable(top_flora_families, col.names = c("Family", "Species Count"), 
             caption = "Table 3. Top 10 most species-rich plant families in Peruvian ANPs.")
```

| Family          | Species Count |
|:----------------|--------------:|
| Orchidaceae     |          1143 |
| Asteraceae      |           735 |
| Fabaceae        |           642 |
| Rubiaceae       |           599 |
| Poaceae         |           463 |
| Melastomataceae |           377 |
| Solanaceae      |           338 |
| Malvaceae       |           247 |
| Araceae         |           245 |
| Lauraceae       |           208 |

Table 3. Top 10 most species-rich plant families in Peruvian ANPs.
{.table}

### 3.3 Fauna Composition (`anp_species_fauna`)

The fauna dataset comprises 6,420 records covering major vertebrate
classes and invertebrates.

``` r

data(anp_species_fauna)

fauna_groups <- anp_species_fauna %>%
  count(grupo, sort = TRUE)

knitr::kable(fauna_groups, col.names = c("Taxonomic Group", "Species Count"),
             caption = "Table 4. Fauna species breakdown by main taxonomic group.")
```

| Taxonomic Group | Species Count |
|:----------------|--------------:|
| Insectos        |          2847 |
| Aves            |          1758 |
| Peces           |           793 |
| Mamiferos       |           447 |
| Anfibios        |           312 |
| Reptiles        |           263 |

Table 4. Fauna species breakdown by main taxonomic group. {.table}

### 3.4 Species Occurrences, Endemism & Conservation Threats (`anp_species_occ`)

Analyzing 55,155 occurrence records reveals key hotspots of endemic and
threatened species.

``` r

data(anp_species_occ)

# Summary of endemism and threat status
total_occ <- nrow(anp_species_occ)
endemic_count <- sum(anp_species_occ$endemica == TRUE, na.rm = TRUE)
threatened_count <- sum(anp_species_occ$amenazada == TRUE, na.rm = TRUE)
both_count <- sum(anp_species_occ$endemica == TRUE & anp_species_occ$amenazada == TRUE, na.rm = TRUE)

cat("Total Occurrence Records:", total_occ, "\n")
#> Total Occurrence Records: 55155
cat("Endemic Species Occurrences:", endemic_count, sprintf("(%.2f%%)\n", 100 * endemic_count / total_occ))
#> Endemic Species Occurrences: 2432 (4.41%)
cat("Threatened Species Occurrences:", threatened_count, sprintf("(%.2f%%)\n", 100 * threatened_count / total_occ))
#> Threatened Species Occurrences: 1601 (2.90%)
cat("Both Endemic & Threatened Occurrences:", both_count, "\n")
#> Both Endemic & Threatened Occurrences: 276

# Top 5 ANPs by occurrence richness
top_anps <- anp_species_occ %>%
  count(anp_nombre, sort = TRUE) %>%
  head(5)

knitr::kable(top_anps, col.names = c("Protected Natural Area", "Record Count"),
             caption = "Table 5. Top 5 protected natural areas with the highest occurrence record density.")
```

| Protected Natural Area | Record Count |
|:-----------------------|-------------:|
| Tambopata              |         3665 |
| Yanachaga - Chemillen  |         3356 |
| de Machupicchu         |         2924 |
| Allpahuayo Mishana     |         2710 |
| Pacaya - Samiria       |         2151 |

Table 5. Top 5 protected natural areas with the highest occurrence
record density. {.table}

### 3.5 Global Biogeographic Distribution (`anp_especies_distr`)

Using `wcvpmatch::wcvp_distribution()`, 183,558 global distribution
records were matched against the World Checklist of Vascular Plants
(WCVP).

``` r

data(anp_especies_distr)

# Top native botanical regions for Peruvian ANP flora
top_regions <- anp_especies_distr %>%
  filter(occurrence_type == "native") %>%
  count(area, sort = TRUE) %>%
  head(10)

knitr::kable(top_regions, col.names = c("Botanical Area (WGSRPD L3)", "Native Species Count"),
             caption = "Table 6. Top 10 botanical areas sharing native flora species with Peruvian ANPs.")
```

| Botanical Area (WGSRPD L3) | Native Species Count |
|:---------------------------|---------------------:|
| Peru                       |                10203 |
| Ecuador                    |                 6408 |
| Colombia                   |                 6374 |
| Bolivia                    |                 5968 |
| Brazil North               |                 4486 |
| Venezuela                  |                 4440 |
| Panamá                     |                 2672 |
| Costa Rica                 |                 2590 |
| Guyana                     |                 2382 |
| Brazil West-Central        |                 2302 |

Table 6. Top 10 botanical areas sharing native flora species with
Peruvian ANPs. {.table}

------------------------------------------------------------------------

## 4. Taxonomic Standardization & Quality Control Protocols

Data quality was ensured through a multi-stage validation workflow:

1.  **Flora Standardization**: Binomial scientific names were matched
    against the Angiosperm Phylogeny Group IV (APG IV) standard.
2.  **Fauna Harmonization**: Scientific names and higher taxonomic ranks
    (Order, Family, Class) were validated against international
    taxonomic authorities (ITIS, GBIF).
3.  **Biogeographic Cross-referencing**: Global distributions were
    linked using the World Geographic Scheme for Recording Plant
    Distributions (WGSRPD Level 3) standard.
4.  **Package Compliance**: `rbioanp` strictly passes `R CMD check` with
    **0 Errors, 0 Warnings, and 0 Notes**.

------------------------------------------------------------------------

## 5. Usage Example & Reproducibility

``` r

library(rbioanp)
library(dplyr)

# Find endemic and threatened species in Tambopata National Reserve
tambopata_priority <- anp_species_occ %>%
  filter(
    anp_nombre == "Tambopata",
    endemica == TRUE,
    amenazada == TRUE
  ) %>%
  select(especie, clase, familia, endemica, amenazada)

head(tambopata_priority)
```

------------------------------------------------------------------------

## Data Availability & Citation

All datasets included in `rbioanp` are open access under the MIT license
and derived from official public databases of [SERNANP
bioANP](https://biodiversidadanp.sernanp.gob.pe/).

If you use `rbioanp` in academic research or conservation planning,
please cite:

> Santos Andrade, P. E. (2026). *rbioanp: Access and Analyze
> Biodiversity Data from Peru’s Protected Natural Areas*. R package
> version 0.1.0. <https://github.com/PaulESantos/rbioanp>
