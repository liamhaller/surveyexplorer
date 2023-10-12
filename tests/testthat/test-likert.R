test_that("basic function", {
  berlinbears <- berlinbears %>% select(starts_with('p_')) %>% likert_summary()
  expect_no_error(likert_graph(berlinbears))
  })

