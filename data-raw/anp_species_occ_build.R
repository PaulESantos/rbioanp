## code to prepare `anp_species_occ` dataset goes here
## Este script procesa datos de ocurrencia de especies en Áreas Naturales Protegidas del Perú

# Cargar librerías necesarias ----
library(tidyverse)

# Funciones auxiliares ----

#' Convertir texto a formato de capitalización simple
#'
#' Convierte todo el texto a minúsculas excepto la primera letra
#'
#' @param text Cadena de texto a convertir
#' @return Texto con la primera letra en mayúscula y el resto en minúsculas
#' @noRd
str_to_simple_cap <- function(text) {
  # Convertir todo el texto a minúsculas
  text <- tolower(text)

  # Obtener la primera letra y convertirla a mayúscula
  first_letter <- toupper(substr(text, 1, 1))

  # Obtener el resto del texto desde la segunda letra en adelante
  rest_text <- substr(text, 2, nchar(text))

  # Combinar la primera letra en mayúscula con el resto del texto en minúsculas
  result <- paste0(first_letter, rest_text)

  return(result)
}

# Procesamiento de datos ----

anp_species_occ <- readxl::read_excel("data-raw/anp_species_oc.xlsx") |>
  # Corregir nombres de órdenes mal clasificados
  dplyr::mutate(orden = dplyr::case_when(
    orden %in% c("Lophocoleineae", "Jungermanniineae") ~ "Jungermanniales",
    TRUE ~ orden
  )) |>
  # Renombrar columnas para consistencia
  dplyr::rename(
    anp_nombre = anp_name,
    anp_categoria = categoria
  ) |>
  # Limpiar comillas en nombres de especies
  dplyr::mutate(especie_clean = stringr::str_remove_all(especie, '"')) |>
  dplyr::mutate(especie_clean = str_remove_all(especie, "[\\\"']")) |>
  # Corregir errores tipográficos específicos en nombres de especies
  dplyr::mutate(especie = dplyr::case_when(
    especie == "Peperomia rotundatavar. rotundata" ~ "Peperomia rotundata var. rotundata",
    TRUE ~ especie
  )) |>
  dplyr::mutate(especie_clean = dplyr::case_when(
    especie == "Pitcairnia pungens var pungens" ~ "Pitcairnia pungens var. pungens",
    especie == "Peperomia rotundatavar. rotundata" ~ "Peperomia rotundata var. rotundata",
    especie == "Calceolaria nivalis subesp. cerasifolia" ~ "Calceolaria nivalis subsp. cerasifolia",
    especie == "\"Megoleria\" susiana polymacula" ~ "Megoleria susiana polymacula",
    especie == "\"Hypoleria\" orolina arzalia" ~ "Hypoleria orolina arzalia",
    TRUE ~ especie
  )) |>
  # Aplicar capitalización estandarizada
  dplyr::mutate(especie_clean = str_to_simple_cap(especie_clean)) |>
  # Filtrar registros que no corresponden a especies válidas
  dplyr::filter(!especie %in% c(
    # Familias registradas como especies
    "Cyprinodontidae", "Salmonidae", "Trichomycteridae",
    # Categorías taxonómicas que no corresponden a especie
    "Maxillaria sect. cyrtidiorchis", "Maxillaria sect. ornithidium",
    "Rhynchospora sect. paniculatae", "Solanum sect. geminata",
    "Anthurium sect. Digitinervium", "Anthurium sect. Cardiolonchium",
    "Anthurium sect. Calomystrium",
    # Registros de género como especie
    "Xenophyllum", "Syntrichia", "Rhexophyllum", "Andreaea",
    "Leptodontium", "Gertrudiella"
  )) |>
  # Extraer subgéneros y epítetos de nombres con paréntesis
  tidyr::extract(
    especie_clean,
    into = c("subgenero_temp", "epiteto_temp"),
    regex = "\\((.*?)\\)\\s+(\\w+)",
    remove = FALSE
  ) |>
  # Identificar rangos infraespecíficos
  dplyr::mutate(rango_infraespecifico = dplyr::case_when(
    stringr::str_detect(especie_clean, " var\\.") ~ "var",
    stringr::str_detect(especie_clean, "subsp\\.") ~ "subsp",
    stringr::str_detect(especie_clean, "fo\\.") ~ "fo",
    stringr::str_detect(especie_clean, "subvar\\.") ~ "subvar",
    stringr::str_detect(especie_clean, " x ") ~ "hibrido",
    especie == "Lonomia (Lonomia) descimoni descimoni" ~ "infrasp",
    stringr::str_detect(especie_clean, "[a-z]{1,} [a-z]{1,} [a-z]{1,}") ~ "infrasp",
    TRUE ~ NA_character_
  )) |>
  # Crear sinónimos y limpiar nombres
  dplyr::mutate(
    sinonimo = paste(subgenero_temp, epiteto_temp) |> str_to_simple_cap(),
    especie_clean = stringr::str_replace(especie_clean, "\\s*\\(.*?\\)", "")
  ) |>
  dplyr::select(-subgenero_temp, -epiteto_temp) |>
  # Clasificar rangos taxonómicos
  dplyr::mutate(rango_taxonomico = dplyr::case_when(
    stringr::str_detect(especie_clean, " var\\. | subsp\\. | fo\\. | subvar\\.") ~ "Infraespecie",
    stringr::str_detect(especie_clean, "[a-z]{1,} [a-z]{1,} [a-z]{1,}") ~ "Infraespecie",
    stringi::stri_count_words(especie_clean) == 2 ~ "Especie",
    stringr::str_detect(especie_clean, " [a-z]{1,}-[a-z]{1,}") ~ "Especie",
    stringr::str_detect(especie_clean, "[A-Za-z]{1,} x [a-z]{1,}") ~ "Hibrido",
    especie == "Lonomia (Lonomia) descimoni descimoni" ~ "Infraespecie",
    TRUE ~ NA_character_
  )) |>
  # Limpiar valores NA en sinónimos
  dplyr::mutate(sinonimo = dplyr::if_else(
    sinonimo == "Na na",
    NA_character_,
    sinonimo
  )) |>
  dplyr::mutate(familia = dplyr::case_when(
   familia == "Caricaceae" & especie == "Colicodendron scabridum" ~ "Capparaceae",
   familia == "Passifloraceae" & orden == "Malpighiales" & especie == "Ipomoea carnea" ~ "Convolvulaceae",
    TRUE ~ familia
  )) |>
  dplyr::mutate(orden = dplyr::case_when(
    familia == "Convolvulaceae" & especie == "Ipomoea carnea" ~ "Solanales",
    TRUE ~ orden
  )) |>
  dplyr::distinct()

