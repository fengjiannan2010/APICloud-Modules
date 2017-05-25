# **概述**

折线图模块源码（含 iOS 和 Android ）

APICloud 的 UIVividLine 是一个折线图模块，可指定该模块依附于当前主 window ，本模块打开的视图类似 open 一个 frame。开发者可通过相应接口参数自定义其样式，设置、刷新、拼接数据等功能。本模块封装的UI布局都是规定死的，其功能也不能满足 APICloud 开发者日益增长的项目需求。应广大开发者要求，特将本模块源码开源，原生开发者可以在此模块的基础上继续完善该模块的其它接口。让前端开发者很快地在 APICloud 上开发出各式各样、效果炫酷的app。

# **模块接口文档**

<p style="color: #ccc;margin-bottom: 30px;">来自于：APICloud 官方<a style="background-color: #95ba20; color:#fff; padding:4px 8px;border-radius:5px;margin-left:30px; margin-bottom:0px; font-size:12px;text-decoration:none;" target="_blank" href="http://www.apicloud.com/mod_detail?mdId=19023">立即使用</a></p>

<ul id="tab" class="clearfix">
	<li class="active"><a href="#method-content">Method</a></li>
</ul>
<div id="method-content">

<div class="outline">

[open](#1)

[reloadData](#2)

[appendData](#3)

[close](#4)

[hide](#5)

[show](#6)

</div>

# **概述**

UIVividLine模块封装了一个折线图视图，开发者可自定义其样式，可刷新数据，左右拖动查看不同的数据，并且能响应用户点击结点的事件。支持设置每个节点的示意图标，单击节点弹出气泡提示框。如下图：


![图片说明](http://docs.apicloud.com/img/docImage/module-doc-img/layout/UIVividLine/UIVividLine1.PNG)

**注意：open 时，若传入的 datas 内元素个数少于当前屏幕所能显示的最大个数时，不可左右拖动模块**

<div id="1"></div>

# **open**

打开折线图视图

open({params}, callback(ret))

## params

rect：

- 类型：JSON 对象	
- 描述：（可选项）模块的位置及尺寸
- 默认值： 见内部字段
- 内部字段：

```js
{
    x: 0,                              //（可选项）数字类型；模块左上角的 X 坐标（相对于所属的 Window 或 Frame）；默认：0
    y: 0,                              //（可选项）数字类型；模块左上角的 Y 坐标（相对于所属的 Window 或 Frame）；默认：0
    w: 320,                            //（可选项）数字类型；模块的宽度；默认：所属的 Window 或 Frame 的宽度
    h: 300                             //（可选项）数字类型；模块的高度；默认：w-20
}
```

styles:

- 类型：JSON 对象
- 描述：（可选项）折线图样式配置
- 默认值：见内部字段
- 内部字段：

```js
{
    bg: 'rgba(0,0,0,0)',            //（可选项）字符串类型；模块背景配置，支持grb、rgba、#、img；默认：rgba(0,0,0,0)
    xAxisGap: w/6.5,                //（可选项）X 轴标记间隔距离；默认：w/6
    yAxis: {                        //（可选项）JSON 对象；K 线图坐标系 y 轴配置参数
       max: 5,                      //（可选项）数字类型；Y 轴最大值；默认：5
       min: 1,                      //（可选项）数字类型；Y 轴最小值（大于零）；默认：1
       step: 1,                     //（可选项）数字类型；Y 轴步幅；默认最小值：1
       suffix: '级',                //（可选项）字符串类型；Y 轴标注后缀；默认:空字符串
       width: w/6.5,                //（可选项）数字类型；Y 轴的标注所占的宽度；默认： w/6.5
       color: '#696969',            //（可选项）字符串类型；Y 轴标注字体颜色，支持rgb、rgba、#；默认：#696969
       size: 12                     //（可选项）数字类型；Y 轴标注字体大小；默认：12
    },
    xAxis: {                        //（可选项）JSON 对象；X 轴的样式配置
       color: '#fff',               //（可选项）字符串类型；X 轴标注字体颜色，支持rgb、rgba、#；默认：#fff
       size: 12,                    //（可选项）数字类型；X 轴标注字体大小；默认：12
       height: h/6.0,               //（可选项）数字类型；X 轴所占高度；默认：h/6.0
       bubble: {                    //（可选项）JSON对象；点击结点时，在对应 X 轴上弹出的提示框样式配置
          w: w/(6.5*2.0),           //（可选项）数字类型；提示框的宽；默认：w/(6.5*2.0)
          h: h/9.0,                 //（可选项）数字类型；提示框的高；默认：h/9.0
          bg: 'fs://vidBubble.png', //（可选项）字符串类型；提示框的背景图片设置，要求本地路径（fs://、widget://）;若不传则不显示提示框背景
          size: 14,                 //（可选项）数字类型；提示框内的字体大小；默认：14
          color: '#fff'             //（可选项）字符串类型；提示框内的字体颜色；默认：#fff 
       }
    },
    coordinate: {                   //（可选项）JSON对象；坐标线的样式配置
       horizontal: {                //（可选项）JSON对象；横坐标线样式配置
          color: '#696969',         //（可选项）字符串类型；横坐标线颜色，支持 rgb、rgba、#；默认：#696969
          width: 0.5,               //（可选项）数字类型；横坐标线粗细；默认：0.5
          style: 'solid'            //（可选项）字符串类型；横坐标线类型，取值范围：dash（虚线）、solid（实线）；默认：solid
		},
       vertical: {                  //（可选项）JSON对象；竖坐标线样式配置
          color:'rgba(0,0,0,0)',    //（可选项）字符串类型；竖坐标线颜色，支持 rgb、rgba、#；默认：rgba(0,0,0,0)
          width: 0.5,               //（可选项）数字类型；竖坐标线粗细；默认：0.5
          style: 'solid'            //（可选项）字符串类型；竖坐标线类型，取值范围：dash（虚线）、solid（实线）；默认：solid
		}
    },
    line: {                         //（可选项）JSON 对象；折线的样式配置
       color: '#fff',               //（可选项）字符串类型；折线颜色设置，支持 rgb、rgba、#；默认：#fff
       width: 1                     //（可选项）数字类型；折线粗细；默认：1.0
    },
    node: {                         //（可选项）JSON 对象；结点的样式配置
       size: 3,                     //（可选项）数字类型；结点大小；默认：3.0
       color: '#fff',               //（可选项）数字类型；结点颜色设置，支持 rgb、rgba、#；默认：#fff
       hollow: false                //（可选项）布尔类型；是否为空心圆；默认：false
    },
    icon: {                         //（可选项）JSON对象；结点上示意图标的大小配置
       width: 60,                   //（可选项）数字类型；结点上示意图标的宽；默认：60
       height: 60                   //（可选项）数字类型；结点上示意图标的高；默认：60
    }
}
```

datas：

- 类型：数组对象	
- 描述：折线的数据信息
- 内部字段：

```js
[{	
	mark: '',   //字符串类型；X 轴标注
	value: ,    //数字类型；标注对应的值，取值范围在 min 和 max 之间
	icon: ''    //（可选项）字符串类型；结点提示图标的路径，要求本地路径（fs://、widget://）
}]
```

fixedOn：

- 类型：字符串类型
- 描述：（可选项）模块视图添加到指定 frame 的名字（只指 frame，传 window 无效）
- 默认：模块依附于当前 window

fixed:

- 类型：布尔
- 默认值：true
- 描述：是否将模块视图固定到窗口上，不跟随窗口上下滚动，可为空

## callback(ret)

ret：

- 类型：JSON 对象
- 内部字段：

```js
{
     id: 1,                   //数字类型；打开的折线图视图的 id
     eventType: 'nodeClick',  //字符串类型；交互事件类型，取值范围如下：
                              //show：模块打开并显示在页面上
                              //nodeClick：用户点击结点事件
                              //scrollLeft：向左滑动到头后再滑动一定阈值（40）后触发该事件
                              //scrollRight：向右滑动到头后再滑动一定阈值（40）后触发该事件
     index:3                  //数字类型；点击结点的下标，仅当 eventType 为 nodeClick 时有值
}
```

## 示例代码

```js
var obj = api.require('UIVividLine');
obj.open({
	rect: {
		x: 10,
		y: 10,
		w: 300,
		h: 150
	},
	styles: {
		bg: 'widget://res/UIVividLine/bg.png',
		xAxisGap: 46.1,
		yAxis: {
			max: 5,
			min: 1,
			step: 1,
			suffix: '级',
			width: 46.1,
			color: '#696969',
			size: 12
		},
		xAxis: {
			color: '#fff',
			size: 12,
			height: 25,
			bubble: {
				w: 23,
				h: 17,
				bg: 'widget://res/UIVividLine/bubble.png',
				size: 14,
				color: '#fff'
			}
		},
		coordinate: {
			horizontal: {
				color: '#696969',
				width: 0.5,
				style: 'solid'
			},
			vertical: {
				color: '#696969',
				width: 0.5,
				style: 'solid'
			}
		},
		line: {
			color: '#fff',
			width: 1
		},
		node: {
			size: 3,
			color: '#fff',
			hollow: false
		},
		icon: {
			width: 30,
			height: 30
		}
	},
	fixedOn: api.frameName,
	fixed: true,
	datas: [{
		mark: '15:00',
		value: 3,
		icon: 'widget://res/UIVividLine/icon1.png'
	}, {
		mark: '16:00',
		value: 2,
		icon: 'widget://res/UIVividLine/icon2.png'
	}, {
		mark: '17:00',
		value: 4,
		icon: 'widget://res/UIVividLine/icon3.png'
	}, {
		mark: '18:00',
		value: 2,
		icon: 'widget://res/UIVividLine/icon4.png'
	}, {
		mark: '19:00',
		value: 3,
		icon: 'widget://res/UIVividLine/icon5.png'
	}, {
		mark: '20:00',
		value: 2,
		icon: 'widget://res/UIVividLine/icon6.png'
	}]
}, function(ret) {
	api.alert({
		msg: JSON.stringify(ret)
	});
});
```

## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="2"></div>

# **reloadData**

刷新折线数据

reloadData({params})

## params

id：

- 类型：数字	
- 描述：操作视图的 id

datas：

- 类型：数组对象	
- 描述：折线的数据信息
- 内部字段：

```js
[{	
	mark: '',   //字符串类型；X 轴标注
	value: ,    //数字类型；标注对应的值，取值范围在 min 和 max 之间
	icon: ''    //（可选项）字符串类型；结点提示图标的路径，要求本地路径（fs://、widget://）
}]
```

## 示例代码

```js
var UIVividLine = api.require('UIVividLine');
UIVividLine.reloadData({
	id: 1,
	datas: [{
		mark: '15:00',
		value: 1,
		icon: 'widget://res/UIVividLine/icon1.png'
	}, {
		mark: '16:00',
		value: 2,
		icon: 'widget://res/UIVividLine/icon2.png'
	}, {
		mark: '17:00',
		value: 2,
		icon: 'widget://res/UIVividLine/icon3.png'
	}, {
		mark: '18:00',
		value: 2,
		icon: 'widget://res/UIVividLine/icon4.png'
	}, {
		mark: '19:00',
		value: 2,
		icon: 'widget://res/UIVividLine/icon5.png'
	}, {
		mark: '20:00',
		value: 4,
		icon: 'widget://res/UIVividLine/icon6.png'
	}]
});
```

## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="3"></div>

# **appendData**

往现有数据拼接新数据

appendData({params})

## params

id：

- 类型：数字	
- 描述：操作视图的 id

datas：

- 类型：数组对象	
- 描述：折线的数据信息
- 内部字段：

```js
[{	
	mark: '',   //字符串类型；X 轴标注
	value: ,    //数字类型；标注对应的值，取值范围在 min 和 max 之间
	icon: ''    //（可选项）字符串类型；结点提示图标的路径，要求本地路径（fs://、widget://）
}]
```

orientation：

- 类型：字符串	
- 描述：（可选项）拼接数据的方向，取值范围：right，left
- 默认值：right

## 示例代码

```js
var UIVividLine = api.require('UIVividLine');
UIVividLine.appendData({
	id: 1,
	orientation: 'right',
	datas: [{
		mark: '21:00',
		value: 1,
		icon: 'widget://res/UIVividLine/icon1.png'
	}, {
		mark: '22:00',
		value: 2,
		icon: 'widget://res/UIVividLine/icon2.png'
	}, {
		mark: '23:00',
		value: 2,
		icon: 'widget://res/UIVividLine/icon3.png'
	}, {
		mark: '24:00',
		value: 2,
		icon: 'widget://res/UIVividLine/icon4.png'
	}, {
		mark: '00:00',
		value: 2,
		icon: 'widget://res/UIVividLine/icon5.png'
	}, {
		mark: '01:00',
		value: 4,
		icon: 'widget://res/UIVividLine/icon6.png'
	}]
});
```

## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="4"></div>

# **close**

关闭折线图视图，并从内存里清空

close({params})

## params

id：

- 类型：数字	
- 描述：操作视图的 id

## 示例代码

```js
var UIVividLine = api.require('UIVividLine');
UIVividLine.close({
	id: 1
});
```

## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="5"></div>

# **hide**

隐藏折线图视图，并没有从内存里清空

hide ({params})

## params

id：

- 类型：数字	
- 描述：操作视图的 id

## 示例代码

```js
var UIVividLine = api.require('UIVividLine');
UIVividLine.hide({
	id: 1
});
```
## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="6"></div>

# **show**

显示已隐藏的折线图视图

show ({params})

## params

id：

- 类型：数字	
- 描述：操作视图的 id

## 示例代码

```js
var UIVividLine = api.require('UIVividLine');
UIVividLine.show({
	id: 1
});
```

## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本
