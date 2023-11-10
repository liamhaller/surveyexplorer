

#Singlechoice_summary




#Valid inputs


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








data.table <- singlechoice_summary(berlinbears, question = income, group_by = species, subgroups_to_exclude = c('black bear'))




gt.table <-  data.table %>%
  tidyr::pivot_wider(names_from=c(group_by),
                     values_from=c(n,freq),
                     names_glue = "{group_by}_{.value}",
                     names_sort = TRUE) %>%

  rowwise(question) %>%
  mutate(zztotal_n = sum(c_across(ends_with('_n')))) %>%
  ungroup() %>%
  mutate(zztotal_freq = zztotal_n/sum(zztotal_n)) %>%
  select(question, sort(names(.)))

sample_size <- sum(data.table$n)


columnwise_total <-
  gt.table %>%
  select(ends_with('_n')) %>%
  purrr::map_df(sum) %>%
  mutate(
    across(.cols = everything(),
           .fns = function(x) {x/sample_size},
           .names = "{str_extract(.col, pattern = '[^_]*')}_freq")
  ) %>%
  select(sort(names(.))) %>%
  mutate(question = "Columnwise Total", .before = everything())


gt.table <- gt.table %>%
  add_row(columnwise_total) %>%

  gt::gt(rowname_col = 'question', groupname_col = 'group_by') %>%
  gt::tab_spanner_delim(delim="_") %>%
  gt::tab_style(
    style = gt::cell_text(align = "center"),
    locations = gt::cells_column_labels()) %>%
  gt::tab_spanner(label = md('**Rowwise Total**'),
                  columns = dplyr::starts_with("zz"),
                  level = 1,
                  replace = TRUE,
                  id = 'rowwise'
  ) %>%
  gt::cols_label(ends_with('_freq') ~ 'Frequency',
                 ends_with('_n') ~ 'Count') %>%
  gt::fmt_percent(columns = contains('freq'), decimals = 2) %>%

  #Styling#
  #Make summary rows grey
  gt::tab_style(gt::cell_fill(color = '#d3d3d3'),
                locations = list(
                  gt::cells_body(columns = dplyr::starts_with("zz")),
                  gt::cells_body(rows = dplyr::matches("Columnwise Total"))
                )) %>%
  gt::tab_style(gt::cell_text(weight = 'bold'),
                locations = gt::cells_stub(rows = "Columnwise Total")
                )




gt.table

