# 前言

這系列的文章是想要重新在寫一次我使用Rcpp的心得，希望供其他R的愛好者參考。

過去我認為，要能理解Rcpp的語法，必須先對C++這個我個人認為最難學的語言先學到某種程度才行。
根據Effective C++的作者Scott Meyers的看法，C++其實是下列四種程式語言的集合(難怪很難，一個打四個!!):

- C (指標、陣列等等)
- 物件導向
- STL 標準函式庫
- Template

我錯了！

Rcpp的源碼中的確用了大量的C++的功能，但是對一般的Rcpp使用者來說，只要能用就好！而C++中複雜的部份Rcpp都包裝起來，只露出簡單的API給使用者。

家齊某次和我hackthon時看到我寫的Rcpp的程式碼不禁驚呼：

「這Rcpp寫起來和R很類似阿！」

除非你想要hack他、擴充他，否則即使是C++的新手，應該也可以輕鬆的開始上手Rcpp。

# Rcpp 簡介

Rcpp 是一個整合R和C++的library，並且提供了許多功能讓使用者能在C++中使用類似R的語法。

通常使用Rcpp不外乎是為了：

1. 優化R：利用編譯過後的程式大幅度的增加迴圈效能，以及增加記憶體的使用效率。
1. 學習R：利用Rcpp快速的測試R 底層的C 函數，以了解R 的底層。
1. 擴充R：將其他第3方的C套件整合到R之中，擴充R既有的功能。

講這麼多，相信沒經驗的讀者還是對Rcpp沒有概念，
所以我們先具體來看一個stackoverflow上的例子吧。(取自<http://stackoverflow.com/questions/14494964/how-to-find-nearby-integers-efficiently/14496071#14496071>
)

有一個R使用者希望能優化(加速)這段R script:

```r
for(i in 1:length(centers)){
	data2 <- data1
	data2[,1] <- data2[,1] - centers[i] + ncol(score_matrix)/2
	region_scores <- subset(data2,data2[,1] > 0 & data2[,1] <= ncol(score_matrix))
	score_matrix[i,region_scores[,1]]<-region_scores[,2]
}
```

接著再來看看我改的Rcpp code。看不懂細節沒關係，我們之後會再說明。這裡主要先讓讀者了解Rcpp code的架構：

```cpp
  // R物件和C++物件之間的轉換
  NumericMatrix data1(Rdata1); 
  NumericVector centers(Rcenters);
  NumericMatrix score_matrix(Rscore_matrix);
  NumericVector data2(data1.nrow());
  // 演算法
  for(int i = 0;i < centers.size();i++) {
    data2 = data1.column(0);
    data2 = data2 - centers(i) + score_matrix.ncol() / 2;
    // subset 的部份
    for(int j = 0, k = 0;j < data2.size();j++) { 
      if (data2(j) <= 0)
        continue;
      if (data2(j) > score_matrix.ncol())
        continue;
      score_matrix(i, data2(j) - 1) = data1(j,1);
    } // end subset
  }
  // 回傳資料
  return score_matrix;
```

從這個範例來看，扣除`subset`的部份，Rcpp的語法是不是和R差不多呢？ 例如：

> `data2 = data2 - centers(i) + score_matrix.ncol() / 2;`

這已經是R才有的向量式四則運算了，一般來說在C/C++中是不能這樣寫的。
這都是由於Rcpp的作者群已經在Rcpp的原始碼中把各種複雜的物件轉換邏輯給包裝起來了，所以我們才可以用這種類似R script的寫法來大幅提速(作問者說快了70倍)。

另外讀者也能注意到，在原文中我並不需要告訴發問者如何設定Rcpp的編譯環境，而僅僅引用兩個套件：`inline`和`Rcpp`。這是因為`Rcpp`也幫大家整合好開發環境，不然一般來說要把C/C++的程式嵌入到R中，需要不少繁瑣且容易出錯的設定。

一個撰寫Rcpp code的過程通常可以切割為：

1. 設定環境，將C++嵌入R
1. 將R 物件轉換為C++物件
1. 在C++實作演算法
1. 將C++物件轉換為R物件

所以讀者若想快速上手Rcpp，筆者建議：

1. 架設Rcpp開發環境，成功執行Hello World
1. 學習基本的C 語法，至少能寫出流程控制(能夠使用`if`, `while`, `for`等等)
1. 從範例中學習R 和C++物件的轉換
1. 從範例中學習Rcpp 所提供的，在C++中和R類似的語句
1. 從既有的範例中修改成使用者需要的程式

本系列的目的是希望能讓不熟悉C/C++的R使用者，能夠初步的使用Rcpp來優化既有的R函數。
接下來在繼續更深入的分享我多年來使用Rcpp的心得。
最後是提供我知道的範例，供初學者參考、修改。
