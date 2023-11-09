

#' Tabulate Array/Matrix questions
#'
#' @inheritParams multichoice_summary
#'
#' @return placeholder
#' @export
#'
matrix_table <- function(dataset,
                         question,
                         group_by = NULL,
                         subgroups_to_exclude = NULL,
                         weights = NULL){


  try(group_by <- rlang::ensym(group_by), silent = TRUE) # try function is here since if is null, then it will fail
  try(weights <- rlang::ensym(weights), silent = TRUE) # try function is here since if is null, then it will fail

  data.table <- multichoice_summary(dataset = dataset,
                                    question =  all_of(question),
                                    group_by =   if(!is.null(group_by)){group_by},
                                    subgroups_to_exclude =  subgroups_to_exclude,
                                    weights =   if(!is.null(weights)){weights})


  #replace with weights logic
  if(is.null(weights)){ #Without weights
    data.table <- data.table %>%
      mutate(`Percent (count)` = paste0(paste0(round(100*freq,2),'% '), '(', n, ')')) %>%
      select(-c(n,freq))
  } else { #with weights
    data.table <- data.table %>%
      mutate(`Percent (count)` = paste0(round(100*freq,2),'% ')) %>%
      select(-c(n,freq))
  }

  #Wide format for GT
  data.table <- data.table %>%
    tidyr::pivot_wider(names_from=c(response),
                       values_from=c(`Percent (count)`))

  if(is.null(group_by)){
    #No groupipng
    matrix.table <- data.table %>%
      gt::gt(rowname_col = 'question') %>%
      gt::tab_style(
        style = gt::cell_text(align = "center"),
        locations = gt::cells_column_labels())

  } else {
    #with grouping
    matrix.table <-data.table %>%
      gt::gt(rowname_col = 'question', groupname_col = 'group_by') %>%
      gt::tab_style(
        style = gt::cell_text(align = "center"),
        locations = gt::cells_column_labels()) %>%
      tab_style(
          style = cell_text(weight = "bold"),
          locations = cells_row_groups())


  }
return(matrix.table)

}


# Matrix Graph ------------------------------------------------------------


#' Title
#'
#' @inheritParams multichoice_summary

#'
#' @return placeholdder
#' @export
#'
matrix_graph <- function(dataset,
                         question,
                         group_by = NULL,
                         subgroups_to_exclude = NULL,
                         weights = NULL){


  try(group_by <- rlang::ensym(group_by), silent = TRUE) # try function is here since if is null, then it will fail
  try(weights <- rlang::ensym(weights), silent = TRUE) # try function is here since if is null, then it will fail

  data.table <- multichoice_summary(dataset = dataset,
                                    question =  all_of(question),
                                    group_by =   if(!is.null(group_by)){group_by},
                                    subgroups_to_exclude =  subgroups_to_exclude,
                                    weights =   if(!is.null(weights)){weights}) %>%
    select(-freq)

  data.table$response <-  as.numeric(data.table$response)
  data.table$n <-  as.numeric(data.table$n)
  if(!is.null(weights)){
    data.table$n <- round(data.table$n,0)
  }


if(is.null(group_by)){
  #no subgroups
  data.table <- data.table %>%
    group_by(question) %>%
    uncount(n) %>%
    summarise(
      mean = mean(response),
      sd = sd(response),
      n = n(),
      se = sd / sqrt(n()))

  graph.likert_mean <- ggplot(data.table, aes(x= factor(question), y=mean)) +
    geom_point(size = 2) +
    geom_errorbar(aes(ymin=mean - 2*se ,ymax=mean + 2*se),width=0, linewidth =1) +
    coord_flip() +
    #shape of the graph
    ylim(1,5) +

    #text
    labs(subtitle = "",
         title = "",
         y = '',
         x = "") +
    #styling
    #scale_color_manual() +
    dezim::dezim_style() +
    theme(legend.position="bottom")+
    theme(legend.title=element_blank())

  } else{

  data.table <- data.table %>%
    group_by(question, group_by) %>%
    uncount(n) %>%
    summarise(
      mean = mean(response),
      sd = sd(response),
      n = n(),
      se = sd / sqrt(n()))

  graph.likert_mean <- ggplot(data.table, aes(x= factor(question), y=mean, color = group_by)) +
    geom_point(size = 2, position = position_dodge(width=0.5)) +
    geom_errorbar(aes(ymin=mean - 2*se ,ymax=mean + 2*se),
                  width=0, linewidth =1, position = position_dodge(width=0.5)) +
    coord_flip() +
    #shape of the graph
    ylim(1,5) +

    #text
    labs(subtitle = "",
         title = "",
         y = '',
         x = "") +
    #styling
    #scale_color_manual() +
    dezim::dezim_style() +
    theme(legend.position="bottom")+
    theme(legend.title=element_blank())

  }
return(graph.likert_mean)
}









