library(dplyr)
library(zoo)

zz <- read.csv('src_data/PowellMeadFullHistorical.csv')


# sum the storage to get total system storage
zz <- filter(zz, Variable == 'storage') %>% 
  group_by(Date) %>% 
  summarize(TotStorage = sum(Value))

# only want end-of-december values
zz$Date <- zoo::as.yearmon(zz$Date)
# dplyr does not support type yearmon
zz <- zz[format(zz$Date,'%b') == 'Dec',]
# only inlcude the year
zz <- zz %>% mutate(Year = format(Date,'%Y')) %>% 
  select(Year,TotStorage)
write.table(zz,'src_data/MeadPowellCombinedStorage.tsv', quote = F, sep = '\t', row.names = F)
