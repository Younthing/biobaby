# Generated from create-biobaby.Rmd: do not edit by hand

#' @title 执行MR分析
#' @description 此函数执行暴露和结局数据的MR分析，包括数据和谐化，平行计算，以及MR分析结果的评估和过滤。
#'
#' @param exp_data 暴露数据，数据框。
#' @param outcome_data 结局数据，数据框。
#' @param cores 整数，用于平行计算的核心数，默认为可用核心数的一半。
#' @return MR分析的最终结果，数据框。
#' @examples
#' final_results <- parallel_mr(exp_data, outcome_data, cores = 4)
#' @details 此函数首先和谐化暴露和结局数据，然后进行MR分析，并对结果进行评估和过滤，返回最终的MR分析结果。
#'
#' @note 请确保输入数据框的格式正确。
#' @keywords MR analysis harmonization parallel processing
#' @import future furrr dplyr purrr stringr TwoSampleMR
#' @export
#'
parallel_mr <- function(exp_data, outcome_data, cores = availableCores() / 2) {
  # Set up parallel processing plan
  plan(multisession, workers = cores)

  exp_data <- exp_data[which(exp_data$SNP %in% outcome_data$SNP), ]

  # 过滤掉弱工具变量 Fstat < 10
  calculate_F <- function(dat) {
    dat$Fstat <- (abs(dat$beta.exposure) / dat$se.exposure)^2
    dat
  }
  exp_data <- calculate_F(exp_data)
  exp_data <- exp_data %>% filter(Fstat >= 10)

  # Function to harmonize data
  harmonize_exposure_data <- function(exposure_data, outcome_data) {
    tryCatch({
      TwoSampleMR::harmonise_data(exposure_dat = exposure_data, outcome_dat = outcome_data)
    }, error = function(e) {
      message("Error harmonizing data: ", e$message)
      NULL
    })
  }

  # Harmonize data in parallel
  exposure_data_list <- split(exp_data, exp_data$id.exposure)
  harmonized_data_list <- future_map(exposure_data_list, harmonize_exposure_data, outcome_data = outcome_data)

  # Combine harmonized data and filter, ensuring only data frames are used
  combined_data <- harmonized_data_list %>%
    keep(is.data.frame) %>%
    bind_rows() %>%
    filter(mr_keep) %>%
    split(.$id.exposure)

  # Rename exposure groups and remove those with fewer than 3 SNPs
  named_data <- combined_data %>%
    set_names(paste0("A", seq_along(.))) %>%
    discard(~ nrow(.x) < 3)

  # Function to perform MR analysis based on heterogeneity results
  parallel_mr <- function(data) {
    heterogeneity_result <- mr_heterogeneity(data)
    method_list <- if (heterogeneity_result$Q_pval[2] < 0.05) {
      c("mr_egger_regression", "mr_weighted_median", "mr_ivw_mre")
    } else {
      c("mr_egger_regression", "mr_weighted_median", "mr_ivw_fe")
    }

    mr(data, method_list = method_list)
  }

  # Perform MR analysis in parallel
  mr_results_list <- future_map(named_data, parallel_mr)

  # Combine MR results and round p-values
  combined_results <- mr_results_list %>%
    keep(is.data.frame) %>%
    bind_rows() %>%
    mutate(pval = round(pval, 3))

  # Function to evaluate MR results and annotate directions and p-values
  evaluate_mr_results <- function(mr_result) {
    if (!is.data.frame(mr_result)) {
      stop("Expected a data frame for MR results but got ", class(mr_result))
    }

    mr_result %>%
      mutate(
        b_direction = if_else(abs(sum(sign(b))) == 3, NA_character_, "Inconsistent direction"),
        p_no = case_when(
          method == "MR Egger" & pval >= 0.05 ~ "MR Egger",
          method == "Weighted median" & pval >= 0.05 ~ "Weighted median",
          str_detect(method, "Inverse variance") & pval >= 0.05 ~ "IVW",
          TRUE ~ " "
        )
      ) %>%
      mutate(p_no = str_trim(paste(p_no, collapse = " ")))
  }

  # Apply evaluation function to all results using safely to handle potential errors
  evaluated_results <- combined_results %>%
    split(.$id.exposure) %>%
    map(safely(evaluate_mr_results))

  # Extract results and handle errors
  evaluated_results <- evaluated_results %>%
    map("result") %>%
    compact() # Remove NULLs (errors)

  # Combine evaluated results
  final_results <- bind_rows(evaluated_results) %>%
    filter(is.na(b_direction)) %>%
    filter(!str_detect(p_no, "IVW"))

  return(final_results)
}
