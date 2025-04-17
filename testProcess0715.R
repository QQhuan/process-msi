library(Cardinal)
options(scipen = 999)

# 限定mz的范围
min_mz <- 800
max_mz <- 4500
desired_resolution <- 0.032498 # 期望的m/z分辨率

folder_path <- "E:\\mass_spectrum_data\\CRC-PXD019662-20240607\\TMA5B-alltumours-nonormalization.imzML"



msi <- readImzML(folder_path, memory = FALSE, verbose = TRUE, mass.range = c(100, max_mz))
plot(msi)

# 使用 image() 函数绘制更精细的图像
image(msi, col = heat.colors(128), zlim = c(0, quantile(msi@intensity, 0.95)), 
      main = "MSI Data Visualization", xlab = "X Coordinate", ylab = "Y Coordinate")
print(msi)
set.seed(1)

msi <- subset(msi, mz >= 800)
peaks <- estimateReferencePeaks(msi)
mse_recalibrate <- recalibrate(msi, ref=peaks, method="locmax", tolerance=50, units="ppm")
plot(mse_recalibrate)

# 查看校准后的数据概览
normalized_msi <- normalize(mse_recalibrate, method = "tic")
plot(normalized_msi, col="purple")
# 数据平滑
mse_smoothed1 <- smooth(normalized_msi, method="sgolay", width=11) # 第一次平滑，宽度参数需根据数据调整
mse_smoothed <- smooth(mse_smoothed1, method="sgolay", width=11) # 第二次平滑，宽度参数需根据数据调整
# 绘制原始数据
plot(normalized_msi, type = "l", col = "blue", lty = 1, lwd = 2, 
     main = "Comparison of Original and Smoothed Data",
     xlab = "m/z", ylab = "Intensity")

# 添加第一次平滑后的数据
lines(mse_smoothed1, col = "green", lty = 2, lwd = 2)

# 添加第二次平滑后的数据
lines(mse_smoothed, col = "red", lty = 3, lwd = 2)

# 添加图例
legend("topright", legend = c("Original", "Smoothed (1st)", "Smoothed (2nd)"),
       col = c("blue", "green", "red"), lty = c(1, 2, 3), lwd = 2)
# 基线校正
mse_baselined <- reduceBaseline(mse_smoothed, method="median") # 采用局部中值插值法

# 数据分箱
mse_bin = bin(mse_baselined, spectra="intensity", method="mean", unit="mz", resolution=desired_resolution, mass.range = c(min_mz, max_mz))
peaks = estimateReferencePeaks(mse_bin)
mse_pick = peakPick(mse_bin, method="cwt",SNR=14, units="ppm")
plot(mse_pick)
# final
mse_final <- process(mse_bin)
print(mse_final)
plot(mse_final)

# 导出
#filename <- basename(folder_path)
#name <- gsub(".imzML$", "", filename)
#root <- "E:\\mass_spectrum_data\\CRC-PXD019662-20240607\\processed0715"
#output_path <- file.path(root, name)
#writeImzML(mse_final, output_path)

# 打印处理信息
cat("Processed:", filename, "\n")
