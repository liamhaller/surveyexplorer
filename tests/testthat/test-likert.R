test_that("basic function", {
  berlinbears <- berlinbears %>% dplyr::select(dplyr::starts_with('p_')) %>% likert_summary()
  expect_no_error(likert_graph(berlinbears))
  })

