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

# 簡介

Rcpp 是一個整合R和C++的library。通常使用Rcpp不外乎是為了：

1. 優化R：利用編譯過後的程式大幅度的增加回圈效能，以及增加記憶體的使用效率。
1. 學習R：利用Rcpp快速的測試R 底層的C 函數
1. 擴充R：將其他第3方的C套件整合到R之中

一般使用者通常用Rcpp的目的是「優化R」，所以只要找一個架構相似的Rcpp code，然後把演算法改成需要的演算法即可。

以下我將由淺入深，依序來介紹如何使用Rcpp。有加速需求的朋友只需要看前面，而對R底層更有興趣的朋友，或是想要投身Opensource願意壯大R的朋友，就請繼續看下去囉。

# 優化R

你手上有一段跑很慢的R script，想要加速他嘛？你的記憶體不夠了，想要改進記憶體效率嘛？Rcpp有機會可以幫你解決這類問題！但是在一頭栽進來之前，我們也應該要知道Rcpp的能力範圍，以評估我們是不是值得用Rcpp來優化我們的程式。

而對於C++不熟的讀者，使用Rcpp最快的方式就是直接拿現成的code來改，所以就讓我們先來看一些Rcpp的範例吧！

## 範例一

先來看一個stackoverflow上的例子吧：

<http://stackoverflow.com/questions/14494964/how-to-find-nearby-integers-efficiently/14496071#14496071>

以下是問題者提供的R script:

```r
for(i in 1:length(centers)){
	data2 <- data1
	data2[,1] <- data2[,1] - centers[i] + ncol(score_matrix)/2
	region_scores <- subset(data2,data2[,1] > 0 & data2[,1] <= ncol(score_matrix))
	score_matrix[i,region_scores[,1]]<-region_scores[,2]
}
```

這個Script滿足以下幾個條件，所以改起來非常容易，加速的效果也很顯著(作者說Rcpp的版本快了70倍)：

- 迴圈：R語言的迴圈很慢。
- 簡單的操作：取值，加減乘除和比較。這段Script中最複雜的是`subset`函數。

接著再來看看我改的Rcpp code。看不懂細節沒關係，我們之後會再說明。這裡主要先讓讀者了解一個Rcpp code的樣式：

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
    }
  }
  // 回傳資料
  return score_matrix;
