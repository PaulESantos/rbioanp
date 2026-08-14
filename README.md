
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rbioanp <img src="man/figures/rbioanp_logo.png" align="right" height="139" width="120" style="max-height: 139px; height: 139px; width: auto;" />

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/rbioanp)](https://CRAN.R-project.org/package=rbioanp)
[![R-CMD-check](https://github.com/PaulESantos/rbioanp/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/PaulESantos/rbioanp/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/PaulESantos/rbioanp/graph/badge.svg)](https://app.codecov.io/gh/PaulESantos/rbioanp)
<!-- badges: end -->

## Overview

**rbioanp** provides easy access to curated biodiversity datasets from
Peru’s National System of State-Protected Natural Areas (SINANPE) via
the [bioANP platform](https://biodiversidadanp.sernanp.gob.pe/). The
package delivers standardized inventories and occurrence records of
flora and fauna from Peru’s protected natural areas, supporting
biodiversity research, conservation planning, and environmental analysis
in R.

## Features

- **Access to official biodiversity data** from Peru’s protected natural
  areas
- **Flora dataset**: 12,050+ standardized plant species across SINANPE
- **Fauna dataset**: 6,400+ animal species (vertebrates) with taxonomic
  classification
- **Occurrence records**: 55,100+ species occurrences within protected
  areas
- **Protected areas registry**: Official listing of 287 state-protected
  natural areas with legal and administrative information
- **Standardized taxonomic data**: Updated scientific names, families,
  and orders based on international standards (APG for flora, ITIS for
  fauna)

## Datasets Included

### `anp_list`

Official list of state-protected natural areas in Peru. - **Variables**:
`categoria`, `codigo`, `nombre`, `base_legal_creacion`,
`fecha_promulgacion_creacion`, `ubicacion_politica`, `extension_ha`,
etc. - **Scope**: Includes National Parks, Reserves, Sanctuaries, and
more.

### `anp_species_flora`

Standardized flora species inventory. - **Taxonomy**: Aligned with APG
(Angiosperm Phylogeny Group) standards. - **Variables**: `especie`,
`familia`, `orden`, `rango_infraespecifico`, `rango_taxonomico`.

### `anp_species_fauna`

Comprehensive fauna species inventory (Vertebrates). - **Taxonomy**:
Cleaned and validated following ITIS standards. - **Variables**:
`grupo`, `clase`, `orden`, `familia`, `especie`, `sinonimo`,
`rango_taxonomico`.

### `anp_species_occ`

Species occurrence records within protected areas. - **Integration**:
Combines species data with geographic context. - **Variables**:
`anp_nombre`, `anp_categoria`, `especie`, `familia`, `orden`,
`endemica`, `amenazada`, etc.

## Installation

You can install the development version of rbioanp from GitHub:

``` r
# Install devtools if not already installed
# install.packages("pak")

pak::pak("PaulESantos/rbioanp")
```

## Quick Start

``` r
library(rbioanp)
library(tidyverse)
#> ── Attaching core tidyverse packages ──────────────────────── tidyverse 2.0.0 ──
#> ✔ dplyr     1.2.1     ✔ readr     2.2.0
#> ✔ forcats   1.0.1     ✔ stringr   1.6.0
#> ✔ ggplot2   4.0.3     ✔ tibble    3.3.1
#> ✔ lubridate 1.9.5     ✔ tidyr     1.3.2
#> ✔ purrr     1.2.2     
#> ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
#> ✖ dplyr::filter() masks stats::filter()
#> ✖ dplyr::lag()    masks stats::lag()
#> ℹ Use the conflicted package (<http://conflicted.r-lib.org/>) to force all conflicts to become errors

# Load the protected areas registry
data(anp_list)
head(anp_list)
#> # A tibble: 6 × 13
#>   categoria          codigo nombre         codigo_2 nombre_2 base_legal_creacion
#>   <chr>              <chr>  <chr>          <chr>    <chr>    <chr>              
#> 1 PARQUES NACIONALES PN 01  de Cutervo     <NA>     <NA>     LEY No 13694       
#> 2 PARQUES NACIONALES PN 02  de Tingo Maria <NA>     <NA>     LEY No 15574       
#> 3 PARQUES NACIONALES PN 03  del Manu       <NA>     <NA>     D.S. No 644-1973-AG
#> 4 PARQUES NACIONALES PN 04  Huascaran      <NA>     <NA>     D.S. No 0622-1975-…
#> 5 PARQUES NACIONALES PN 05  Cerros de Amo… <NA>     <NA>     D.S. No 0800-1975-…
#> 6 PARQUES NACIONALES PN 06  del Rio Abiseo <NA>     <NA>     D.S. No 064-1983-AG
#> # ℹ 7 more variables: fecha_promulgacion_creacion <date>,
#> #   base_legal_modificacion <chr>, fecha_promulgacion_modificacion <chr>,
#> #   ubicacion_politica <chr>, extension_ha <dbl>, fuente <chr>, version <chr>

# Count protected areas by category
table(anp_list$categoria)
#> 
#>  AREAS DE CONSERVACION PRIVADA AREAS DE CONSERVACION REGIONAL 
#>                            146                             36 
#>          BOSQUES DE PROTECCION                  COTOS DE CAZA 
#>                              6                              2 
#>             PARQUES NACIONALES      REFUGIO DE VIDA SILVESTRE 
#>                             15                              3 
#>             RESERVAS COMUNALES            RESERVAS NACIONALES 
#>                             11                             45 
#>         RESERVAS PAISAJÍSTICAS          SANTUARIOS HISTORICOS 
#>                              2                              4 
#>          SANTUARIOS NACIONALES               ZONAS RESERVADAS 
#>                              9                              8

# Load fauna species data
data(anp_species_fauna)

# Count species by group
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

# Load occurrence records
data(anp_species_occ)

# Find endemic threatened species
anp_species_occ %>%
  filter(endemica == TRUE, amenazada == TRUE)
#> # A tibble: 276 × 11
#>    anp_categoria        anp_nombre clase orden familia especie sinonimo endemica
#>    <chr>                <chr>      <chr> <chr> <chr>   <chr>   <chr>    <lgl>   
#>  1 Bosque de Proteccion Alto Mayo  Aves  Stri… Strigi… Xenogl… <NA>     TRUE    
#>  2 Bosque de Proteccion Alto Mayo  Aves  Pass… Tyrann… Zimmer… <NA>     TRUE    
#>  3 Bosque de Proteccion Alto Mayo  Aves  Pass… Furnar… Thripo… <NA>     TRUE    
#>  4 Bosque de Proteccion Alto Mayo  Aves  Pass… Gralla… Gralla… <NA>     TRUE    
#>  5 Bosque de Proteccion Alto Mayo  Rept… Serp… Viperi… Bothro… <NA>     TRUE    
#>  6 Bosque de Proteccion Alto Mayo  Mamm… Prim… Pithec… Callic… <NA>     TRUE    
#>  7 Bosque de Proteccion Alto Mayo  Equi… Aspa… Orchid… Masdev… <NA>     TRUE    
#>  8 Bosque de Proteccion Alto Mayo  Mamm… Prim… Atelid… Lagoth… <NA>     TRUE    
#>  9 Bosque de Proteccion Alto Mayo  Aves  Apod… Trochi… Loddig… <NA>     TRUE    
#> 10 Bosque de Proteccion Alto Mayo  Aves  Pici… Picidae Picumn… <NA>     TRUE    
#> # ℹ 266 more rows
#> # ℹ 3 more variables: amenazada <lgl>, rango_infraespecifico <chr>,
#> #   rango_taxonomico <chr>

# Species distribution across protected areas
anp_species_occ %>%
  count(anp_nombre, sort = TRUE)
#> # A tibble: 75 × 2
#>    anp_nombre                n
#>    <chr>                 <int>
#>  1 Tambopata              3665
#>  2 Yanachaga - Chemillen  3356
#>  3 de Machupicchu         2924
#>  4 Allpahuayo Mishana     2710
#>  5 Pacaya - Samiria       2151
#>  6 El Sira                1963
#>  7 Sierra del Divisor     1715
#>  8 Bahuaja - Sonene       1706
#>  9 Alto Mayo              1670
#> 10 de Tingo Maria         1460
#> # ℹ 65 more rows
```

## Data Sources

All datasets are sourced from the official [bioANP
platform](https://biodiversidadanp.sernanp.gob.pe/) maintained by the
National Service of State-Protected Natural Areas (SERNANP, Servicio
Nacional de Áreas Naturales Protegidas por el Estado).

## Citation

If you use this package in your research, please cite:

    Santos Andrade, P. E. (2026). rbioanp: Access and Analyze Biodiversity Data from
    Peru's Protected Natural Areas. R package version 0.1.0.
    https://github.com/PaulESantos/rbioanp

## Related Resources

- [bioANP Platform](https://biodiversidadanp.sernanp.gob.pe/) - Official
  biodiversity portal
