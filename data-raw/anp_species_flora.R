library(tidyverse)

# Funciones auxiliares
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

files <- list.files("data-raw\\flora",
           full.names = TRUE)

flora <- purrr::map_dfr(files,
                        ~readr::read_csv(.) |>
                          dplyr::mutate(grupo = .) |>
                          dplyr::relocate(grupo)
                        ) |>
  tidyr::drop_na() |>
  janitor::clean_names() |>
  dplyr::mutate(grupo = stringr::str_remove_all(
    grupo,
    ".*[/\\\\]|\\.csv$"
  ) |>
    stringr::str_to_sentence()
    ) |>
  dplyr::mutate(orden = dplyr::case_when(
    orden %in% c("Lophocoleineae", "Jungermanniineae") ~ "Jungermanniales",
    TRUE ~ orden
  )) |>
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
  dplyr::select(-grupo) |>
  dplyr::distinct()

flora

flora |>
  add_count(especie) |>
  filter(n != 1) |>
  group_by(especie) |>
  summarise(n_or = n_distinct(orden),
            n_fam = n_distinct(familia))


# Limpieza de especies con mas de un orden y familia

by_specie <- flora |>
  group_by(especie) |>
  summarise(n_familias = n_distinct(familia),
            n_orden = n_distinct(orden),
            n_clase = n_distinct(clase))

# FAMILIAS
by_specie |>
  count(n_familias)

spe_multi_fam <- flora |>
  group_by(especie) |>
  filter(n_distinct(familia) > 1) |>
  summarise(familias_encontradas = paste(unique(familia), collapse = ", "))
spe_multi_fam

library(TNRS)

sp_clean <- TNRS(spe_multi_fam$especie_clean,
                 sources = "wcvp")

clean_familias <- left_join(spe_multi_fam,
  sp_clean |>
  select(Name_submitted, Accepted_family),
  by = c("especie" = "Name_submitted")) |>
  janitor::clean_names()

# ORDENES
by_specie |>
  count(n_orden)

spe_multi_ord <- flora |>
  group_by(especie) |>
  filter(n_distinct(orden) > 1) |>
  summarise(ordenes_encontradas = paste(unique(orden), collapse = ", "))

spe_multi_ord

library(taxize)

res <- classification(spe_multi_ord$especie, db = "tropicos")

tabla_ordenes <-
res |>
  unclass() |>
  enframe(name = "especie", value = "datos") |>
  mutate(orden_clean = map_chr(datos, function(x) {

    if (!is.data.frame(x)) return(NA_character_)

    val <- x %>%
      filter(rank == "order") %>%
      pull(name)

    if (length(val) == 0) return(NA_character_)
    return(val)
  })) |>
  select(especie, orden_clean)

tabla_ordenes

clean_ordenes <- spe_multi_ord |>
  left_join(tabla_ordenes,
            by = c("especie" = "especie"))
#====================================================================

flora
clean_familias
clean_ordenes

# Realizamos la integración secuencialmente
flora_actualizada <- flora |>
  # 1. Unimos con clean_familias para traer 'accepted_family'
  left_join(
    clean_familias |>  select(especie, accepted_family),
    by = "especie"
  ) |>
  # 2. Unimos con clean_ordenes para traer 'orden_clean'
  left_join(
    clean_ordenes |>  select(especie, orden_clean),
    by = "especie"
  ) |>
  # 3. Renombramos la columna si deseas mantener el nombre exacto 'familia_clean'
  rename(familia_clean = accepted_family) |>
  mutate(
    familia_clean = if_else(
    is.na(familia_clean),
    familia,
    familia_clean),
    orden_clean = if_else(
      is.na(orden_clean),
      orden,
      orden_clean
    )
    )

# Verificamos el resultado
flora_final <- flora_actualizada |>
  select(especie_clean, familia_clean, orden_clean,
         rango_infraespecifico, rango_taxonomico) |>
  distinct()

flora_final
anp_species_flora <- flora_final |>
  rename(especie = especie_clean,
         fammilia = familia_clean,
         orden = orden_clean)
anp_species_flora

# Guardar el dataset en el paquete ----
usethis::use_data(anp_species_flora,
                  compress = "xz",
                  overwrite = TRUE)


