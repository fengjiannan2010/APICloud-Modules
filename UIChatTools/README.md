# 概述

聊天盒子模块源码（内含iOS和android）

APICloud 的 UIChatTools 模块是一个聊天输入框模块，可通过此模块调用一个简单的聊天盒子功能，支持自定义标签面板，附加功能面板和录音按钮等相关功能。但是由于本模块 UI 布局界面为固定模式，不能满足日益增长的广大开发者对搜索模块样式的需求。因此，广大原生模块开发者，可以参考此模块的开发方式、接口定义等开发规范，或者基于此模块开发出更多符合产品设计的新 UI 布局的模块，希望此模块能起到抛砖引玉的作用。

# 模块接口

<p style="color: #ccc; margin-bottom: 30px;">来自于：官方<a style="background-color: #95ba20; color:#fff; padding:4px 8px;border-radius:5px;margin-left:30px; margin-bottom:0px; font-size:12px;text-decoration:none;" target="_blank" href="//www.apicloud.com/mod_detail/UIChatTools">立即使用</a></p>


<div class="outline">

[open](#m1)
[setAppendButton](#m2)
[faceListener](#m3)
[addFace](#m4)
[imageListener](#m5)
[toolsListener](#m6)
[recorderListener](#m7)
[startTimer](#m8)
[close](#m9)
[show](#m10)
[hide](#m11)
[popupKeyboard](#m12)
[closeKeyboard](#m13)
[popupBoard](#m14)
[closeBoard](#m15)
[value](#m16)
[insertValue](#m17)
[chatBoxListener](#m18)
[setPlaceHolder](#m19)
[clearText](#m20)

</div>

# 论坛示例

为帮助用户更好更快的使用模块，论坛维护了一个[示例](https://community.apicloud.com/bbs/thread-111843-1-1.html)，示例中包含示例代码、知识点讲解、注意事项等，供您参考。

# **概述**

UIChatTools 模块是一个聊天输入框模块，开发者可自定义该输入框的功能。通过 open 接口可在当前 window 底部打开一个输入框，该输入框的生命属于当前 window 所有。当输入框获取焦点后，会自动弹动到软键盘之上。开发者可通过监听输入框距离底部弹动的高度，来改变聊天对话界面的高度，从而实现类似 QQ 聊天页面的功能。**UIChatTools 模块是 UIChatBox 模块的优升级。**


本模块的主要功能有：

1，自定义表情集：open 接口的 emotionPath 参数

2，自定义输入框最大自适应高度：open 接口的 maxRows 参数

3，输入框占位提示文字：open 接口的 placeholder 参数

4，自定义是否显示附件功能按钮：

5，自定义显示录音按钮：

6，手动弹出、关闭软键盘功能

7，输入框插入、获取当前文本

8，动态刷新附加功能面板

功能详情参考接口参数。

模块预览图如下：

![UIChatTools](https://docs.apicloud.com/img/docImage/UIChatTools.jpg)

本模块源码已开源：[https://github.com/apicloudcom/APICloud-Modules/UIChatTools](https://github.com/apicloudcom/APICloud-Modules/UIChatTools)

# 模块接口

<div id="m1"></div>

# **open**

打开聊天输入框

open({parmas}, callback(ret, err))

## params

chatBox：

- 类型：JSON 对象
- 描述：（可选项）聊天输入框配置
- 内部字段：

```j
{
    placeholder: '',       //（可选项）字符串类型；占位提示文本，不传则无占位符
    autoFocus: false,     //（可选项）布尔类型；是否在打开时自动获取焦点，并弹出键盘；默认：false
    maxRows: 6             //（可选项）数字类型；显示的最大行数（高度自适应），超过最大行数则可上下滚动查看；默认：6
}
```

styles：

- 类型：JSON 对象
- 描述：（可选项）聊天输入框样式配置
- 内部字段：

```j
{
    bgColor: '#D1D1D1',   //（可选项）字符串类型；模块背景色配置，支持rgb、rgba、#；默认：#D1D1D1
    margin: 10,           //（可选项）数字类型；输入框左右边距；默认：10
    mask: {               //（可选项）JOSN 对象；聊天框以外区域的遮罩层配置，若不传则无遮罩层
       bgColor:'rgba(0,0,0,0.5)',//（可选项）字符串类型；遮罩层背景色配置，支持rgb、rgba、#；默认：rgba(0,0,0,0.5)
    }             
}
```

useFacePath：

- 类型：布尔类型
- 描述：（可选项）返回文本中表情是否以路径返回。仅Android有效。
- 默认：false

isShowAddImg：

- 类型：布尔类型
- 描述：（可选项）是否显示表情面板中的加号按钮
- 默认：true

tools：

- 类型：JSON 对象
- 描述：聊天输入框下工具栏配置
- 内部字段：

```js
{
    h: 44,          //（可选项）数字类型；工具栏高度；默认：44
    iconSize: 30,   //（可选项）数字类型；工具栏每个按钮的图标大小；默认：30
    recorder: {     //（可选项）JSON 对象；录音按钮配置，若不传则工具栏无录音按钮，本功能需配合recorderListener 接口使用
       normal: '',  //字符串类型；常态下的图标，要求本地路径（fs、widget）
       selected: '' //字符串类型；选中后的图标，要求本地路径（fs、widget），同按下时高亮状态公用同一个图标
    },
    image: {        //（可选项）JSON 对象；选图片按钮配置，若不传则工具栏无选图按钮，本功能需配合imageListener 接口使用
       normal: '',  //字符串类型；常态下的图标，要求本地路径（fs、widget）
       selected: '' //字符串类型；选中后的图标，要求本地路径（fs、widget），同按下时高亮状态公用同一个图标
    },
    video: {        //（可选项）JSON 对象；录像按钮配置，若不传则工具栏无录像按钮，本功能需配合toolsListener 接口使用
       normal: '',  //字符串类型；常态下的图标，要求本地路径（fs、widget）
       selected: '' //字符串类型；选中后的图标，要求本地路径（fs、widget），同按下时高亮状态公用同一个图标
    },
    packet: {       //（可选项）JSON 对象；红包按钮配置，若不传则工具栏无红包按钮，本功能需配合toolsListener 接口使用
       normal: '',  //字符串类型；常态下的图标，要求本地路径（fs、widget）
       selected: '' //字符串类型；选中后的图标，要求本地路径（fs、widget），同按下时高亮状态公用同一个图标
    },
    face: {         //（可选项）JSON 对象；表情按钮配置，若不传则工具栏无表情按钮，本功能需配合 faceListener、addFace 接口以及 emotions 参数使用
       normal: '',  //字符串类型；常态下的图标，要求本地路径（fs、widget）
       selected: '' //字符串类型；选中后的图标，要求本地路径（fs、widget），同按下时高亮状态公用同一个图标
    },
    append: {       //（可选项）JSON 对象；附加按钮配置，若不传则工具栏无附加按钮，本功能需配合 setAppendButton 接口使用
       normal: '',  //字符串类型；常态下的图标，要求本地路径（fs、widget）
       selected: '' //字符串类型；选中后的图标，要求本地路径（fs、widget），同按下时高亮状态公用同一个图标
    }
}
```

emotions：

- 类型：数组
- 描述：表情包源文件夹路径组成的数组
- 注意：

```js
    1，本参数必须在 tools -> face 参数有值时有效
    2，表情包源文件就是表情图片所在的文件夹，须同时包含一个与该文件夹同名的 .json 配置文件
    3，表情包源文件路径必须是本地路径，如：fs://、widget://
    4，.json 文件内的 name 值必须与表情文件夹内表情图片名对应，emoji 表情除外。
    5，本数组的第一个路径值必须是普通表情包路径，其余路径为附加表情包路径
    6，表情包源文件内必须包含一个通该文件夹同名的 .png 图标，用来显示在表情面板表情索引导航条
```

- 内部字段示例：

```js
	['widget://res/emotions/basic','widget://res/emotions/append1','widget://res/emotions/append2']
```

- 普通表情包`.json`配置文件格式如下：

```json
	[
	   	 {   
			label:"常用表情",
			emotions:[
	                    {"name": "Expression_1","text": "[微笑]"},
			    {"name": "Expression_2","text": "[撇嘴]"},
			    {"name": "Expression_3","text": "[色]"}
	              	] 
		 },
	     	{
			label:'全部表情',
	         	emotions:[
			    {"name": "Expression_11","text": "[尴尬]"},
			    {"name": "Expression_12","text": "[发怒]"},
			    {"name": "Expression_13","text": "[调皮]"},
			    {"name": "Expression_14","text": "[呲牙]"},
			    {"name": "Expression_15","text": "[惊讶]"},
			    {"name": "Expression_16","text": "[难过]"},
			    {"name": "Expression_17","text": "[酷]"},
			    {"name": "Expression_18","text": "[冷汗]"},
			    {"name": "Expression_19","text": "[抓狂]"},
			    {"name": "Expression_20","text": "[吐]"}
	     		]
		},
	     	{
	         	label:"emoji表情",
			emotions:[
	                	{"name": "😀","text": "😀"},
	                	{"name": "😁","text": "😁"},
	                	{"name": "😂","text": "😂"}
	     		]
		}
]
```


- 附加表情包`.json`配置文件格式如下：

```json
[
        {"name": "Expression_1","text": "[微笑]"},
        {"name": "Expression_2","text": "[撇嘴]"},
        {"name": "Expression_3","text": "[色]"},
        {"name": "Expression_4","text": "[发呆]"},
        {"name": "Expression_5","text": "[得意]"},
        {"name": "Expression_6","text": "[流泪]"},
        {"name": "Expression_7","text": "[害羞]"},
        {"name": "Expression_8","text": "[闭嘴]"},
        {"name": "Expression_9","text": "[睡]"},
        {"name": "Expression_10","text": "[大哭]"}
]
```

- 另附：[表情包文件夹资源示例](/img/docImage/emotions.zip)


## callback(ret)

ret：

- 类型：JSON 对象
- 内部字段：

```js
{
    eventType: 'show',  //字符串类型；回调的事件类型，
                        //取值范围：
                        //show：模块打开成功并显示在屏幕上
                        //send：用户点击表情面板、键盘面板（在android 平台上表示输入框右边发送按钮）发送按钮
    msg: ''             //字符串类型；当 eventType 为 send 时，此参数返回输入框的内容，否则无返回值
}
```
## 示例代码

```js
var UIChatTools = api.require('UIChatTools');
UIChatTools.open({
	chatBox: {
	    placeholder: '聊天内容',     
	    autoFocus: false,  
	    maxRows: 6     
	},
	styles: {
	    bgColor: '#D1D1D1',   
	    margin: 10,           
	    mask: {               
	       bgColor:'rgba(0,0,0,0.5)'
	    }             
	},
	tools: {
	    h: 44,          
	    iconSize: 30,   
	    recorder: {     
	       normal: 'fs://UIChatTolls/recorder.png',  
	       selected: 'fs://UIChatTolls/recorder1.png' 
	    },
	    image: {        
	       normal: 'fs://UIChatTolls/image.png',  
	       selected: 'fs://UIChatTolls/image1.png' 
	    },
	    video: {        
	       normal: 'fs://UIChatTolls/video.png',  
	       selected: 'fs://UIChatTolls/video1.png' 
	    },
	    packet: {       
	       normal: 'fs://UIChatTolls/packet.png',  
	       selected: 'fs://UIChatTolls/packet1.png' 
	    },
	    face: {         
	       normal: 'fs://UIChatTolls/face.png',  
	       selected: 'fs://UIChatTolls/face1.png' 
	    },
	    append: {       
	       normal: 'fs://UIChatTolls/append.png',  
	       selected: 'fs://UIChatTolls/append1.png'
	    }
	},
	emotions:['widget://res/emotions/basic','widget://res/emotions/append1','widget://res/emotions/append2']
}, function(ret) {
	if (ret) {
		api.alert({msg:JSON.stringify(ret)});
	} 
});
```

## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="m2"></div>

# **setAppendButton**

设置附加功能按钮，**仅当 open 接口内 tools->append 参数有值时，本接口有效**

setAppendButton({params}, callback(ret))

## params

styles：

- 类型：JSON 对象
- 描述：（可选项）附加功能面板按钮样式配置
- 内部字段：

```js
{
    row: 2,            //（可选项）数字类型；每页显示按钮行数；默认：2
    column: 4,         //（可选项）数字类型；每页显示按钮的列数；默认：4
    iconSize: 30,      //（可选项）数字类型；按钮图标大小；默认：30
    titleSize: 13,     //（可选项）数字类型；按钮下标题文字大小；默认：13
    titleColor: ''     //（可选项）字符串类型；按钮下标题文字颜色；默认：#000
}
```

buttons：

- 类型：数组
- 描述：附加功能面板按钮信息集合，可分页显示
- 内部字段：

```js
[{
    normal: '',       //字符串类型；按钮常态下的背景图标路径，要求本地路径（fs、widget）
    highlight: '',    //字符串类型；按钮被点击时高亮状态的背景图标路径，要求本地路径（fs、widget）
    title: ''         //字符串类型；按钮下边的标题文字
}]
```

## callback(ret)

ret：

- 类型：JSON 对象
- 内部字段：

```js
{
     index: 0     //数字类型；用户点击按钮的索引（从零开始）
}
```

## 示例代码

```js
var UIChatTools = api.require('UIChatTools');
UIChatTools.setAppendButton({
	styles: {
	    row: 2,         
	    column: 4,         
	    iconSize: 30,      
	    titleSize: 13,   
	    titleColor: ''     
    },
    buttons: [
       {
		    normal: 'fs://UIChatTools/append1.png',       
		    highlight: 'fs://UIChatTools/append11.png',    
		    title: '电话'       
       },{
		    normal: 'fs://UIChatTools/append2.png',       
		    highlight: 'fs://UIChatTools/append21.png',    
		    title: '收藏' 
       },{
		    normal: 'fs://UIChatTools/append3.png',       
		    highlight: 'fs://UIChatTools/append31.png',    
		    title: '发红包' 
       },{
		    normal: 'fs://UIChatTools/append2.png',       
		    highlight: 'fs://UIChatTools/append21.png',    
		    title: '收藏' 
       },{
		    normal: 'fs://UIChatTools/append3.png',       
		    highlight: 'fs://UIChatTools/append31.png',    
		    title: '发红包' 
       },{
		    normal: 'fs://UIChatTools/append2.png',       
		    highlight: 'fs://UIChatTools/append21.png',    
		    title: '收藏' 
       },{
		    normal: 'fs://UIChatTools/append3.png',       
		    highlight: 'fs://UIChatTools/append31.png',    
		    title: '发红包' 
       },{
		    normal: 'fs://UIChatTools/append2.png',       
		    highlight: 'fs://UIChatTools/append21.png',    
		    title: '收藏' 
       },{
		    normal: 'fs://UIChatTools/append3.png',       
		    highlight: 'fs://UIChatTools/append31.png',    
		    title: '发红包' 
       },{
		    normal: 'fs://UIChatTools/append2.png',       
		    highlight: 'fs://UIChatTools/append21.png',    
		    title: '收藏' 
       },{
		    normal: 'fs://UIChatTools/append3.png',       
		    highlight: 'fs://UIChatTools/append31.png',    
		    title: '发红包' 
       },{
		    normal: 'fs://UIChatTools/append2.png',       
		    highlight: 'fs://UIChatTools/append21.png',    
		    title: '收藏' 
       }
    ]
}, function(ret) {
   api.alert({msg:'点击了第'+ret.index+'个按钮'});
});
```

## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="m3"></div>

# **faceListener**

表情面板相关功能事件的监听，**仅当 open 接口内 tools->face 参数有值时，本接口有效**

faceListener({params}, callback(ret, err))

## params

name：

- 类型：字符串
- 描述：事件的目标对象
- 取值范围：
    * face：表情点击事件（开发者可在此事件的回调里发送点击的表情）
    * appendFace：表情面板上附件按钮点击事件（开发者可在此事件里通过addFace接口添加附加表情包）

## callback(ret)

ret：

- 类型：JSON 对象
- 描述：所监听到的事件
- 内部字段：

```js
{
     emoticonName: 'append1',  //字符串类型；表情包文件夹名字，仅当 name 为 face 时本参数有值
     text:'[么么哒]'            //字符串类型；用户所点击的表情的 text 内容，仅当 name 为 face 时本参数有值
}
```

## 示例代码

```js
var UIChatTools = api.require('UIChatTools');
UIChatTools.faceListener({
	name: 'face'
}, function(ret) {
   api.alert({msg:JSON.stringify(ret)});
});

var UIChatTools = api.require('UIChatTools');
UIChatTools.faceListener({
	name: 'appendFace'
}, function(ret) {

   // 
   if(ret.emoticonName == undefined){
	 //打开添加表情页面
   	api.openWin({
		    name: 'face',
		    url: './face.html'
	});
	//选择表情后调用addFace接口添加表情包
	var UIChatTools = api.require('UIChatTools');
	UIChatTools.addFace({
		path: 'fs://newFace'
	});
   } else{
	// 点击表情
   }
  
});
```

## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本


<div id="m4"></div>

# **addFace**

添加表情包，**仅当 open 接口内 tools->face 参数有值时，本接口有效**

addFace({params}, callback(ret, err))

## params

path：

- 类型：字符串
- 描述：表情包文件夹路径，表情包格式规范要求同 open 内附加表情包格式规范一致

## callback(ret)

ret：

- 类型：JSON 对象
- 描述：所监听到的事件
- 内部字段：

```js
{
     status: true  //布尔类型；是否添加成功，true|false
}
```

## 示例代码

```js
var UIChatTools = api.require('UIChatTools');
UIChatTools.addFace({
	path: 'fs://newFace'
}, function(ret) {
   api.alert({msg:JSON.stringify(ret)});
});
```

## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="m5"></div>

# **imageListener**

选择图片相关功能事件的监听，**仅当 open 接口内 tools->image 参数有值时，本接口有效**

imageListener({params}, callback(ret, err))

## callback(ret)

ret：

- 类型：JSON 对象
- 描述：所监听到的事件
- 内部字段：

```js
{
     eventType: album, // 字符串类型，事件返回类型取值范围如下：
		       // album
		       // edit
		       // send
     images:[]     //数组类型；用户选择的图片绝对路径（iOS平台上会把所选择系统相册内图片拷贝到app沙箱缓冲目录下）组成的数组，仅当 eventType 为 edit 或 send 时本参数有值
}
```

## 示例代码

```js
var UIChatTools = api.require('UIChatTools');
UIChatTools.imageListener(function(ret){
	alert(JSON.stringify(ret));
});
```

## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本


<div id="m6"></div>

# **toolsListener**

用户点击工具栏内某个按钮事件的监听

toolsListener(callback(ret))

## callback(ret)

ret：

- 类型：JSON 对象
- 描述：用户点击工具栏按钮的监听事件
- 内部字段：

```js
{
      eventType:'recorder'    //字符串类型；监听到的事件类型，取值范围如下：
                              //recorder：用户点击录音按钮事件
                              //image：用户点击选择图片按钮事件
                              //video：用户点击视频按钮事件
                              //packet：用户点击钱包按钮的事件
                              //face：用户点击表情按钮的事件
                              //append：用户点击附件功能按钮事件
}
```

## 示例代码

```js
//监听 talkback 按钮
var UIChatTools = api.require('UIChatTools');
UIChatTools.toolsListener(function(ret) {
   if (ret.eventType == 'packet') {
      api.openWin({
		    name: 'packet',
		    url: './packet.html',
		    pageParam: {
		        name: '发红包'
		    }
		});
   }
});
```

## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="m7"></div>

# **recorderListener**

录音相关功能事件的监听，**仅当 open 接口内 tools->recorder 参数有值时，本接口有效**

recorderListener(callback(ret, err))


## callback(ret)

ret：

- 类型：JSON 对象
- 描述：所监听到的事件

```js
{
	eventType: press, // 取值范围如下：
			  // press 对讲按钮按下触发，仅在按下talkback按钮时有效
              // auditionTouchOn 触摸到左侧试听按钮时触发（仅在按下talkback时有效）
			  // audition 试听
			  // send 发送  仅在按下record按钮时有效
			  // cancel 取消 
			  // shortTime 按下时间太短，仅在按下talkback时有效
			  // start 开始 仅在按下录音按钮时有效
			  // stop  停止 仅在按下录音按钮时有效
	target: talkback  // 取值范围如下：
			  // talkback 对讲按钮
			  // record 录音按钮
			  
}
```
## 示例代码

```js
//监听 talkback 按钮
var UIChatTools = api.require('UIChatTools');
UIChatTools.recorderListener(function(ret) {
	if(ret.eventType == 'press' && ret.target == 'talkback'){
		alert('按下录音');
	}
	
	if(ret.eventType == 'start' && ret.target == 'record'){
		alert('开始录音');
	}
});
```

## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="m8"></div>

# **startTimer**

开始录音后开启录音计时器，使录音页面计时器开始计时。**本接口仅能在 recorderListener 监听 target 为 talkback/record，name 为 press/start 时的监听回调函数内调用**

startTimer()

## 示例代码

```js
var UIChatTools = api.require('UIChatTools');
UIChatTools.startTimer();
```

## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="m9"></div>

# **close**

关闭聊天输入框

close()

## 示例代码

```js
var UIChatTools = api.require('UIChatTools');
UIChatTools.close();
```

## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="m10"></div>

# **show**

显示聊天输入框

show()

## 示例代码

```js
var UIChatTools = api.require('UIChatTools');
UIChatTools.show();
```

## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="m11"></div>

# **hide**

隐藏聊天输入框

hide()

## 示例代码

```js
var UIChatTools = api.require('UIChatTools');
UIChatTools.hide();
```

## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="m12"></div>

# **popupKeyboard**

弹出键盘

popupKeyboard()

## 示例代码

```js
var UIChatTools = api.require('UIChatTools');
UIChatTools.popupKeyboard();
```

## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="m13"></div>

# **closeKeyboard**

收起键盘

closeKeyboard()

## 示例代码

```js
var UIChatTools = api.require('UIChatTools');
UIChatTools.closeKeyboard();
```

## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="m14"></div>

# **popupBoard**

弹出表情、附加功能面板

popupBoard({params})

## params

target:

- 类型：字符串
- 描述：操作的面板类型，取值范围如下：
	- emotion：表情面板
	- extras：附加功能面板
- 默认值：emotion
	

## 示例代码

```js
var UIChatTools = api.require('UIChatTools');
UIChatTools.popupBoard({
	target: 'extras'
});
```

## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="m15"></div>

# **closeBoard**

收起表情、附加功能面板

closeBoard()

## 示例代码

```js
var UIChatTools = api.require('UIChatTools');
UIChatTools.closeBoard();
```

## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="m16"></div>

# **value**

获取或设置聊天输入框的内容

value({params}, callback(ret, err))

## params

msg：

- 类型：字符串
- 描述：（可选项）聊天输入框的内容，若不传则返回输入框的值

## callback(ret, err)

ret：

- 类型：JSON 对象
- 内部字段：

```js
{
    status: true,        //布尔型；true||false
    msg: ''              //字符串类型；输入框当前内容文本
}
```

## 示例代码

```js
var UIChatTools = api.require('UIChatTools');
//设置输入框的值
UIChatTools.value({
	msg: '设置输入框的值'
});

//获取输入框的值
UIChatTools.value(function(ret, err) {
	if (ret) {
		alert(JSON.stringify(ret));
	} else {
		alert(JSON.stringify(err));
	}
});
```

## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="m17"></div>

# **insertValue**

向聊天输入框的指定位置插入内容

insertValue({params})

## params

index：

- 类型：数字
- 描述：（可选项）待插入内容的起始位置。**注意：中文，全角符号均占一个字符长度；索引从0开始，0表示插入到最前面，1表示插入到第一个字符后面，2表示插入到第二个字符后面，以此类推。**
- 默认值：当前输入框的值的长度

msg：

- 类型：字符串
- 描述：（可选项）要插入的内容
- 默认值：''

## 示例代码

```js
var UIChatTools = api.require('UIChatTools');
UIChatTools.insertValue({
	index: 10,
	msg: '这里是插入的字符串'
});
```

## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="m18"></div>

# **chatBoxListener**

添加输入框相关事件的监听

chatBoxListener({params}, callback(ret))

## params

name：

- 类型：字符串
- 描述：监听的事件类型
- 取值范围：
   - move：输入框弹动事件
   - change：输入框高度改变事件
   - valueChanged：输入框内容改变事件

## callback(ret)

ret：

- 类型：JSON 对象
- 描述：监听事件返回目标值，**注意：模块分为三分部分：1，输入框（chatBox）及其所占区域；2，工具栏（tools）；3，键盘（及表情面包、附件功能面板、录音面板、图片选择面板）所占区域**
- 内部字段：

```js
{
    chatBoxHeight: 60,     //数字类型；输入框所占区域的高度，仅当监听 move 和 change 事件时本参数有值
    panelHeight: 300 ,     //数字类型；工具栏下边缘距离屏幕底部（键盘及表情面板、附件功能面板、录音面板、图片选择面板所占区域）的高度，仅当监听 move 和 change 事件时本参数有值
    value: ''              //字符串类型；输入框当前内容，仅当 name 为 valueChanged 时有值
}
```

## 示例代码

```js
var UIChatTools = api.require('UIChatTools');
UIChatTools.chatBoxListener({
		name:'move'
}, function(ret){
	alert(JSON.stringify(ret));
});			
UIChatTools.chatBoxListener({
	       name:'change'
}, function(ret){
	alert(JSON.stringify(ret));
});
UIChatTools.chatBoxListener({
	       name:'valueChanged'
}, function(ret){
	alert(JSON.stringify(ret));
});
```
## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="m19"></div>

# **setPlaceholder**

重设聊天输入框的占位提示文本

setPlaceholder({params})

## params

placeholder：

- 类型：字符串
- 描述：（可选项）占位提示文本，若不传或传空则表示清空占位提示内容

## 示例代码

```js
var UIChatTools = api.require('UIChatTools');
UIChatTools.setPlaceholder({
	placeholder: '修改了占位提示内容'
});
```

## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="m20"></div>

# **clearText**

清空输入框文本

clearText()

## 示例代码

```js
var UIChatTools = api.require('UIChatTools');
UIChatTools.clearText();
```

## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

