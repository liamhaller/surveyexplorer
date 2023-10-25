
#Valid inputs

test_that("tibble as input", {
  berlinbears <- dplyr::as_tibble(berlinbears)
  expect_no_error(singlechoice_graph(berlinbears, question = income))
  expect_no_warning(singlechoice_graph(berlinbears, question = income))
})


#Subgroups and levels to exclude

test_that("subgroup works", {
  expect_no_error(singlechoice_graph(berlinbears, question = income, subgroup = gender))
  expect_no_warning(singlechoice_graph(berlinbears, question = income, subgroup = gender))

})

test_that("One correct level to exclude", {
  berlinbears <- dplyr::as_tibble(berlinbears)
  expect_no_error(singlechoice_graph(berlinbears, question = income, subgroup = species, levels_to_exclude = c('black bear')))
  expect_no_warning(singlechoice_graph(berlinbears, question = income, subgroup = species, levels_to_exclude = c('black bear')))

})

test_that("One valid level to exclude", {
  expect_no_error(singlechoice_graph(berlinbears, question = income, subgroup = species, levels_to_exclude = c('black bear')))
  expect_no_warning(singlechoice_graph(berlinbears, question = income, subgroup = species, levels_to_exclude = c('black bear')))
})

test_that("One invalid level to exclude", {
  expect_error(singlechoice_graph(berlinbears, question = income, subgroup = species, levels_to_exclude = c('black bears')))
})

test_that("Multiple valid level to exclude", {
  berlinbears <- dplyr::as_tibble(berlinbears)
  expect_no_error(singlechoice_graph(berlinbears, question = income, subgroup = species, levels_to_exclude = c('black bear', 'brown bear')))
  expect_no_warning(singlechoice_graph(berlinbears, question = income, subgroup = species, levels_to_exclude = c('black bear', 'brown bear')))
})


test_that("One valid one invalid level to exclude", {
  berlinbears <- dplyr::as_tibble(berlinbears)
  expect_error(singlechoice_graph(berlinbears, question = income, subgroup = species, levels_to_exclude = c('black bear', 'brown bears')))
})




test_that("weights works", {
  expect_no_error(singlechoice_graph(berlinbears, question = income,
                                     subgroup = gender, weights = weights))
  expect_no_warning(singlechoice_graph(berlinbears, question = income,
                                     subgroup = gender, weights = weights))
})


###Single choice table
test_that("table, question only", {
  expect_no_error(singlechoice_table(berlinbears, question = income))
})


test_that("table, question with weights", {
  expect_no_error(singlechoice_table(berlinbears, question = income, weights = weights)
  )
})



test_that("table, question with subgroup", {
  expect_no_error(singlechoice_table(berlinbears, question = income,
                                                            subgroup = gender)
  )
})



test_that("table, question with subgroup and weights", {
  expect_no_error(singlechoice_table(berlinbears, question = income,
                                                            subgroup = gender, weights = weights))
})

test_that("table, question with subgroup, weights, and exclusion", {
  expect_no_error(singlechoice_table(berlinbears, question = income, subgroup = species, levels_to_exclude = c('black bear')))
})







