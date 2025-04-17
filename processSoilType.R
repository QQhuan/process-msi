#####
library(data.table)
library(mltools) # version 0.3.5


dat_yourdata <- fread("C:/Users/A/Desktop/Rds文件/data/1231.csv")
print(data_df)
# 
# model inputs: feox(mmol/kg), alox(mmol/kg), ph, clay(%), som(g/kg) and soil types，log 转化和归一化
# 土壤风化程度: “Slightly”, “Intermediately” and “Strongly” weathering degree
# 土壤类型与土壤风化程度参考  Convert WRB soil types to USDA 
dat_yourdata[, soilty_wrb := 
               ifelse(soilty_cn == "Acrisols", "Ultisols",
                      ifelse(soilty_cn == "Phaeozems", "Mollisols",
                             ifelse(soilty_cn == "Cambisols", "Inseptisols",
                                    ifelse(soilty_cn == "Gleysols", "Inseptisols",
                                           ifelse(soilty_cn == "Regosols", "Entisols",
                                                  ifelse(soilty_cn == "Chernozems", "Mollisols",
                                                         ifelse(soilty_cn == "Kastanozems", "Mollisols",
                                                                ifelse(soilty_cn == "Arenosols", "Entisols",
                                                                       ifelse(soilty_cn == "Solonchaks", "Aridisols", 
                                                                              ifelse(soilty_cn == "Anthrosols", "Inseptisols",
                                                                                     ifelse(soilty_cn == "Luvisols", "Alfisols",
                                                                                            ifelse(soilty_cn == "Solonetz", "Aridisols",
                                                                                                   ifelse(soilty_cn == "Fluvisols", "Entisols",
                                                                                                          ifelse(soilty_cn == "Histosols", "Histosols",
                                                                                                                 ifelse(soilty_cn == "Leptosols", "Entisols",
                                                                                                                        ifelse(soilty_cn == "Andosols", "Andisols",
                                                                                                                               ifelse(soilty_cn == "Calcisols", "Aridisols",
                                                                                                                                      ifelse(soilty_cn == "Cryosols", "Geilsols", "Spodosols"))))))))))))))))))]

print(dat_yourdata)
dat_yourdata[, soilty_usda := 
               ifelse(soilty_wrb == "Geilsols", "Slightly",
                      ifelse(soilty_wrb == "Histosols", "Slightly",
                             ifelse(soilty_wrb == "Spodosols", "Strongly",
                                    ifelse(soilty_wrb == "Andisols", "Slightly",
                                           ifelse(soilty_wrb == "Oxisols", "Strongly",
                                                  ifelse(soilty_wrb == "Vertisols", "Intermediately",
                                                         ifelse(soilty_wrb == "Aridisols", "Intermediately",
                                                                ifelse(soilty_wrb == "Ultisols", "Strongly",
                                                                       ifelse(soilty_wrb == "Mollisols", "Intermediately",
                                                                              ifelse(soilty_wrb == "Alfisols", "Intermediately",
                                                                                     ifelse(soilty_wrb == "Inseptisols", "Slightly",
                                                                                            ifelse(soilty_wrb == "Entisols", "Slightly", NA))))))))))))]

print(dat_yourdata)
# 保存结果为 CSV 文件
write.csv(dat_yourdata, file = "C:/Users/A/Desktop/Rds文件/data/data_typed.csv", row.names = FALSE)