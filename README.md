# PhotoArchiver

[English Version](./documents/en.md)

## 简介

<img src="assets/icon.png" width="100px">

![License](https://img.shields.io/badge/License-MIT-dark_green)

<a href="https://apps.microsoft.com/detail/9p1wgv9bxbtv?referrer=appbadge&mode=direct">
	<img src="https://get.microsoft.com/images/en-us%20dark.svg" width="200"/>
</a>

PhotoArchiver 是一款能够将文件夹内的照片按照**时间整理**和**地点整理**进行高效分类与归纳的实用工具。

> [!IMPORTANT]
> **使用前提说明：**
> - **EXIF 信息：** 本工具完全依赖照片的 EXIF 元数据。如果照片不包含必要的 EXIF 信息（如时间戳），将会被忽略。
> - **GPS 定位：** 如果您需要使用“按照地点整理”功能，拍摄设备必须支持 GPS 定位功能并已记录经纬度信息（如智能手机拍摄的照片通常包含，而大部分传统相机并不具备 GPS 模块）。
> - **地理位置解析说明：** 
>   - 获取图片的位置信息**不需要连接互联网**，该功能由 [geobed](https://github.com/andreiashu/geobed) 提供支持。
>   - 该库没有提供城市多语言对照，简体/繁体中文转换可能会存在问题。
>   - 部分定位映射可能会存在问题（例如：有的图片可以精确到区，有的则只能精确到市）。

动态库组件仓库[在这里](https://github.com/Zhoucheng133/PhotoArchiver-Core)

## 功能特点

- **按照时间整理**：自动提取照片的 EXIF 拍摄时间，按年、月等层级或时间线将照片归档到对应的文件夹中。
- **按照地点整理**：根据照片内嵌的 GPS 地理位置信息，将照片按国家、省市或具体地点进行智能归类管理。

## 截图

<img src="screenshots/cn/1.png">
<img src="screenshots/cn/2.png">