```

從這個範例來看，扣除`subset`的部份，Rcpp的語法是不是和R差不多呢？這都是由於Rcpp的作者群已經在Rcpp的原始碼中把各種複雜的物件轉換邏輯給包裝起來了，所以我們才可以用簡單的Rcpp API來大幅提速。

這段程式碼的前四行就是將R的資料結構和C++的資料結構互通，後半段則是寫出演算法的邏輯。而所有Rcpp code的樣式都是這樣的：

1. 先將R物件轉換成C++物件。例如這裡我們把Rdata1轉換成NumericMatrix。
1. 再來實作C++版本的演算法。如果只是取值、比大小，或是簡單的加減乘除，和vector based的加減乘除，那Rcpp API都有支援，所以寫起來和R語言差不多。

## 範例二

這是另一個stackoverflow上的問題(<http://stackoverflow.com/questions/14495697/speeding-up-a-repeated-function-call/14495967#14495967>)。發問者想要優化這個R script:

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

所以這段Rcpp code改起來也很快：

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

仔細看一下，是不是整個Rcpp code的部份也只是：

1. 將R物件轉換成C++物件。
1. 實作C++版本的演算法。

所以只要能熟悉Rcpp API，那寫C++就和寫R 差不多，但是效能可是差很多的呢！
這個例子中，我自己測出來的結果是快了140倍。

## 安裝和使用Rcpp

為了能讓讀者動手嘗試，這裡我只介紹一種最簡單的使用Rcpp的方法。

- 在Windows的讀者請先安裝`Rtools`。
- 接著在R底下安裝Rcpp套件和inline套件。它們目前都在CRAN上，應該可以輕鬆安裝。

接著我們來測試看看能不能正常使用Rcpp:

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

## 物件的轉換

是時候來仔細的看看上述兩個範例中所使用的Rcpp API了:

- NumericVector
- NumericMatrix

這兩個物件分別代表著R之中的`numeric`型態的向量和矩陣。

### 物件的型態(type)

R的使用者可能不清楚什麼是*型態*，所以我這裡簡單的解釋何謂型態。

所有的物件，最終就是電腦中的0和1(又稱做bit)，而電腦要怎麼解釋這些0和1的意義？

舉例來說，`00000011`這8個bit可以解釋為文字符號`"0"`，也可以解釋為整數`3`。

而型態就是電腦解釋這些bit的方式。

在程式中常見的基礎型態是整數、數值(實數)、字串或boolean，而他們在R和C++中有不一樣的名字：

- 整數型態在R叫`integer`，C++叫`int`
- 數值型態在R叫`numeric`，C++叫`double`
- 字串型態在R叫`character`，C++叫`std::string`*。先不要管那個`::`，就把`std::string`當成一個型態的名稱就好！
- boolean型態在R叫`logical`，C++叫`bool`

備註: 字串型態在C++中有點複雜，詳細解釋的話超過本章節的範圍了。所以簡單起見，我一律用`std::string`來代表。

在R 的世界中，R 會自動判斷物件的型態，所以使用者並不需要有這方面的知識，就可以用R了。

但是在C++的世界中，所有物件的型態都要非常清楚。所以在用Rcpp的時候，我們需要初步的了解R 物件的型態。實際上，只要熟悉上面提到的4個型態，就可以將Rcpp應用在很廣泛的問題了！所以讀者不用感到害怕。

### R 物件型態的範例

`numeric`向量的例子有：

- `pi`
- `rnorm(10)`

一般來說，確認`a`物件是不是`numeric`可以用`class(a)`來確認。如果結果是`"numeric"`的話，那就是了。

`numeric`矩陣的例子則是：

- `matrix(rnorm(100), 10, 10)`

檢查`a`是不是`numeric`型態的矩陣的話，通常都是先檢查`class(a)`是不是`"matrix"`，再檢查`class(a[1])`是不是`"numeric"`型態。

### 利用Rcpp API來將R物件傳遞至C++

以下是一個簡單的範例，它將一個R物件傳遞到C++之中，然後把第一個元素印出來：

```r
library(Rcpp)
library(inline)
f <- cxxfunction(sig=c(Ra = "numeric"), plugin="Rcpp", body='
  NumericVector a(Ra);
  Rcout << a[0] << std::endl;
')
f(pi)
```

`f(pi)`運作的結果應是：

```
> f(pi)
3.14159
NULL
```

首先我們仔細的看sig=c(Ra = "numeric") 這行，他的意思就是：第一個參數在C++裡面叫作`Ra`，而且在R中必須是`numeric`型態。

在C++中，直接傳遞進來的物件一律都是`SEXP`型態。對於讀者來說，只要知道`SEXP`是R 的原生C API中的定義的一種型態就可以了，他的意義則已經超出這章的範圍。我們這裡的目的是要學Rcpp API。

所以在C++中，`Ra`是一個`SEXP`，我們則需要運用Rcpp API把他轉換成一個非常好用的物件：`NumericVector`。作法就是：

```cpp
NumericVector a(Ra);
```

也就是我們範例的第一行。這就是讀者要學的Rcpp API的第1招語法：

```
<Rcpp API 物件型態> <C++物件名稱>(<R物件名稱>);
```

這短短一行code做了以下的事情：

- 告訴C++: `a`是一個型態為`NumericVector`的物件。
- 告訴C++: `a`的值和Ra有關。

即使我們知道`a`是一個`NumericVector`型態的物件，具體來說`a`的內容，也就是那一串0、1還是沒有說清楚是什麼。而`a(Ra)`告訴電腦，`a`這個`NumericVector`是一個和`Ra`建立關係的`NumericVector`。(事實上，*他們共用同一塊記憶體*)

所以當R執行`f(pi)`的時候，`Ra`就是`pi`，然後`a`就是一個值是`pi`的`NumericVector`。

那什麼是`NumericVector`呢？

讀著們暫時就把它想像成一個R中數值向量在C++中的代表就可以了！之後我們會再詳細解釋它的特性。

C++物建中，`a[0]`代表的就是`a`的第一個元素了，也就是第一個小數。注意喔，C++中，元素的座標是從`0`開始，而R的座標是從1開始。所以C++的座標比R的座標少1。這裡的語法，C++和R很類似，這都是因為Rcpp刻意讓使用者能夠在C++中使用近似R中的語法。

```cpp
Rcout << a[0] << std::endl;
```

這行呢，則代表將`a[0]`輸出到R console顯示，`std::endl`則是C++內的換行符號。

所以最終呢，我們印出`a`的第一個元素的數值，到console中。而`a`，就是`Ra`，在`f(pi)`中它的值也就是`3.14159...`。

以上就是R 如何將物件傳遞給C++的範例和說明囉！





