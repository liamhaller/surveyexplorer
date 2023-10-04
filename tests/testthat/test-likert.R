load_all()
test_that("basic function", {
  berlinbears <- berlinbears %>% select(starts_with('p_')) %>% likert_summary()
  expect_no_error(likert_graph(berlinbears))
  })


debugonce(likert_graph)
likert_graph(berlinbearsl, colors = color_palette) + dezim::dezim_style()

colors <- rev(c("#D9AB11", "#2F5D47", "#8C9981", "#EED394","#D57F43"))

labels = c("Strongly disagree", 'Disagree','Neutral','Agree','Strongly agre')

data <- berlinbears %>% select(starts_with('p_')) %>% likert_summary()



