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
library(onnx)             # transfer model to onnx
library(reticulate)
library(data.table)

# 设置Python环境（如果需要指定特定版本或路径）
use_python("F:\\env\\python3.12\\python.exe", required = TRUE) # 如果默认Python环境没有安装所需的库，请指定Python路径

# 加载XGBoost模型
xgb_model_path <- "C:/Users/A/Desktop/Rds文件/xgboost_feox_model.rds"
xgb_model <- readRDS(xgb_model_path)


# 检查模型类型并保存为二进制格式（以便Python读取）
if (inherits(xgb_model, "xgb.Booster")) {
  binary_model_path <- "C:/Users/A/Desktop/Rds文件/xgboost_feox_model.bin"
  xgb.save(xgb_model, binary_model_path)
} else if (inherits(xgb_model, "xgb.Booster.handle")) {
  binary_model_path <- "C:/Users/A/Desktop/Rds文件/xgboost_feox_model.bin"
  xgb.save.raw(xgb_model$handle, binary_model_path)
} else {
  stop("The loaded model is not of class 'xgb.Booster'. Please ensure you are loading the correct model.")
}


# 将XGBoost模型对象传递给Python
xgb_py <- reticulate::py_assign("xgb_model", xgb_model)

# 使用Python进行转换
py_run_string("
import xgboost as xgb
from skl2onnx import convert_xgboost
from skl2onnx.common.data_types import FloatTensorType
from onnx import save_model

# 假设训练数据有number_of_features个特征
number_of_features = 10  # 替换为实际的特征数量

# 定义输入类型
initial_type = [('float_input', FloatTensorType([None, number_of_features]))]

# 转换为ONNX格式
onnx_model = convert_xgboost(xgb_model, initial_types=initial_type)

# 保存ONNX模型
save_model(onnx_model, 'C:/Users/A/Desktop/Rds文件/xgboost_feox_model.onnx')
")

cat("Model successfully converted to ONNX format.\n")