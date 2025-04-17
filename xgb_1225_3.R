# 安装和加载xgboost包
if (!requireNamespace("xgboost", quietly = TRUE)) {
  install.packages("xgboost")
}
library(xgboost)

# 加载模型
xgb_model <- readRDS("C:/Users/A/Desktop/Rds文件/1215final model_qmax.rds")

# 模拟新数据
set.seed(123)
n <- 100
alox <- rnorm(n, mean = 49, sd = 40)
FeOX <- rnorm(n, mean = 42, sd = 50)
SOM <- rnorm(n, mean = 15, sd = 10) + 0.01
SOM[SOM <= 0] <- 0.01
Clay <- rnorm(n, mean = 8.6, sd = 20) + 0.01
Clay[Clay <= 0] <- 0.01
pH <- runif(n, min = 4.2, max = 8.4)
Ptot <- rnorm(n, mean = 0.42, sd = 0.5) + 0.01

# 创建数据框并进行对数转换
newdata <- data.frame(
  ln_al = log(SOM+2),
  ln_som = log(SOM+2),
  ln_clay = log(Clay+2),
  ln_fe = log(Clay+2),
  soilty_usda_Intermediately = log(Ptot+1),
  soilty_usda_Slightly = pH,
  ph = pH,
  soilty_usda_Strongly = alox
)

# 将数据框转换为xgb.DMatrix对象
# newdata_dmatrix <- xgb.DMatrix(data = as.matrix(newdata))
# print(newdata_dmatrix)
# 使用模型进行预测
predictions <- predict(xgb_model, newdata)

# 查看预测结果
print(predictions)