## code to prepare `DATASET` dataset goes here


berlinbears <- data.frame(matrix(data = seq(1:500), nrow = 500))
colnames(berlinbears) <- 'id'

## Demographic variables
berlinbears$species <- sample( c('brown bear', 'polar bear', 'panda bear', 'black bear', NA_character_), 500,
                              replace=TRUE, prob=c(0.1, 0.2, 0.60, 0.05, .05) )


berlinbears$genus <- ifelse(berlinbears$species == 'panda bear', 'Ailuropoda', 'Ursus')

berlinbears$gender <- sample( c('male', 'female', NA_character_), 500,
                              replace=TRUE, prob=c(0.50, 0.45, .05))

berlinbears$age <- round(runif(500, 1, 25),0)

berlinbears$is_parent <- ifelse(berlinbears$age < 10, 0,  sample(c(1, 0), 500,
                                                                  replace=TRUE, prob=c(0.55, 0.45)))

#Single choice questions

berlinbears$income <-  sample( c('<1000', '1000-2000', '2000-3000', '3000-4000', '5000+', "No answer", NA_character_), 500,
                               replace=TRUE, prob=c(0.15, 0.10, 0.35, 0.25, .10,.04, .01) )



#multiple choice questions
berlinbears$will_eat.SQ001 <- sample( c(0, 1, NA_integer_), 500,
                                       replace=TRUE, prob=c(0.70, .25, 0.05))
berlinbears$will_eat.SQ002 <- sample( c(0, 1), 500,
                                      replace=TRUE, prob=c(0.40, .60))
berlinbears$will_eat.SQ003 <- sample( c(0, 1, NA_integer_), 500,
                                      replace=TRUE, prob=c(0.85, .10, .05))
berlinbears$will_eat.SQ004 <- sample( c(0, 1), 500,
                                      replace=TRUE, prob=c(0.05, .95))
berlinbears$will_eat.SQ005 <- sample( c(0, 1, NA_integer_), 500,
                                      replace=TRUE, prob=c(0.50, .45, .05))

berlinbears$issues.SQ001 <- sample( c(0, 1), 500,
                                      replace=TRUE, prob=c(0.90, .10))
berlinbears$issues.SQ002 <- sample( c(0, 1), 500,
                                    replace=TRUE, prob=c(0.27, .73))
berlinbears$issues.SQ003 <- sample( c(0, 1, NA_integer_), 500,
                                    replace=TRUE, prob=c(0.20, .75, .05))
berlinbears$issues.SQ004 <- sample( c(0, 1, NA_integer_), 500,
                                    replace=TRUE, prob=c(0.50, .45, .05))

#likert data


berlinbears$p_likespine <- sample( c(1,2,3,4,5), 500,
                                    replace=TRUE, prob=c(0.70, .15, .05, .05,.05))
berlinbears$p_likeshoney<- sample( c(1,2,3,4,5, NA_integer_), 500,
                                        replace=TRUE, prob=c(0.01, .01, .03, .1,.80, .05))
berlinbears$p_eatstrash <- sample( c(1,2,3,4,5), 500,
                                        replace=TRUE, prob=c(0.25, .15, .4, .1,.1))
berlinbears$p_swims <- sample( c(1, 2,3,4,5, NA_integer_), 500,
                                        replace=TRUE, prob=c(0.10, .1, .5, .15,.10, .05))
berlinbears$p_hibernates <- sample( c(1, 2,3,4,5), 500,
                                        replace=TRUE, prob=c(0.05, .05, .2, .35,.35))
berlinbears$p_likes_zoo <- sample( c(1, 2,3,4,5, NA_integer_), 500,
                                        replace=TRUE, prob=c(0.65, .15, .05, .05,.05, .05))


berlinbears$c_diet <- sample( c('low', 'medium', 'high', NA_character_), 500,
                                   replace=TRUE, prob=c(0.75, .15, .05, .05))
berlinbears$c_exercise <- sample( c('low', 'medium', 'high', NA_character_), 500,
                                   replace=TRUE, prob=c(0.25, .25, .25, .25))



berlinbears$h_winter <- sample( c('forest', 'cave', 'tree', 'zoo', NA_character_), 500,
                                   replace=TRUE, prob=c(0.15, .1, .15, .4, .1))
berlinbears$h_summer <- sample( c('forest', 'cave', 'tree', 'zoo', NA_character_), 500,
                                   replace=TRUE, prob=c(0.10, .05, .05, .5, .30))





#Survey weights

berlinbears$weights <- rnorm(500, 1, 2)
berlinbears$weights <- ifelse(berlinbears$weights < 0, berlinbears$weights*-1, berlinbears$weights)





#usethis::use_data(berlinbears, overwrite = TRUE)



