
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rbioanp <img src="man/figures/rbioanp_logo.png" align="right" height="200" />

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

**rbioanp** provides convenient access to curated biodiversity datasets
from Peru’s National System of State-Protected Natural Areas (SINANPE)
through the [bioANP platform](https://biodiversidadanp.sernanp.gob.pe/).
The package includes standardized datasets of flora and fauna species
inventories and occurrence records from Peru’s diverse ecosystems,
facilitating biodiversity research and conservation analysis.

## Motivation

Peru is one of the most biodiverse countries in the world, with vast
ecosystems ranging from the Amazon rainforest to the Andes mountains and
coastal regions. The SINANPE system protects these critical areas, and
the bioANP platform provides comprehensive biodiversity inventories.
This package makes these valuable datasets easily accessible to
researchers, conservationists, and data scientists using R.

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
- **Standardized taxonomic data**: Updated scientific names, families, and
  orders based on international standards (APG for flora, ITIS for fauna)
  
## Datasets Included
  
### `anp_list`
  
Official list of state-protected natural areas in Peru.
  
- **Variables**: `categoria`, `codigo`, `nombre`, `base_legal_creacion`,
  `fecha_promulgacion_creacion`, `ubicacion_politica`, `extension_ha`, etc.
- **Scope**: Includes National Parks, Reserves, Sanctuaries, and more.
  
### `anp_species_flora`
  
Standardized flora species inventory.
  
- **Taxonomy**: Aligned with APG (Angiosperm Phylogeny Group) standards.
- **Variables**: `especie`, `familia`, `orden`, `rango_infraespecifico`,
  `rango_taxonomico`.
  
### `anp_species_fauna`
  
Comprehensive fauna species inventory (Vertebrates).
  
- **Taxonomy**: Cleaned and validated following ITIS standards.
- **Variables**: `grupo`, `clase`, `orden`, `familia`, `especie`,
  `sinonimo`, `rango_taxonomico`.
  
### `anp_species_occ`
  
Species occurrence records within protected areas.
  
- **Integration**: Combines species data with geographic context.
- **Variables**: `anp_nombre`, `anp_categoria`, `especie`, `familia`,
  `orden`, `endemica`, `amenazada`, etc.

## Installation

You can install the development version of rbioanp from GitHub:

``` r
# Install devtools if not already installed
# install.packages("devtools")

devtools::install_github("PaulESantos/rbioanp")
```

## Quick Start

``` r
library(rbioanp)
library(dplyr)

# Load the protected areas registry
data(anp_list)
head(anp_list)

# Count protected areas by category
table(anp_list$categoria)

# Load fauna species data
data(anp_species_fauna)

# Count species by group
anp_species_fauna %>%
  group_by(grupo) %>%
  tally()

# Load occurrence records
data(anp_species_occ)

# Find endemic threatened species
anp_species_occ %>%
  filter(endemica == TRUE, amenazada == TRUE)

# Species distribution across protected areas
anp_species_occ %>%
  count(anp_nombre, sort = TRUE)
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

## Contributing

Contributions are welcome! Please read
[CONTRIBUTING.md](.github/CONTRIBUTING.md) for details on our code of
conduct and the process for submitting pull requests.

## License

This package is licensed under the MIT License - see the
[LICENSE](LICENSE.md) file for details.

## Code of Conduct

Please note that this project is released with a [Contributor Code of
Conduct](.github/CODE_OF_CONDUCT.md). By participating in this project
you agree to abide by its terms.

## Support

For issues, questions, or suggestions, please visit the [GitHub Issues
page](https://github.com/PaulESantos/rbioanp/issues) or see our [Support
guidelines](.github/SUPPORT.md).

## Related Resources

- [bioANP Platform](https://biodiversidadanp.sernanp.gob.pe/) - Official
  biodiversity portal
- [SERNANP Official Website](https://www.gob.pe/sernanp) - National
  Service of State-Protected Natural Areas
- [SINANPE System](https://www.gob.pe/institucion/sernanp) - Peru’s
  National System of Protected Areas
