# **概述**

底部导航条模块源码（含 iOS 和 Android ）

APICloud 的 NVTabBar 是一个底部导航条模块，该模块依附于当前主 window 。开发者可通过相应接口参数自定义其样式，设置、取消选中状态，动态配置 item 的徽章（badge）等功能。本模块封装的UI布局都是规定死的，其功能也不能满足 APICloud 开发者日益增长的项目需求。应广大开发者要求，特将本模块源码开源，原生开发者可以在此模块的基础上继续完善该模块的其它接口。让前端开发者很快地在 APICloud 上开发出各式各样、效果炫酷的app。

# **模块接口文档**

<p style="color: #ccc; margin-bottom: 30px;">来自于：APICloud 官方</p>

<div class="outline">

[open](#open)

[hide](#hide)

[show](#show)

[close](#close)

[setBadge](#setBadge)

[setSelect](#setSelect)

[bringToFront](#bringToFront)

</div>

# **模块简述**

NVTabBar 是一个底部导航条模块，该模块依附于当前主 window 。开发者可通过相应接口参数自定义其样式，设置、取消选中状态，动态配置 item 的徽章（badge）等功能。

本模块可实现的效果图如下所示：


![图片说明](http://docs.apicloud.com/img/docImage/NVTabBar/dot1.png)


![图片说明](http://docs.apicloud.com/img/docImage/NVTabBar/dot2.png)


![图片说明](http://docs.apicloud.com/img/docImage/NVTabBar/dynamic1.png)


![图片说明](http://docs.apicloud.com/img/docImage/NVTabBar/dynamic2.png)


![图片说明](http://docs.apicloud.com/img/docImage/NVTabBar/tuber1.png)


![图片说明](http://docs.apicloud.com/img/docImage/NVTabBar/tuber2.png)


![图片说明](http://docs.apicloud.com/img/docImage/NVTabBar/tuber3.png)


<div id="open"></div>

# **open**

打开模块并显示

open({params}, callback(ret))

## params

styles：

- 类型：JSON 对象
- 描述：模块样式配置
- 默认值：见内部字段
- 内部字段：

```js
{
    bg: '#fff',         //（可选项）字符串类型；模块背景，支持 rgb、rgba、#、img；默认：#ffffff
    h: 50 ,             //（可选项）数字类型；模块的高度（含分割线）；默认：50
    dividingLine: {     //（可选项）JSON对象；模块顶部的分割线配置
       width: 0.5,      //（可选项）数字类型；分割线粗细；默认：0.5
       color: '#000'    //（可选项）字符串类型；分割线颜色；默认：#000
    },
    badge: {            //（可选项）JSON对象；徽章样式配置；若不传则去内部字段默认值
       bgColor: '#ff0', //（可选项）字符串类型；徽章背景色，支持rgb、rgba、#；默认：#ff0
       numColor: '#fff',//（可选项）字符串类型；徽章数字字体颜色，支持rgb、rgba、#；默认：#fff
       size: 6.0,       //（可选项）数字类型；徽章半径大小；默认值：6.0
       fontSize:10      // (可选项) 数字类型;设置徽章字体大小;默认值: 10 ;注意:仅支持iOS。
       centerX: 6.0,    //（可选项）数字类型；徽章中心点坐标（相对于所属item的背景面板坐标系）；默认值：icon图标的右上角
       centerY: 6.0     //（可选项）数字类型；徽章中心点坐标（相对于所属item的背景面板坐标系）；默认值：icon图标的右上角
    }
}
```

items：

- 类型：数组
- 描述：导航条子项配置，子项条数不能超过 5
- 内部字段：

```js
[{
    w: api.winWidth/5.0,      //（可选项）数字类型；子项的宽度（识别点击事件的区域宽度）；默认：api.winWidth/items子项总数
    bg: {                     //（可选项）JSON对象；子项背景配置，若不传则取内部字段默认值
       marginB: 0,            //（可选项）数字类型；子项背景距离模块底部的距离，设置大于0的数字可实现凸起效果；默认：0
       image: 'rgba(0,0,0,0)',//（可选项）字符串类型；子项的背景，支持rgb、rgba、#、img（仅支持本地图片路径fs://、widget://）；默认：rgba(0,0,0,0)
    },
    iconRect: {               //（可选项）JSON对象；子项按钮图标的大小配置，位置居中显示；默认值见内部字段
       w: 25.0,               //（可选项）数字类型；子项按钮图标的宽度；默认：25.0
       h: 25.0,               //（可选项）数字类型；子项按钮图标的高度；默认：25.0
    },
    icon: {                   // JSON对象；子项按钮图标配置
		normal: '',           // 字符串类型；子项按钮常态下的背景图片路径，要求本地路径（fs://、widget://）
		highlight: '',        //（可选项）字符串类型；子项按钮高亮态下的背景图片路径，要求本地路径（fs://、widget://），若不传或传空则无按钮高亮效果
		selected: ''          //（可选项）字符串类型；子项按钮按钮选中后的背景图片路径，要求本地路径（fs://、widget://），若不传或传空则无选中后效果
    },
    title: {                  //（可选项）JSON对象；子项标题配置，若不传则取内部字段默认值
       text: '',              //（可选项）字符串类型；子项按钮下面的标题文字，若不传或传空则不显示
       size: 12.0,            //（可选项）数字类型；子项标题文字大小；默认：12.0  
       normal: '#696969',     //（可选项）字符串类型；子项标题文字常态颜色；默认：#696969
       selected: '#ff0',      //（可选项）字符串类型；子项标题文字选中后颜色；默认：#ff0
       marginB: 6.0           //（可选项）数字类型；子项标题距离模块下边缘的距离；默认：6.0
       ttf:'Alkatip Basma Tom'//（可选项）字符串类型；默认值：当前系统字体；
	                            本参数在 iOS 平台上表示字体名称 （必须已在 config 文件内配置 ttf 文件(http://docs.apicloud.com/Dev-Guide/app-config-manual#14-1)，并在 widget 包内包含该 ttf 文件）；
	                            本参数在 android 平台上表示 ttf 文件路径，要求本地路径（fs://、widget://）
    }
}]
```

selectedIndex：

- 类型：数字
- 描述：（可选项）默认值为选中状态的按钮的索引，若不传则默认无选中项


## callback(ret)

ret：

- 类型：JSON 对象
- 内部字段：

```js
{
    eventType: 'show',      //字符串类型；交互事件类型，取值范围如下：
                            //show：打开模块并显示事件
                            //click：用户点击模块内子按钮事件
    index:0                 //数字类型；用户点击按钮的索引，仅当 eventType 为 click 时有值
}
```

## 示例代码

```js
var NVTabBar = api.require('NVTabBar');
NVTabBar.open({
	styles: {
		bg: '#fff',
		h: 50,
		dividingLine: {
			width: 0.5,
			color: '#000'
		},
		badge: {
			bgColor: '#ff0',
			numColor: '#fff',
			size: 6.0,
			fontSize:10 //数字类型,设置徽章字体大小,默认10。注意:仅支持iOS。
		}
	},
	items: [{
		w: api.winWidth / 3.0,
		bg: {
			marginB: 0,
			image: 'rgba(0,0,0,0)'
		},
		iconRect: {
			w: 25.0,
			h: 25.0,
		},
		icon: {
			normal: 'fs://res/NVTabBar/icon1.png',
			highlight: 'fs://res/NVTabBar/icon2.png',
			selected: 'fs://res/NVTabBar/icon3.png'
		},
		title: {
			text: '消息',
			size: 12.0,
			normal: '#696969',
			selected: '#ff0',
			marginB: 6.0
		}
	}, {
		w: api.winWidth / 3.0,
		bg: {
			marginB: 0,
			image: 'rgba(0,0,0,0)'
		},
		iconRect: {
			w: 25.0,
			h: 25.0,
		},
		icon: {
			normal: 'fs://res/NVTabBar/icon2.png',
			highlight: 'fs://res/NVTabBar/icon21.png',
			selected: 'fs://res/NVTabBar/icon23.png'
		},
		title: {
			text: '联系人',
			size: 12.0,
			normal: '#696969',
			selected: '#ff0',
			marginB: 6.0
		}
	}, {
		w: api.winWidth / 3.0,
		bg: {
			marginB: 0,
			image: 'rgba(0,0,0,0)'
		},
		iconRect: {
			w: 25.0,
			h: 25.0,
		},
		icon: {
			normal: 'fs://res/NVTabBar/icon3.png',
			highlight: 'fs://res/NVTabBar/icon31.png',
			selected: 'fs://res/NVTabBar/icon32.png'
		},
		title: {
			text: '动态',
			size: 12.0,
			normal: '#696969',
			selected: '#ff0',
			marginB: 6.0
		}
	}],
	selectedIndex: 0
}, function(ret, err) {
	if (ret) {
		alert(JSON.stringify(ret));
	}
});
```

## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="hide"></div>

# **hide**

隐藏模块（并没有从内存清除）

hide();

## 示例代码

```js
var NVTabBar = api.require('NVTabBar');
NVTabBar.hide();
```

## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本


<div id="show"></div>

# **show**

显示已隐藏的模块

show();

## 示例代码

```js
var NVTabBar = api.require('NVTabBar');
NVTabBar.show();
```
## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="close"></div>

# **close**

关闭模块，并从内存里清除

close()

## 示例代码
```js
var NVTabBar = api.require('NVTabBar');
NVTabBar.close();
```

## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="setBadge"></div>

# **setBadge**

设置按钮右上角的徽章

setBadge({params})

## params

index:

- 类型：数字
- 说明：（可选项）要设置的子项的下标
- 默认值：0

badge：

- 类型：字符串
- 说明：（可选项）要设置的徽章的内容
- 备注：若不传则表示清除已显示的徽章，若传空字符串则显示小红点（大小为徽章的1.0/2.0）

## 示例代码

```js
var NVTabBar = api.require('NVTabBar');
NVTabBar.setBadge({
	index: 3,
	badge: ''
});
```

## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="setSelect"></div>

# **setSelect**

设置按钮的选中状态

setSelect({params})
 
## params
 
index：

- 类型：数字
- 描述：（可选项）要设置的子项的索引
- 默认值：0

selected：

- 类型：布尔
- 描述：（可选项）要设置的子项按钮的状态
- 默认值：true


icons：

- 类型：数组
- 描述：（可选项）设置子按钮的多图联播效果（gif图效果），若不传本参数则默认显示open接口内配置的图片
- 示例代码：

```
['fs://res/gif1.png','fs://res/gif2.png','fs://res/gif3.png','fs://res/gif4.png','fs://res/gif5.png','fs://res/gif6.png']
```

interval:

- 类型：数字
- 描述：（可选项）动画帧之间的时间间隔（单位:毫秒 ms）
- 默认：300

## 示例代码

```js
var NVTabBar = api.require('NVTabBar');
NVTabBar.setSelect({
	index: 1,
	selected: true,
	icons:['fs://res/gif1.png','fs://res/gif2.png','fs://res/gif3.png','fs://res/gif4.png','fs://res/gif5.png','fs://res/gif6.png']
});
```

## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="bringToFront"></div>

# **bringToFront**

将已经打开的模块置为最上层显示

bringToFront()

##示例代码

```js
var NVTabBar = api.require('NVTabBar');
NVTabBar.bringToFront();
```

##可用性

iOS系统，Android系统

可提供的1.0.0及更高版本