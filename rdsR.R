# 加载必要的库
library(xgboost)
library(readr)


# 加载模型
model <- readRDS("C:/Users/A/Desktop/Rds文件/xgboost_alox_model.rds")

# 定义测试数据
# 注意：确保这些值与训练模型时使用的特征相同，并且应用相同的变换（如自然对数）
test_data <- data.frame(
  ph = c(6.0),                  # 不转换pH值
  ln_som = log(c(250)),        # SOM (mg/kg) 的自然对数值
  ln_clay = log(c(30)),        # clay content (%) 的自然对数值
  ln_totalp = log(c(1))       # total P (g/kg) 的自然对数值
)

# 将测试数据转换为 xgb.DMatrix 格式
dtest <- xgb.DMatrix(data = as.matrix(test_data))

# 使用模型进行预测
predictions <- predict(model, test_data)

# 输出预测结果
print(predictions)

# 如果模型输出的是 ln(FeOX(mmol/kg)) 和 ln(AlOX(mmol/kg)) 的对数值，
# 那么我们可能需要将它们转换回原始尺度
original_scale_predictions <- exp(predictions)
print(original_scale_predictions)

