# Generated from create-biobaby.Rmd: do not edit by hand

#' @title 导出MR分析结果到Excel文件
#' @description 此函数将MR分析的最终结果导出到指定的Excel文件中，包含两个工作表：最终结果和清理后的暴露数据。
#'
#' @param final_results MR分析的最终结果，数据框。
#' @param output_file 字符串，输出Excel文件的文件名，默认为"results.xlsx"。
#' @return 无返回值。结果会保存到指定的Excel文件中。
#' @examples
#' export_results(final_results, output_file = "results.xlsx")
#' @details 此函数创建一个新的Excel工作簿，并将MR分析的最终结果和清理后的暴露数据分别写入两个工作表中。最终结果会保存到指定的Excel文件中。
#'
#' @note 请确保输入的数据框格式正确。
#' @keywords export results Excel
#' @import openxlsx dplyr tidyr
#' @export
#'
export_results <- function(final_results, output_file = "results.xlsx") {
  # 创建一个新的工作簿
  workbook <- createWorkbook("自动暴露")

  # 添加工作表到工作簿
  addWorksheet(workbook, "Final Results", gridLines = FALSE)
  addWorksheet(workbook, "Cleaned Exposures", gridLines = FALSE)

  # 将数据写入第一个工作表
  writeData(workbook,
            sheet = "Final Results",
            x = final_results,
            rowNames = FALSE)

  # 将数据写入第二个工作表
  writeData(workbook,
            sheet = "Cleaned Exposures",
            x = final_results %>%
              distinct(exposure) %>%
              separate(exposure, into = c("exposure", "remove"), sep = "\\|") %>%
              select(-remove),
            rowNames = FALSE)

  # 定义交替行的样式
  body_style <- createStyle(
    border = "TopBottom",
    bgFill = "#e3e9f4",
    fgFill = "#e3e9f4"
  )

  # 设置第一列的列宽
  setColWidths(workbook,
               sheet = "Final Results",
               cols = 1,
               widths = 21)

  # 保存工作簿到文件
  saveWorkbook(workbook,
               file = output_file,
               overwrite = TRUE)

  # 确认保存的信息
  message("Workbook saved as: ", output_file)
}

