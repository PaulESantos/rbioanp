# Standardized Fauna Species of Peruvian Natural Protected Areas (BioANP)

A comprehensive and cleaned dataset containing the taxonomic
classification of fauna species registered within the National System of
Natural Protected Areas (SINANPE) in Peru. This dataset includes
terrestrial and aquatic vertebrates (amphibians, birds, mammals,
reptiles, and fish).

## Usage

``` r
anp_species_fauna
```

## Format

A tibble with 6,420 rows and 7 variables:

- grupo:

  Character. The general administrative or common group classification
  (e.g., "Anfibios", "Aves", "Mamíferos", "Peces", "Reptiles").

- clase:

  Character. The biological class to which the species belongs (e.g.,
  "Amphibia", "Aves", "Mammalia", "Actinopterygii").

- orden:

  Character. The taxonomic order (e.g., "Anura", "Passeriformes").

- familia:

  Character. The taxonomic family (e.g., "Centrolenidae", "Felidae").

- especie:

  Character. The scientific name of the species (binomial nomenclature).

- sinonimo:

  Character. Known taxonomic synonyms if applicable. Contains `NA` if no
  synonym is recorded in the cleaned version.

- rango_taxonomico:

  Character. The level of the taxonomic rank, "Especie" -
  "Infraespecie".

## Source

<https://biodiversidadanp.sernanp.gob.pe/>

## Examples

``` r

 library(dplyr)
#> 
#> Attaching package: ‘dplyr’
#> The following objects are masked from ‘package:stats’:
#> 
#>     filter, lag
#> The following objects are masked from ‘package:base’:
#> 
#>     intersect, setdiff, setequal, union
 # Count the number of species per group
 anp_species_fauna %>%
   group_by(grupo) %>%
   tally()
#> # A tibble: 6 × 2
#>   grupo         n
#>   <chr>     <int>
#> 1 Anfibios    312
#> 2 Aves       1758
#> 3 Insectos   2847
#> 4 Mamiferos   447
#> 5 Peces       793
#> 6 Reptiles    263
```
