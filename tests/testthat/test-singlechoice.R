

#Singlechoice_summary



#Valid inputs
test_that("single choice: excluded subgroup without group_by", {
  expect_error(singlechoice_graph(berlinbears, question = income,  subgroups_to_exclude = 'panda'))
})


#singlechoice_graph
test_that("sc graph: tibble as input", {
  berlinbears <- dplyr::as_tibble(berlinbears)
  expect_no_error(
    singlechoice_graph(berlinbears, question = income)
    )
  expect_no_warning(
    singlechoice_graph(berlinbears, question = income)
    )
})


#group_bys and levels to exclude

test_that("sc graph: group_by works", {
  expect_no_error(singlechoice_graph(berlinbears, question = income, group_by = gender))
  expect_no_warning(singlechoice_graph(berlinbears, question = income, group_by = gender))

})

test_that("sc graph: One correct level to exclude", {
  berlinbears <- dplyr::as_tibble(berlinbears)
  expect_no_error(singlechoice_graph(berlinbears, question = income, group_by = species, subgroups_to_exclude = c('black bear')))
  expect_no_warning(singlechoice_graph(berlinbears, question = income, group_by = species, subgroups_to_exclude = c('black bear')))

})

test_that("sc graph: One valid level to exclude", {
  expect_no_error(singlechoice_graph(berlinbears, question = income, group_by = species, subgroups_to_exclude = c('black bear')))
  expect_no_warning(singlechoice_graph(berlinbears, question = income, group_by = species, subgroups_to_exclude = c('black bear')))
})

test_that("sc graph: One invalid level to exclude", {
  expect_error(singlechoice_graph(berlinbears, question = income, group_by = species, subgroups_to_exclude = c('black bears')))
})

test_that("sc graph: Multiple valid level to exclude", {
  berlinbears <- dplyr::as_tibble(berlinbears)
  expect_no_error(singlechoice_graph(berlinbears, question = income, group_by = species, subgroups_to_exclude = c('black bear', 'brown bear')))
  expect_no_warning(singlechoice_graph(berlinbears, question = income, group_by = species, subgroups_to_exclude = c('black bear', 'brown bear')))
})


test_that("sc graph: One valid one invalid level to exclude", {
  berlinbears <- dplyr::as_tibble(berlinbears)
  expect_error(singlechoice_graph(berlinbears, question = income, group_by = species, subgroups_to_exclude = c('black bear', 'brown bears')))
})




test_that("sc graph: weights works", {
  expect_no_error(singlechoice_graph(berlinbears, question = income,
                                     group_by = gender, weights = weights))
  expect_no_warning(singlechoice_graph(berlinbears, question = income,
                                     group_by = gender, weights = weights))
})


###Single choice table
test_that("table, question only", {
  expect_no_error(
    singlechoice_table(berlinbears, question = income)
    )
})


test_that("table, question with weights", {
  expect_no_error(
    singlechoice_table(berlinbears, question = income, weights = weights)
  )
})



test_that("table, question with group_by", {
  expect_no_error(
    singlechoice_table(berlinbears, question = income,  group_by = gender)
  )
})



test_that("table, question with group_by and weights", {
  expect_no_error(
    singlechoice_table(berlinbears, question = income,  group_by = gender, weights = weights)
    )
})

test_that("table, question with group_by, weights, and exclusion", {
  expect_no_error(
    singlechoice_table(berlinbears, question = income, group_by = species, subgroups_to_exclude = c('black bear'))
    )
})




