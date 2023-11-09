




test_that("Matrix table: Columns only", {
  expect_no_error(
    matrix_table(berlinbears, dplyr::starts_with('p_'))
  )
})


test_that("Matrix table: Group by", {
  expect_no_error(
    matrix_table(berlinbears, dplyr::starts_with('p_'),
                 group_by = species,
                 subgroups_to_exclude = 'panda bear' )
    )
})


test_that("Matrix table: Group by, weights", {
  expect_no_error(
    matrix_table(berlinbears, dplyr::starts_with('p_'),
                 group_by = species,
                 subgroups_to_exclude = 'panda bear',
                 weights = weights )
    )
})



# Matrix graph ------------------------------------------------------------



test_that("Matrix graph: Columns only", {
  expect_no_error(
    matrix_graph(berlinbears, dplyr::starts_with('p_'))
  )
})


test_that("Matrix graph: Group by", {
  expect_no_error(
    matrix_graph(berlinbears, dplyr::starts_with('p_'),
                 group_by = species,
                 subgroups_to_exclude = 'panda bear' )
  )
})


test_that("Matrix graph: Group by, weights", {
  expect_no_error(
    matrix_graph(berlinbears, dplyr::starts_with('p_'),
                 group_by = species,
                 subgroups_to_exclude = 'panda bear',
                 weights = weights )
  )
})


