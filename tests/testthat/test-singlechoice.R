
# Inputs and basic functions

test_that("tibble as input", {
  berlinbears <- dplyr::as_tibble(berlinbears)
  expect_no_error(singlechoice_graph(berlinbears, question = income))
})


test_that("subgroup works", {
  expect_no_error(singlechoice_graph(berlinbears, question = income, subgroup = gender))
})

test_that("weights works", {
  expect_no_error(singlechoice_graph(berlinbears, question = income,
                                     subgroup = gender, weights = weights))
})


