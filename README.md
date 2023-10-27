# 大气层个人整合包生成脚本

## 更新日志
- 2023-10-27 更新脚本，修正 `Tesla` 链接更新造成的运行错误
- 2023-10-13 更新脚本，修正 `SigPatches` 链接更新造成的运行错误；新增2个Nro插件
- 2023-05-11 更新脚本，修正 `Lockpick_RCM` 仓库失效造成的运行错误；每天16点定时生成整合包
- 2023-05-04 更新脚本
- 2023-04-28 更新脚本，自动生成 Release 内容
- 2023-04-27 添加 Github Action 自动打包代码

## 使用说明（仅适用于 `Linux` ）:
  - 安装 `jq` 工具
  - 运行脚本

## 功能如下：

- 下载最新：
  - 大气层三件套
    - [x] `Hekate + Nyx` [From Here](https://github.com/CTCaer/hekate/releases/latest/)
    - [x] `Atmosphere + Fusee` [From Here](https://github.com/Atmosphere-NX/Atmosphere/releases/latest)
    - [x] `SigPatches` [From Here](https://sigmapatches.coomer.party/sigpatches.zip?08.22.2023)
  - Payload 插件
    - [ ] 主机系统的密钥提取工具 `Lockpick_RCM` [Frome Here](https://github.com/shchmue/Lockpick_RCM/releases/latest)
    - [x] Hekate下的文件管理工具 `TegraExplorer` [Frome Here](https://github.com/zdm65477730/TegraExplorer/releases)
    - [x] Hekate下删除主题和关闭插件自动启动 `CommonProblemResolver` [Frome Here](https://github.com/zdm65477730/CommonProblemResolver/releases)
  - Nro 插件列表
    - [x] 一键关机重启工具 `Safe_Reboot_Shutdown.nro` [Frome Here](https://github.com/dezem/Safe_Reboot_Shutdown/releases/latest)
    - [x] 联网检测是否屏蔽任天堂服务器 `Switch_90DNS_tester.nro` [Frome Here](https://github.com/meganukebmp/Switch_90DNS_tester/releases/latest)
    - [x] 游戏存档管理工具 `Checkpoint` [From Here](https://github.com/BernardoGiordano/Checkpoint/releases/latest)
    - [x] 游戏安装，存档管理和文件传输工具 `DBI` [From Here](https://github.com/rashevskyv/dbi/releases/latest)
    - [x] 游戏安装和文件传输工具 `Awoo Installer` [From Here](https://github.com/dragonflylee/Awoo-Installer/releases/latest)
    - [x] 深海工具箱 `Hekate-toolbox` [From Here](https://github.com/WerWolv/Hekate-Toolbox/releases/latest)
    - [x] 游戏游玩时间记录工具 `NX-Activity-Log` [From Here](https://github.com/zdm65477730/NX-Activity-Log/releases/latest)
    - [x] 主题安装工具 `NXThemesInstaller` [From Here](https://github.com/exelix11/SwitchThemeInjector/releases/latest)
    - [x] 游戏存档管理工具 `JKSV` [From Here](https://github.com/J-D-K/JKSV/releases/latest)
    - [x] 系统切换工具 `tencent-switcher-gui` [From Here](https://github.com/CaiMiao/Tencent-switcher-GUI/releases/latest)
    - [x] 金手指工具 `Breeze` [From Here](https://github.com/tomvita/Breeze-Beta/releases/latest)
    - [x] SigPatches更新工具 `Sigpatch-Updater` [From Here](https://github.com/ITotalJustice/sigpatch-updater/releases/latest)
    - [x] 大气层三件套更新工具 `AtmoPackUpdater` [From Here](https://github.com/PoloNX/AtmoPackUpdater/releases)
  - 补丁
    - [x] `systemPatches` 补丁 [From Here](https://github.com/exelix11/theme-patches)
  - 特斯拉3中英文插件整合包
    - [x] `Tesla3` [From Here](https://github.com/laila509/Tesla-plugins/releases/latest)
  - Ovl 插件
    - [x] 金手指工具 `Zing` [From Here](https://github.com/tomvita/Zing/releases/latest)

- 文件操作：
    - [x] 移动 `fusee.bin` 至 `bootloader/payloads` 文件夹
    - [x] 将 `hekate_ctcaer_*.bin` 重命名为 `payload.bin`
    - [x] 在 `bootloader` 文件夹中创建 `hekate_ipl.ini`
    - [x] 在根目录中创建 `exosphere.ini`
    - [x] 在 `atmosphere` 文件夹中创建 `hosts` 文件夹
    - [x] 在 `atmosphere/hosts` 文件夹中创建 `emummc.txt` 和 `sysmmc.txt` ，屏蔽任天堂服务器
    - [x] 在根目录中创建 `boot.ini`
    - [x] 在 `atmosphere/config` 文件夹中创建 `override_config.ini`
    - [x] 在 `atmosphere/config` 文件夹中创建 `system_settings.ini`
    - [x] 删除 `switch` 文件夹中 `reboot_to_payload.nro`
    - [x] 删除 `switch` 文件夹中 `reboot_to_hekate.nro`
