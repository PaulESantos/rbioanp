# Species Occurrence Records in Peru's Protected Natural Areas

Dataset containing biodiversity occurrence records from Peru's Protected
Natural Areas (ANP) within the National System of State Protected
Natural Areas (SINANPE).

## Usage

``` r
anp_species_occ
```

## Format

A tibble with 55,155 rows and 12 columns:

- anp_categoria:

  Protected Natural Area category (e.g., "National Park", "National
  Reserve", "National Sanctuary")

- anp_nombre:

  Protected Natural Area name

- clase:

  Taxonomic class

- orden:

  Taxonomic order

- familia:

  Taxonomic family

- especie:

  Scientific name of the species

- endemica:

  Logical indicator of whether the species is endemic to Peru

- amenazada:

  Logical indicator of whether the species is under any threat category

- rango_infraespecifico:

  Infraspecific rank if applicable (var, subsp, fo, subvar, hibrido,
  infrasp)

- sinonimo:

  Taxonomic synonym presented as part of the original name

- rango_taxonomico:

  Rank classification ("Especie", "Infraespecie")

## Source

Data downloaded from the [bioANP
platform](https://biodiversidadanp.sernanp.gob.pe/), developed by the
National Service of State Protected Natural Areas (SERNANP)

## Details

The dataset has been processed to:

- Standardize the structure of scientific names

- Remove invalid records at the species level (families, genera,
  sections)

- Identify infraspecific ranks (varieties, subspecies, forms)

- Extract synonyms from scientific names

- Classify the taxonomic rank of each record

## Examples

``` r
# Load dataset
data(anp_species_occ)

# View structure
str(anp_species_occ)
#> tibble [55,155 × 11] (S3: tbl_df/tbl/data.frame)
#>  $ anp_categoria        : chr [1:55155] "Bosque de Proteccion" "Bosque de Proteccion" "Bosque de Proteccion" "Bosque de Proteccion" ...
#>  $ anp_nombre           : chr [1:55155] "Aledaño a la Bocatoma del Canal Nuevo Imperial" "Aledaño a la Bocatoma del Canal Nuevo Imperial" "Aledaño a la Bocatoma del Canal Nuevo Imperial" "Aledaño a la Bocatoma del Canal Nuevo Imperial" ...
#>  $ clase                : chr [1:55155] "Aves" "Aves" "Aves" "Aves" ...
#>  $ orden                : chr [1:55155] "Passeriformes" "Accipitriformes" "Pelecaniformes" "Passeriformes" ...
#>  $ familia              : chr [1:55155] "Hirundinidae" "Accipitridae" "Threskiornithidae" "Tyrannidae" ...
#>  $ especie              : chr [1:55155] "Hirundo rustica" "Geranoaetus melanoleucus" "Plegadis ridgwayi" "Elaenia albiceps" ...
#>  $ sinonimo             : chr [1:55155] NA NA NA NA ...
#>  $ endemica             : logi [1:55155] FALSE FALSE FALSE FALSE FALSE FALSE ...
#>  $ amenazada            : logi [1:55155] FALSE FALSE FALSE FALSE FALSE FALSE ...
#>  $ rango_infraespecifico: chr [1:55155] NA NA NA NA ...
#>  $ rango_taxonomico     : chr [1:55155] "Especie" "Especie" "Especie" "Especie" ...

# Endemic threatened species
anp_species_occ |>
  dplyr::filter(endemica == TRUE, amenazada == TRUE)
#> # A tibble: 276 × 11
#>    anp_categoria        anp_nombre clase orden familia especie sinonimo endemica
#>    <chr>                <chr>      <chr> <chr> <chr>   <chr>   <chr>    <lgl>   
#>  1 Bosque de Proteccion Alto Mayo  Aves  Stri… Strigi… Xenogl… NA       TRUE    
#>  2 Bosque de Proteccion Alto Mayo  Aves  Pass… Tyrann… Zimmer… NA       TRUE    
#>  3 Bosque de Proteccion Alto Mayo  Aves  Pass… Furnar… Thripo… NA       TRUE    
#>  4 Bosque de Proteccion Alto Mayo  Aves  Pass… Gralla… Gralla… NA       TRUE    
#>  5 Bosque de Proteccion Alto Mayo  Rept… Serp… Viperi… Bothro… NA       TRUE    
#>  6 Bosque de Proteccion Alto Mayo  Mamm… Prim… Pithec… Callic… NA       TRUE    
#>  7 Bosque de Proteccion Alto Mayo  Equi… Aspa… Orchid… Masdev… NA       TRUE    
#>  8 Bosque de Proteccion Alto Mayo  Mamm… Prim… Atelid… Lagoth… NA       TRUE    
#>  9 Bosque de Proteccion Alto Mayo  Aves  Apod… Trochi… Loddig… NA       TRUE    
#> 10 Bosque de Proteccion Alto Mayo  Aves  Pici… Picidae Picumn… NA       TRUE    
#> # ℹ 266 more rows
#> # ℹ 3 more variables: amenazada <lgl>, rango_infraespecifico <chr>,
#> #   rango_taxonomico <chr>

# Species by protected area
anp_species_occ |>
  dplyr::count(anp_nombre, sort = TRUE)
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

# Distribution by taxonomic class
anp_species_occ |>
  dplyr::count(clase, sort = TRUE)
#> # A tibble: 10 × 2
#>    clase              n
#>    <chr>          <int>
#>  1 Equisetopsida  29388
#>  2 Aves           16858
#>  3 Insecta         2986
#>  4 Mammalia        2955
#>  5 Actinopterygii  1665
#>  6 Reptilia         650
#>  7 Amphibia         611
#>  8 Elasmobranchii    39
#>  9 Holocephali        2
#> 10 Leptocardii        1
```
