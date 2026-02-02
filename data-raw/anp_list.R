# Cargar librerías necesarias ----
library(tidyverse)      # Manipulación de datos
library(tabulapdf)      # Extracción de tablas desde PDF
library(readxl)         # Lectura de archivos Excel
library(usethis)        # Para use_data()

# Definir funciones auxiliares ----

#' Estandarizar formato de números de normas legales
#'
#' Convierte variaciones de "N°", "Nº", "N o", etc. a un formato estándar "No"
#'
#' @param x Vector de caracteres con números de normas legales
#' @return Vector de caracteres estandarizado
#' @examples
#' estandarizar_numero("LEY N° 13694") # "LEY No 13694"
estandarizar_numero <- function(x) {
  x |>
    # Eliminar espacios redundantes
    stringr::str_squish() |>
    # Reemplazar N°, Nº, N o, No, etc. por "No"
    stringr::str_replace_all(
      stringr::regex("\\bN\\s*[º°o]?\\b", ignore_case = TRUE),
      "No"
    ) |>
    # Limpiar si quedó "No °" o "No º"
    stringr::str_replace_all(
      stringr::regex("\\bNo\\s*[º°]\\s*", ignore_case = TRUE),
      "No "
    ) |>
    # Asegurar un solo espacio después de "No"
    stringr::str_replace_all("No\\s+", "No ") |>
    # Limpieza final de espacios
    stringr::str_squish()
}

#' Eliminar tildes conservando la letra Ñ
#'
#' @param texto Un vector de caracteres (columna de texto).
#' @return El mismo texto sin acentos ni diéresis.
limpiar_tildes <- function(texto) {
  con_tilde <- "áéíóúÁÉÍÓÚüÜ"
  sin_tilde <- "aeiouAEIOUuU"

  chartr(con_tilde, sin_tilde, texto)
}

# Extracción inicial de datos desde PDF (opcional) ----
# Este paso puede omitirse si ya se tiene el archivo Excel procesado

# Ruta al archivo PDF original
#ruta_pdf <- "data-raw/listado-oficial-anp-06-01-2026.pdf"

# Extraer tablas del PDF usando tabulapdf
# Nota: Este método requiere ajuste manual posterior
#text_tables <- extract_tables(ruta_pdf)

# Convertir a tibble y limpiar nombres de columnas
# datos_pdf <- text_tables |>
#   as.data.frame() |>
#   tibble::as_tibble() |>
#   janitor::clean_names()

# Exportar a Excel para formateo manual (paso intermedio)
# writexl::write_xlsx(datos_pdf, "data-raw/listado-oficial-anp-06-01-2026.xlsx")

# Lectura y procesamiento del archivo Excel ----

# Leer el archivo Excel con la lista formateada manualmente
# Fuente: Listado oficial de las Áreas Naturales Protegidas del SINANPE
# Actualizado al: 16 de diciembre de 2025
anp_list <- readxl::read_excel("data-raw/listado-oficial-anp-06-01-2026.xlsx") |>

  # Limpiar y convertir extensión a numérico
  # Eliminar espacios en blanco de los números
  dplyr::mutate(
    extension_ha = as.numeric(gsub("\\s+", "", extension_ha))
  ) |>

  # Convertir fecha de promulgación a formato Date
  # Formato original: dd.mm.yyyy
  dplyr::mutate(
    fecha_promulgacion_creacion = as.Date(
      fecha_promulgacion_creacion,
      format = "%d.%m.%Y"
    )
  ) |>

  # Estandarizar formato de números en base legal de creación
  dplyr::mutate(
    base_legal_creacion = estandarizar_numero(base_legal_creacion)
  ) |>

  # Estandarizar formato de números en base legal de modificación
  dplyr::mutate(
    base_legal_modificacion = estandarizar_numero(base_legal_modificacion)
  ) |>
  # remover las tildes de la variable nombre
  dplyr::mutate(
    nombre = limpiar_tildes(nombre)
  ) |>

  # Corrección específica para un caso particular
  # Agregar espacio faltante en D.S. No017-93-PCM
  dplyr::mutate(
    base_legal_modificacion = dplyr::if_else(
      base_legal_modificacion == "D.S. No017-93-PCM",
      "D.S. No 017-93-PCM",
      base_legal_modificacion
    )
  ) |>
  dplyr::mutate(nombre = dplyr::if_else(
    nombre == "SISTEMA DE\rISLAS, ISLOTES Y\rPUNTAS\rGUANERAS",
    "Sistema de Islas, Islotes y Puntas Guaneras",
    nombre
  ) |>
    stringr::str_squish()
    ) |>
  dplyr::mutate(fuente = "SERNANP",
                version = "16-12-2025")

# Verificar estructura del dataset ----
glimpse(anp_list)

# Verificar registros por categoría
anp_list |>
  count(categoria, sort = TRUE)

# Resumen de extensiones
anp_list |>
  group_by(categoria) |>
  summarise(
    total_anp = n(),
    extension_total_ha = sum(extension_ha, na.rm = TRUE),
    extension_media_ha = mean(extension_ha, na.rm = TRUE),
    extension_min_ha = min(extension_ha, na.rm = TRUE),
    extension_max_ha = max(extension_ha, na.rm = TRUE)
  )

# Guardar como dataset del paquete ----

# Documentación del dataset:
# Listado oficial de las Áreas Naturales Protegidas
# Sistema de Áreas Naturales Protegidas por el Estado (SINANPE)
# Fuente: Servicio Nacional de Áreas Naturales Protegidas por el Estado (SERNANP)
# Fecha de actualización: 16 de diciembre de 2025
#
# Variables:
# - categoria: Categoría de ANP (ej: PARQUES NACIONALES, RESERVAS NACIONALES)
# - codigo: Código de identificación (ej: PN 01, RN 02)
# - nombre: Nombre del ANP
# - codigo_2: Código secundario (para subdivisiones)
# - nombre_2: Nombre secundario (para subdivisiones)
# - base_legal_creacion: Norma legal de creación
# - fecha_promulgacion_creacion: Fecha de promulgación de creación
# - base_legal_modificacion: Norma legal de modificación (si aplica)
# - fecha_promulgacion_modificacion: Fecha de promulgación de modificación
# - ubicacion_politica: Departamento(s) donde se ubica
# - extension_ha: Extensión en hectáreas

usethis::use_data(anp_list, overwrite = TRUE, compress = "xz")

# Mensaje de confirmación
message("✓ Dataset 'anp_list' guardado exitosamente")
message("  Total de ANP: ", nrow(anp_list))
message("  Categorías: ", n_distinct(anp_list$categoria))