anp_species_occ
# Guardar el dataset en el paquete ----
usethis::use_data(anp_species_occ,
                  compress = "xz",
                  overwrite = TRUE)

# Opcional: Crear versión comprimida adicional si el dataset es muy grande
# usethis::use_data(anp_species_occ, overwrite = TRUE, compress = "xz")

anp_species_occ
by_species <- anp_species_occ |>
  group_by(especie) |>
  summarise(n_familia = n_distinct(familia),
            n_orden = n_distinct(orden))

by_species |>
  count(n_familia)

species_multi_familia <- anp_species_occ |>
  group_by(especie) |>
  filter(n_distinct(familia) > 1) |>
  summarise(ordenes_encontradas = paste(unique(familia), collapse = ", ")) |>
  ungroup()
  #as.data.frame()


familia_clean <- anp_species_flora |>
  filter(especie %in% species_multi_familia$especie) |>
  select(especie, fammilia_clean = fammilia)

anp_species_occ_1 <- anp_species_occ |>
  left_join(familia_clean,
            by = "especie")


#=====================================================================



by_species |>
  count(n_orden)

species_multi_ornden <- anp_species_occ |>
  group_by(especie) |>
  filter(n_distinct(orden) > 1) |>
  summarise(ordenes_encontradas = paste(unique(orden), collapse = ", ")) |>
  as.data.frame()

species_multi_ornden


