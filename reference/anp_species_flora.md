# Standardized Flora Species of Peruvian Natural Protected Areas (BioANP)

A cleaned and standardized dataset containing the taxonomic
classification of flora species registered within the National System of
Natural Protected Areas (SINANPE) in Peru. The data has been processed
to align with modern taxonomic standards for Families and Orders.

## Usage

``` r
anp_species_flora
```

## Format

A tibble with 12,052 rows and 5 variables:

- especie:

  Character. The standardized binomial scientific name (Genus + specific
  epithet). In the case of infraspecific taxa, it includes the full name
  including subspecies or variety markers.

- familia:

  Character. The accepted botanical family name, standardized to follow
  APG (Angiosperm Phylogeny Group) or relevant current classifications
  (e.g., Cactaceae, Asteraceae).

- orden:

  Character. The accepted botanical order, providing higher-level
  taxonomic context (e.g., Caryophyllales, Asterales).

- rango_infraespecifico:

  Character. Indicates the rank of the infraspecific taxon if applicable
  (e.g., "subsp", "var"). Contains `NA` for species-level entries.

- rango_taxonomico:

  Character. The formal taxonomic rank of the entry, typically "Especie"
  (Species) or "Infraespecie" (Infraspecies).

## Source

<https://biodiversidadanp.sernanp.gob.pe/>

## Examples

``` r
if (FALSE) { # \dontrun{
library(dplyr)
# Filter for species within the Cactaceae family
cacti <- anp_species_flora %>%
    filter(familia == "Cactaceae")
} # }
```
