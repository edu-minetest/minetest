[中文]|[English](./README.md)

## 什么是 《莽兜世界:教育版》

《[莽兜世界:教育版](https://edu.ihom.app)》是基于[Minetest][minetest]（一款开源体素游戏引擎）打造的开源互动教育世界应用。

欢迎访问网站: https://edu.ihom.app 获得更多信息.

### [Minetest][minetest]的互动游戏世界

[Minetest][minetest]的“[体素](https://zh.m.wikipedia.org/zh-hans/體素)”概念类似于积木（如乐高积木）.在互动世界里你可以用"积木"创建房子、制作工具，而与价格昂贵的乐高积木不同的是，你可以在你的创作里面走动，体验你所创造的“新世界”。

![blocks](imgs/numerica.png) ![sun rise](imgs/sunrise.jpg)

## 下载

* 国外: https://github.com/edu-minetest/minetest/releases/
* 国内镜像: https://gitee.com/mt-edu/minetest/releases

## 源代码地址

* Github : https://github.com/edu-minetest/minetest/
* Gitee 镜像: https://gitee.com/mt-edu/minetest/

本分支(`Release`)只为发布而设立.

所实话我并不想建立独立的minetest版本,为了随时能够合并回主分支,采用独立功能分支的方式进行开发.
`Minetest:Edu`的主功能分支在:`edu/builtin`,以及一系列以`edu/`打头的子功能分支组成.

分支说明:

* `edu/builtin`: 新增学生界面和教师界面
* `edu/settings/binary`: 新增支持二进制配置文件
* `edu/drawHeader`: 修正drawHeader
* `edu/static_spawnpoint`: 修正出生点问题
* `edu/android/client-translation`: 修正android默认中文问题
* `feat/singleplayer-user`: 支持多用户在单机游戏中

## 源代码版权声明

* [Minetest 体素游戏引擎](https://minetest.net/)遵循[LGPL2.1](https://www.gnu.org/licenses/old-licenses/lgpl-2.1.html)版权许可证
* 《莽兜世界:教育版》遵循[LGPL3](https://www.gnu.org/licenses/lgpl-3.0.zh-cn.html)开源许可证

