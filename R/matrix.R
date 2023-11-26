

#' Tabulate Array/Matrix questions
#'
#' @inheritParams multi_summary
#'
#' @return placeholder
#' @importFrom dplyr n
#' @export
#'
#'
#' @family matrix questions

#'
matrix_table <- function(dataset,
                         question,
                         group_by = NULL,
                         subgroups_to_exclude = NULL,
                         weights = NULL,
                         na.rm = FALSE){


  try(group_by <- rlang::ensym(group_by), silent = TRUE) # try function is here since if is null, then it will fail
  try(weights <- rlang::ensym(weights), silent = TRUE) # try function is here since if is null, then it will fail
  `Percent (count)` <- response <- freq <- NULL #created useing NSE, necessary to avoid visible binding note

  data.table <- multi_summary(dataset = dataset,
                                    question =  all_of(question),
                                    group_by =   if(!is.null(group_by)){group_by},
                                    subgroups_to_exclude =  subgroups_to_exclude,
                                    weights =   if(!is.null(weights)){weights},
                                    na.rm = na.rm)


  #replace with weights logic
  if(is.null(weights)){ #Without weights
    data.table <- data.table %>%
      dplyr::mutate(`Percent (count)` = paste0(paste0(round(100*freq,2),'% '), '(', n, ')')) %>%
      dplyr::select(-c(n,freq))
  } else { #with weights
    data.table <- data.table %>%
      dplyr::mutate(`Percent (count)` = paste0(round(100*freq,2),'% ')) %>%
      dplyr::select(-c(n,freq))
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
      gt::tab_style(
          style = gt::cell_text(weight = "bold"),
          locations = gt::cells_row_groups())


  }
return(matrix.table)

}


# Matrix Mean plot ------------------------------------------------------------


#' Matrix Mean Plot
#'
#' Visualizes the mean and standard deviation of responses to a specified question.
#' If grouping is specified, the plot compares the means across different groups.
#'
#' @inheritParams multi_summary
#'
#' @return A ggplot object representing the mean plot.
#' @export
#' @family matrix questions

matrix_mean <- function(dataset,
                         question,
                         group_by = NULL,
                         subgroups_to_exclude = NULL,
                         weights = NULL,
                         na.rm = FALSE){


  try(group_by <- rlang::ensym(group_by), silent = TRUE) # try function is here since if is null, then it will fail
  try(weights <- rlang::ensym(weights), silent = TRUE) # try function is here since if is null, then it will fail
  se <- sd <- response <- freq <- NULL #created useing NSE, necessary to avoid visible binding note

  data.table <- multi_summary(dataset = dataset,
                                    question =  all_of(question),
                                    group_by =   if(!is.null(group_by)){group_by},
                                    subgroups_to_exclude =  subgroups_to_exclude,
                                    weights =   if(!is.null(weights)){weights},
                                    na.rm = na.rm) %>%
    dplyr::select(-freq)

  data.table$response <-  as.numeric(data.table$response)
  data.table$n <-  as.numeric(data.table$n)
  if(!is.null(weights)){
    data.table$n <- round(data.table$n,0)
  }


if(is.null(group_by)){
  #no subgroups
  data.table <- data.table %>%
    dplyr::group_by(question) %>%
    tidyr::uncount(n) %>%
    dplyr::summarise(
      mean = mean(response),
      sd = stats::sd(response),
      n = n(),
      se = sd / sqrt(n()))

  graph.likert_mean <- ggplot(data.table, aes(x= factor(question), y=mean)) +
    ggplot2::geom_point(size = 2) +
    ggplot2::geom_errorbar(aes(ymin=mean - 2*se ,ymax=mean + 2*se),width=0, linewidth =1) +
    ggplot2::coord_flip() +
    #shape of the graph

    #text
    ggplot2::labs(subtitle = "",
         title = "",
         y = '',
         x = "")

  } else{

  data.table <- data.table %>%
    dplyr::group_by(question, group_by) %>%
    tidyr::uncount(n) %>%
    dplyr::summarise(
      mean = mean(response),
      sd = sd(response),
      n = n(),
      se = sd / sqrt(n()))

  graph.likert_mean <- ggplot(data.table, aes(x= factor(question), y=mean, color = group_by)) +
    ggplot2::geom_point(size = 2, position = ggplot2::position_dodge(width=0.5)) +
    ggplot2::geom_errorbar(aes(ymin=mean - 2*se ,ymax=mean + 2*se),
                  width=0, linewidth =1, position = ggplot2::position_dodge(width=0.5)) +
    ggplot2::coord_flip() +
    #shape of the graph

    #text
    ggplot2::labs(subtitle = "",
         title = "",
         y = '',
         x = "")

  }
return(graph.likert_mean)
}






# Frequency graph ---------------------------------------------------------


#' Matrix Frequency Plot
#'
#' Generate a grouped bar chart displaying the frequency distribution of
#' responses for a categorical variable. The function supports optional
#' subgrouping of data using the `group_by` variable, exclusion of specific
#' subgroups with 'subgroups_to_exclude,' and data weighting with the 'weights'
#' parameter. Users can also choose to exclude NA values from the questions
#' prior to analysis using the 'na.rm' parameter.
#'
#'
#' @inheritParams multi_summary

#'
#' @return A ggplot2 object representing a grouped bar chart displaying the frequency distribution of responses
#' for the specified categorical variable. The chart supports grouping, weighting, and exclusion of subgroups.
#'
#'
#' @export
#' @family matrix questions


matrix_freq <- function(dataset,
                             question,
                             group_by = NULL,
                             subgroups_to_exclude = NULL,
                             weights = NULL,
                             na.rm = FALSE){


  try(group_by <- rlang::ensym(group_by), silent = TRUE) # try function is here since if is null, then it will fail
  try(weights <- rlang::ensym(weights), silent = TRUE) # try function is here since if is null, then it will fail
  response <- freq <- NULL #created useing NSE, necessary to avoid visible binding note
  data.table <- multi_summary(dataset = dataset,
                                    question =  all_of(question),
                                    group_by =   if(!is.null(group_by)){group_by},
                                    subgroups_to_exclude =  subgroups_to_exclude,
                                    weights =   if(!is.null(weights)){weights},
                                    na.rm = na.rm)


 graph.freq <-  ggplot2::ggplot(data.table, aes(x= question, y = freq,
                                  fill = response,
                                  label = scales::percent(freq))) +
    ggplot2::geom_bar(stat = 'identity' ) +
    ggplot2::geom_text(position = ggplot2::position_fill(vjust = .5),
                       check_overlap = TRUE,
                       size = 3.3) +
    ggplot2::coord_flip() +
    ggplot2::labs(subtitle = "",
                  title = "",
                  y = '',
                  x = "",
                  fill = "") +
   ggplot2::facet_wrap(~group_by, scales = "fixed", ncol = 2) +
   ggplot2::theme_minimal()



 return(graph.freq)


}








