# 加载必要的库
library(mlr3)
library(mlr3learners)
library(caret)
library(readxl)
library(ggplot2)
library(data.table)       # Efficient data processing
library(ggplot2)          # Plotting
library(caret)            # Data splitting
library(mlr3)             # Machine learning framework
library(mlr3learners)     # Provide various learners
library(mlr3measures)     # Evaluation metrics
library(mlr3tuning)       # Hyperparameter tuning
library(paradox)          # Define parameter space
library(broom)            # Extract model parameters
library(DALEX)    

# 读取数据
clay_data <- as.numeric(unlist(read_excel("C:/Users/A/Desktop/Rds文件/data/ExcelCLAY.xls")$Clay))
som_data <- as.numeric(unlist(read_excel("C:/Users/A/Desktop/Rds文件/data/ExcelORGC.xls")$SOM))
ph <- as.numeric(unlist(read_excel("C:/Users/A/Desktop/Rds文件/data/ExcelPHH2O.xls")$pH))

# 对数转换
ln_clay <- log(clay_data + 1) # 避免对0取log导致的问题
ln_som <- log(som_data + 1)
ln_totalp <- log(som_data + 1)
ln_fe <- log(clay_data + 1)
# 创建数据框
data <- data.table(ln_clay, ln_som, ph, ln_totalp, ln_fe)

# 数据划分（70% 训练，30% 测试）
set.seed(123) # 设置随机种子以保证结果可复现
trainIndex <- createDataPartition(data$ph, p = .7, list = FALSE)
trainData <- data[trainIndex, ]
testData <- data[-trainIndex, ]
print(testData)

# 加载XGB模型
xgb_model <- readRDS("C:/Users/A/Desktop/Rds文件/xgboost_feox_model.rds")

# 创建测试数据的任务（仅包含特征）
# test_task <- TaskRegr$new(id = "ph_prediction_test", backend = testData[, -which(names(testData) == "ph")])

# 使用加载的模型进行预测
prediction <- xgb_model$predict_newdata(newdata = testData) # [, -which(names(testData) == "ln_al")])
print(prediction$response)
