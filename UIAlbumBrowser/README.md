# **概述**

相册多媒体资源访问器（含 iOS 和 Android ）

APICloud 的 UIAlbumBrowser 是一个相册访问模块，是 UIMediaScanner 模块的升级版。在 Android 平台上，它能扫描当前设备上所有的图片、视频媒体资源，可以 push 出一个 window 的形式展示出来。当然，APICloud 平台的开发者也可以用 scan 等其他功能性接口扫描资源，然后根据扫描到的资源完全自定义的展示页面。注意在 iOS 平台上由于系统权限限制，本模块只能扫描系统相册内的媒体资源。由于本模块 UI 布局界面为固定模式，不能满足日益增长的广大开发者对侧滑列表模块样式的需求。因此，广大原生模块开发者，可以参考此模块的开发方式、接口定义等开发规范，或者基于此模块开发出更多符合产品设计的新 UI 布局的模块，希望此模块能起到抛砖引玉的作用。


# **模块接口文档**

<p style="color: #ccc; margin-bottom: 30px;">来自于：官方<a style="background-color: #95ba20; color:#fff; padding:4px 8px;border-radius:5px;margin-left:30px; margin-bottom:0px; font-size:12px;text-decoration:none;" target="_blank" href="//www.apicloud.com/mod_detail/UIAlbumBrowser">立即使用</a></p>

<div class="outline">