anp_species_occ <- anp_species_occ_1 |>
  distinct() |>
  left_join(
anp_species_flora |>
  filter(especie %in% species_multi_ornden$especie ) |>
  select(especie, orden_clean = orden) |> distinct(),
by = "especie"
) |>
left_join(
anp_species_fauna |>
  filter(especie %in% species_multi_ornden$especie ) |>
  select(especie, orden_clean_2 = orden) |> distinct(),
by = "especie"
) |>
  mutate(orden_clean = case_when(
    is.na(orden_clean) ~ orden,
    !is.na(orden_clean_2) ~ orden_clean_2,
    TRUE ~ orden_clean
  )) |>
  mutate(fammilia_clean = if_else(
    is.na(fammilia_clean),
    familia,
    fammilia_clean
  )) |>
  dplyr::select(anp_categoria,
         anp_nombre,
         clase,
         orden = orden_clean,
         familia = fammilia_clean,
         especie = especie_clean,
         sinonimo,
         endemica,
         amenazada,
         rango_infraespecifico,
         rango_taxonomico) |>
  dplyr::mutate(orden = case_when(
  # --- Fauna ---
  especie %in% c("Centropomus unionensis", "Eleotris picta",
                 "Dormitator latifrons", "Halichoeres dispilus") ~ "Perciformes",
  especie %in% c("Achirus klunzingeri", "Trinectes fonsecensis") ~ "Pleuronectiformes",

  # --- Flora (Ordenado por Orden Taxonómico) ---
  especie %in% c("Elodea potamogeton", "Incarum pavonii") ~ "Alismatales",
  especie %in% c("Bidens andicola", "Mniodes coarctata") ~ "Asterales",
  especie == "Clinanthus humilis" ~ "Asparagales",
  especie %in% c("Cordia nodosa", "Cordia bicolor", "Cordia lomatoloba",
                 "Cordia alliodora", "Cordia ucayaliensis", "Nama dichotoma",
                 "Pectocarya lateriflora", "Wigandia urens") ~ "Boraginales",
  especie %in% c("Phytolacca rivinoides", "Calandrinia ciliata") ~ "Caryophyllales",
  especie == "Commelina tuberosa" ~ "Commelinales",
  especie == "Cayaponia tubulosa" ~ "Cucurbitales",
  especie %in% c("Leucaena trichodes", "Monnina salicifolia") ~ "Fabales",
  especie %in% c("Schrebera americana", "Distictella magnoliifolia") ~ "Lamiales",
  especie %in% c("Clusia ducuoides", "Caryocar glabrum", "Casearia obovalis",
                 "Drypetes amazonica", "Xylosma benthamii", "Goupia glabra",
                 "Cassipourea peruviana", "Euphorbia peplus") ~ "Malpighiales",
  especie %in% c("Urena lobata", "Tarasa urbaniana") ~ "Malvales",
  especie == "Dendrobangia boliviana" ~ "Metteniusales",
  especie %in% c("Myrcianthes discolor", "Myrcianthes myrsinoides", "Myrcia aliena",
                 "Eugenia discreta", "Eugenia florida", "Eugenia lambertiana",
                 "Eugenia muricata", "Myrcia fallax", "Eugenia biflora",
                 "Myrcia hylobates", "Myrcia maxima", "Eugenia patrisii",
                 "Myrcia bracteata", "Eugenia heterochroma", "Eugenia multirimosa") ~ "Myrtales",
  especie == "Pseudoconnarus macrophyllus" ~ "Oxalidales",
  especie == "Cyclanthus bipartitus" ~ "Pandanales",
  especie %in% c("Isolepis inundata", "Isolepis nigricans", "Isolepis cernua",
                 "Deuterocohnia longipetala") ~ "Poales",
  especie %in% c("Oreocallis grandiflora", "Lomatia hirsuta", "Roupala monosperma") ~ "Proteales",
  especie %in% c("Urera baccifera", "Urera capitata") ~ "Rosales",
  especie %in% c("Dendrophthora dimorpha", "Quinchamalium procumbens") ~ "Santalales",
  especie == "Trattinnickia peruviana" ~ "Sapindales",
  especie == "Lygodium venustum" ~ "Schizaeales",
  especie %in% c("Ipomoea quamoclit", "Lycopersicon hirsutum",
                 "Ipomoea purpurea", "Ipomoea tiliacea") ~ "Solanales",

  # Valor por defecto
  TRUE ~ orden
))


by_species <- anp_species_occ |>
  group_by(especie) |>
  summarise(n_familia = n_distinct(familia),
            n_orden = n_distinct(orden))

by_species |>
  count(n_familia)
by_species |>
  count(n_orden)

anp_species_occ

usethis::use_data(anp_species_occ,
                  compress = "xz",
                  overwrite = TRUE)
