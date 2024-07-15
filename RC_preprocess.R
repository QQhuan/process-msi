library(Cardinal)
options(scipen = 999)

# 限定mz的范围
min_mz <- 800
max_mz <- 3000
desired_resolution <- 0.01083 # 期望的m/z分辨率

folder_path <- "E:\\mass_spectrum_data\\CRC-PXD019662-20240607"
set.seed(1)

# 获取文件夹下所有imzML文件的完整路径
file_paths <- list.files(folder_path, pattern = "*.imzML", full.names = TRUE)

for (path in file_paths) {
  msi <- readImzML(path, memory = FALSE, verbose = TRUE, mass.range = c(min_mz, max_mz))
  # 质量校准
  
  peaks <- estimateReferencePeaks(msi)
  mse_recalibrate <- recalibrate(msi, ref=peaks, method="locmax", tolerance=50, units="ppm")
  
  # 查看校准后的数据概览
  normalized_msi <- normalize(mse_recalibrate, method = "tic")
  
  # 数据平滑
  mse_smoothed1 <- smooth(normalized_msi, method="sgolay", width=11) # 第一次平滑，宽度参数需根据数据调整
  mse_smoothed <- smooth(mse_smoothed1, method="sgolay", width=11) # 第二次平滑，宽度参数需根据数据调整
  
  # 基线校正
  mse_baselined <- reduceBaseline(mse_smoothed, method="median") # 采用局部中值插值法
  
  # 数据分箱
  mse_bin = bin(mse_baselined, spectra="intensity", method="mean", unit="mz", resolution=desired_resolution, mass.range = c(min_mz, max_mz))
  
  # final
  mse_final <- process(mse_bin)
  
  # 导出
  filename <- basename(path)
  name <- gsub(".imzML$", "", filename)
  root <- "E:\\mass_spectrum_data\\CRC-PXD019662-20240607\\processed0713"
  output_path <- file.path(root, name)
  writeImzML(mse_final, output_path, mass.range = c(min_mz, max_mz))
  
  # 打印处理信息
  cat("Processed:", filename, "\n")
}
