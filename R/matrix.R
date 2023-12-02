

#' Create a table of frequencies and counts for matrix questions
#'
#' This function creates a table showing percentages and counts for each
#' response option in a multiple-choice question, specified by `question`. If
#' grouping is provided with `group_by`, the table is extended to include
#' subgroups. Subgroups can be excluded, and survey weights are supported for
#' adjusted counts. The table is formatted for clarity and can be displayed in
#' wide format. When weights are used, counts are presented as percentages only,
#' and a note is added at the bottom of the table.
#'
#' @inheritParams multi_summary
#'
#' @return  A gt table summarizing percentages and counts for each response
#'   option in the specified multiple-choice question. If grouping is provided,
#'   the table includes subgroups and is formatted for clarity.
#'
#'  @examples
#'   #Array question (1-5)
#'   matrix_table(berlinbears, dplyr::starts_with('p_'))
#'
#'   #Use `group_by` to partition the question into several groups
#'   matrix_table(berlinbears, dplyr::starts_with('p_'), group_by = species,
#'   subgroups_to_exclude = 'panda bear' )
#'
#'   #Remove NA category
#'   matrix_table(berlinbears, dplyr::starts_with('p_'), group_by = species,
#'   subgroups_to_exclude = 'panda bear', na.rm = TRUE
#'
#'   #Categorical input
#'   matrix_table(berlinbears, dplyr::starts_with('c_'), group_by = is_parent)
#'
#'
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

  #save user input for name of table
  question_name <-  deparse(substitute(question))
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
        locations = gt::cells_column_labels()) %>%
      gt::tab_header(
        title = paste0("Question: ", question_name))

  } else {
    #with grouping
    matrix.table <-data.table %>%
      gt::gt(rowname_col = 'question', groupname_col = 'group_by') %>%
      gt::tab_style(
        style = gt::cell_text(align = "center"),
        locations = gt::cells_column_labels()) %>%
      gt::tab_style(
          style = gt::cell_text(weight = "bold"),
          locations = gt::cells_row_groups()) %>%
      gt::tab_header(
        title = paste0("Question: ", question_name),
        subtitle = paste0("grouped by: ", group_by))


  }
return(matrix.table)

}


# Matrix Mean plot ------------------------------------------------------------


#' Matrix Mean Plot
#'
#' This function creates a likert-style plot showing means and standard errors
#' for a specified numeric variable, `question`. Optionally, the plot can be
#' grouped by another variable, `group_by`, and subgroups can be excluded. If
#' survey weights are provided, the counts are adjusted accordingly. The plot is
#' flipped for better readability in likert-style format.
#'
#' @inheritParams multi_summary
#'
#' @return A likert-style ggplot displaying means and standard errors. The plot
#'   is flipped for better readability, and if grouping is specified, different
#'   colors represent distinct subgroups.
#'
#' @examples
#' #basic plot
#'   matrix_mean(berlinbears, dplyr::starts_with('p_'))
#'
#'  #with grouping and weights
#'    matrix_mean(berlinbears, dplyr::starts_with('p_'), group_by = species,
#'    subgroups_to_exclude = 'panda bear', weights = weights, na.rm = TRUE )
#'
#'
#'
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
         x = "", color = "")

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
         x = "", color = '')

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
#' @examples
#'  #Array question (1-5)
#'   matrix_freq(berlinbears, dplyr::starts_with('p_'))
#'
#'   #remove NA category
#'   matrix_freq(berlinbears, dplyr::starts_with('p_'), na.rm = TRUE)
#'
#'   #Use `group_by` to partition the question into several groups
#'   matrix_freq(berlinbears, dplyr::starts_with('p_'), group_by = species,
#'   subgroups_to_exclude = c('panda bear', NA ), na.rm = TRUE)
#'
#'   #Categorical input
#'   matrix_freq(berlinbears, dplyr::starts_with('c_'), group_by = is_parent, na.rm = TRUE)
#'
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
                                  label = scales::percent(freq, accuracy = .001))) +
    ggplot2::geom_bar(stat = 'identity' ) +
    ggplot2::geom_text(position = ggplot2::position_fill(vjust = .5),
                       check_overlap = TRUE,
                       size = 3.3) +
    ggplot2::coord_flip() +
    ggplot2::labs(subtitle = "",
                  title = "",
                  y = '',
                  x = "",
                  fill = "")+
   ggplot2::theme_minimal() +
   ggplot2::guides(fill = ggplot2::guide_legend(reverse=T))


 if(!is.null(group_by)){
   graph.freq <- graph.freq +
     ggplot2::facet_wrap(~group_by, scales = "fixed", ncol = 2)

 }




 return(graph.freq)


}








