


# Summary -----------------------------------------------------------------





test_that("Input: Columns only", {
  expect_no_error(
    multi_summary(berlinbears, question = 2:3, na.rm = FALSE)
    )
})

test_that("Input: na.rm", {
  expect_no_error(
    multi_summary(berlinbears, question = 2:3, na.rm = TRUE)
  )
})

test_that("Input: na.rm, group_by", {
  expect_no_error(
    multi_summary(berlinbears, question = dplyr::starts_with('will_eat'), group_by = gender, na.rm = TRUE)
  )
})


test_that("Input: Tidyselect columns", {
  expect_no_error(
    multi_summary(berlinbears, question = dplyr::starts_with('will_eat'), na.rm = FALSE)
    )
})

test_that("Input: Tidyselect columns, subgroup", {
  expect_no_error(
    multi_summary(berlinbears, question = dplyr::starts_with('will_eat'), group_by = gender, na.rm = FALSE)
    )
})

test_that("Input: Tidyselect columns, subgroup, weights", {
  expect_no_error(
    multi_summary(berlinbears, question = dplyr::starts_with('will_eat'), group_by = gender, weights = weights, na.rm = FALSE)
    )
})


test_that("Input: excluded subgroup without group_by", {
  expect_error(multi_summary(berlinbears, question = dplyr::starts_with('will_eat'),  subgroups_to_exclude = 'panda', na.rm = FALSE))
})









# Graphs ------------------------------------------------------------------


test_that("Graph: columns only", {
  expect_no_error(
    multi_freq(berlinbears, question = dplyr::starts_with('will_eat'))
    )
})

test_that("Graph: subgroup", {
  expect_no_error(
    multi_freq(berlinbears, question = dplyr::starts_with('will_eat'), group_by = species)
    )
})

test_that("Graph: subgroups to exclude", {

  x <- multi_freq(berlinbears, question = dplyr::starts_with('will_eat'), group_by = gender, subgroups_to_exclude = NA)
  y <- multi_freq(berlinbears, question = dplyr::starts_with('will_eat'), group_by = gender)

 expect_false(
    identical(as.list(x),as.list(y))
    )
})





test_that("Graph: subgroup, weights", {
  expect_no_error(
    multi_freq(berlinbears, question = dplyr::starts_with('will_eat'), group_by = gender, weights = weights)
    )
})

test_that("Graph: subgroup, weights, na.rm", {
  expect_no_error(
    multi_freq(berlinbears, question = dplyr::starts_with('will_eat'), group_by = gender, weights = weights, na.rm = TRUE)
  )
})


test_that("graph: wrong data format", {

  expect_error(
    multi_freq(berlinbears, question = dplyr::starts_with('c_'))
  )
})


# Table -------------------------------------------------------------------

test_that("Table: columns only", {
  expect_no_error(
    multi_table(berlinbears, question = dplyr::starts_with('will_eat'))
    )
})

test_that("Table: wrong data format", {

  expect_error(
    multi_table(berlinbears, question = dplyr::starts_with('c_'))
  )
})


test_that("Table: subgroup", {
  expect_no_error(
    multi_table(berlinbears, question = dplyr::starts_with('will_eat'), group_by = species)
    )
})

test_that("Table: subgroup, weights, exclude NA", {
  expect_no_error(
    multi_table(berlinbears, question = dplyr::starts_with('will_eat'), group_by = gender, subgroups_to_exclude = NA, weights = weights)
    )
})








