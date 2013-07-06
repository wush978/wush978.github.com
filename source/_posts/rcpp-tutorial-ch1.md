# Rcpp 入門

## 適合使用Rcpp做優化的R script

在開始之前，筆者要強調：*並不是所有的R Script都適合使用Rcpp來做優化*。

我們先來看一些適合的例子。這是上一章出現的R script：

```r
for(i in 1:length(centers)){
	data2 <- data1
	data2[,1] <- data2[,1] - centers[i] + ncol(score_matrix)/2
	region_scores <- subset(data2,data2[,1] > 0 & data2[,1] <= ncol(score_matrix))
	score_matrix[i,region_scores[,1]]<-region_scores[,2]
}
```

這個Script滿足以下幾個條件，所以改起來非常容易，加速的效果也很顯著(作者說Rcpp的版本快了70倍)：

- 迴圈：R語言的迴圈很慢，而Rcpp的迴圈很快。
- 簡單的操作：取值(`[`)，加減乘除(`+`, `/`)、布林運算(`&`)和比較(`>`, `<=`)。這段Script中最複雜的是`subset`函數。演算法的邏輯愈簡單，用Rcpp寫起來就越省力。

我們再看另一個stackoverflow上的例子，取自<http://stackoverflow.com/questions/14495697/speeding-up-a-repeated-function-call/14495967#14495967>。
發問者想要優化這個R script:

```r
# x0: a scalar. rs: a numeric vector, length N
# N: typically ~5000
f <- function (x0, rs, N) {
    lambda <- 0                                                                 
    x <- x0                                                                     
    for (i in 1:N) {                                                            
        r <- rs[i]                                                              
        rx <- r * x                                                             
        lambda <- lambda + log(abs(r - 2 * rx))                                 
        # calculate the next x value
        x <- rx - rx * x                                                        
    }                                                                           
    return(lambda / N)                                                          
}
```

仔細看看，這段Script是不是也符合剛剛提到的兩個特性呢？

- 有使用迴圈
- 演算法很簡單

所以我改起來也很快：

```cpp
  double x0 = as<double>(Rx0);
  NumericVector rs(Rrs);
  int N = rs.size();
  double lambda = 0, x = x0, r, rx;
  for(int i = 0;i < N;i++) {
    r = rs[i];
    rx = r * x;
    lambda = lambda + log( fabs(r - 2 * rx) );
    x = rx - rx * x;
  }
  lambda /= N;
  return wrap(lambda);
```

改成Rcpp後也加速了140倍。

## 設定Rcpp開發環境

為了能先讓讀者動手嘗試，這裡我先介紹一種最簡單的使用Rcpp的方法：

- 在Windows的讀者請先安裝`Rtools`。
- 接著在R底下安裝Rcpp套件和inline套件。它們目前都在CRAN上，應該可以輕鬆安裝。

接著我們來測試看看能不能正常使用Rcpp：

```r
library(Rcpp)
library(inline)
f <- cxxfunction(sig=c(), plugin="Rcpp", body='
  Rcout << "Hello World!" << std::endl;               
')
f()
```

如果設定正常的話，就可以在R console上看到：

```
> f()
Hello World!
NULL
```

ps. 這裡我假設讀者並沒有更改R的安裝路徑。如果不是裝在預設路徑，那可能還需要額外的設定了。

## 物件的轉換

是時候來仔細的看看上述兩個範例中所使用的Rcpp 物件了:

- NumericVector
- NumericMatrix
- as

這些是和物件轉換相關的Rcpp API。`as`的情況比較複雜，所以我們先解釋`NumericVector`和`NumericMatrix`。
如名稱所述，這兩個物件分別代表著R之中的`numeric`型態的向量和矩陣。

Rcpp中物件的名稱是經過設計的，讀者在累積足夠的知識後，應該從名稱就可以猜到Rcpp物件是對應到哪一種類型的R物件了。

在更進一步解釋之前，我們需要先了解*物件的型態*。

### 物件的型態(type)

由於使用R的時候，R會自動判斷物件的型態，所以R的使用者可能不清楚什麼是*型態*。

所有物件的資料，最終就是電腦記憶體中的0和1(又稱做bit)，而電腦要怎麼解釋這些0和1的意義？

舉例來說，`00110000`這8個bit可以解釋為文字符號`"0"`，也可以解釋為整數`48`。

而型態就是電腦解釋這些bit的方式。

在程式中常見的基礎型態是整數、數值(實數)、字串或boolean，而他們在R和C++中有不一樣的名字：

- 整數型態在R叫`integer`，C++叫`int`
- 數值型態在R叫`numeric`，C++叫`double`
- 字串型態在R叫`character`，C++叫`std::string`*。先不要管那個`::`，就把`std::string`當成一個型態的名稱就好！
- boolean型態在R叫`logical`，C++叫`bool`

備註: 字串型態在C++中有點複雜，詳細解釋的話超過本章節的範圍了。所以簡單起見，我一律用`std::string`來代表。

在R 的世界中，R 會自動判斷物件的型態，所以使用者並不需要有這方面的知識，就可以用R了。

但是在C++的世界中，所有物件的型態都要非常清楚。所以在用Rcpp的時候，我們需要初步的了解R 物件的型態。實際上，只要熟悉上面提到的4個型態，就可以將Rcpp應用在很廣泛的問題了！所以讀者不用感到害怕。









