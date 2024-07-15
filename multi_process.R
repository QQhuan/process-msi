library(Cardinal)
options(scipen = 999)

# 限定mz的范围
min_mz <- 120
max_mz <- 1500
desired_resolution <- 0.01 # 期望的m/z分辨率

file_paths <- c("E:\\mass_spectrum_data\\DGC\\imzML\\GC070N_DGC_83882_E001209_F1_R1.imzML") #,
                #"E:\\mass_spectrum_data\\DGC\\imzML\\GC070N_DGC_83882_E001209_F2_R1.imzML",
               # "E:\\mass_spectrum_data\\DGC\\imzML\\GC070T_DGC_83881_E001208_F1_R1.imzML",
               # "E:\\mass_spectrum_data\\DGC\\imzML\\GC070T_DGC_83881_E001208_F2_R1.imzML")
filename <- c("GC070N_DGC_83882_E001209_F1_R1") #, "GC070N_DGC_83882_E001209_F2_R1", "GC070T_DGC_83881_E001208_F1_R1","GC070T_DGC_83881_E001208_F2_R1")
set.seed(1)
# 创建空列表以存储处理后的数据
processed_msis <- list()

for (path in file_paths) {
  # 读取数据
  msi <- readImzML(path, memory = FALSE, verbose = TRUE, mass.range = c(min_mz, max_mz))
  
  # 质量校准
  peaks <- estimateReferencePeaks(msi)
  msi_calibrated <- recalibrate(msi, ref = peaks, method = "locmax", tolerance = 10, units = "ppm")
  
  # 为了统一m/z轴，可以使用binning
  msi_binned <- bin(msi_calibrated, resolution = desired_resolution, units = "mz")
  
  # 其他处理步骤
  msi_baselined <- reduceBaseline(msi_binned, method = "locmin")
  msi_smoothed <- smooth(msi_baselined, method = "gaussian", width = 5)
  # msi_align <- peakAlign(msi_smoothed)
  
  msi_final <- process(msi_smoothed)
  
  # 保存或添加到列表中
  processed_msis[[path]] <- msi_final
}

root <- "E:\\mass_spectrum_data\\DGC\\processed2\\"

# 保存处理的数据
for (i in seq_along(processed_msis)) {
  output_path <- paste(root, filename[i], sep = "")
  writeImzML(processed_msis[[i]], output_path)
}