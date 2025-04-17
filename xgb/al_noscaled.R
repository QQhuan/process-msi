#####
library(data.table)
library(mltools) # version 0.3.5
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
# 
# model inputs: feox(mmol/kg), alox(mmol/kg), ph, clay(%), som(g/kg) and soil types，log 转化和归一化
# 土壤风化程度: “Slightly”, “Intermediately” and “Strongly” weathering degree
# 土壤类型与土壤风化程度参考  Convert WRB soil types to USDA 

# step3: prediction

##----prediction----

## -----------------------------
## 1. 加载训练好的模型
## -----------------------------
full_model <- readRDS("C:/Users/A/Desktop/Rds文件/1230xgboost_model_noncalcareous.rds") # al预测模型

## -----------------------------
## 2. 读取并预处理数据
##    （以下以 东方 为示例）
## -----------------------------
# 2.1 读取 CSV 数据
data_df <- fread("C:/Users/A/Desktop/Rds文件/data/source.csv")

# 2.2 将原有列名转换成小写，并去掉特殊字符“[”
cols_old <- colnames(data_df)
cols_new <- tolower(unlist(tstrsplit(cols_old, '\\[', keep=1)))
setnames(data_df, cols_old, cols_new)

## -----------------------------
## 3. 定义所需均值、标准差等参数
##    (这些值来自 建模的统计结果，固定值)
## -----------------------------
ph_mean      <- 6.44
ph_sd        <- 1.34
lnsom_mean   <- 3
lnsom_sd     <- 0.66
lnclay_mean  <- 2.88
lnclay_sd    <- 0.96
lnfe_mean    <- 3.26
lnfe_sd      <- 0.74
lnal_mean    <- 3.22
lnal_sd      <- 0.82
lnqmax_mean  <- 6.09
lnqmax_sd    <- 0.68

## -----------------------------
## 4. 
##    (在 data_df 基础上创建用于预测的表 dat_qmax)
## -----------------------------
dat_qmax <- data_df[, .(
  ph,       # pH 值
  alox,     # 氧化铝
  som,      # 土壤有机碳
  clay,     # 黏土含量
  tp        # 总磷 mg/kg
)]

# 4.1 计算中间变量，删除/替换多余列
dat_qmax[ , som := som]    # SOM 的计算方式：SOC×2×10（有机碳与SOM的转换系数2，%=> g/kg 是10）
dat_qmax[ , lnal := log(alox)]     # 
dat_qmax[ , lnsom := log(som)]     # 
dat_qmax[ , lnclay := log(clay)]   # 
dat_qmax[ , ln_totalp := log(tp*1000)]   # 转为g/kg，并取对数 

# 4.2 将 soilty 转换为因子，并做 One-Hot 编码

# 4.3 对部分特征进行标准化（减去均值再除以标准差）
# for all variables: LnX scaled = (ln Xvalue -lnX mean)/lnXsd see word doc
dat_qmax[ , ph := (ph - ph_mean) / ph_sd]
dat_qmax[ , lnsom_scaled := (lnsom - lnsom_mean) / lnsom_sd]
dat_qmax[ , lnal_scaled  := (lnal  - lnal_mean ) / lnal_sd ]
dat_qmax[ , lnclay_scaled := (lnclay - lnclay_mean) / lnclay_sd]

## -----------------------------
## 5. 选择并重命名预测所需的列
## -----------------------------
dat_pred <- dat_qmax[, .(
  ph,
  lnsom_scaled,
  lnal_scaled,
  lnclay_scaled,
  ln_totalp
)]

# 使用 setnames() 批量重命名，必须与该列名保持一致
setnames(
  dat_pred,
  old = c("ph", "lnsom_scaled", "lnal_scaled", "lnclay_scaled", "ln_totalp"),
  new = c("ph", "ln_som", "ln_al", "ln_clay", "ln_totalp")
)

## -----------------------------
## 6. 使用模型进行预测
## -----------------------------
# 注意：predict() 返回的是 ln(qmax) 在经过再次标准化后的预测值
predictions <- predict(full_model, newdata = dat_pred)
print(predictions)
# 6.1 合并预测结果到 dat_pred 中
dat_pred <- as.data.table(cbind(dat_pred, lnal_scaled = predictions))

dat_pred[ , lnal := lnal_scaled * lnal_sd + lnal_mean]

dat_pred[ , al := exp(lnal * lnal_sd + lnal_mean)]
# 7. 保存结果为 CSV 文件
write.csv(dat_pred, file = "C:/Users/A/Desktop/Rds文件/lnal_predictions.csv", row.names = FALSE)

























