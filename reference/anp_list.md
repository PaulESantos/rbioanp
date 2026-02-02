# Official List of State-Protected Natural Areas in Peru

A comprehensive dataset containing information about all officially
recognized natural protected areas (Áreas Naturales Protegidas - ANP) in
Peru, as maintained by the National Service of State-Protected Natural
Areas (SERNANP).

## Usage

``` r
anp_list
```

## Format

A tibble with 287 rows and 13 variables:

- categoria:

  Character. Category of the protected area (e.g., "PARQUES NACIONALES",
  "RESERVAS NACIONALES", "SANTUARIOS NACIONALES"). Represents the IUCN
  management category adapted to Peruvian legislation.

- codigo:

  Character. Primary identification code for the protected area,
  typically consisting of a category abbreviation and sequential number
  (e.g., "PN 01" for the first National Park).

- nombre:

  Character. Official name of the protected area.

- codigo_2:

  Character. Secondary identification code, if applicable. Contains NA
  for most entries.

- nombre_2:

  Character. Secondary or alternative name, if applicable. Contains NA
  for most entries.

- base_legal_creacion:

  Character. Legal instrument that established the protected area (e.g.,
  "LEY No 13694", "D.S. No 644-1973-AG"). May include laws (LEY),
  supreme decrees (D.S.), or other legal documents.

- fecha_promulgacion_creacion:

  Date. Promulgation date of the legal instrument that created the
  protected area, in YYYY-MM-DD format.

- base_legal_modificacion:

  Character. Legal instrument(s) that modified the original protected
  area designation, if any. May contain multiple references separated by
  semicolons. Contains NA if no modifications exist.

- fecha_promulgacion_modificacion:

  Character. Promulgation date(s) of modification legal instruments. May
  contain multiple dates separated by slashes for multiple
  modifications. Contains NA if no modifications exist.

- ubicación_politica:

  Character. Political-administrative location of the protected area,
  listing department(s) where it is located. Multiple departments are
  separated by commas and "y" (and).

- extension_ha:

  Numeric. Total area of the protected area in hectares.

- fuente:

  Character. Data source, typically "SERNANP" (Servicio Nacional de
  Áreas Naturales Protegidas por el Estado).

- version:

  Character. Version date of the official list in DD-MM-YYYY format.

## Source

Official List of State-Protected Natural Areas, National Service of
State-Protected Natural Areas (SERNANP), Peru.
<https://www.gob.pe/institucion/sernanp/informes-publicaciones/2560580-listado-oficial-de-las-areas-naturales-protegidas>

## Details

This dataset includes all categories of state-protected natural areas in
Peru:

- National Parks (Parques Nacionales - PN)

- National Sanctuaries (Santuarios Nacionales - SN)

- Historical Sanctuaries (Santuarios Históricos - SH)

- National Reserves (Reservas Nacionales - RN)

- Wildlife Refuges (Refugio de Vida Silvestre - RVS)

- Landscape Reserves (Reservas Paisajísticas - RP)

- Communal Reserves (Reservas Comunales - RC)

- Protection Forests (Bosques de Protección - BP)

- Hunting Reserves (Cotos de Caza - CC)

- Reserved Zones (Zonas Reservadas - ZR)

- Regional Conservation Areas (Áreas de Conservación Regional - ACR)

- Private Conservation Areas (Áreas de Conservación Privada - ACP)

The protected areas system in Peru covers various ecosystems including
Amazon rainforest, Andean highlands, coastal deserts, and marine
environments. The dataset reflects the official status as of the version
date specified in the `version` variable.

Legal instruments referenced include:

- LEY: Law passed by Congress

- D.S.: Decreto Supremo (Supreme Decree)

- R.M.: Resolución Ministerial (Ministerial Resolution)

- D.L.: Decreto Ley (Decree Law)

## See also

- SERNANP official website: <https://www.gob.pe/sernanp>

- Peru's National System of State-Protected Natural Areas (SINANPE)

## Examples

``` r
if (FALSE) { # \dontrun{
# Load the dataset
data(anp_list)

# View the first few entries
head(anp_list)

# Count protected areas by category
table(anp_list$categoria)

# Find the largest protected area
anp_list[which.max(anp_list$extension_ha), ]

# List all National Parks
subset(anp_list, categoria == "PARQUES NACIONALES")

# Protected areas created after 2000
subset(anp_list, fecha_promulgacion_creacion > as.Date("2000-01-01"))

# Total protected area (hectares) by category
aggregate(extension_ha ~ categoria, data = anp_list, FUN = sum)

} # }
```
