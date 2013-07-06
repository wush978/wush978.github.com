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