[open](#open)

[imagePicker](#imagePicker)

[closePicker](#closePicker)

[requestAlbumPermissions](#requestAlbumPermissions)

[scan](#scan)

[fetch](#fetch)

[scanGroups](#scanGroups)

[scanByGroupId](#scanByGroupId)

[fetchGroup](#fetchGroup)

[transPath](#transPath)

[transVideoPath](#transVideoPath)

[getVideoDuration](#getVideoDuration)

[openGroup](#openGroup)

[closeGroup](#closeGroup)

[changeGroup](#changeGroup)

[openAlbum](#openAlbum)

[closeAlbum](#closeAlbum)

</div>

# 论坛示例

为帮助用户更好更快的使用模块，论坛维护了一个[示例](https://community.apicloud.com/bbs/thread-109416-1-1.html)，示例中包含示例代码、知识点讲解、注意事项等，供您参考。

# **概述**

UIAlbumBrowser 是一个本地媒体资源扫描器，在 Android 平台上可扫描整个设备的资源，iOS 仅扫描相册内的资源。本模块仅支持对本地图片资源的浏览、读取，目前尚不支持编辑。注意本模块在iPhone设备上仅支持 iOS8.0 及以上版本。

由于系统平台差异，iOS 上和 android 上相册分组策略有所不同。

	iOS 上系统相册分组策略如下：
	相机胶卷（All组）:  a,b,c,d,e,f,g
	A组：a
	B组：b,c
	C组：f,g

	android 上系统相册分组策略如下：
	A组：a
	B组：b,c
	C组：d,e,f,g

	因此，若要在 android 平台上显示 All 组，开发者需自行组合。

本模块封装了两种方案。

方案一：

通过 open 接口打开一个自带 UI 界面的媒体资源浏览页面，相当于打开了一个 window 。当用户选择指定媒体资源，可返回绝对路径给前端开发者。前端开发者可通过此绝对路径读取指定媒体资源文件。**注意：在 iOS 平台上需要先调用 transPath 接口将路径转换之后才能读取目标资源媒体文件。**

方案二：

通过 scan 接口扫描指定数量的媒体资源文件，本接口是纯功能类接口，不带界面。开发者可根据此接口扫描到的文件自行开发展示页面，极大的提高了自定义性。注意展示页面要做成赖加载模式，以免占用内存过高导致 app 假死。懒加载模式可通过 fetch 接口实现持续向下加载更多功能。

<!--以上两种方案详细功能，请参考接口说明。-->

**UIAlbumBrowser 模块是 UIMediaScanner 模块的优化升级版。**

<!--![图片说明](/img/docImage/UIAlbumBrowser/1.PNG)-->

**注意：使用本模块前需在云编译页面添加勾选访问相册权限，否则会有崩溃闪退现象**

# 模块接口


<div id="open"></div>

# **open**

打开多媒体资源选择器，打开后会全屏显示

open({params}, callback(ret))

## params

max：

- 类型：数字
- 描述：（可选项）最多选择几张图片
- 默认值：9

type：

- 类型：字符串
- 描述：（可选项）显示图片或显示图片和视频
- 取值范围：
    * all（图片和视频）
    * image（图片）
    * video（视频）
    
isOpenPreview：

- 类型：布尔
- 描述：（可选项）显是否打开预览界面
- 默认：true

classify：

- 类型：布尔
- 描述：（可选项）是否将图片分类显示，为 true 时，会首先跳转到相册分类列表页面，false时打开第一个分组的详情。(仅对iOS有效)
**注意:iOS把所有照片或相机胶卷调整为第一个分组，此调整借鉴微信朋友圈的相册选择**
- 默认：true

selectedAll：

- 类型：布尔
- 描述：（可选项）当type为all时，视频和图片不能同时选中，参考微信，仅当type为all时本参数有意义
- 默认：true  

styles：

- 类型：JSON 对象
- 描述：（可选项）模块各部分的样式
- 内部字段：

```js
{
    bg: '#FFFFFF',                      //（可选项）字符串类型；资源选择器背景，支持 rgb，rgba，#；默认：'#FFFFFF'
    mark: {                             //（可选项）JSON对象；选中图标的样式
        icon: '',                       //（可选项）字符串类型；图标路径（本地路径，支持fs://、widget://）；默认：对勾图标
        position: 'bottom_left',        //（可选项）字符串类型；图标的位置，默认：'bottom_left'
                                        // 取值范围：
                                        // top_left（左上角）
                                        // bottom_left（左下角）
                                        // top_right（右上角）
                                        // bottom_right（右下角）
        size: 20                        //（可选项）数字类型；图标的大小；默认：显示的缩略图的宽度的三分之一
    },
    nav: {                              //（可选项）JSON对象；导航栏样式
        bg: '#eee',                     //（可选项）字符串类型；导航栏背景，支持 rgb，rgba，#；默认：'rgba(0,0,0,0.6)'
        titleColor: '#fff',             //（可选项）字符串类型；标题文字颜色，支持 rgb，rgba，#；默认：'#fff'
        titleSize: 18,                  //（可选项）数字类型；标题文字大小，默认：18
        cancelColor: '#fff',            //（可选项）字符串类型；取消按钮的文字颜色；支持 rgb，rgba，#；默认：'#fff'
        cancelSize: 16,                 //（可选项）数字类型；取消按钮的文字大小；默认：18
        finishColor: '#fff',            //（可选项）字符串类型；完成按钮的文字颜色，支持 rgb，rgba，#；默认：'#fff'
        finishSize: 16                  //（可选项）数字类型；完成按钮的文字大小；默认：18
    }
}
```

rotation：

- 类型：布尔
- 描述：屏幕是否旋转（横屏），为 true 时可以横竖屏旋转，false 时禁止横屏
- 默认值：false




## callback(ret)

ret：

- 类型：JSON 对象
- 内部字段：

```js
{
    eventType: cancel,               //字符串类型；按钮点击事件，取值范围
                                     //confirm 用户点击确定按钮事件
                                     //cancel 用户点击取消按钮事件
    list: [{                         //数组类型；返回选定的资源信息数组
        gifImagePath:'',             //字符串类型；gif图路径，返回gif图在本地的绝对路径，可直接使用 注意:当gifImagePath存在，则不返回path和thumbPath路径
        path: '',                    //字符串类型；资源路径，返回资源在本地的绝对路径，注意：iOS 平台上需要用 transPath 接口转换之后才可读取原图
        thumbPath: '',               //字符串类型；缩略图路径，返回资源缩略图在本地的绝对路径
        suffix: '',                  //字符串类型；文件后缀名，如：png、jpg、 mp4(iOS不支持)
        size: 1048576,               //数字类型；资源大小，单位（Bytes）
        time: '1490580032000',       //字符串类型；资源修改时间，格式：时间戳，单位为毫秒。  
        videoPath:''                 //字符串类型；视频路径
        longitude:116.3718           //数字类型；资源的经度 ；注意确认一下相机的定位权限是否被开启，如果不开启的话经纬度为0，查看方式:设置-->隐私-->定位服务-->相机 (仅支持iOS)
        latitude:39.982'             //数字类型；资源的纬度度  (仅支持iOS)      
    }]
}
```

## 示例代码

```js
var UIAlbumBrowser = api.require('UIAlbumBrowser');
UIAlbumBrowser.open({
	max: 9,
	styles: {
		bg: '#fff',
		mark: {
			icon: '',
			position: 'bottom_left',
			size: 20
		},
		nav: {
			bg: 'rgba(0,0,0,0.6)',
			titleColor: '#fff',
			titleSize: 18,
			cancelColor: '#fff',
			cancelSize: 16,
			finishColor: '#fff',
			finishSize: 16
		}
	},
	rotation: true
}, function(ret) {
	if (ret) {
		alert(JSON.stringify(ret));
	}
});
```
 
## 可用性

iOS系统，android系统

可提供的1.0.0及更高版本

<div id="imagePicker"></div>

# **imagePicker**

打开图片选择器，打开后会全屏显示

imagePicker({params}, callback(ret))

## params

max：

- 类型：数字
- 描述：（可选项）最多选择几张图片
- 默认值：9


showCamera:

- 类型：布尔
- 描述：是否显示相机
- 默认：true

styles：

- 类型：JSON 对象
- 描述：（可选项）模块各部分的样式
- 内部字段：

```js
{
    bg: '#FFFFFF',                      //（可选项）字符串类型；资源选择器背景，支持 rgb，rgba，#；默认：'#FFFFFF'
    cameraImg:'widget://res/cameraImg.png',
                                        //(可选项）字符串类型；相机图片路径（本地路径，支持fs://、widget://）；默认：相机图片
    mark: {                             //（可选项）JSON对象；选中图标的样式
        icon: '',                       //（可选项）字符串类型；图标路径（本地路径，支持fs://、widget://）；默认：对勾图标
        position: 'bottom_left',        //（可选项）字符串类型；图标的位置，默认：'bottom_left'
                                        // 取值范围：
                                        // top_left（左上角）
                                        // bottom_left（左下角）
                                        // top_right（右上角）
                                        // bottom_right（右下角）
        size: 20                        //（可选项）数字类型；图标的大小；默认：显示的缩略图的宽度的三分之一
    },
    nav: {                              //（可选项）JSON对象；导航栏样式
        bg: '#eee',                     //（可选项）字符串类型；导航栏背景，支持 rgb，rgba，#；默认：'rgba(0,0,0,0.6)'
        cancelColor: '#fff',            //（可选项）字符串类型；取消按钮的文字颜色；支持 rgb，rgba，#；默认：'#fff'
        cancelSize: 16,                 //（可选项）数字类型；取消按钮的文字大小；默认：18
        nextStepColor: '#fff',            //（可选项）字符串类型；下一步按钮的文字颜色，支持 rgb，rgba，#；默认：'#fff'
        nextStepSize: 16                  //（可选项）数字类型；下一步按钮的文字大小；默认：18
    },
  thumbnail:{      //（可选项）返回的缩略图配置，**建议本图片不要设置过大** 若已有缩略图，则使用已有的缩略图。若要重新生成缩略图，可先调用清除缓存接口api.clearCache()。  
      w: 100,     //（可选项）数字类型；返回的缩略图的宽；默认：原图的宽度
      h: 100      //（可选项）数字类型；返回的缩略图的宽；默认：原图的高度
}  
    
}
```
animation：

- 类型：布尔
- 描述：（可选项）点击下一步按钮时是否有动画
- 默认：true

## callback(ret)

ret：

- 类型：JSON 对象
- 内部字段：

```js
{
    eventType: cancel,               //字符串类型；按钮点击事件，取值范围
                                     //nextStep 用户点击下一步按钮事件
                                     //cancel 用户点击取消按钮事件
    originalPath: ''                 //字符串类型；拍照结束后把原图的图片路径
    list: [{                         //数组类型；返回选定的资源信息数组
        path: '',                    //字符串类型；资源路径，返回资源在本地的绝对路径，注意：iOS 平台上需要用 transPath 接口转换之后才可读取原图
        thumbPath: '',               //字符串类型；缩略图路径，返回资源缩略图在本地的绝对路径                      
    }]
}
```

## 示例代码

```js
var UIAlbumBrowser = api.require('UIAlbumBrowser');
UIAlbumBrowser.imagePicker({
	max: 9,
	styles: {
    bg: '#FFFFFF',                   
    cameraImg:'widget://res/cameraImg.png',
    mark: {                             
        icon: '',                       
        position: 'bottom_left',      
        size: 20                        
    },
    nav: {                              
        bg: '#eee',                     
        cancelColor: '#fff',            
        cancelSize: 16,  
        nextStepColor: '#fff',
        nextStepSize: 16                 
    }
    },
    animation:true,	
}, function(ret) {
   if (ret.eventType == 'nextStep') {
  var UIAlbumBrowser = api.require('UIAlbumBrowser');
   UIAlbumBrowser.closePicker();
   }
});
```
 
## 可用性

iOS系统，安卓系统

可提供的1.0.0及更高版本

<div id="closePicker"></div>

# **closePicker**

针对imagePicker接口关闭

closePicker()

## 示例代码

```js
var UIAlbumBrowser = api.require('UIAlbumBrowser');
UIAlbumBrowser.closePicker();
```

## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本


<div id="requestAlbumPermissions"></div>

# **requestAlbumPermissions**

请求相册权限

CheckAlbumPermissions( callback(ret))


## callback(ret)

ret：

- 类型：JSON 对象
- 内部字段：

```js
{
  isAccessPermissions: ture    //布尔类型；是否有相册权限
}
```

## 示例代码

```js
var UIAlbumBrowser = api.require('UIAlbumBrowser');
UIAlbumBrowser.requestAlbumPermissions({
}, function(ret, err) {
	if (ret) {
		alert(JSON.stringify(ret));
	} else {
		alert(JSON.stringify(err));
	}
});
```

## 可用性

iOS系统

可提供的1.0.0及更高版本


<div id="scan"></div>

# **scan**

扫描系统多媒体资源，可以通过 Web 代码自定义多选界面。**注意：页面展示的图片建议使用缩略图，一次显示的图片不宜过多（1至2屏）**

scan({params}, callback(ret))

## params

type：

- 类型：字符串
- 描述：返回的资源种类；默认：'all'
- 取值范围：
    * all（图片和视频）
    * image（图片）
    * video（视频）

count：

- 类型：数字
- 描述：（可选项）每次返回的资源数量，剩余资源可用 fetch 接口遍历
- 默认：全部资源数量（不建议使用默认值）

sort：

- 类型：JSON 对象
- 描述：（可选项）图片排序方式
- 内部字段：

```js
{
    key: 'time',    //（可选项）字符串类型；排序方式；默认：'time'
                    //取值范围：
                    //time（按图片创建时间排序）
    order: 'desc'   //（可选项）字符串类型；排列顺序；默认：'desc'
                    //取值范围：
                    //asc（旧->新）
                    //desc（新->旧）
}
```

thumbnail：

- 类型：JSON 对象
- 描述：（可选项）返回的缩略图配置，**建议本图片不要设置过大** 若已有缩略图，则使用已有的缩略图。若要重新生成缩略图，可先调用清除缓存接口api.clearCache()。
- 内部字段：

```js
{
      w: 100,     //（可选项）数字类型；返回的缩略图的宽；默认：100
      h: 100      //（可选项）数字类型；返回的缩略图的宽；默认：100
}
```
## callback(ret)

ret：

- 类型：JSON 对象
- 内部字段：

```js
{
    total: 100,                      //数字类型；媒体资源总数
	list: [{                          //数组类型；返回指定的资源信息数组
	     gifImagePath:'',             //字符串类型；gif图路径，返回gif图在本地的绝对路径，可直接使用 注意:当gifImagePath存在，则不返回path和thumbPath路径
		  path: '',                    //字符串类型；资源路径，返回资源在本地的绝对路径。注意：在 iOS 平台上需要先调用 transPath 接口将路径转换之后才能读取目标资源媒体文件
        thumbPath: '',                //字符串类型；缩略图路径，返回资源缩略图在本地的绝对路径
        suffix: '',                   //字符串类型；文件后缀名，如：png，jpg, mp4(iOS不支持)
        size: 1048576,                //数字类型；资源大小，单位（Bytes）
        time: '1490580032000',        //字符串类型；资源修改时间，格式：时间戳，单位为毫秒。
        mediaType:'',                 //字符串类型;所在相册的类型,   Image ,Video ,Audio。
        duration:50,                  //数字类型；视频时长,单位为毫秒
	}]
}
```

## 示例代码

```js
var UIAlbumBrowser = api.require('UIAlbumBrowser');
UIAlbumBrowser.scan({
	type: 'all',
	count: 10,
	sort: {
		key: 'time',
		order: 'desc'
	},
	thumbnail: {
		w: 100,
		h: 100
	}
}, function(ret) {
	if (ret) {
		alert(JSON.stringify(ret));
	}
});
```

## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="fetch"></div>

# **fetch**

获取指定数量的多媒体资源，没有更多资源则返回空数组，**必须配合 scan 接口的 count 参数一起使用**。

fetch(callback(ret))

## callback(ret)

ret：

- 类型：JSON 对象
- 内部字段：

```js
{
	list: [{                          //数组类型；返回指定的资源信息数组
	      gifImagePath:'',            //字符串类型；gif图路径，返回gif图在本地的绝对路径，可直接使用 注意:当gifImagePath存在，则不返回path和thumbPath路径
		  path: '',                    //字符串类型；资源路径，返回资源在本地的绝对路径。注意：在 iOS 平台上需要先调用 transPath 接口将路径转换之后才能读取目标资源媒体文件
        thumbPath: '',                //字符串类型；缩略图路径，返回资源缩略图在本地的绝对路径
        suffix: '',                   //字符串类型；文件后缀名，如：png，jpg, mp4(iOS不支持)
        size: 1048576,                //数字类型；资源大小，单位（Bytes）
        time: '1490580032000',        //字符串类型；资源修改时间，格式：时间戳，单位为毫秒。
        mediaType:'',                 //字符串类型;所在相册的类型,   Image ,Video ,Audio.
        duration:50                   //数字类型；视频时长,单位为毫秒
	}]
}
```

## 示例代码

```js
var UIAlbumBrowser = api.require('UIAlbumBrowser');
UIAlbumBrowser.fetch(function(ret, err) {
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

<div id="scanGroups"></div>

# **scanGroups**

扫描系统多媒体资源的分组，可以通过 Web 代码自定义多选界面。

scanGroups({params}, callback(ret))

## params

type：

- 类型：字符串
- 描述：返回的资源种类；默认：'all'(iOS不支持)
- 取值范围：
    * all（图片和视频）
    * image（图片）
    * video（视频）

thumbnail：

- 类型：JSON 对象
- 描述：（可选项）返回的缩略图配置，**建议本图片不要设置过大** 若已有缩略图，则使用已有的缩略图。若要重新生成缩略图，可先调用清除缓存接口api.clearCache()。
- 内部字段：

```js
{
      w: 100,     //（可选项）数字类型；返回的缩略图的宽；默认：100
      h: 100      //（可选项）数字类型；返回的缩略图的宽；默认：100
}
```

## callback(ret)

ret：

- 类型：JSON 对象
- 内部字段：

```js
{
    total: 10,                      //数字类型；媒体资源分组总数
	list: [{                        //数组类型；返回指定的资源信息数组
        thumbPath: '',              //字符串类型；缩略图路径，返回资源缩略图在本地的绝对路径  (安卓上返回的是第一张,iOS返回的是最后一张)
        groupName: '',              //字符串类型；分组名称
		groupId: '',                 //字符串类型；分组名称
		groupType:'',				      //字符串类型；分组类型：image图片，video视频
		imgCount:23					   //数字类型；分组中图片数量
	}]
}
```

## 示例代码

```js
var UIAlbumBrowser = api.require('UIAlbumBrowser');
UIAlbumBrowser.scanGroups({
	type: 'all',
	thumbnail: {
		w: 100,
		h: 100
	}
}, function(ret) {
	if (ret) {
		alert(JSON.stringify(ret));
	}
});
```
## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="scanByGroupId"></div>

# **scanByGroupId**

根据分组id，扫描系统多媒体资源，可以通过 Web 代码自定义多选界面。**注意：页面展示的图片建议使用缩略图，一次显示的图片不宜过多（1至2屏）**

scanByGroupId({params}, callback(ret))

## params

groupId：

- 类型：字符串
- 描述：分组id；

type：

- 类型：字符串
- 描述：分组类型；默认：'all'
- 取值范围：
    * image（图片）
    * video（视频）
    * all(图片,视频)
    
count：

- 类型：数字
- 描述：（可选项）每次返回的资源数量，剩余资源可用 fetchGroup 接口遍历
- 默认：全部资源数量（不建议使用默认值）

sort：

- 类型：JSON 对象
- 描述：（可选项）图片排序方式
- 内部字段：

```js
{
    key: 'time',    //（可选项）字符串类型；排序方式；默认：'time'
                    //取值范围：
                    //time（按图片创建时间排序）
    order: 'desc'   //（可选项）字符串类型；排列顺序；默认：'desc'
                    //取值范围：
                    //asc（旧->新）
                    //desc（新->旧）
}
```

thumbnail：

- 类型：JSON 对象
- 描述：（可选项）返回的缩略图配置，**建议本图片不要设置过大** 若已有缩略图，则使用已有的缩略图。若要重新生成缩略图，可先调用清除缓存接口api.clearCache()。
- 内部字段：

```js
{
      w: 100,     //（可选项）数字类型；返回的缩略图的宽；默认：100
      h: 100      //（可选项）数字类型；返回的缩略图的宽；默认：100
}
```

## callback(ret)

ret：

- 类型：JSON 对象
- 内部字段：

```js
{
    total: 100,                       //数字类型；媒体资源总数
	list: [{                           //数组类型；返回指定的资源信息数组
	     gifImagePath:'',              //字符串类型；gif图路径，返回gif图在本地的绝对路径，可直接使用 注意:当gifImagePath存在，则不返回path和thumbPath路径
		  path: '',                    //字符串类型；资源路径，返回资源在本地的绝对路径。注意：在 iOS 平台上需要先调用 transPath 接口将路径转换之后才能读取目标资源媒体文件
        thumbPath: '',                //字符串类型；缩略图路径，返回资源缩略图在本地的绝对路径
        suffix: '',                   //字符串类型；文件后缀名，如：png，jpg, mp4  (iOS不支持)
        size: 1048576,                //数字类型；资源大小，单位（Bytes）
        time: '1490580032000',        //字符串类型；资源修改时间，格式：时间戳，单位为毫秒。
        mediaType:'',                 //字符串类型;所在相册的类型,   image ,video.
	}]
}
```

## 示例代码

```js
var UIAlbumBrowser = api.require('UIAlbumBrowser');
UIAlbumBrowser.scanByGroupId({
	groupId : 123456,
	type: 'image',
	count: 10,
	sort: {
		key: 'time',
		order: 'desc'
	},
	thumbnail: {
		w: 100,
		h: 100
	}
}, function(ret) {
	if (ret) {
		alert(JSON.stringify(ret));
	}
});
```
## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="fetchGroup"></div>

# **fetchGroup**

从分组中获取指定数量的多媒体资源，没有更多资源则返回空数组，**必须配合 scanByGroupId 接口的 count 参数一起使用**。

fetchGroup(callback(ret))

## callback(ret)

ret：

- 类型：JSON 对象
- 内部字段：

```js
{
	list: [{                         //数组类型；返回指定的资源信息数组
	     gifImagePath:'',            //字符串类型；gif图路径，返回gif图在本地的绝对路径，可直接使用 注意:当gifImagePath存在，则不返回path和thumbPath路径
		  path: '',                   //字符串类型；资源路径，返回资源在本地的绝对路径。注意：在 iOS 平台上需要先调用 transPath 接口将路径转换之后才能读取目标资源媒体文件
        thumbPath: '',               //字符串类型；缩略图路径，返回资源缩略图在本地的绝对路径
        suffix: '',                  //字符串类型；文件后缀名，如：png，jpg, mp4(iOS不支持)
        size: 1048576,               //数字类型；资源大小，单位（Bytes）
        time: '1490580032000',       //字符串类型；资源修改时间，格式：时间戳，单位为毫秒。
        mediaType:'',                //字符串类型;所在相册的类型,   Image ,Video ,Audio.
        duration:50                  //数字类型；视频时长,单位为毫秒
	}]
}
```

## 示例代码

```js
var UIAlbumBrowser = api.require('UIAlbumBrowser');
UIAlbumBrowser.fetchGroup(function(ret, err) {
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

<div id="transPath"></div>

# **transPath**

将相册图片地址转换为可以直接使用的本地路径地址（临时文件夹的绝对路径），**相册图片会被拷贝到临时文件夹，调用 api.clearCache 接口可清除该临时图片文件**

transPath({params}, callback(ret))

## params

path：

- 类型：字符串
- 描述：要转换的图片路径（在相册库的绝对路径）

quality：

- 类型：字符串
- 描述：视频质量（android此参数为图片的quality，不支持视频）
- 默认：medium
- 取值范围：
    - highest
    - medium
    - low

scale：

- 类型：数字
- 描述：图片质量
- 默认：1.0
- 取值范围：0~1.0

## callback(ret)

ret：

- 类型：JSON 对象
- 内部字段：

```js
{
   path: ''          //字符串类型；相册内图片被拷贝到临时文件夹，返回已拷贝图片的绝对路径 
}
```
err：

- 类型：JSON 对象
- 内部字段：

```js
{
  status: false     //转化失败
}
```

## 示例代码

```js
var UIAlbumBrowser = api.require('UIAlbumBrowser');
UIAlbumBrowser.transPath({
	path: ''
}, function(ret, err) {
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

<div id="transVideoPath"></div>

# **transVideoPath**

视频路径转化，**可传给videoPlayer模块直接使用**

transVideoPath({params}, callback(ret))

## params

path：

- 类型：字符串
- 描述：要转换的视频路径（在相册库的绝对路径）

## callback(ret)

ret：

- 类型：JSON 对象
- 内部字段：

```js
{
   status: true,     //布尔类型
   albumVideoPath:'' //字符串类型；相册视频路径
   fileSize: 3819599 //视频文件大小；byte为单位
   duration: 4       //视频时长；单位为秒
}
```
err：

- 类型：JSON 对象
- 内部字段：

```js
{
 code:-1
}
```

## 示例代码

```js
var UIAlbumBrowser = api.require('UIAlbumBrowser');
UIAlbumBrowser.transVideoPath({
	path: ''
}, function(ret, err) {
	if (ret) {
		alert(JSON.stringify(ret));
	} else {
		alert(JSON.stringify(err));
	}
});
```

## 可用性

iOS系统

可提供的1.0.0及更高版本


<div id="getVideoDuration"></div>

# **getVideoDuration**

iOS在scan接口里面可以获取到时长.所以可以不用管.
getVideoDuration({params}, callback(ret))

## params

path：

- 类型：字符串
- 描述：视频资源路径（在相册库的绝对路径,另外支持 fs:// widget://路径）

## callback(ret)

ret：

- 类型：JSON 对象
- 内部字段：

```js
{
   duration: 60    //数字类型；视频时长,单位为毫秒
}
```

## 示例代码

```js
var UIAlbumBrowser = api.require('UIAlbumBrowser');
UIAlbumBrowser.getVideoDuration({
	path: ''
}, function(ret, err) {
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


<div id="openGroup"></div>

# **openGroup**


openGroup({params}, callback(ret))

以 frame 形式打开一个图片预览区域



## params

rect：

- 类型：JSON 对象
- 描述：（可选项）模块的位置及尺寸
- 内部字段：

```js
{
    x: 0,   //（可选项）数字类型；模块左上角的 x 坐标（相对于所属的 Window 或 Frame）；默认：0
    y: 0,   //（可选项）数字类型；模块左上角的 y 坐标（相对于所属的 Window 或 Frame）；默认：0
    w: 320, //（可选项）数字类型；模块的宽度；默认：屏幕宽度
    h: 200  //（可选项）数字类型；模块的高度；默认：w 
}
```


groupId:

**注意:若groupId为空,则会默认打开相机胶卷(所有照片)的相册分类**

- 类型：字符串
- 描述：(可选项)要打开的相册分组 ID



selectedPaths：

- 类型：数组
- 描述：（可选项）图片预览区域默认选中图片的路径组成的数组

fixedOn：

 - 类型：字符串类型
 - 描述：（可选项）模块视图添加到指定 frame 的名字（只指 frame，传 window 无效）
 - 默认：模块依附于当前 window

fixed:

 - 类型：布尔
 - 描述：（可选项）模块是否随所属 window 或 frame 滚动
 - 默认值：true（不随之滚动）

## callback(ret)

ret：

- 类型：JSON 对象
- 内部字段：

```js
{
   groupName:''                      //字符串类型；分组名称当'groupId'为空时,会返回
   eventType: 'camera',              //字符串类型；交互事件类型，取值范围如下：
                                     //camera：点击拍照按钮
                                     //select：选中图片事件
                                     //cancel：取消选中图片事件
                                     //show：打开预览区域成功事件
                                     //change：改变显示分组成功事件
   groupId: '',                      //字符串类型；当前分组 ID                                  
   target:{                          //JSON对象；返回所操作的资源信息
        gifImagePath:'',             //字符串类型（Android 暂不支持gif图片格式）；gif图路径，返回gif图在本地的绝对路径，可直接使用 注意:当gifImagePath存在，则不返回path和thumbPath路径
        path: '',                    //字符串类型；资源路径，返回资源在本地的绝对路径，注意：iOS 平台上需要用 transPath 接口转换之后才可读取原图
        thumbPath: '',               //字符串类型；缩略图路径，返回资源缩略图在本地的绝对路径
    }
}
```

## 示例代码

```js
var UIAlbumBrowser = api.require('UIAlbumBrowser');
UIAlbumBrowser.openGroup({
	groupId:''
}, function(ret) {
	alert(JSON.stringify(ret));
});
```

## 可用性

iOS系统，Android系统

可提供的1.0.3及更高版本


<div id="changeGroup"></div>

# **changeGroup**

通过分组ID改变预览区域显示的分组图片

changeGroup({params})

## params


groupId:

- 类型：字符串
- 描述：要改变的相册分组 ID


selectedPaths：

- 类型：数组
- 描述：（可选项）图片预览区域默认选中图片的路径组成的数组

## 示例代码

```js
var UIAlbumBrowser = api.require('UIAlbumBrowser');
UIAlbumBrowser.changeGroup({
	groupId:''
});
```

## 可用性

iOS系统，Android系统

可提供的1.0.3及更高版本



<div id="closeGroup"></div>

# **closeGroup**

关闭打开的相册分组预览区域

closeGroup()

## 示例代码

```js
var UIAlbumBrowser = api.require('UIAlbumBrowser');
UIAlbumBrowser.close();
```

## 可用性

iOS系统，Android系统

可提供的1.0.3及更高版本


<div id="openAlbum"></div>

# **openAlbum**

以 frame 形式打开一个图片预览区域

openAlbum({params}, callback(ret))


## params

rect：

- 类型：JSON 对象
- 描述：（可选项）模块的位置及尺寸
- 内部字段：

```js
{
    x: 0,   //（可选项）数字类型；模块左上角的 x 坐标（相对于所属的 Window 或 Frame）；默认：0
    y: 0,   //（可选项）数字类型；模块左上角的 y 坐标（相对于所属的 Window 或 Frame）；默认：0
    w: 320, //（可选项）数字类型；模块的宽度；默认：屏幕宽度
    h: 200  //（可选项）数字类型；模块的高度；默认：w 
}
```


groupId:

**注意:若groupId为空,则会默认打开相机胶卷(所有照片)的相册分类**

- 类型：字符串
- 描述：(可选项)要打开的相册分组 ID


max：

- 类型：数字
- 描述：（可选项）最多选择几张图片，超过max则用户点击选中按钮只返回eventType为max的事件回调，不会执行选中操作（点击的图片还是未选中状态）
- 默认值：9

type：

- 类型：字符串
- 描述：（可选项）显示图片或显示图片和视频
- 取值范围：
    * all：展示图片和视频（视频资源缩略图区域左下角有视频小标签）
    * image：只展示图片
    * video：只展示视频（视频资源缩略图区域左下角有视频小标签）

styles：

- 类型：JSON对象
- 描述：
- 内部字段：

```js
{
      column:3,      //（可选项）数字类型；列数；默认：3
      interval: ,    //（可选项）数字类型；每列和每行之间的间距；默认：5
      selector: {    //（可选项）JSON类型；选择器样式配置
         normal: ‘’, //（可选项）字符串类型；选择器常态图标，要求本地路径（fs、widget协议）；默认：默认图标
         active: ‘’, //（可选项）字符串类型；选择器选中图标，要求本地路径（fs、widget协议）；默认：默认图标
         size:   ,   //（可选项）数字类型；选择器大小（正方形边长）；默认：20

      }
}
```

videoPreview：

- 类型：布尔
- 描述：（可选项）选中视频资源时，是否进入预览页面，若为false则直接callback相关信息
- 默认值：true

fixedOn：

 - 类型：字符串类型
 - 描述：（可选项）模块视图添加到指定 frame 的名字（只指 frame，传 window 无效）
 - 默认：模块依附于当前 window

fixed:

 - 类型：布尔
 - 描述：（可选项）模块是否随所属 window 或 frame 滚动
 - 默认值：true（不随之滚动）

## callback(ret)

ret：

- 类型：JSON 对象
- 内部字段：

```js
{
   groupName:''                      //字符串类型；分组名称当'groupId'为空时,会返回
   eventType: 'show',                //字符串类型；交互事件类型，取值范围如下：
                                     //select：选中事件
                                     //cancel：取消选中图片事件
                                     //show：打开预览区域成功事件
                                     //max：超过最大选中图片数事件
   groupId: '',                      //字符串类型；当前分组 ID                                  
   target:{                          //JSON对象；返回所操作的资源信息，仅当 eventType 为 select 时返回值
        type:'image',                //字符串类型；资源类型，image：图片，video：视频
        gifImagePath:'',             //字符串类型（Android 暂不支持gif图片格式）；gif图路径，返回gif图在本地的绝对路径，可直接使用 注意:当gifImagePath存在，则不返回path和thumbPath路径
        path: '',                    //字符串类型；资源路径，返回资源在本地的绝对路径，注意：iOS 平台上需要用 transPath 接口转换之后才可读取原图
        thumbPath: '',               //字符串类型；缩略图路径，返回资源缩略图在本地的绝对路径
    }
}
```

## 示例代码

```js
var UIAlbumBrowser = api.require('UIAlbumBrowser');
UIAlbumBrowser.openAlbum({
	groupId:''
}, function(ret) {
	alert(JSON.stringify(ret));
});
```

## 可用性

iOS系统，Android系统

可提供的1.0.3及更高版本



<div id="closeAlbum"></div>

# **closeAlbum**

关闭 openAlbum 打开的相册预览区域

closeAlbum()

## 示例代码

```js
var UIAlbumBrowser = api.require('UIAlbumBrowser');
UIAlbumBrowser.closeAlbum();
```

## 可用性

iOS系统，Android系统

可提供的1.0.3及更高版本

# 论坛示例

为帮助用户更好更快的使用模块，论坛维护了一个[示例](https://community.apicloud.com/bbs/thread-109416-1-1.html)，示例中包含示例代码、知识点讲解、注意事项等，供您参考。
