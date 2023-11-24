

#Data input

test_that("Input: Columns only", {
  expect_no_error(
    multichoice_summary(berlinbears, question = 2:3)
    )
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

test_that("Input: excluded subgroup without group_by", {
  expect_error(multichoice_summary(berlinbears, question = starts_with('will_eat'),  subgroups_to_exclude = 'panda'))
})



# Graphs ------------------------------------------------------------------



test_that("Graph: columns only", {
  expect_no_error(
    multichoice_graph(berlinbears, question = starts_with('will_eat'))
    )
})

test_that("Graph: subgroup", {
  expect_no_error(multichoice_graph(berlinbears, question = starts_with('will_eat'), group_by = species))
})

test_that("Graph: subgroup, weights", {
  expect_no_error(multichoice_graph(berlinbears, question = starts_with('will_eat'), group_by = gender, weights = weights))
})


# Table -------------------------------------------------------------------

test_that("Table: columns only", {
  expect_no_error(multichoice_table(berlinbears, question = starts_with('will_eat')))
})

test_that("Table: subgroup", {
  expect_no_error(multichoice_table(berlinbears, question = starts_with('will_eat'), group_by = species))
})

test_that("Table: subgroup, weights, exclude NA", {
  expect_no_error(
    multichoice_table(berlinbears, question = starts_with('will_eat'), group_by = gender, subgroups_to_exclude = NA, weights = weights)
    )
})








