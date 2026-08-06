test_that("datasets are loadable", {
    expect_no_error(data("anp_list", package = "rbioanp"))
    expect_no_error(data("anp_species_fauna", package = "rbioanp"))
    expect_no_error(data("anp_species_flora", package = "rbioanp"))
    expect_no_error(data("anp_species_occ", package = "rbioanp"))
    expect_no_error(data("anp_especies_distr", package = "rbioanp"))

    expect_s3_class(anp_list, "data.frame")
    expect_s3_class(anp_species_fauna, "data.frame")
    expect_s3_class(anp_species_flora, "data.frame")
    expect_s3_class(anp_species_occ, "data.frame")
    expect_s3_class(anp_especies_distr, "data.frame")

    expect_true("ubicacion_politica" %in% colnames(anp_list))
    expect_true("familia" %in% colnames(anp_species_flora))
})

