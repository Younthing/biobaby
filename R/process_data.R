# Generated from create-biobaby.Rmd: do not edit by hand

#' @title 处理并合并暴露和结局数据
#' @description 此函数处理暴露数据和结局数据，并根据指定条件进行筛选和合并。
#'
#' @param exp_data 暴露数据，数据框。
#' @param ao_data 全部结局数据，数据框。
#' @param remove_eqtl 逻辑值，是否移除暴露数据中的eQTL，默认为TRUE。
#' @param filter_population 字符串，指定结局数据中需要筛选的人群，默认为"European"。
#' @return 合并后的筛选数据，数据框。
#' @examples
#' result_data <- process_data(exp_data, ao_data, remove_eqtl = TRUE, filter_population = "European")
#' @details 此函数首先处理暴露数据，然后处理结局数据，最后合并筛选后的数据。
#'
#' @note 请确保输入数据框的格式正确。
#' @keywords data processing merge
#' @export
process_data <- function(exp_data, ao_data, remove_eqtl = TRUE, filter_population = "European") {

  # 处理暴露数据
  process_exposure_data <- function(exp_data, remove_eqtl = TRUE) {
    cat(green("总共的暴露信息数量:"), yellow(length(unique(exp_data$id.exposure))), "\n")

    if (remove_eqtl) {
      exp_data <- exp_data %>%
        filter(!str_detect(id.exposure, "eqtl-a"))
      cat(green("去掉eQTL后的暴露信息数量:"), yellow(length(unique(exp_data$id.exposure))), "\n")
    }

    return(exp_data)
  }

  # 处理结局数据
  process_population_data <- function(ao_data, filter_population = "European") {
    if (nrow(problems(ao_data)) > 0) {
      warning(yellow("CSV文件解析时存在问题，请调用problems()查看详细信息。"))
    }

    if (!is.null(filter_population)) {
      ao_data <- ao_data %>%
        filter(population == filter_population)
      cat(green(paste0(filter_population, "人群结局数据trait数量:")), yellow(n_distinct(ao_data$id)), "\n")
    }

    return(ao_data)
  }

  # 合并筛选后的数据
  merge_data <- function(exp_data, ao_data) {
    filtered_data <- exp_data %>%
      filter(id.exposure %in% ao_data$id)

    cat(green("筛选后的全部暴露的SNP数量:"), yellow(nrow(filtered_data)), "\n")

    return(filtered_data)
  }

  # 处理数据
  exp_data <- process_exposure_data(exp_data, remove_eqtl)
  ao_data <- ao_data %>%
    process_population_data(filter_population)

  # 合并数据
  final_data <- merge_data(exp_data, ao_data)

  return(final_data)
}
