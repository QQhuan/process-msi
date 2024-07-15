library(Cardinal)
options(scipen = 999)

# 限定mz的范围
min_mz <- 800
max_mz <- 4500
desired_resolution <- 0.01083 # 期望的m/z分辨率

# 读取数据
data_path <- "E:\\mass_spectrum_data\\CRC-PXD019662-20240607\\TMA7B-alltumour-nonormalization.imzML"
msi <- readImzML(data_path, memory = FALSE, verbose = TRUE, mass.range = c(min_mz, max_mz))
print(msi)

set.seed(1)
# 质量校准
# 首先估计参考峰位置
peaks <- estimateReferencePeaks(msi)
print(peaks)
# 使用局部最大值法进行质量校准
mse_calibrated <- recalibrate(msi, ref=peaks, method="locmax", tolerance=20, units="ppm")
# 为了统一m/z轴，可以使用binning
msi_binned <- bin(mse_calibrated, resolution = desired_resolution, units = "mz")
# 查看校准后的数据概览
normalized_msi <- normalize(msi_binned, method = "tic")

# 基线校正
mse_baselined <- reduceBaseline(normalized_msi, method="locmin") # 采用局部最小值插值法
plot(mse_baselined)
# 数据平滑
mse_smoothed <- smooth(mse_baselined, method="gaussian", width=5) # 高斯平滑，宽度参数需根据数据调整

# 信噪比处理，例如通过峰值提取来实现
#mse_processed <- peakPick(mse_smoothed, method="diff", SNR=2) # 基于差异法，信号噪声比阈值根据数据调整
plot(mse_processed)
print(mse_smoothed)

# mse_align <- peakAlign(mse_smoothed)

#plot(mse_align, i = 4)
# plot(mse_processed)
# 最终处理完后，应用所有排队的处理步骤
mse_final <- process(mse_smoothed)


print(mse_final)

mse_final <- peakPick(mse_final, method="diff", SNR=2)
mse_final <- process(mse_final)

print(mse_align)
#mzlist <- mse_final@spectraData[['mz']]
#n = 111
#print(nrow(mzlist))
#length(mzlist)
#plot(mse_final)
# 绘制多个光谱比较
# plot(mse_final, i=11) # 选了第1, 2, 和第3个光谱比较
# plot(mse_final, i=12) #
# mse_mean <- summarizeFeatures(mse_final, stat="mean") # 计算所有光谱的平均
# plot(mse_mean, "mean") # 绘制平均光谱图```

#coord_m <- data.frame(
#  x = c(1:8034),  # x坐标值
#  y = rep(1, 8034)   # y坐标值
#)
#coord_matrix <- as.matrix(coord_m)
#print(coord_matrix)

# 对整个数据集进行聚类
#data_ssc <- spatialShrunkenCentroids(mse_final, r=1, k=4, s=0, coord=coord_matrix)
#image(data_scc, i=1:4)
#plot(scc, i=1:4)

# 将处理完的数据保存为imzML文件
output_path <- "E:\\mass_spectrum_data\\DGC\\processed2\\GC070T_DGC_83881_E001208_F1_R1"
writeImzML(mse_final, output_path)
