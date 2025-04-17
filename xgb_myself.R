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

# 定义任务
task <- TaskRegr$new(id = "ph_prediction", backend = trainData, target = "ph")

# 初始化XGBoost学习器（使用默认参数）
learner <- lrn("regr.xgboost")

# 训练模型
learner$train(task)
saveRDS(learner, file = "model.rds")
# 预测
prediction <- learner$predict_newdata(newdata = testData)

# 结果评估
performance <- prediction$score(msr("regr.rmse"))
print(paste("RMSE:", performance))

# 可视化预测与实际值对比
ggplot() +
  geom_point(aes(x = testData$ph, y = prediction$response), color = 'blue') +
  geom_abline(slope = 1, intercept = 0, color = 'red', linetype = "dashed") +
  labs(title = "Predicted vs Actual pH Values",
       x = "Actual pH",
       y = "Predicted pH")
