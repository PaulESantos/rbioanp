devtools::load_all()
library(tidyverse)
data("anp_list")
anplist_2 <- anp_list |>
as_tibble() |>
  distinct(categoria, nombre) |>
  mutate(categoria = str_to_title(categoria)) |>
  # Lógica para cambiar a singular
  mutate(categoria = case_when(
    categoria == "Parques Nacionales"          ~ "Parque Nacional",
    categoria == "Santuarios Nacionales"       ~ "Santuario Nacional",
    categoria == "Santuarios Historicos"       ~ "Santuario Historico",
    categoria == "Reservas Nacionales"         ~ "Reserva Nacional",
    categoria == "Reservas Paisajísticas"      ~ "Reserva Paisajistica",
    categoria == "Reservas Comunales"          ~ "Reserva Comunal",
    categoria == "Bosques De Proteccion"       ~ "Bosque de Proteccion",
    categoria == "Cotos De Caza"               ~ "Coto de Caza",
    categoria == "Zonas Reservadas"            ~ "Zona Reservada",
    categoria == "Areas De Conservacion Regional" ~ "Area de Conservacion Regional",
    categoria == "Areas De Conservacion Privada"  ~ "Area de Conservacion Privada",
    TRUE ~ categoria # Mantiene igual si no coincide (ej. Refugio de Vida Silvestre)
  ))

anplist_2 |>
  filter(categoria != "Area de Conservacion Privada") |>
  as.data.frame()

# ---------------------------------------------------------------
# 1. Definir la ruta base donde se crearán las carpetas
# Cambia esto por la ruta de tu preferencia
ruta_destino <- "data-raw\\anp"

# 2. Crear la función para generar las carpetas
crear_carpetas_anp <- function(datos, path_base) {

  # Creamos un vector con las rutas combinadas: Ruta/Categoria/Nombre
  rutas_completas <- datos |>
    mutate(ruta_final = file.path(path_base, categoria, nombre)) |>
    pull(ruta_final)

  # Ejecutamos la creación
  # recursive = TRUE permite crear la carpeta padre (categoria) y la hija (nombre) a la vez
  walk(rutas_completas, ~dir.create(.x, recursive = TRUE, showWarnings = FALSE))

  message("Estructura de carpetas creada exitosamente en: ", path_base)
}

# 3. Ejecutar el proceso con tu dataframe filtrado
anplist_2 |>
  filter(categoria != "Area de Conservacion Privada") |>
  crear_carpetas_anp(path_base = ruta_destino)



# ---------------------------------------------------------------
# 1. Definir la ruta donde están tus carpetas
ruta_base <- "data-raw\\anp"

# 2. Obtener todas las subcarpetas (Nivel: Nombre del ANP)
# Usamos recursive = TRUE pero filtramos para quedarnos solo con las carpetas de nivel "Nombre"
todas_las_carpetas <- list.dirs(ruta_base, full.names = TRUE, recursive = TRUE)

# 3. Analizar el contenido de cada carpeta
reporte_carpetas <- tibble(ruta = todas_las_carpetas) |>
  # Filtramos para excluir la carpeta raíz y las carpetas de "Categoría"
  # (asumiendo que las carpetas de 'Nombre' son las que están al final)
  mutate(nivel = str_count(ruta, "/")) |>
  filter(nivel == max(nivel)) |>
  # Contamos archivos
  mutate(
    total_archivos = map_int(ruta, ~length(list.files(.x))),
    n_excel = map_int(ruta, ~length(list.files(.x, pattern = "\\.csv$|\\.csv$"))),
    n_pdf = map_int(ruta, ~length(list.files(.x, pattern = "\\.pdf$")))
  ) |>
  # Identificamos cuáles NO cumplen con (3 Excel + 1 PDF)
  mutate(estado = case_when(
    total_archivos == 0 ~ "Vacía",
    n_excel == 3 & n_pdf == 1 ~ "Completa",
    TRUE ~ "Incompleta"
  ))

# 4. Ver solo las que tienen problemas
carpetas_con_problemas <- reporte_carpetas |>
  filter(estado != "Completa") |>
  select(ruta, total_archivos, n_excel, n_pdf, estado)

carpetas_con_problemas |>
  filter(!str_detect(ruta, "Regional")) |>
  mutate(ruta = str_remove(ruta, "^data-raw[\\\\/]+anp[\\\\/]+")) |>
  as.data.frame()

