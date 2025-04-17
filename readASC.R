library(readxl)
library(data.table)

# 读取CSV文件, select属性
clay_data <- read_excel("C:/Users/A/Desktop/Rds文件/data/ExcelCLAY.xls")$Clay
som_data <- read_excel("C:/Users/A/Desktop/Rds文件/data/ExcelORGC.xls")$SOM
ph <- read_excel("C:/Users/A/Desktop/Rds文件/data/ExcelPHH2O.xls")$pH
print(clay_data)
clay_data <- as.numeric(unlist(clay_data))
som_data <- as.numeric(unlist(som_data))
ph <- as.numeric(unlist(ph))
ln_Clay <- log(clay_data)
ln_som <- log(som_data)

# 合并列并创建data.table
combined_data <- data.table(ln_Clay, ln_som, ph)

print(combined_data)
