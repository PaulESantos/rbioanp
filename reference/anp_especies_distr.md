# Biogeographic Distribution of Flora Species (WCVP / WGSRPD Level 3)

A dataset containing the global biogeographic distribution of flora
species registered in Peru's Protected Natural Areas (ANP), retrieved
using the `wcvpmatch` package and the World Checklist of Vascular Plants
(WCVP) database. Categorized according to the World Geographic Scheme
for Recording Plant Distributions (WGSRPD) Level 3 standard.

## Usage

``` r
anp_especies_distr
```

## Format

A tibble with 183,558 rows and 9 variables:

- submitted_name:

  Character. Binomial scientific name of the species as registered in
  bioANP.

- matched_taxon:

  Character. Standardized scientific name matched against WCVP.

- match_distance:

  Numeric. String distance of the taxonomic match (0 for exact match).

- continent:

  Character. Continent name corresponding to WGSRPD Level 1.

- region:

  Character. Region name corresponding to WGSRPD Level 2.

- area_code_l3:

  Character. Standardized 3-letter WGSRPD Level 3 geographic area code
  (e.g., "BZN", "CLM", "PER").

- area:

  Character. Full name of the WGSRPD Level 3 botanical area (e.g.,
  "Peru", "Colombia", "Brazil North").

- occurrence_type:

  Character. Type of species occurrence in the area ("native",
  "introduced", "location_doubtful", "extinct").

- distribution_status:

  Character. Status of the distribution record in WCVP.

## Source

Data retrieved from WCVP using
[wcvpmatch](https://github.com/PaulESantos/wcvpmatch) for flora species
in Peru's [bioANP platform](https://biodiversidadanp.sernanp.gob.pe/).

## Details

Information was generated using `wcvpmatch::wcvp_distribution()` from
the [wcvpmatch](https://github.com/PaulESantos/wcvpmatch) package. The
World Geographic Scheme for Recording Plant Distributions (WGSRPD) is a
standard developed by Biodiversity Information Standards (TDWG).

## Examples

``` r
if (FALSE) { # \dontrun{
# Load dataset
data(anp_especies_distr)

# View top geographic areas with native species from Peruvian ANPs
library(dplyr)
anp_especies_distr %>%
  filter(occurrence_type == "native") %>%
  count(area, sort = TRUE)
} # }
```
