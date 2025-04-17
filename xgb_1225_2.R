
# Load required libraries
library(data.table)       # Efficient data processing
library(ggplot2)          # Plotting
library(caret)            # Data splitting
library(mlr3)             # Machine learning framework
library(mlr3learners)     # Provide various learners
library(mlr3measures)     # Evaluation metrics
library(mlr3tuning)       # Hyperparameter tuning
library(paradox)          # Define parameter space
library(broom)            # Extract model parameters
library(DALEX)            # Model explanation (optional)

# 加载模型
xgb_model <- readRDS("C:/Users/A/Desktop/Rds文件/xgboost_feox_model.rds")
# 模拟新数据
set.seed(123)
n <- 10
alox <- rnorm(n, mean = 30, sd = 4)
FeOX <- rnorm(n, mean = 42, sd = 5)
SOM <- rnorm(n, mean = 15, sd = 10) + 0.01
SOM[SOM <= 0] <- 0.01
Clay <- rnorm(n, mean = 8.6, sd = 20) + 0.01
Clay[Clay <= 0] <- 0.01
pH <- runif(n, min = 4.2, max = 8.4)
Ptot <- rnorm(n, mean = 0.42, sd = 0.5) + 0.01

# 创建数据框并进行对数转换
newdata <- data.table(
  ln_som = log(SOM+2),
  ln_clay = log(Clay+2),
  ph = pH
)

print(newdata)
explainers <- list()
print(explainers)
key_model <- 'xgb_model'
explainers[[key_model]] <- list()
response_col <- 'ln_fe'
data_subset <- newdata



explainers[[key_model]]<- 
  DALEX::explain(
    xgb_model,
    data =data_subset,
    y = data_subset[[response_col]],
    label = paste0("1model_", "_xgb_",".rds")
  )


# 将数据框转换为xgb.DMatrix对象
# newdata_dmatrix <- xgb.DMatrix(data = as.matrix(newdata))
# print(newdata_dmatrix)
# 使用模型进行预测
predictions <- predict(xgb_model, newdata = newdata)

# 查看预测结果
print(predictions)
