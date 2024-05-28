# surveyexplorer 0.2.0

-   Add ability to specify response/column for `matrix_freq` and `matrix_table` functions

For example:

```{r}
 matrix_freq(berlinbears,
                dplyr::starts_with('p_'),
                response_order = c(3,2,4,5,1), #Can also specify names
                colors = c("#E1AA28", "#1E5F46", "#7E8F75", "#EFCD83", "#E17832"),
                na.rm = TRUE
    )
```

-   Updated deafult labels in `matrix_freq` graph to improve readability
-   Bug fix in `matrix_mean` that caused standard errors to be underestimated for weighted data
-   Set default order for `multi_table` results to be shown from high to low and removed frequency summary row for non-grouped data since it sums to \> 1

# surveyexplorer 0.1.0

-   Initial submission to CRAN