#                                               ruta total_archivos n_excel n_pdf     estado
# 1           Bosque de Proteccion/Puquio Santa Rosa              2       2     0 Incompleta
# 2             Reserva Comunal/Bajo Putumayo Yaguas              0       0     0      Vacía
# 3                 Reserva Nacional/Dorsal de Nasca              2       2     0 Incompleta
# 4            Reserva Nacional/Mar Tropical de Grau              3       3     0 Incompleta
# 5 Zona Reservada/Reserva Paisajistica Cerro Khapia              2       1     1 Incompleta


# ---------------------------------------------------------------
# Evaluar los archivos

# 1. Definir la ruta base donde están tus carpetas
ruta_base <- "data-raw\\anp"

# 2. Obtener la lista de carpetas de nivel ANP (excluyendo la raíz y carpetas de categoría)
todas_las_carpetas <- list.dirs(ruta_base, full.names = TRUE, recursive = TRUE)
todas_las_carpetas
# Filtramos para quedarnos solo con las carpetas que están al final de la ruta (nivel nombre)
audit_anp <- tibble(ruta = todas_las_carpetas) |>
  mutate(nivel = str_count(ruta, "/")) |>
  filter(nivel == max(nivel)) |>
  mutate(nombre_anp = basename(ruta))

audit_anp

# 3. Función para verificar la existencia de archivos por patrón
verificar_archivos <- function(path) {
  archivos <- list.files(path, ignore.case = TRUE)

  tibble(
    tiene_especies   = any(str_detect(archivos, "especies")),
    tiene_amenazadas = any(str_detect(archivos, "amenazadas")),
    tiene_endemicas  = any(str_detect(archivos, "endemicas")),
    tiene_csv        = any(str_detect(archivos, "csv")),
    tiene_pdf        = any(str_detect(archivos, "\\.pdf$"))
  )
}

# 4. Ejecutar la auditoría
reporte_faltantes <- audit_anp |>
  filter(!str_detect(ruta,"Area de Conservacion Regional")) |>
  mutate(verificacion = map(ruta, verificar_archivos)) |>
  unnest(verificacion) |>
  # Identificamos dónde falta algo (enfocado en los 3 excel/csv + el PDF)
  mutate(completo = tiene_especies & tiene_amenazadas & tiene_endemicas & tiene_pdf)

# 5. Listar solo las carpetas donde falta al menos un archivo
carpetas_incompletas <- reporte_faltantes |>
  filter(!completo) |>
  select(nombre_anp, tiene_especies, tiene_amenazadas, tiene_endemicas, tiene_pdf)

# Ver el resultado
carpetas_incompletas
# # A tibble: 5 × 5
# nombre_anp                        tiene_especies tiene_amenazadas tiene_endemicas tiene_pdf
# <chr>                             <lgl>          <lgl>            <lgl>           <lgl>
# 1 Puquio Santa Rosa                 TRUE           FALSE            TRUE            FALSE
# 3 Dorsal de Nasca                   TRUE           TRUE             FALSE           FALSE
# 4 Mar Tropical de Grau              TRUE           TRUE             TRUE            FALSE
# 5 Reserva Paisajistica Cerro Khapia TRUE           FALSE            FALSE           TRUE

# ---------------------------------------------------------------

#------------------------------------------------------------
# helpers
#------------------------------------------------------------
.safe_read_csv <- function(path) {
  if (!file.exists(path)) return(NULL)
  readr::read_csv(path, show_col_types = FALSE, progress = FALSE) |>
    tidyr::drop_na()
}

# Asegura que exista columna Especie y la normaliza mínimamente
.get_species_vec <- function(df) {
  if (is.null(df)) return(character(0))
  if (!"Especie" %in% names(df)) return(character(0))
  df |>
    dplyr::pull(Especie) |>
    as.character() |>
    str_squish()
}


.list_dirs_fs <- function(root_dir) {
  dirs <- fs::dir_ls(root_dir, type = "directory", recurse = TRUE)

  # hoja = directorio con 0 subdirectorios
  dirs[fs::dir_info(dirs)$type == "directory" &
         lengths(fs::dir_ls(dirs, type = "directory")) == 0]
}


