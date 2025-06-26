from pyecharts.charts import Map
from pyecharts import options as opts
from pyecharts.commons.utils import JsCode

# pip install pandas pyecharts snapshot-selenium selenium  
data = [
    ("北京", 5.2),
    ("上海", 6.8),
    ("广东", 8.3),
    ("浙江", 4.1),
    ("四川", 2.9),
    ("云南", 0.5)
]

# 构造地图
map_chart = (
    Map()
    .add("发文占比（%）", data, "china")
    .set_series_opts(
        label_opts=opts.LabelOpts(
            is_show=True,
            formatter=JsCode("""
                function(params){
                    if (params.value === 0 || isNaN(params.value)) {
                        return '';
                    }
                    return params.name + '\\n' + params.value.toFixed(2) + '%';
                }
            """),
            font_size=10,
            color="black"
        )
    )
    .set_global_opts(
        title_opts=opts.TitleOpts(title="全国各省低空经济发文占比地图（仅显示有数据的标签）"),
        visualmap_opts=opts.VisualMapOpts(
            is_piecewise=True,
            pieces=[
                {"min": 8, "label": ">8%", "color": "#67000d"},
                {"min": 6, "max": 8, "label": "6%-8%", "color": "#cb181d"},
                {"min": 4, "max": 6, "label": "4%-6%", "color": "#ef3b2c"},
                {"min": 2, "max": 4, "label": "2%-4%", "color": "#fb6a4a"},
                {"min": 1, "max": 2, "label": "1%-2%", "color": "#fcae91"},
                {"max": 1, "label": "<1%", "color": "#fee5d9"},
            ],
            pos_left="left",
            pos_bottom="center"
        ),
        tooltip_opts=opts.TooltipOpts(
            formatter="{b}<br/>占比：{c.toFixed(2)}%"
        )
    )
)

# 输出 HTML
map_chart.render("全国低空经济地图_测试数据.html")
print("✅ 地图已生成：全国低空经济地图_测试数据.html")
