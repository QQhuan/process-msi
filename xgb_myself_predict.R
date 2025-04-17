# 加载必要的库
library(mlr3)
library(mlr3learners)
library(caret)
library(readxl)
library(ggplot2)

# 读取数据
clay_data <- as.numeric(unlist(read_excel("C:/Users/A/Desktop/Rds文件/data/ExcelCLAY.xls")$Clay))
som_data <- as.numeric(unlist(read_excel("C:/Users/A/Desktop/Rds文件/data/ExcelORGC.xls")$SOM))
ph <- as.numeric(unlist(read_excel("C:/Users/A/Desktop/Rds文件/data/ExcelPHH2O.xls")$pH))

# 对数转换
ln_Clay <- log(clay_data + 1) # 避免对0取log导致的问题
ln_som <- log(som_data + 1)

# 创建数据框
data <- data.frame(ln_Clay, ln_som, ph)

# 数据划分（70% 训练，30% 测试）
set.seed(123) # 设置随机种子以保证结果可复现
trainIndex <- createDataPartition(data$ph, p = .7, list = FALSE)
trainData <- data[trainIndex, ]
testData <- data[-trainIndex, ]

learner <- readRDS("model.rds")

# 预测
prediction <- learner$predict_newdata(newdata = testData)
print(prediction)

