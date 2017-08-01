# RoyalMjz/DefaultPng
IOS的app运行时不满屏，上下留有黑边


在iPhone5或者6上运行以前写的程序时，会出现上下有一样宽高的黑色区域，明明代已经设置全屏了，为啥还出现这样的问题，那又如何解决呢？

因为我们的那个应用是按照320*480的size来运行的，所以导致上下有黑色。

解决办法就是将Default.png、Default-568h@2x.png、Default@2x.png三张图片添加进项目来，可以加到Supporting Files里(ps：直接将图片拖拽进项目中即可）
这样运行就可以解决问题。

```...如果添加后上下黑边依旧存在，就把模拟器里的 app 删掉，按一下Command+Shift+K，再重新运行即可。
    
             


