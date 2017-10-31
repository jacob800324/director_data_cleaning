### text mining ###

## 先安裝好全部需要的套件 ## 
install.packages("jiebaR") ##此為這次文字探勘最主要的套件
install.packages("plyr")
install.packages("stringr")
install.packages("reshape2")


## 每次打開Ｒ時，需要重新library相關套件 ##
library(jiebaR)
library(jiebaRD)
library(plyr)
library(stringr)
library(reshape2)
library(readxl)


## 由於我們是中文文字探勘，因此需要把Ｒ的預設語系改為中文 ##
### 更改語系 change to chinese system ###
system("defaults write org.R-project.R force.LANG zh_TW.UTF-8")




## 以下是jiebaR套件的斷詞測試，測試套件本身斷詞的效果 ##
### example ###
test <- worker() # 先設置一個worker
test #可以看到套件默認的一些設置和各個詞典的預設值，其中，重要的為stop_word和user
## 以下為三種斷詞方法，三種方法的結果是相同的：
test["我今天晚餐吃了牛排"]
test <= "我今天晚餐吃了牛排"
segment("我今天晚餐吃了牛排",test)
### 測試結束 ###
###########################################################


### 以下可以看到辭典以及其路徑 ###
show_dictpath()
dir(show_dictpath())
### 看辭典內的詞 ###
scan(file="/Library/Frameworks/R.framework/Versions/3.3/Resources/library/jiebaRD/dict/user.dict.utf8", what=character(),nlines=50,sep='\n',encoding='utf-8',fileEncoding='utf-8')
#############################################################



##### 以下開始為董監事學經歷資料的整理 #####


### import the data ###
pondata <- read_excel("~/Desktop/pondata.xlsx")

## 此資料一共有637,669筆，時間由2006年到2017年
## 以人為單位，記錄其學經歷資料 

## 首先，檢查重複值，並且刪除重複值
board <- pondata[!duplicated(pondata),] 
## 果然有重複值，剩下630,777筆

## 我們主要的目標是ge欄，觀察到同一格子中會有兩個以上學經歷，因此要先使用str_split剖開
## 再跟原資料檔合併
board2 <- as.data.frame(str_split(board$ge, pattern = "、", simplify = T))
board2$n <- 1:630777
board$n <- 1:630777
board <- merge(board, board2, by="n")
rm(board2)
board <- board[,-1]

### 只留下要分析的欄位
names(board)
b_analysis <- board[,c(-1,-2,-3,-6,-7,-8,-9,-10)]

## 重新命名欄位 ##
names(b_analysis)
names(b_analysis)[1] <- "date"
names(b_analysis)[2] <- "name"

## 設置新的欄位 : year
b_analysis$year <- substr(b_analysis$date, start = 1, stop = 4)
b_analysis <- b_analysis[,-1]



## 用 melt 將多欄轉成一欄 ##
b_melt <- melt(b_analysis, id.vars=c('name', 'year'),var='experience')
b_melt <- b_melt[which(b_melt$value!=""),] ## 把空白刪除
b_melt <- b_melt[with(b_melt, order(year,name)),] ## 重新排序
b_melt <- b_melt[,-3]
names(b_melt)[3] <- "exp"
b_melt <- b_melt[!duplicated(b_melt),]
write.csv(b_melt, "b_melt.csv", na="", fileEncoding = "big5") ## 先存檔，要注意編碼格式

### 看看各個名字每年出現次數 ###
namefreq <- ddply(b_melt, .(name, year), summarize, Freq=table(name))


###### 資料整理結束 #########
#############################################################



####### 以下開始為斷詞 ########

## 建立文字探勘環境 ##
b_parse <- worker() ## 目前尚未加入user自己的辭典
user_parse <- worker(user="/Users/huangguanwen/user_utf8") ## add user dict.

## 以下為斷詞程序 ##
a <- list()
for(i in 1:682490){
  a[[i]] <- b_parse[b_melt[[i,"exp"]]]
}
## 斷詞完 a為一個list格式
## 可以讓斷詞結果變成data.frame
b_mining <- ldply(a, rbind)

## 亦可以計算每個詞出現的頻率多寡
a_2 <- unlist(a)
freq_list <- freq(a_2)


ponpon from ?