#------------------------------------------------------------
# 1) Procesa UNA carpeta de ANP
#------------------------------------------------------------
consolidar_anp_folder <- function(
    folder,
    out_dir = folder,
    anp_name = basename(folder),
    base_file = "especies.csv",
    endem_file = "endemicas.csv",
    amen_file = "amenazadas.csv",
    overwrite = TRUE
) {
  folder <- normalizePath(folder, winslash = "/", mustWork = TRUE)

  f_especies <- file.path(folder, base_file)
  if (!file.exists(f_especies)) {
    stop("No existe el archivo base '", base_file, "' en: ", folder)
  }

  especies <- .safe_read_csv(f_especies)
  if (!"Especie" %in% names(especies)) {
    stop("El archivo base no tiene columna 'Especie': ", f_especies)
  }

  endemicas   <- .safe_read_csv(file.path(folder, endem_file))
  amenazadas  <- .safe_read_csv(file.path(folder, amen_file))

  v_especies <- str_squish(as.character(especies$Especie))
  v_endem    <- .get_species_vec(endemicas)
  v_amen     <- .get_species_vec(amenazadas)

  out <- especies |>
    mutate(
      Especie  = v_especies,
      endemica = Especie %in% v_endem,
      amenazada = Especie %in% v_amen
    )

  out_name <- paste0("especies_", str_replace_all(anp_name, "\\s+", "_"), ".csv")
  out_path <- file.path(out_dir, out_name)

  if (file.exists(out_path) && !isTRUE(overwrite)) {
    stop("El archivo ya existe y overwrite=FALSE: ", out_path)
  }

  readr::write_csv(out, out_path)
  invisible(out_path)
  return(out)
}

#------------------------------------------------------------
# 2) Procesa MUCHAS carpetas (recursivo): busca especies.csv
#------------------------------------------------------------
consolidar_anp_tree <- function(
    root_dir,
    out_dir = NULL,
    base_file = "especies.csv",
    endem_file = "endemicas.csv",
    amen_file = "amenazadas.csv",
    overwrite = TRUE
) {
  root_dir = "data-raw/anp"
  base_file = "especies.csv"
  endem_file = "endemicas.csv"
  amen_file = "amenazadas.csv"

  root_dir <- normalizePath(root_dir, winslash = "/", mustWork = TRUE)
  root_dir
  folders <- list.dirs(root_dir)
  folders
  root_dir <- normalizePath(root_dir, winslash = "/", mustWork = TRUE)
  root_dir
  folders <- list.dirs(root_dir, recursive = TRUE, full.names = TRUE)
  folders
  # una carpeta es "final" si ninguna otra empieza con ella + "/"
  folders_slash <- paste0(folders, "/")
  folders_slash

  is_parent <- vapply(
    folders_slash,
    function(x) any(startsWith(folders_slash, x) & folders_slash != x),
    logical(1)
  )

  .folders <- folders[!is_parent]
  .folders
  # Solo carpetas donde exista especies.csv
  target_folders <- .folders[file.exists(file.path(.folders, base_file))]
  target_folders



  if (length(target_folders) == 0) {
    stop("No se encontró '", base_file, "' en ningún subdirectorio de: ", root_dir)
  }

  purrr::map(target_folders, \(f) {
    anp_name <- basename(f)
    consolidar_anp_folder(
      folder = f,
      out_dir = f,
      anp_name = basename(f),
      base_file = base_file,
      endem_file = endem_file,
      amen_file = amen_file,
      overwrite = TRUE
    )
  })
}
consolidar_anp_tree(root_dir = "data-raw/anp")

# ---------------------------------------------------------------

archivos_consolidados <- list.files("data-raw\\anp",
                                    recursive = TRUE,
                                    pattern = "^especies_",
                                    full.names = TRUE)

especies_anp <- purrr::map_dfr(archivos_consolidados,
                               ~arrow::read_csv_arrow(.) |>
                                 dplyr::mutate(filename = .) |>
                                 dplyr::relocate(filename))

anp_species <- especies_anp |>
  mutate(filename = str_extract(filename,
                                "(?<=\\\\anp/).*(?=/especies_)")) |>
  separate_wider_delim(
    cols = filename,
    names = c("categoria", "anp_name"),
    delim = "/"
  ) |>
  #select(-filename) |>
  relocate(categoria, anp_name) |>
  janitor::clean_names() |>
  dplyr::mutate(anp_name = dplyr::case_when(
    anp_name == "AllpahuayoMishana" ~ "Allpahuayo Mishana",
    TRUE ~ anp_name
  )
                  )

anp_species  |>
  distinct(categoria, anp_name)
anp_species |>
  distinct(anp_name) |>
  flatten_chr()
anp_species |>
  select(-c(1:2)) |>
  distinct()
