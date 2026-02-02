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

files <- list.files("data-raw\\fauna",
                    full.names = TRUE)
files

fauna <- purrr::map_dfr(files,
                        ~readr::read_csv(.) |>
                          dplyr::mutate(grupo = .) |>
                          dplyr::relocate(grupo)) |>
  tidyr::drop_na() |>
  janitor::clean_names() |>
  dplyr::mutate(grupo = stringr::str_remove_all(
    grupo,
    ".*[/\\\\]|\\.csv$"
  ) |>
    stringr::str_to_sentence()
  )

fauna_by_especie <- fauna |>
  group_by(especie) |>
  summarise(n_familia = n_distinct(familia),
            n_orden = n_distinct(orden),
            n_clase = n_distinct(clase))

fauna_by_especie |>
  count(n_familia)

fauna_by_especie |>
  count(n_orden)

fauna_by_especie |>
  count(n_clase)

spe_multi_orden <- fauna |>
  group_by(especie) |>
  filter(n_distinct(orden) > 1) |>
  summarise(ordenes_encontradas = paste(unique(orden), collapse = ", "))

spe_multi_orden

# Limpieza de especies con multiples ORDENES
res_ordem <- taxize::classification(spe_multi_orden$especie, db = "itis")

tabla_ordenes <-
  res_ordem |>
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
spe_multi_orden

clean_orden <- spe_multi_orden |>
  left_join(tabla_ordenes) |>
  select(-ordenes_encontradas)

clean_orden
fauna
fauna_clean <- fauna |>
  left_join(clean_orden, by = "especie") |>
  mutate(orden_clean = if_else(
    is.na(orden_clean),
    orden,
    orden_clean
  ))

fauna_clean |>
  pull(orden_clean) |>
  unique()
# Limpiar especies sin ORDEN

species_sin_orden <- fauna_clean |>
  filter(orden_clean == "'-" )

species_sin_orden

sp_sin_ordem <- taxize::classification(species_sin_orden$especie, db = "itis")
sp_sin_ordem

tabla_ordenes_2 <-
  sp_sin_ordem |>
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
  select(especie, orden_clean2 = orden_clean)

tabla_ordenes_2

species_sin_orden

fauna_clean_2 <- fauna_clean |>
  left_join(tabla_ordenes_2, by = "especie") |>
  #filter(orden_clean == "'-" ) |>
  mutate(orden_clean = if_else(
    orden_clean == "'-",
    orden_clean2,
    orden_clean
  )) |>
  mutate(orden_clean =  case_when(
    especie == "Genyatremus pacifici" ~ "Perciformes",
    especie == "Rhencus panamensis" ~ "Perciformes",
    especie == "Haemulopsis nitida" ~ "Perciformes",
    TRUE ~ orden_clean
      ))




fauna_clean_2 |>
  pull(orden_clean) |>
  unique()

fauna_clean_2 |>
  pull(familia) |>
  unique()

fauna_final <- fauna_clean_2 |>
  # Limpiar comillas en nombres de especies
  dplyr::mutate(especie_clean = stringr::str_remove_all(especie, '"')) |>
  dplyr::mutate(especie_clean = str_remove_all(especie, "[\\\"']")) |>
  dplyr::mutate(nword = stringi::stri_count_words(especie)) |>
  #distinct(nword) |>
  tidyr::extract(
    especie_clean,
    into = c("subgenero_temp", "epiteto_temp"),
    regex = "\\((.*?)\\)\\s+(\\w+)",
    remove = FALSE
  ) |>
  dplyr::mutate(
    # Solo creamos el sinónimo si cumple AMBAS condiciones
    sinonimo = dplyr::if_else(
      nword == 3 & stringr::str_detect(especie, " \\("),
      paste(subgenero_temp, epiteto_temp) |> str_to_simple_cap(),
      NA_character_ # O mantener el valor previo si ya existía la columna
    ),
    # Solo limpiamos el nombre si cumple AMBAS condiciones
    especie_clean = dplyr::if_else(
      nword == 3 & stringr::str_detect(especie, " \\("),
      stringr::str_replace(especie_clean, "\\s*\\(.*?\\)", ""),
      especie_clean # Si no cumple, se queda como estaba
    )
  ) |>
  dplyr::select(-subgenero_temp, -epiteto_temp) |>
  dplyr::mutate(especie_clean = case_when(
    especie == "Dendropsophus timbeba (Dendropsophus allenorum )" ~ "Dendropsophus timbeba",
    especie == "Ranitomeya sirensis (Ranitomeya biolat, Ranitomeya lamasi )" ~ "Ranitomeya sirensis",
    especie == "Lonomia (Lonomia) descimoni descimoni" ~ "Lonomia descimoni descimoni",
    especie == "Chrysops varians var. Turdus" ~ "Chrysops varians var turdus",
    TRUE ~ especie_clean
  )) |>
  dplyr::mutate(sinonimo = case_when(
    especie == "Dendropsophus timbeba (Dendropsophus allenorum )" ~ "Dendropsophus allenorum",
    especie == "Ranitomeya sirensis (Ranitomeya biolat, Ranitomeya lamasi )" ~ "Ranitomeya biolat - Ranitomeya lamasi",
    especie == "Lonomia (Lonomia) descimoni descimoni" ~ "Lonomia descimoni",
    TRUE ~ sinonimo
  )) |>
  dplyr::filter(!especie %in% c(
    # Familias registradas como especies
    "Cyprinodontidae", "Salmonidae", "Trichomycteridae")) |>
  # Clasificar rangos taxonómicos
  dplyr::mutate(rango_taxonomico = dplyr::case_when(
    stringr::str_detect(especie_clean, "[a-z]{1,} [a-z]{1,} [a-z]{1,}") ~ "Infraespecie",
    stringr::str_detect(especie_clean, " var\\. ") ~ "Infraespecie",
    nword == 2 ~ "Especie",
    stringr::str_detect(especie_clean, " [a-z]{1,}-[a-z]{1,}") ~ "Especie",
    stringi::stri_count_words(especie_clean) == 2 ~ "Especie",
    stringi::stri_count_words(especie_clean) == 3 ~ "Infraespecie",
    TRUE ~ NA_character_
  )) |>
  dplyr::distinct()

fauna_final

anp_species_fauna <-
  fauna_final |>
  dplyr::select(
    grupo, clase,
    orden = orden_clean,
    familia,
    especie = especie_clean,
    sinonimo, rango_taxonomico)
anp_species_fauna

# Guardar el dataset en el paquete ----
usethis::use_data(anp_species_fauna,
                  compress = "xz",
                  overwrite = TRUE)
anp_species_fauna |>
  glimpse()

summary(anp_species_fauna)
