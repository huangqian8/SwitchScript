# 大气层个人整合包生成脚本

## 功能如下：

- 下载最新：
  - 大气层三件套
    - [x] `Atmosphere + Fusee` [From Here](https://github.com/Atmosphere-NX/Atmosphere/releases/latest)
    - [x] `Hekate + Nyx 简体中文` [From Here](https://github.com/easyworld/hekate/releases/latest)
    - [x] `Sigpatches` [From Here](https://hackintendo.com/download/sigpatches/)
  - Payload插件
    - [x] 主机系统的密钥提取工具 `Lockpick_RCM` [From Here](https://github.com/Decscots/Lockpick_RCM/releases/latest)
    - [x] Hekate下的文件管理工具 `TegraExplorer` [From Here](https://github.com/suchmememanyskill/TegraExplorer/releases/latest)
    - [x] Hekate下删除主题和关闭插件自动启动 `CommonProblemResolver` [From Here](https://github.com/zdm65477730/CommonProblemResolver/releases/latest)
  - Nro插件
    - [x] 联网检测是否屏蔽任天堂服务器 `Switch_90DNS_tester` [From Here](https://github.com/meganukebmp/Switch_90DNS_tester/releases/latest)
    - [x] 游戏安装，存档管理和文件传输工具 `DBI` [From Here](https://github.com/rashevskyv/dbi/releases/latest)
    - [x] 游戏安装和文件传输工具 `Awoo Installer` [From Here](https://github.com/dragonflylee/Awoo-Installer/releases/latest)
    - [x] 深海工具箱 `Hekate-toolbox` [From Here](https://github.com/WerWolv/Hekate-Toolbox/releases/latest)
    - [x] 游戏游玩时间记录工具 `NX-Activity-Log` [From Here](https://github.com/zdm65477730/NX-Activity-Log/releases/latest)
    - [x] 主题安装工具 `NXThemesInstaller` [From Here](https://github.com/exelix11/SwitchThemeInjector/releases/latest)
    - [x] 游戏存档管理工具 `JKSV` [From Here](https://github.com/J-D-K/JKSV/releases/latest)
    - [x] 系统切换工具 `tencent-switcher-gui` [From Here](https://github.com/CaiMiao/Tencent-switcher-GUI/releases/latest)
    - [x] 多工具合一任天堂Switch更新器 `aio-switch-updater` [From Here](https://github.com/HamletDuFromage/aio-switch-updater/releases/latest)
    - [x] 第三方B站客户端 `wiliwili` [From Here](https://github.com/xfangfang/wiliwili/releases/latest)
    - [x] Mod下载器 `SimpleModDownloader` [From Here](https://github.com/PoloNX/SimpleModDownloader/releases/latest)
    - [x] Jellyfin客户端 `Switchfin` [From Here](https://github.com/dragonflylee/switchfin/releases/latest)
    - [x] 串流工具 `Moonlight` [From Here](https://github.com/XITRIX/Moonlight-Switch/releases/latest)
    - [x] 文件管理 `NX-Shell` [From Here](https://www.tekqart.com/thread-222735-1-1.html)
    - [x] 黑商店 `hb-appstore`  [From Here](https://github.com/fortheusers/hb-appstore/releases/latest)
    - [x] 系统升级工具 `daybreak`  [From Here](https://www.tekqart.com/thread-258184-1-1.html)

  - 补丁
    - [x] 主题破解 `theme-patches` [From Here](https://github.com/exelix11/theme-patches)
  - Ultrahand
    - [x] 加载器 `nx-ovlloader` [From Here](https://www.tekqart.com/thread-222735-1-1.html)
    - [x] 菜单 `Ultrahand-Overlay` [From Here](https://github.com/ppkantorski/Ultrahand-Overlay/releases/latest)
  - Ovl插件
    - [x] 金手指工具 `EdiZon` [From Here](https://www.tekqart.com/thread-222735-1-1.html)
    - [x] 系统模块 `ovl-sysmodules` [From Here](https://www.tekqart.com/thread-222735-1-1.html)
    - [x] 系统监视 `StatusMonitor` [From Here](https://www.tekqart.com/thread-222735-1-1.html)
    - [x] 掌机底座模式切换 `ReverseNX-RT` [From Here](https://www.tekqart.com/thread-222735-1-1.html)
    - [x] 局域网联机 `ldn_mitm` [From Here](https://www.tekqart.com/thread-222735-1-1.html)
    - [x] 虚拟Amiibo `emuiibo` [From Here](https://www.tekqart.com/thread-222735-1-1.html)
    - [x] 时间同步 `QuickNTP` [From Here](https://www.tekqart.com/thread-222735-1-1.html)
    - [x] 色彩调整 `Fizeau` [From Here](https://www.tekqart.com/thread-222735-1-1.html)
    - [x] 金手指工具 `Zing` [From Here](https://www.tekqart.com/thread-222735-1-1.html)
    - [x] 后台音乐 `sys-tune` [From Here](https://www.tekqart.com/thread-370954-1-1.html)
    - [x] 系统补丁 `sys-patch` [From Here](https://github.com/impeeza/sys-patch/releases/latest)
    - [x] 超频插件 `sys-clk` [From Here](https://github.com/retronx-team/sys-clk/releases/latest)
    - [x] 调频插件 `OC Toolkit` [From Here](https://github.com/halop/OC_Toolkit_SC_EOS/releases/latest)

  - 其他
    - [x] 蓝牙手柄插件 `MissionControl` [From Here](https://github.com/ndeadly/MissionControl/releases/latest)

- 文件操作：
    - [x] 移动 `fusee.bin` 至 `bootloader/payloads` 文件夹
    - [x] 将 `hekate_ctcaer_*.bin` 重命名为 `payload.bin`
    - [x] 在 `bootloader` 文件夹中创建 `hekate_ipl.ini`
    - [x] 在根目录中创建 `exosphere.ini`
    - [x] 在 `atmosphere/hosts` 文件夹中创建 `emummc.txt` 和 `sysmmc.txt`
    - [x] 在根目录中创建 `boot.ini`
    - [x] 在 `atmosphere/config` 文件夹中创建 `override_config.ini`
    - [x] 在 `atmosphere/config` 文件夹中创建 `system_settings.ini`
    - [x] 删除 `switch` 文件夹中 `haze.nro`
    - [x] 删除 `switch` 文件夹中 `daybreak.nro`
    - [x] 删除 `switch` 文件夹中 `reboot_to_payload.nro`

## 使用说明（仅适用于 `Linux` ，科学上网环境）:
  - 安装 `jq` 工具
  - 运行脚本（switchScript.sh）

## 更新日志
- 2024-08-26 更新脚本，修正 `OC Toolkit` 更新造成的运行错误
- 2024-07-21 添加 `sys-clk`、`OC Toolkit`
- 2024-07-16 更新脚本，替换 `Tesla-Menu` 为 `Ultrahand-Overlay`，去除 `sys-clk`
- 2024-07-06 更新 `daybreak` 为汉化版
- 2024-06-29 添加 `hb-appstore`
- 2024-06-22 添加 `SigPatches`、`MissionControl`
- 2024-06-20 更新 `hekate_ipl.ini` 修正启动时 `nosigchk` 报错；集成 `NX-Shell`
- 2024-06-16 更新 `Hekate + Nyx`、`sys-patch` 仓库链接，去除 `SigPatches`
- 2024-05-25 更新 `sys-patch`，集成`Moonlight`
- 2024-05-15 更新 `SigPatches`，修正部分游戏运行错误的情况
- 2024-04-12 更新脚本，修正插件源更新造成的运行错误，增强脚本的稳定性
- 2024-01-30 添加 `Switchfin` 插件
- 2024-01-27 添加 `Hekate` 汉化，删除4个 `Nro` 插件
- 2024-01-25 更新 `Tesla` 仓库链接
- 2024-01-24 添加 `sys-tune` 插件
- 2024-01-19 添加 `aio-switch-updater`、`wiliwili`、`SimpleModDownloader` 插件
- 2024-01-09 更新 `Tesla` 仓库链接
- 2023-12-15 更新 `Lockpick_RCM` 仓库链接
- 2023-12-04 删除 `Safe_Reboot_Shutdown.nro` 插件，添加3个 `Ovl` 插件
- 2023-12-03 添加 `Atmosphere-OC-Suite` 插件
- 2023-11-25 添加 `SwitchTime` 插件
- 2023-11-09 更新 `Lockpick_RCM` 仓库链接
- 2023-10-13 更新脚本，修正 `SigPatches` 链接更新造成的运行错误；新增2个 `Nro` 插件
- 2023-05-11 更新脚本，修正 `Lockpick_RCM` 仓库失效造成的运行错误；每天16点定时生成整合包
- 2023-05-04 更新脚本
- 2023-04-28 更新脚本，自动生成 Release 内容
- 2023-04-27 添加 Github Action 自动打包代码

## 截图
![](https://raw.githubusercontent.com/huangqian8/SwitchPlugins/main/screenshot/screenshot.png)