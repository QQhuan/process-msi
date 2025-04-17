library(Cardinal)
options(scipen = 999)

# 限定mz的范围
min_mz <- 101.05
max_mz <- 1499.9
desired_resolution <- 0.05 # 0.01083 # 期望的m/z分辨率，降低分辨率—— 分辨率太高数据占内存太大无法，多个数据集同时进行实验

path <- "G:/ibp0328/2--neg/MXY-20240422-NEG.imzML"
set.seed(1)


# 注意：对于continuous imzML文件，cardinal默认不能指定范围
msi <- readImzML(path, memory = FALSE, verbose = TRUE) #, mass.range = c(min_mz, max_mz))
# 提取所有m/z值并计算最小值

#mz_values <- mz(msi)        # 获取整个m/z向量
#print(mz_values[1])
#write.table(mz_values[1],
#            file = "first_mz_value.txt",
#            row.names = FALSE,
#            col.names = FALSE)
#min_mz <- min(mz_values)    # 计算最小值

# 输出结果
#print(paste("Minimum m/z value:", min_mz))
# 手动裁剪msi中featureData（mz）的范围
mass <- subset(msi)
# 可视化检查mz范围，结果正确 plot(mass)
# 质量校准
peaks <- estimateReferencePeaks(mass)
mse_recalibrate <- recalibrate(mass, ref=peaks, method="locmax", tolerance=50, units="ppm")

plot(mse_recalibrate)
# 查看校准后的数据概览
normalized_msi <- normalize(mse_recalibrate, method = "tic")
plot(normalized_msi)

# 数据平滑
mse_smoothed1 <- smooth(normalized_msi, method="sgolay", width=11) # 第一次平滑，宽度参数需根据数据调整
mse_smoothed <- smooth(mse_smoothed1, method="sgolay", width=5) # 第二次平滑，宽度参数需根据数据调整

plot(mse_smoothed)
# 基线校正
mse_baselined <- reduceBaseline(mse_smoothed, method="median") # 采用局部中值插值法

plot(mse_baselined)
# 数据分箱
mse_bin = bin(mse_baselined, spectra="intensity", method="sum", unit="mz", resolution=desired_resolution, mass.range = c(min_mz, max_mz))
plot(mse_bin)
# final
mse_final <- process(mse_bin)

# 导出
filename <- basename(path)
name <- gsub(".imzML$", "", filename)
root <- "E:\\mass_spectrum_data\\ipb-20250407"
output_path <- file.path(root, name)
writeImzML(mse_final, output_path, mass.range = c(min_mz, max_mz))

# 打印处理信息
cat("Processed:", filename, "\n")
