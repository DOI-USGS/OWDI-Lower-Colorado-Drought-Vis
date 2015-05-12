library(dplyr)
data <- read.csv('../src_data/BasinStudy_TR-C_HistoricalDataDump_Provisional.csv', stringsAsFactors = F)
head(data)

depletion <- summarise(group_by(data, Year), depletion = sum(SumOfDepletion_kafy))
write.table(depletion,'../src_data/Basin_Depletion_yearly_PROVISIONAL.tsv', quote = F, sep = '\t', row.names = F)

