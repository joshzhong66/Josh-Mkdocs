---
title: 首页
template: home.html
---

<!--center><font  color= #518FC1 size=6 class="ml3">循此苦旅，以达星辰</font></center-->

<script src="https://cdnjs.cloudflare.com/ajax/libs/animejs/2.0.2/anime.min.js"></script>


本站点文章主要记录个人的 **日常**，包含对于互联网 IT、运维、工作生活的相关文章汇总。

<div id="rcorners">
    <body>
      <font color="#4351AF">
        <p class="p1"></p>
<script defer>
    //格式：2020年04月12日 10:20:00 星期二
    function format(newDate) {
        var day = newDate.getDay();
        var y = newDate.getFullYear();
        var m =
            newDate.getMonth() + 1 < 10
                ? "0" + (newDate.getMonth() + 1)
                : newDate.getMonth() + 1;
        var d =
            newDate.getDate() < 10 ? "0" + newDate.getDate() : newDate.getDate();
        var h =
            newDate.getHours() < 10 ? "0" + newDate.getHours() : newDate.getHours();
        var min =
            newDate.getMinutes() < 10
                ? "0" + newDate.getMinutes()
                : newDate.getMinutes();
        var s =
            newDate.getSeconds() < 10
                ? "0" + newDate.getSeconds()
                : newDate.getSeconds();
        var dict = {
            1: "一",
            2: "二",
            3: "三",
            4: "四",
            5: "五",
            6: "六",
            0: "天",
        };
        //var week=["日","一","二","三","四","五","六"]
        return (
            y +
            "年" +
            m +
            "月" +
            d +
            "日" +
            " " +
            h +
            ":" +
            min +
            ":" +
            s +
            " 星期" +
            dict[day]
        );
    }
    var timerId = setInterval(function () {
        var newDate = new Date();
        var p1 = document.querySelector(".p1");
        if (p1) {
            p1.textContent = format(newDate);
        }
    }, 1000);
</script>
      </font>
    </body>
  </div>
<p align="center">
    <img src="https://pic.joshzhong.top/i/2025/05/14/swrzis.gif" alt><br>
</p>






!!! abstract "非常喜欢纪伯伦的名言-如下："

    我们已经走得太远，以至于忘了当初为什么而出发。
    
    再遥远的目标，也经不起执着的坚持。
    
    用记忆拥抱着过去，用希望拥抱着未来。
    
    思想是天空中的鸟，在语言的笼里，也许会展翼，却不会飞翔。
    
    第一次，当它本可进取时，却故作谦卑；
    
    第二次，当它在空虚时，用爱欲来填充；
    
    第三次，在困难和容易之间，它选择了容易；
    
    第四次，它犯了错，却借由别人也会犯错来宽慰自己；
    
    第五次，它自由软弱，却把它认为是生命的坚韧；
    
    第六次，当它鄙夷一张丑恶的嘴脸时，却不知那正是自己面具中的一副；
    
    第七次，它侧身于生活的污泥中，虽不甘心，却又畏首畏尾。 ——《我曾七次鄙视我的灵魂》

