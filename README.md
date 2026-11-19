# 大气层个人整合包生成脚本

## 功能如下：

- 下载最新：
  - 大气层三件套
    - [x] `Atmosphere + Fusee` [From Here](https://github.com/Atmosphere-NX/Atmosphere/releases/latest)
    - [x] `Hekate + Nyx 简体中文` [From Here](https://github.com/easyworld/hekate/releases/latest)
    - [x] `Sigpatches` [From Here](https://gbatemp.net/threads/sigpatches-for-atmosphere-hekate-fss0-fusee-package3.571543/page-275#post-10692213)
  - Payload插件
    - [x] 主机系统的密钥提取工具 `Lockpick_RCM` [From Here](https://github.com/zdm65477730/Lockpick_RCMDecScots/releases/latest)
    - [x] Hekate下的文件管理工具 `TegraExplorer` [From Here](https://github.com/zdm65477730/TegraExplorer/releases/latest)
    - [x] Hekate下删除主题和关闭插件自动启动 `CommonProblemResolver` [From Here](https://github.com/zdm65477730/CommonProblemResolver/releases/latest)
  - Nro插件
    - [x] 联网检测是否屏蔽任天堂服务器 `Switch_90DNS_tester` [From Here](https://github.com/meganukebmp/Switch_90DNS_tester/releases/latest)
    - [x] 游戏安装，存档管理和文件传输工具 `DBI` [From Here](https://github.com/gzk47/DBIPatcher/releases/latest)
    - [x] 游戏安装和文件传输工具 `Awoo Installer` [From Here](https://github.com/Huntereb/Awoo-Installer/releases/latest)
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
    - [x] 文件管理 `NX-Shell` [From Here](https://github.com/zdm65477730/NX-Shell/releases/latest)
    - [x] Homebrew 启动器 `Sphaira` [From Here](https://github.com/ITotalJustice/sphaira/releases/latest)
    - [x] 黑商店 `hb-appstore`  [From Here](https://github.com/fortheusers/hb-appstore/releases/latest)
    - [x] 系统升级工具 `daybreak`  [From Here](https://www.tekqart.com/thread-258184-1-1.html)

  - 补丁
    - [x] 主题破解 `theme-patches` [From Here](https://github.com/exelix11/theme-patches)
  - Ultrahand
    - [x] 加载器 `nx-ovlloader` [From Here](https://github.com/zdm65477730/nx-ovlloader/releases/latest)
    - [x] 菜单 `Ultrahand-Overlay` [From Here](https://github.com/zdm65477730/Ultrahand-Overlay/releases/latest)
  - Ovl插件
    - [x] 金手指工具 `EdiZon` [From Here](https://github.com/zdm65477730/EdiZon-Overlay/releases/latest)
    - [x] 系统模块 `ovl-sysmodules` [From Here](https://github.com/zdm65477730/ovl-sysmodules/releases/latest)
    - [x] 系统监视 `StatusMonitor` [From Here](https://github.com/zdm65477730/Status-Monitor-Overlay/releases/latest)
    - [x] 掌机底座模式切换 `ReverseNX-RT` [From Here](https://github.com/zdm65477730/ReverseNX-RT/releases/latest)
    - [x] 局域网联机 `ldn_mitm` [From Here](https://github.com/zdm65477730/ldn_mitm/releases/latest)
    - [x] 虚拟Amiibo `emuiibo` [From Here](https://github.com/zdm65477730/emuiibo/releases/latest)
    - [x] 时间同步 `QuickNTP` [From Here](https://github.com/zdm65477730/QuickNTP/releases/latest)
    - [x] 色彩调整 `Fizeau` [From Here](https://github.com/zdm65477730/Fizeau/releases/latest)
    - [x] 系统补丁 `sys-patch` [From Here](https://github.com/zdm65477730/sys-patch/releases/latest)
    - [x] 超频插件 `sys-clk` [From Here](https://github.com/zdm65477730/sys-clk/releases/latest)
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

## 使用说明（需要 `Bash 3.2+`，建议科学上网环境）:
  - 安装依赖：
    - `macOS`：`brew install bash curl jq unzip git`
    - `Debian / Ubuntu / WSL`：`sudo apt install bash curl jq unzip git`
    - `Fedora`：`sudo dnf install bash curl jq unzip git`
    - `Arch Linux`：`sudo pacman -S bash curl jq unzip git`
  - 运行脚本：
    - `Linux / WSL`：`bash switchScript.sh`
    - `macOS Apple Silicon`：`/opt/homebrew/bin/bash switchScript.sh`
    - `macOS Intel`：`/usr/local/bin/bash switchScript.sh`
    - 如果已添加可执行权限，也可以运行：`chmod +x switchScript.sh && ./switchScript.sh`
  - 说明：脚本兼容 macOS 默认 `/bin/bash` 3.2，也兼容常见 Linux / WSL 环境。
  - 可选：如果频繁遇到 GitHub API 限流或部分插件下载失败，可设置 `GITHUB_TOKEN` 后再运行脚本。
  - 可选参数：
    - `--strict`：任一所选组件准备失败时返回非零状态；自动发布默认启用，防止发布缺少组件的整合包。
    - `--dry-run`：只显示将执行的分组，不下载或写入文件
    - `--only <groups>`：只运行指定分组，例如 `--only core,configs,finalize`
  - 注意：全量运行会清空并重建 `SwitchSD`；使用 `--only` 时会保留已有 `SwitchSD` 内容，仅补齐目录并执行指定分组。
  - 已有 SD 卡如遇到 `nosigchk` 启动报错，可删除 `bootloader/hekate_ipl.ini` 中两处 `kip1patch=nosigchk`；或运行 `bash switchScript.sh --only configs` 后，将生成的 `SwitchSD/bootloader/hekate_ipl.ini` 复制到 SD 卡对应位置（覆盖前请备份自定义启动配置）。

## 自动构建与验证

- 每天北京时间 16:17 请求自动构建，GitHub 调度可能延迟；也可在 Actions 页面使用 `Run workflow` 手动运行。
- 脚本、配置模板和构建 workflow 的修改会触发构建；README 单独修改不触发发布。
- 自动发布使用 `--strict`，所选组件失败时停止发布。普通本地运行保留警告模式，失败组件会写入 `description.txt`。
- 发布流程串行执行，构建源码固定为触发运行的提交，发布说明记录该提交 SHA。同日仍沿用日期标签并更新已有 Release。
- `--only` 局部更新会保留 `description.txt` 中其他组件上次成功记录的版本；失败组件单独列出，版本清单不替代文件完整性检查。
- Release 同时提供 `SwitchSD.zip`、`SwitchSD.zip.sha256` 和组件版本清单 `description.txt`。下载压缩包和校验文件后，可在 Linux 上执行 `sha256sum -c SwitchSD.zip.sha256`，或在 macOS 上执行 `shasum -a 256 -c SwitchSD.zip.sha256` 验证下载文件。
- 旧版本清理只处理有效 `YYYYMMDD` 日期标签的正式 Release，保留最近 5 个，并保护当前发布；草稿、预发布和其他标签不参与删除。可运行 `python3 scripts/prune_releases.py --repo huangqian8/SwitchScript --keep 5` 预览，只有显式传入 `--execute` 才会删除 Release 和对应标签。
- 离线回归检查：`python3 -m unittest discover -s tests -v`；脚本语法检查：`bash -n switchScript.sh`。

## 更新日志
- 2026-11-19 替换旧版 Release 清理工具，增加清理预览与保护规则；发布压缩包校验文件和组件版本清单
- 2026-11-19 完善构建触发、严格发布和失败报告；修复 API 缓存，增加请求超时重试、手动构建、发布并发控制与离线回归检查
- 2026-11-15 移除两个自制系统启动项中的 `kip1patch=nosigchk`，避免启动时请求该外部补丁导致报错（#34）
- 2026-06-20 模板化配置文件，优化 `--only` 模式，兼容 `Bash 3.2+` 并增加最终结构校验
- 2026-04-18 添加 `Sphaira` 启动器
- 2026-03-01 精简优化 `switchScript.sh`
- 2025-12-28 去除 `Zing` 和 `sys-tune`，更新 `DBI` 、 `Awoo Installer` 及 `emuiibo` 仓库地址
- 2025-10-06 更新 `system_settings.ini`
- 2025-05-27 精简代码，修正由于 `API` 限制而造成的运行错误
- 2025-05-23 批量更新插件地址
- 2025-05-12 更新 `Lockpick_RCM` 仓库地址
- 2025-05-11 更新 `hekate_ipl.ini`
- 2024-12-11 更新 `Lockpick_RCM` 仓库地址，降级 `DBI` 至版本658
- 2024-10-29 更新脚本，修正 `sys-patch` 文件更新造成的运行错误
- 2024-10-11 更新脚本，修正 `Lockpick_RCM` 仓库失效造成的运行错误
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
