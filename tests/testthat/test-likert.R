

# Input -------------------------------------------------------------------





test_that("Likert input: Numerical, without labels", {
  expect_no_error(
    matrix_likert(berlinbears, dplyr::starts_with('p_'))
  )
})

test_that("Likert input: Numerical, with labels", {
  expect_no_error(
    matrix_likert(berlinbears, dplyr::starts_with('p_'),
                 labels = c('Strongly disagree', 'Disagree','Neutral','Agree','Strongly agree'))
  )
})


test_that("Likert input: Numerical, with labels", {
  expect_no_error(
    matrix_likert(berlinbears, dplyr::starts_with('p_'),
                 labels = c('Strongly disagree', 'Disagree','Neutral','Agree','Strongly agree'))
  )
})


test_that("Likert input: Factor, without labels", {
  berlinbears$c_diet <- factor(berlinbears$c_diet, levels = c('low', 'medium', 'high'))
  berlinbears$c_exercise <- factor(berlinbears$c_exercise, levels = c('low', 'medium', 'high'))

  expect_no_error(
    matrix_likert(berlinbears, dplyr::starts_with('c_'))
  )
})


test_that("Likert input: Character, without labels", {
  expect_error(
    matrix_likert(berlinbears, dplyr::starts_with('c_'))
  )
})

test_that("Likert input: Character, with labels", {
  expect_no_error(
    matrix_likert(berlinbears, dplyr::starts_with('c_'), labels = c('low', 'medium', 'high'))
  )
})

test_that("Likert input: incorrect number of labels", {
  expect_error(
    matrix_likert(berlinbears, dplyr::starts_with('p_'), labels = c('low', 'medium', 'high'))
  )
})

test_that("Likert input: three levels, no colors", {
  expect_no_error(
    matrix_likert(berlinbears, dplyr::starts_with('c_'),
                 labels = c('low', 'medium', 'high'))
  )
})



# Graphing ----------------------------------------------------------------



test_that("Likert graph: Default, without weights", {
  expect_no_error(
    matrix_likert(berlinbears, dplyr::starts_with('p_'))
  )
})

test_that("Likert graph: Default, with weights", {
  expect_no_error(
    matrix_likert(berlinbears, dplyr::starts_with('p_'),
                 weights = weights)
  )
})


test_that("Likert graph: Incorrect number of labels", {
  expect_error(
    matrix_likert(berlinbears,
                 dplyr::starts_with('p_'),
                 labels = c('Strongly disagree', 'Disagree','Neutral','Agree'))
  )
})

test_that("Likert graph: NA.RM = FALSE, Incorrect number of labels", {
  expect_error(
    matrix_likert(berlinbears,
                 dplyr::starts_with('p_'),
                 na.rm = FALSE)
  )
})








