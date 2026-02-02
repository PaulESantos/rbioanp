#' Species Occurrence Records in Peru's Protected Natural Areas
#'
#' Dataset containing biodiversity occurrence records from Peru's Protected
#' Natural Areas (ANP) within the National System of State Protected Natural
#' Areas (SINANPE).
#'
#' @format A tibble with 55,155 rows and 12 columns:
#' \describe{
#'   \item{anp_categoria}{Protected Natural Area category (e.g., "National Park",
#'     "National Reserve", "National Sanctuary")}
#'   \item{anp_nombre}{Protected Natural Area name}
#'   \item{clase}{Taxonomic class}
#'   \item{orden}{Taxonomic order}
#'   \item{familia}{Taxonomic family}
#'   \item{especie}{Scientific name of the species}
#'   \item{endemica}{Logical indicator of whether the species is endemic to Peru}
#'   \item{amenazada}{Logical indicator of whether the species is under any threat category}
#'   \item{rango_infraespecifico}{Infraspecific rank if applicable (var, subsp, fo, subvar, hibrido, infrasp)}
#'   \item{sinonimo}{Taxonomic synonym presented as part of the original name}
#'   \item{rango_taxonomico}{Rank classification ("Especie", "Infraespecie")}
#' }
#'
#' @details
#' The dataset has been processed to:
#' \itemize{
#'   \item Standardize the structure of scientific names
#'   \item Remove invalid records at the species level (families, genera, sections)
#'   \item Identify infraspecific ranks (varieties, subspecies, forms)
#'   \item Extract synonyms from scientific names
#'   \item Classify the taxonomic rank of each record
#' }
#'
#' @source Data downloaded from the \href{https://biodiversidadanp.sernanp.gob.pe/}{bioANP platform},
#'   developed by the National Service of State Protected Natural Areas (SERNANP)
#'
#' @examples
#' # Load dataset
#' data(anp_species_occ)
#'
#' # View structure
#' str(anp_species_occ)
#'
#' # Endemic threatened species
#' anp_species_occ |>
#'   dplyr::filter(endemica == TRUE, amenazada == TRUE)
#'
#' # Species by protected area
#' anp_species_occ |>
#'   dplyr::count(anp_nombre, sort = TRUE)
#'
#' # Distribution by taxonomic class
#' anp_species_occ |>
#'   dplyr::count(clase, sort = TRUE)
"anp_species_occ"
