# 前言

這系列的文章是想要重新在寫一次我使用Rcpp的心得，希望供其他R的愛好者參考。

過去我認為，要能理解Rcpp的語法，必須先對C++這個我個人認為最難學的語言先學到某種程度才行。
根據Effective C++的作者Scott Meyers的看法，C++其實是下列四種程式語言的集合(難怪很難，一個打四個!!):

- C (指標、陣列等等)
- 物件導向
- STL 標準函式庫
- Template

但是現在我認為我錯了。

Rcpp的源碼中的確用了大量的C++的特性，但是對一般的Rcpp使用者來說，我們只要能用就好，而C++中複雜的部份Rcpp都幫我們解決了。

家齊某次和我hackthon時看到我寫的Rcpp的程式碼不禁驚呼：

「這根本和R很類似阿！」

這就是Rcpp的設計理念。

除非你想要hack他、擴充他，否則即使是C++的新手，應該也可以輕鬆的開始上手Rcpp。

# 介紹

Rcpp 是一個整合R和C++的library。通常我使用Rcpp不外乎是：

1. 加速R：利用編譯過後的程式大幅度的增加回圈效能，以及增加記憶體的使用效率。
1. 學習R：利用Rcpp快速的測試R 底層的C 函數
1. 擴充R：將其他第3方的C套件整合到R之中

一般使用者通常用Rcpp的目的是「加速R」，所以只要找一個架構相似的Rcpp code，然後把演算法改成需要的演算法即可。

以下我將由淺入深，依序來介紹如何使用Rcpp。有加速需求的朋友只需要看前面，而對R底層更有興趣的朋友，或是想要投身Opensource願意撞大R的朋友，也很歡迎繼續看下去。

# 加速R

## 範例一

我們先來看一個stackoverflow上的例子吧：

<http://stackoverflow.com/questions/14494964/how-to-find-nearby-integers-efficiently/14496071#14496071>

先看看他寫的R script:

```r
for(i in 1:length(centers)){
	data2 <- data1
	data2[,1] <- data2[,1] - centers[i] + ncol(score_matrix)/2
	region_scores <- subset(data2,data2[,1] > 0 & data2[,1] <= ncol(score_matrix))
	score_matrix[i,region_scores[,1]]<-region_scores[,2]
}
```

這個Script滿足以下幾個條件，所以改起來非常容易，加速的效果也很顯著(作者說Rcpp的版本快了70倍)：

- 迴圈：R語言的回圈很慢。
- 簡單的演算法邏輯：取值，加減乘除和比較。最複雜的是`subset`函數。

R有優化許多數值演算法，例如矩陣乘法。使用Rcpp來自己寫矩陣乘法，通常會比R原生的還慢喔！所以在優化之前記得要先審時度勢，判斷要不要花力氣下去改寫。

那再來看看我改的Rcpp code:

```cpp
src <- '
  // R物件和C++物件的轉換
  NumericMatrix data1(Rdata1); 
  NumericVector centers(Rcenters);
  NumericMatrix score_matrix(Rscore_matrix);
  NumericVector data2(data1.nrow());
  // 改寫演算法
  for(int i = 0;i < centers.size();i++) {
    data2 = data1.column(0); // data2 = data1[,1]
    data2 = data2 - centers(i) + score_matrix.ncol() / 2; // data2 = data2 - centers[i] + ncol(score_matrix) / 2
    for(int j = 0, k = 0;j < data2.size();j++) { // subset 的部份。
      if (data2(j) <= 0)
        continue;
      if (data2(j) > score_matrix.ncol())
        continue;
      score_matrix(i, data2(j) - 1) = data1(j,1);
    }
  }
  return score_matrix;
'
```

從這個範例來看，扣除`subset`的部份，Rcpp的語法是不是和R差不多呢？這都是由於Rcpp的作者群已經在Rcpp的原始碼中把各種複雜的物件轉換邏輯給包裝起來了，所以我們才可以用如此近似R的語法來大幅提速。
