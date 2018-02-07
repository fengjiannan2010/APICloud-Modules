/*
Title: signature
Description: signature
*/
<p style="color: #ccc; margin-bottom: 30px;">来自于：官方<a style="background-color: #95ba20; color:#fff; padding:4px 8px;border-radius:5px;margin-left:30px; margin-bottom:0px; font-size:12px;text-decoration:none;" target="_blank" href="//www.apicloud.com/mod_detail/signature">立即使用</a></p>
<ul id="tab" class="clearfix">
	<li class="active"><a href="#method-content">Method</a></li>
</ul>

<div id="method-content">
</div>

## 异步接口

<div class="outline">

[md5](#1)
[sha1](#2)
[aes](#3)
[aesDecode](#4)
[base64](#5)
[base64Decode](#6)
[rsaKeyPair](#7)
[rsa](#8)
[rsaDecode](#9)
[aesECB](#10)
[aesDecodeECB](#11)
[desECB](#12)
[desDecodeECB](#13)
[hmacSha1](#14)
[aesCBC](#15)
[aesDecodeCBC](#16)
[sha256](#sha256)

</div>

## 同步接口
<div class="outline">

[md5Sync](#1sync)
[sha1Sync](#2sync)
[aesSync](#3sync)
[aesDecodeSync](#4sync)
[base64Sync](#5sync)
[base64DecodeSync](#6sync)
[rsaKeyPairSync](#7sync)
[rsaSync](#8sync)
[rsaDecodeSync](#9sync)
[aesECBSync](#10sync)
[aesDecodeECBSync](#11sync)
[desECBSync](#12sync)
[desDecodeECBSync](#13sync)
[hmacSha1Sync](#14sync)
[aesCBCSync](#15sync)
[aesDecodeCBCSync](#16sync)
[sha256Sync](#sha256Sync)

</div>

# **概述**

signature 是一个加密模块，可以把指定字符串按照 MD5、AES、BASE64、sha1方式加密，本模块的每个接口都实现了两套方法，同步和异步。开发者可按需求自行选择接口调用。

** 注意：MD5 SHA1 是不可逆的，只有加密没有解密**

# *异步接口*

<div id="1"></div>

# **md5**

将字符串进行 MD5 签名

md5({params}, callback(ret, err))

## params

data：

- 类型：字符串
- 描述：要签名的字符串

uppercase:

- 类型：布尔
- 描述：（可选项）签名后返回的字符串为大写
- 默认：true

## callback(ret, err)

ret：

- 类型：JSON 对象
- 内部字段：

```js
{
        status: true    //布尔类型；是否签名成功，true|false
        value: ''       //字符串类型；MD5 签名后的字符串
}
```

err：

- 类型：JSON 对象
- 内部字段：

```js
{
	     code:           //数字类型；错误码，取值范围如下：
	                     //-1：未知错误
	                     //1：数据源（data）为空
}
```

## 示例代码

```js
var signature = api.require('signature');
signature.md5({
	data: 'APICloud'
}, function(ret, err) {
	if (ret.status) {
		alert(JSON.stringify(ret));
	} else {
		alert(JSON.stringify(err));
	}
});
```
## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="2"></div>

# **sha1**

将字符串进行 sha1 加密

sha1({params}, callback(ret, err))

## params

data：

- 类型：字符串
- 描述：要加密的字符串

uppercase:

- 类型：布尔
- 描述：（可选项）加密后返回的字符串为大写
- 默认：true

## callback(ret, err)

ret：

- 类型：JSON 对象
- 内部字段：

```js
{
        status: true    //布尔类型；是否加密成功，true|false
        value: ''       //字符串类型；SHA1 加密后的字符串
}
```

err：

- 类型：JSON 对象
- 内部字段：

```js
{
	     code:           //数字类型；错误码，取值范围如下：
	                     //-1：未知错误
	                     //1：数据源（data）为空
}
```

## 示例代码

```js
var signature = api.require('signature');
signature.sha1({
	data: 'APICloud'
}, function(ret, err) {
	if (ret.status) {
		alert(JSON.stringify(ret));
	} else {
		alert(JSON.stringify(err));
	}
});
```
## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="3"></div>

# **aes**

将字符串进行 AES 加密（加密模式和填充模式分别为：CBC/PKCS7Padding；初始iv为：{0xA,1,0xB,5,4,0xF,7,9,0x17,3,1,6,8,0xC,0xD,91}，加密等级位数：aes-256-cbc）

aes({params}, callback(ret, err))

## params

data：

- 类型：字符串
- 描述：要加密的字符串

key:

- 类型：字符串
- 描述：aes 加密算法使用的 key

## callback(ret, err)

ret：

- 类型：JSON 对象
- 内部字段：

```js
{
        status: true    //布尔类型；是否加密成功，true|false
        value: ''       //字符串类型；AES 加密后的字符串
}
```

err：

- 类型：JSON 对象
- 内部字段：

```js
{
	     code:           //数字类型；错误码，取值范围如下：
	                     //-1：未知错误
	                     //1：数据源（data）为空
}
```

## 示例代码

```js
var signature = api.require('signature');
signature.aes({
	data: 'APICloud',
	key: 'boundary'
}, function(ret, err) {
	if (ret.status) {
		alert(JSON.stringify(ret));
	} else {
		alert(JSON.stringify(err));
	}
});
```
## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="4"></div>

# **aesDecode**

将字符串进行 AES 解密（加密模式和填充模式分别为：CBC/PKCS7Padding；初始iv为：{0xA,1,0xB,5,4,0xF,7,9,0x17,3,1,6,8,0xC,0xD,91}，加密等级位数：aes-256-cbc）

aesDecode({params}, callback(ret, err))

## params

data：

- 类型：字符串
- 描述：要解密的字符串

key:

- 类型：字符串
- 描述：aes 解密算法使用的 key

## callback(ret, err)

ret：

- 类型：JSON 对象
- 内部字段：

```js
{
        status: true    //布尔类型；是否解密成功，true|false
        value: ''       //字符串类型；AES 解密后的字符串
}
```

err：

- 类型：JSON 对象
- 内部字段：

```js
{
	     code:           //数字类型；错误码，取值范围如下：
	                     //-1：未知错误
	                     //1：数据源（data）为空
}
```

## 示例代码

```js
var signature = api.require('signature');
signature.aesDecode({
	data: '******',
	key: 'boundary'
}, function(ret, err) {
	if (ret.status) {
		alert(JSON.stringify(ret));
	} else {
		alert(JSON.stringify(err));
	}
});
```
## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="5"></div>

# **base64**

将字符串进行 BASE64 加密

base64({params}, callback(ret, err))

## params

data：

- 类型：字符串
- 描述：要加密的字符串

## callback(ret, err)

ret：

- 类型：JSON 对象
- 内部字段：

```js
{
        status: true    //布尔类型；是否加密成功，true|false
        value: ''       //字符串类型；BASE64 加密后的字符串
}
```

err：

- 类型：JSON 对象
- 内部字段：

```js
{
	     code:           //数字类型；错误码，取值范围如下：
	                     //-1：未知错误
	                     //1：数据源（data）为空
}
```

## 示例代码

```js
var signature = api.require('signature');
signature.base64({
	data: 'APICloud'
}, function(ret, err) {
	if (ret.status) {
		alert(JSON.stringify(ret));
	} else {
		alert(JSON.stringify(err));
	}
});
```
## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="6"></div>

# **base64Decode**

将字符串进行 BASE64 解密

base64Decode({params}, callback(ret, err))

## params

data：

- 类型：字符串
- 描述：要解密的字符串


## callback(ret, err)

ret：

- 类型：JSON 对象
- 内部字段：

```js
{
        status: true    //布尔类型；是否解密成功，true|false
        value: ''       //字符串类型；BASE64 解密后的字符串
}
```

err：

- 类型：JSON 对象
- 内部字段：

```js
{
	     code:           //数字类型；错误码，取值范围如下：
	                     //-1：未知错误
	                     //1：数据源（data）为空
}
```

## 示例代码

```js
var signature = api.require('signature');
signature.base64Decode({
	data: '******'
}, function(ret, err) {
	if (ret.status) {
		alert(JSON.stringify(ret));
	} else {
		alert(JSON.stringify(err));
	}
});
```
## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="7"></div>

# **rsaKeyPair**

获取rsa密钥对, **此接口仅支持 Android 平台**

rsaKeyPair({params})

## params

keyLength：

- 类型：数字
- 描述：秘钥长度（512~2048）
- 默认：1024


## callback(ret, err)

ret：

- 类型：JSON 对象
- 内部字段：

```js
{
    privateKey ： {
		encoded ： '' //私钥编码
		modulus ： '' //系数
		exponent ： '' //指数
	}，
	publicKey ： {
		encoded ： '' //公钥编码
		modulus ： '' //系数
		exponent ： '' //指数
	}
}
```

## 示例代码

```js
var signature = api.require('signature');
signature.rsaKeyPair(
	function(ret) {
		alert(JSON.stringify(ret));
	}
);
```
## 可用性

Android系统

可提供的1.0.0及更高版本

<div id="8"></div>

# **rsa**

rsa加密

rsa({params})

## params

data：

- 类型：字符串
- 描述：要加密的字符串

publicKey：

- 类型：字符串
- 描述：加密所需公钥，**注意：在android平台上直接传 encoded（字符串），在 iOS 平台上需传公钥文件（.der 格式）的地址路径（仅支持本地路径fs://、widget://）**
- 提示：iOS 平台不需要使用 rsaKeyPair 接口生成密钥对，而是需要在 mac 终端下，使用 openssl 命令行来生成密钥对，然后将生成的公钥 .der 文件（路径）传给模块即可。如：

	```js
	//生成长度为 1024 的私钥：private_key.pem （文件名可自定义）
	openssl genrsa -out private_key.pem 1024

	//使用私钥文件创建所需的证书：rsaCertReq.csr（文件名可自定义）
	openssl req -new -key private_key.pem -out rsaCertReq.csr

	//使用 x509 创建证书：rsaCert.crt（文件名可自定义）
	openssl x509 -req -days 3650 -in rsaCertReq.csr -signkey private_key.pem -out rsaCert.crt

	//生成 .der 格式的公钥：public_key.der（文件名可自定义）
	openssl x509 -outform der -in rsaCert.crt -out public_key.der

	//生成解密所需 .p12文件：private_key.p12（文件名可自定义）
	openssl pkcs12 -export -out private_key.p12 -inkey private_key.pem -in rsaCert.crt

	```
	具体可网上搜索“openssl 生成密匙对” 的使用方法，注意记得生成过程中输入的密码，解密需要用到。

## callback(ret, err)

ret：

- 类型：JSON 对象
- 内部字段：

```js
{
    status: true    //布尔类型；是否加密成功，true|false
    value: ''       //字符串类型；rsa 加密后的字符串
}
```

err：

- 类型：JSON 对象
- 内部字段：

```js
{
     code:          //数字类型；错误码，取值范围如下：
                    //-1：未知错误
                    //1：数据源（data）为空
}
```

## 示例代码

```js
var signature = api.require('signature');
signature.rsa({
	data: 'APICloud',
	publicKey: ''
}, function(ret) {
	alert(JSON.stringify(ret));
});
```
## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="9"></div>

# **rsaDecode**

rsa解密 

rsaDecode({params})

## params

data：

- 类型：字符串
- 描述：要解密的字符串

privateKey：

- 类型：字符串
- 描述：解密所需私钥，**注意：在android平台上直接传私钥 encoded（字符串），在 iOS 平台上需传私钥文件（.p12 格式）的地址路径（仅支持本地路径fs://、widget://）**
- 提示：iOS 平台不需要使用 rsaKeyPair 接口生成密钥对，而是需要在 mac 终端下，使用 openssl 命令行来生成密钥对，然后将生成的私钥 .p12 文件（路径）传给模块即可，生成方法参考 rsa 接口 publicKey 参数详述。

password:

- 类型：字符串
- 描述：使用 openssl 命令生成密钥对时所输入的私钥文件提取密码 **仅 iOS 平台需要**

## callback(ret, err)

ret：

- 类型：JSON 对象
- 内部字段：

```js
{
    status: true    //布尔类型；是否加密成功，true|false
    value: ''       //字符串类型；rsa 解密后的字符串
}
```

err：

- 类型：JSON 对象
- 内部字段：

```js
{
     code:          //数字类型；错误码，取值范围如下：
                    //-1：未知错误
                    //1：数据源（data）为空
}
```

## 示例代码

```js
var signature = api.require('signature');
signature.rsaDecode({
	data: 'APICloud',
	privateKey: '',
	password: ''
}，function(ret, err) {
	alert(JSON.stringify(ret));
});
```
## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本


<div id="10"></div>

# **aesECB**

将字符串进行 AES 加密（加密模式和填充模式分别为：ECB/PKCS7Padding；数据块：256位；输出：base64；字符集：utf8）

注意：本接口会对加密后的内容再进行一次 base64 编码。

aesECB({params}, callback(ret, err))

## params

data：

- 类型：字符串
- 描述：要加密的字符串

key:

- 类型：字符串
- 描述：aes 加密算法使用的 key

## callback(ret, err)

ret：

- 类型：JSON 对象
- 内部字段：

```js
{
        status: true    //布尔类型；是否加密成功，true|false
        value: ''       //字符串类型；AES 加密后的字符串
}
```

err：

- 类型：JSON 对象
- 内部字段：

```js
{
	     code:           //数字类型；错误码，取值范围如下：
	                     //-1：未知错误
	                     //1：数据源（data）为空
}
```

## 示例代码

```js
var signature = api.require('signature');
signature.aesECB({
	data: 'APICloud',
	key: 'boundary'
}, function(ret, err) {
	if (ret.status) {
		alert(JSON.stringify(ret));
	} else {
		alert(JSON.stringify(err));
	}
});
```
## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="11"></div>

# **aesDecodeECB**

将字符串进行 AES 解密（加密模式和填充模式分别为：ECB/PKCS7Padding；数据块：256位；输出：base64；字符集：utf8）

注意：本接口会先对要解密的内容进行一次 base64 解码。

aesDecodeECB({params}, callback(ret, err))

## params

data：

- 类型：字符串
- 描述：要解密的字符串

key:

- 类型：字符串
- 描述：aes 解密算法使用的 key

## callback(ret, err)

ret：

- 类型：JSON 对象
- 内部字段：

```js
{
        status: true    //布尔类型；是否解密成功，true|false
        value: ''       //字符串类型；AES 解密后的字符串
}
```

err：

- 类型：JSON 对象
- 内部字段：

```js
{
	     code:           //数字类型；错误码，取值范围如下：
	                     //-1：未知错误
	                     //1：数据源（data）为空
}
```

## 示例代码

```js
var signature = api.require('signature');
signature.aesDecodeECB({
	data: '******',
	key: 'boundary'
}, function(ret, err) {
	if (ret.status) {
		alert(JSON.stringify(ret));
	} else {
		alert(JSON.stringify(err));
	}
});
```
## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本



<div id="12"></div>

# **desECB**

将字符串进行 DES 加密（加密模式和填充模式分别为：ECB/PKCS5Padding）

**注意：本加密过程是：base64签名-》DES 加密-》转换为16进制字符串**

desECB({params}, callback(ret, err))

## params

data：

- 类型：字符串
- 描述：要加密的字符串

key:

- 类型：字符串
- 描述：des 加密算法使用的 key

## callback(ret, err)

ret：

- 类型：JSON 对象
- 内部字段：

```js
{
        status: true    //布尔类型；是否加密成功，true|false
        value: ''       //字符串类型；DES 加密后的字符串
}
```

err：

- 类型：JSON 对象
- 内部字段：

```js
{
	     code:           //数字类型；错误码，取值范围如下：
	                     //-1：未知错误
	                     //1：数据源（data）为空
}
```

## 示例代码

```js
var signature = api.require('signature');
signature.desECB({
	data: 'APICloud',
	key: 'boundary'
}, function(ret, err) {
	if (ret.status) {
		alert(JSON.stringify(ret));
	} else {
		alert(JSON.stringify(err));
	}
});
```
## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="13"></div>

# **desDecodeECB**

将字符串进行 DES 解密（加密模式和填充模式分别为：ECB/PKCS5Padding）

desDecodeECB({params}, callback(ret, err))

## params

data：

- 类型：字符串
- 描述：要解密的字符串

key:

- 类型：字符串
- 描述：des 解密算法使用的 key

## callback(ret, err)

ret：

- 类型：JSON 对象
- 内部字段：

```js
{
        status: true    //布尔类型；是否解密成功，true|false
        value: ''       //字符串类型；DES 解密后的字符串
}
```

err：

- 类型：JSON 对象
- 内部字段：

```js
{
	     code:           //数字类型；错误码，取值范围如下：
	                     //-1：未知错误
	                     //1：数据源（data）为空
}
```

## 示例代码

```js
var signature = api.require('signature');
signature.desDecodeECB({
	data: '******',
	key: 'boundary'
}, function(ret, err) {
	if (ret.status) {
		alert(JSON.stringify(ret));
	} else {
		alert(JSON.stringify(err));
	}
});
```
## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本


<div id="14"></div>

# **hmacSha1**

将字符串进行 hmacSha1 加密

hmacSha1({params}, callback(ret, err))

## params

data：

- 类型：字符串
- 描述：要加密的字符串

key:

- 类型：字符串
- 描述：秘钥

## callback(ret, err)

ret：

- 类型：JSON 对象
- 内部字段：

```js
{
        status: true    //布尔类型；是否加密成功，true|false
        value: ''       //字符串类型；hmacSha1 加密后的字符串
}
```

err：

- 类型：JSON 对象
- 内部字段：

```js
{
	     code:           //数字类型；错误码，取值范围如下：
	                     //-1：未知错误
	                     //1：数据源（data）为空
}
```

## 示例代码

```js
var signature = api.require('signature');
signature.hmacSha1({
	data: 'APICloud',
	key: 'key'
}, function(ret, err) {
	if (ret.status) {
		alert(JSON.stringify(ret));
	} else {
		alert(JSON.stringify(err));
	}
});
```
## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="15"></div>

# **aesCBC**

将字符串进行 AES 加密（加密模式和填充模式分别为：CBC/PKCS7Padding；加密等级位数：aes-128-cbc）

注意：本接口加密后会把字符串十六进制转换输出

aesCBC({params}, callback(ret, err))

## params

data：

- 类型：字符串
- 描述：要加密的字符串

key:

- 类型：字符串
- 描述：aes 加密算法使用的 key


iv:

- 类型：字符串
- 描述：aes 加密算法使用的偏移量

## callback(ret, err)

ret：

- 类型：JSON 对象
- 内部字段：

```js
{
        status: true    //布尔类型；是否加密成功，true|false
        value: ''       //字符串类型；AES 加密后的字符串
}
```

err：

- 类型：JSON 对象
- 内部字段：

```js
{
	     code:           //数字类型；错误码，取值范围如下：
	                     //-1：未知错误
	                     //1：数据源（data）为空
}
```

## 示例代码

```js
var signature = api.require('signature');
signature.aesCBC({
	data: 'APICloud',
	key: 'boundary',
	iv:'0102030405060708'
}, function(ret, err) {
	if (ret.status) {
		alert(JSON.stringify(ret));
	} else {
		alert(JSON.stringify(err));
	}
});
```
## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="16"></div>

# **aesDecodeCBC**

将字符串进行 AES 解密（加密模式和填充模式分别为：CBC/PKCS7Padding；加密等级位数：aes-128-cbc）

注意：本接口会首先将字符串十六进制解析成二进制数据流

aesDecode({params}, callback(ret, err))

## params

data：

- 类型：字符串
- 描述：要解密的字符串，注意必须是十六进制字符串

key:

- 类型：字符串
- 描述：aes 解密算法使用的 key


iv:

- 类型：字符串
- 描述：aes 加密算法使用的偏移量

## callback(ret, err)

ret：

- 类型：JSON 对象
- 内部字段：

```js
{
        status: true    //布尔类型；是否解密成功，true|false
        value: ''       //字符串类型；AES 解密后的字符串
}
```

err：

- 类型：JSON 对象
- 内部字段：

```js
{
	     code:           //数字类型；错误码，取值范围如下：
	                     //-1：未知错误
	                     //1：数据源（data）为空
}
```

## 示例代码

```js
var signature = api.require('signature');
signature.aesDecodeCBC({
	data: '******',
	key: 'boundary',
	iv:'0102030405060708'
}, function(ret, err) {
	if (ret.status) {
		alert(JSON.stringify(ret));
	} else {
		alert(JSON.stringify(err));
	}
});
```
## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本


<div id="sha256"></div>

# **sha256**

将字符串进行 sha256 签名

md5({params}, callback(ret, err))

## params

data：

- 类型：字符串
- 描述：要加密的字符串


## callback(ret, err)

ret：

- 类型：JSON 对象
- 内部字段：

```js
{
        status: true    //布尔类型；是否成功，true|false
        value: ''       //字符串类型；sha256签名后的字符串
}
```

err：

- 类型：JSON 对象
- 内部字段：

```js
{
	     code:           //数字类型；错误码，取值范围如下：
	                     //-1：未知错误
	                     //1：数据源（data）为空
}
```

## 示例代码

```js
var signature = api.require('signature');
signature.sha256({
	data: 'APICloud'
}, function(ret, err) {
	if (ret.status) {
		alert(JSON.stringify(ret));
	} else {
		alert(JSON.stringify(err));
	}
});
```
## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

# *同步接口*

<div id="1sync"></div>

# **md5Sync**

将字符串进行 MD5 签名（本过程为同步）

md5Sync({params})

## params

data：

- 类型：字符串
- 描述：要签名的字符串

uppercase:

- 类型：布尔
- 描述：（可选项）签名后返回的字符串为大写
- 默认：true


## return

value：

- 类型：字符串
- 描述：签名后的字符串

## 示例代码

```js
var signature = api.require('signature');
var value = signature.md5Sync({
	data: 'APICloud'
});

alert(value);
```
## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="2sync"></div>

# **sha1Sync**

将字符串进行 SHA1 加密（本加密过程为同步）

sha1Sync({params})

## params

data：

- 类型：字符串
- 描述：要加密的字符串

uppercase:

- 类型：布尔
- 描述：（可选项）加密后返回的字符串为大写
- 默认：true


## return

value：

- 类型：字符串
- 描述：加密后的字符串

## 示例代码

```js
var signature = api.require('signature');
var value = signature.sha1Sync({
	data: 'APICloud'
});

alert(value);
```
## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="3sync"></div>

# **aesSync**

将字符串进行 AES 加密（本加密过程为同步），加密模式和填充模式分别为：CBC/PKCS7Padding；初始iv为：{0xA,1,0xB,5,4,0xF,7,9,0x17,3,1,6,8,0xC,0xD,91}；加密等级位数：aes-256-cbc

aesSync({params})

## params

data：

- 类型：字符串
- 描述：要加密的字符串

key:

- 类型：字符串
- 描述：aes 加密算法使用的 key

## return

value：

- 类型：字符串
- 描述：加密后的字符串

## 示例代码

```js
var signature = api.require('signature');
var value = signature.aesSync({
	data: 'APICloud',
	key: 'boundary'
});

alert(value);
```
## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="4sync"></div>

# **aesDecodeSync**

将字符串进行 AES 解密（本解密过程为同步），加密模式和填充模式分别为：CBC/PKCS7Padding；初始iv为：{0xA,1,0xB,5,4,0xF,7,9,0x17,3,1,6,8,0xC,0xD,91}；加密等级位数：aes-256-cbc

aesDecodeSync({params})

## params

data：

- 类型：字符串
- 描述：要解密的字符串

key:

- 类型：字符串
- 描述：aes 解密算法使用的 key

## return

value：

- 类型：字符串
- 描述：解密后的字符串

## 示例代码

```js
var signature = api.require('signature');
var value = signature.aesDecodeSync({
	data: '******',
	key: 'boundary'
});

alert(value);
```
## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="5sync"></div>

# **base64Sync**

将字符串进行 BASE64 加密（本加密过程为同步）

base64Sync({params})

## params

data：

- 类型：字符串
- 描述：要加密的字符串

uppercase:

- 类型：布尔
- 描述：（可选项）加密后返回的字符串为大写
- 默认：true

## return

value：

- 类型：字符串
- 描述：加密后的字符串

## 示例代码

```js
var signature = api.require('signature');
var value = signature.base64Sync({
	data: 'APICloud'
});

alert(value);
```
## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="6sync"></div>

# **base64DecodeSync**

将字符串进行 BASE64 解密（本解密过程为同步）

base64DecodeSync({params})

## params

data：

- 类型：字符串
- 描述：要解密的字符串

uppercase:

- 类型：布尔
- 描述：（可选项）解密后返回的字符串为大写
- 默认：true

## return

value：

- 类型：字符串
- 描述：解密后的字符串

## 示例代码

```js
var signature = api.require('signature');
var value = signature.base64DecodeSync({
	data: '******'
});

alert(value);
```
## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本


<div id="7sync"></div>

# **rsaKeyPairSync**

获取rsa密钥对（同步），**此接口仅支持 Android 平台**

rsaKeyPairSync({params})

## params

keyLength：

- 类型：数字
- 描述：秘钥长度（512~2048）
- 默认：1024


## return

ret：

- 类型：JSON 对象
- 内部字段：

```js
{
   privateKey: {       //JSON对象；私钥信息
		encoded: ''     //字符串类型；私钥编码
		modulus: ''     //字符串类型；系数
		exponent: ''    //字符串类型；指数
   }
	 publicKey: {      //JSON对象；公钥信息
		encoded: ''     //字符串类型；公钥编码
		modulus: ''     //字符串类型；系数
		exponent: ''    //字符串类型；指数
   }	
}
```

## 示例代码

```js
var signature = api.require('signature');
var ret = signature.rsaKeyPairSync();
alert(JSON.stringify(ret));
```
## 可用性

Android系统

可提供的 1.0.0 及更高版本

<div id="8sync"></div>

# **rsaSync**

rsa加密 （本加密为同步）

rsaSync({params})

## params

data：

- 类型：字符串
- 描述：要加密的字符串

publicKey：

- 类型：字符串
- 描述：加密所需公钥，**注意：在android平台上直接传 encoded（字符串），在 iOS 平台上需传公钥文件（.der 格式）的地址路径（仅支持本地路径fs://、widget://）**
- 提示：iOS 平台不需要使用 rsaKeyPair 接口生成密钥对，而是需要在 mac 终端下，使用 openssl 命令行来生成密钥对，然后将生成的公钥 .der 文件（路径）传给模块即可。如这里使用语句：

	```js
	//生成长度为 1024 的私钥：private_key.pem （文件名可自定义）
	openssl genrsa -out private_key.pem 1024

	//使用私钥文件创建所需的证书：rsaCertReq.csr（文件名可自定义）
	openssl req -new -key private_key.pem -out rsaCertReq.csr

	//使用 x509 创建证书：rsaCert.crt（文件名可自定义）
	openssl x509 -req -days 3650 -in rsaCertReq.csr -signkey private_key.pem -out rsaCert.crt

	//生成 .der 格式的公钥：public_key.der（文件名可自定义）
	openssl x509 -outform der -in rsaCert.crt -out public_key.der

	//生成解密所需 .p12文件：private_key.p12（文件名可自定义）
	openssl pkcs12 -export -out private_key.p12 -inkey private_key.pem -in rsaCert.crt

	```
	具体可网上搜索“openssl 生成密匙对” 的使用方法，注意记得生成过程中输入的密码，解密需要用到。

## return

value：

- 类型：字符串
- 描述：加密后的字符串

## 示例代码

```js
var signature = api.require('signature');
var value = signature.rsaSync({
	data: 'APICloud',
	publicKey: ''
});
alert(JSON.stringify(value));
```
## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="9sync"></div>

# **rsaDecodeSync**

rsa解密 (同步)

rsaDecodeSync({params})

## params

data：

- 类型：字符串
- 描述：要解密的字符串

privateKey：

- 类型：字符串
- 描述：解密所需私钥，**注意：在android平台上直接传私钥 encoded（字符串），在 iOS 平台上需传私钥文件（.p12 格式）的地址路径（仅支持本地路径fs://、widget://）**
- 提示：iOS 平台不需要使用 rsaKeyPair 接口生成密钥对，而是需要在 mac 终端下，使用 openssl 命令行来生成密钥对，然后将生成的私钥 .p12 文件（路径）传给模块即可，生成方法参考 rsaSync 接口 publicKey 参数详述。

password:

- 类型：字符串
- 描述：使用 openssl 命令生成密钥对时所输入的私钥文件提取密码 **仅 iOS 平台需要**

## return

value：

- 类型：字符串
- 描述：加密后的字符串

## 示例代码

```js
var signature = api.require('signature');
var value = signature.rsaDecodeSync({
	data: 'APICloud',
	privateKey: '',
	password: ''
});
alert(JSON.stringify(value));
```

## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本


<div id="10sync"></div>

# **aesECBSync**

将字符串进行 AES 加密（本加密过程为同步），加密模式和填充模式分别为：ECB/PKCS7Padding；数据块：256位；输出：base64；字符集：utf8

注意：本接口会对加密后的内容再次进行 base64 编码。

aesECBSync({params})

## params

data：

- 类型：字符串
- 描述：要加密的字符串

key:

- 类型：字符串
- 描述：aes 加密算法使用的 key

## return

value：

- 类型：字符串
- 描述：加密后的字符串

## 示例代码

```js
var signature = api.require('signature');
var value = signature.aesECBSync({
	data: 'APICloud',
	key: 'boundary'
});

alert(value);
```
## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="11sync"></div>

# **aesDecodeECBSync**

将字符串进行 AES 解密（本解密过程为同步），加密模式和填充模式分别为：WCB/PKCS7Padding；数据块：256位；输出：base64；字符集：utf8

注意：本接口会先对要解密的内容进行一次 base64 解码。

aesDecodeECBSync({params})

## params

data：

- 类型：字符串
- 描述：要解密的字符串

key:

- 类型：字符串
- 描述：aes 解密算法使用的 key

## return

value：

- 类型：字符串
- 描述：解密后的字符串

## 示例代码

```js
var signature = api.require('signature');
var value = signature.aesDecodeECBSync({
	data: '******',
	key: 'boundary'
});

alert(value);
```
## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本


<div id="12sync"></div>

# **desECBSync**

将字符串进行 DES 加密（本加密过程为同步），加密模式和填充模式分别为：ECB/PKCS5Padding

**注意：本加密过程是：base64签名-》DES 加密-》转换为16进制字符串**

desECBSync({params})

## params

data：

- 类型：字符串
- 描述：要加密的字符串

key:

- 类型：字符串
- 描述：des 加密算法使用的 key

## return

value：

- 类型：字符串
- 描述：加密后的字符串

## 示例代码

```js
var signature = api.require('signature');
var value = signature.desECBSync({
	data: 'APICloud',
	key: 'boundary'
});

alert(value);
```
## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="13sync"></div>

# **desDecodeECBSync**

将字符串进行 DES 解密（本解密过程为同步），加密模式和填充模式分别为：ECB/PKCS5Padding

desDecodeECBSync({params})

## params

data：

- 类型：字符串
- 描述：要解密的字符串

key:

- 类型：字符串
- 描述：des 解密算法使用的 key

## return

value：

- 类型：字符串
- 描述：解密后的字符串

## 示例代码

```js
var signature = api.require('signature');
var value = signature.desDecodeECBSync({
	data: '******',
	key: 'boundary'
});

alert(value);
```
## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本


<div id="14sync"></div>

# **hmacSha1Sync**

将字符串进行 hmacSha1 加密（本加密过程为同步）

hmacSha1Sync({params})

## params

data：

- 类型：字符串
- 描述：要加密的字符串

key:

- 类型：字符串
- 描述：秘钥

## return

value：

- 类型：字符串
- 描述：加密后的字符串

## 示例代码

```js
var signature = api.require('signature');
var value = signature.hmacSha1Sync({
	data: 'APICloud',
	key: 'key'
});

alert(value);
```
## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本


<div id="15sync"></div>

# **aesCBCSync**

将字符串进行 AES 加密（加密模式和填充模式分别为：CBC/PKCS7Padding；加密等级位数：aes-128-cbc）

注意：本接口加密后会把字符串十六进制转换输出

aesCBCSync({params})

## params

data：

- 类型：字符串
- 描述：要加密的字符串

key:

- 类型：字符串
- 描述：aes 加密算法使用的 key


iv:

- 类型：字符串
- 描述：aes 加密算法使用的偏移量


## return

value：

- 类型：字符串
- 描述：加密后的字符串

## 示例代码

```js
var signature = api.require('signature');
var value = signature.aesCBCSync({
	data: 'APICloud',
	key: 'boundary',
	iv:'0102030405060708'
});
```
## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="16sync"></div>

# **aesDecodeCBCSync**

将字符串进行 AES 解密（加密模式和填充模式分别为：CBC/PKCS7Padding；加密等级位数：aes-128-cbc）

注意：本接口会首先将字符串十六进制解析成二进制数据流

aesDecodeSync({params})

## params

data：

- 类型：字符串
- 描述：要解密的字符串，注意必须是十六进制字符串

key:

- 类型：字符串
- 描述：aes 解密算法使用的 key


iv:

- 类型：字符串
- 描述：aes 加密算法使用的偏移量

## return

value：

- 类型：字符串
- 描述：解密后的字符串

## 示例代码

```js
var signature = api.require('signature');
var value = signature.aesDecodeCBCSync({
	data: '******',
	key: 'boundary',
	iv:'0102030405060708'
});
```
## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本

<div id="sha256Sync"></div>

# **sha256Sync**

将字符串进行 sha256 签名（本过程为同步）

sha256Sync({params})

## params

data：

- 类型：字符串
- 描述：要签名的字符串


## return

value：

- 类型：字符串
- 描述：签名后的字符串

## 示例代码

```js
var signature = api.require('signature');
var value = signature.sha256Sync({
	data: 'APICloud'
});

alert(value);
```
## 可用性

iOS系统，Android系统

可提供的1.0.0及更高版本
