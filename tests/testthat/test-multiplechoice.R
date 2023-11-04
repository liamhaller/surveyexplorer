

#Data input

test_that("Input: Columns only", {
  expect_no_error(multichoice_summary(berlinbears, question = 2:3))
})

test_that("Input: Tidyselect columns", {
  expect_no_error(multichoice_summary(berlinbears, question = starts_with('will_eat')))
})

test_that("Input: Tidyselect columns, subgroup", {
  expect_no_error(multichoice_summary(berlinbears, question = starts_with('will_eat'), group_by = gender))
})

test_that("Input: Tidyselect columns, subgroup, weights", {
  expect_no_error(multichoice_summary(berlinbears, question = starts_with('will_eat'), group_by = gender, weights = weights))
})


# Graphs ------------------------------------------------------------------



test_that("Graph: columns only", {
  expect_no_error(multichoice_graph(berlinbears, question = starts_with('will_eat')))
})

test_that("Graph: subgroup", {
  expect_no_error(multichoice_graph(berlinbears, question = starts_with('will_eat'), group_by = species))
})

test_that("Graph: subgroup, weights", {
  expect_no_error(multichoice_graph(berlinbears, question = starts_with('will_eat'), group_by = gender, weights = weights))
})



