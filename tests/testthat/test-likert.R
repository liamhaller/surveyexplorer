







test_that("Likert graph: Default, without weights", {
  expect_no_error(
    likert_graph(berlinbears, dplyr::starts_with('p_'))
  )
})





