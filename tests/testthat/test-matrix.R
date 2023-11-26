



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

test_that("Matrix table: Group by, na.rm", {
  expect_no_error(
    matrix_table(berlinbears, dplyr::starts_with('p_'),
                 group_by = species,
                 subgroups_to_exclude = 'panda bear', na.rm = TRUE )
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


test_that("Matrix table: Group by, weights", {
  expect_no_error(
    matrix_table(berlinbears, dplyr::starts_with('p_'),
                 group_by = species,
                 subgroups_to_exclude = 'panda bear',
                 weights = weights )
  )
})


test_that("Matrix table: Categorical input", {
  expect_no_error(
    matrix_table(berlinbears, dplyr::starts_with('c_'))
  )
})


test_that("Matrix table: Categorical input, group_by", {
  expect_no_error(
    matrix_table(berlinbears, dplyr::starts_with('c_'), group_by = is_parent)
  )
})



# Matrix graph ------------------------------------------------------------



test_that("Matrix graph: Columns only", {
  expect_no_error(
    matrix_mean(berlinbears, dplyr::starts_with('p_'))
  )
})


test_that("Matrix graph: Group by", {
  expect_no_error(
    matrix_mean(berlinbears, dplyr::starts_with('p_'),
                 group_by = species,
                 subgroups_to_exclude = 'panda bear' )
  )
})


test_that("Matrix graph: Group by, weights", {
  expect_no_error(
    matrix_mean(berlinbears, dplyr::starts_with('p_'),
                 group_by = species,
                 subgroups_to_exclude = 'panda bear',
                 weights = weights )
  )
})


# Freq --------------------------------------------------------------------




test_that("Matrix freq: Columns only", {
  expect_no_error(
    matrix_freq(berlinbears, dplyr::starts_with('p_'))
  )
})


test_that("Matrix freq: Group by", {
  expect_no_error(
    matrix_freq(berlinbears, dplyr::starts_with('p_'),
                group_by = species,
                subgroups_to_exclude = 'panda bear' )
  )
})


test_that("Matrix freq: Group by, weights", {
  expect_no_error(
    matrix_freq(berlinbears, dplyr::starts_with('p_'),
                group_by = species,
                subgroups_to_exclude = 'panda bear',
                weights = weights )
  )
})













