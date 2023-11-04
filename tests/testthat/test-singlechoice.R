

#Singlechoice_summary




#Valid inputs


#singlechoice_graph
test_that("tibble as input", {
  berlinbears <- dplyr::as_tibble(berlinbears)
  expect_no_error(singlechoice_graph(berlinbears, question = income))
  expect_no_warning(singlechoice_graph(berlinbears, question = income))
})


#group_bys and levels to exclude

test_that("group_by works", {
  expect_no_error(singlechoice_graph(berlinbears, question = income, group_by = gender))
  expect_no_warning(singlechoice_graph(berlinbears, question = income, group_by = gender))

})

test_that("One correct level to exclude", {
  berlinbears <- dplyr::as_tibble(berlinbears)
  expect_no_error(singlechoice_graph(berlinbears, question = income, group_by = species, subgroups_to_exclude = c('black bear')))
  expect_no_warning(singlechoice_graph(berlinbears, question = income, group_by = species, subgroups_to_exclude = c('black bear')))

})

test_that("One valid level to exclude", {
  expect_no_error(singlechoice_graph(berlinbears, question = income, group_by = species, subgroups_to_exclude = c('black bear')))
  expect_no_warning(singlechoice_graph(berlinbears, question = income, group_by = species, subgroups_to_exclude = c('black bear')))
})

test_that("One invalid level to exclude", {
  expect_error(singlechoice_graph(berlinbears, question = income, group_by = species, subgroups_to_exclude = c('black bears')))
})

test_that("Multiple valid level to exclude", {
  berlinbears <- dplyr::as_tibble(berlinbears)
  expect_no_error(singlechoice_graph(berlinbears, question = income, group_by = species, subgroups_to_exclude = c('black bear', 'brown bear')))
  expect_no_warning(singlechoice_graph(berlinbears, question = income, group_by = species, subgroups_to_exclude = c('black bear', 'brown bear')))
})


test_that("One valid one invalid level to exclude", {
  berlinbears <- dplyr::as_tibble(berlinbears)
  expect_error(singlechoice_graph(berlinbears, question = income, group_by = species, subgroups_to_exclude = c('black bear', 'brown bears')))
})




test_that("weights works", {
  expect_no_error(singlechoice_graph(berlinbears, question = income,
                                     group_by = gender, weights = weights))
  expect_no_warning(singlechoice_graph(berlinbears, question = income,
                                     group_by = gender, weights = weights))
})


###Single choice table
test_that("table, question only", {
  expect_no_error(singlechoice_table(berlinbears, question = income))
})


test_that("table, question with weights", {
  expect_no_error(singlechoice_table(berlinbears, question = income, weights = weights)
  )
})



test_that("table, question with group_by", {
  expect_no_error(singlechoice_table(berlinbears, question = income,
                                                            group_by = gender)
  )
})



test_that("table, question with group_by and weights", {
  expect_no_error(singlechoice_table(berlinbears, question = income,
                                                            group_by = gender, weights = weights))
})

test_that("table, question with group_by, weights, and exclusion", {
  expect_no_error(singlechoice_table(berlinbears, question = income, group_by = species, subgroups_to_exclude = c('black bear')))
})







