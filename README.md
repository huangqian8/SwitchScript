# 大气层个人整合包生成脚本

自动下载 Atmosphere、Hekate、自制软件和插件，生成 `SwitchSD` 目录及配置文件，并通过 GitHub Actions 构建发布整合包。

[下载最新整合包](https://github.com/huangqian8/SwitchScript/releases/latest) · [查看构建记录](https://github.com/huangqian8/SwitchScript/actions) · [反馈问题](https://github.com/huangqian8/SwitchScript/issues)

## 快速开始

需要 **Bash 3.2+** 及 `curl`、`jq`、`unzip`、`git`，并能访问 GitHub 下载资源。脚本兼容 macOS 默认 Bash、Linux 和 WSL。

在项目目录中运行：

```bash
bash switchScript.sh
```

输出位于 `SwitchSD/`，组件版本记录在 `description.txt`。

> 全量运行会清空并重建 `SwitchSD`。如需保留已有内容，请使用下方的 `--only` 参数。

<details>
<summary>安装依赖与其他启动方式</summary>

| 环境 | 安装命令 |
| --- | --- |
| macOS（Homebrew） | `brew install bash curl jq unzip git` |
| Debian / Ubuntu / WSL | `sudo apt install bash curl jq unzip git` |
| Fedora | `sudo dnf install bash curl jq unzip git` |
| Arch Linux | `sudo pacman -S bash curl jq unzip git` |

也可以使用 Homebrew 安装的 Bash：

- macOS Apple Silicon：`/opt/homebrew/bin/bash switchScript.sh`
- macOS Intel：`/usr/local/bin/bash switchScript.sh`

直接执行脚本：`chmod +x switchScript.sh && ./switchScript.sh`。

如果频繁遇到 GitHub API 限流或部分插件下载失败，可设置 `GITHUB_TOKEN` 后再运行脚本。

</details>

## 常用参数

| 参数 | 说明 |
| --- | --- |
| `--dry-run` | 只显示执行分组，不下载或写入文件 |
| `--only <groups>` | 仅执行指定分组，保留已有 `SwitchSD` 内容 |
| `--network-stack <name>` | 选择 `ldn_mitm`（默认）或 `roomcircuit` |
| `--strict` | 任一所选组件准备失败时返回非零状态，自动发布默认启用 |
| `--help` | 显示帮助 |

```bash
# 预览执行计划
bash switchScript.sh --dry-run

# 仅更新核心组件、配置并完成整理
bash switchScript.sh --only core,configs,finalize

# 使用 RoomCircuit 替代 ldn_mitm
bash switchScript.sh --network-stack roomcircuit
```

可选分组：`core`、`payload`、`homebrew`、`special`、`system`、`configs`、`finalize`。

<details>
<summary>已有 SD 卡的 nosigchk 启动报错处理</summary>

删除 SD 卡 `bootloader/hekate_ipl.ini` 中两处 `kip1patch=nosigchk`；或运行：

```bash
bash switchScript.sh --only configs
```

将生成的 `SwitchSD/bootloader/hekate_ipl.ini` 复制到 SD 卡对应位置。覆盖前请备份自定义启动配置。

</details>

## 集成内容

包含核心启动组件、Payload、自制软件、系统模块和 Overlay 插件，详细清单及上游链接见下方。

默认随系统启动 **Ultrahand 加载器（nx-ovlloader）** 和 **sys-patch**；Ultrahand 菜单仍需手动呼出，其他模块的自启动标记会在整理阶段移除。此规则在全量运行或包含 `finalize` 分组时应用，仅为已安装的模块创建启动标记。

<details>
<summary>展开组件清单与下载来源</summary>

### 大气层三件套

| 组件 | 用途 |
| --- | --- |
| [Atmosphere + Fusee](https://github.com/Atmosphere-NX/Atmosphere/releases/latest) | 核心组件 |
| [Hekate + Nyx 简体中文](https://github.com/easyworld/hekate/releases/latest) | 核心组件 |
| [Sigpatches](https://gbatemp.net/threads/sigpatches-for-atmosphere-hekate-fss0-fusee-package3.571543/page-275#post-10692213) | 核心组件 |

### Payload插件

| 组件 | 用途 |
| --- | --- |
| [Lockpick_RCM](https://github.com/zdm65477730/Lockpick_RCMDecScots/releases/latest) | 主机系统的密钥提取工具 |
| [TegraExplorer](https://github.com/zdm65477730/TegraExplorer/releases/latest) | Hekate下的文件管理工具 |
| [CommonProblemResolver](https://github.com/zdm65477730/CommonProblemResolver/releases/latest) | Hekate下删除主题和关闭插件自动启动 |

### Nro插件

| 组件 | 用途 |
| --- | --- |
| [Switch_90DNS_tester](https://github.com/meganukebmp/Switch_90DNS_tester/releases/latest) | 联网检测是否屏蔽任天堂服务器 |
| [DBI](https://github.com/gzk47/DBIPatcher/releases/latest) | 游戏安装，存档管理和文件传输工具 |
| [Awoo Installer](https://github.com/Huntereb/Awoo-Installer/releases/latest) | 游戏安装和文件传输工具 |
| [Hekate-toolbox](https://github.com/WerWolv/Hekate-Toolbox/releases/latest) | 深海工具箱 |
| [NX-Activity-Log](https://github.com/zdm65477730/NX-Activity-Log/releases/latest) | 游戏游玩时间记录工具 |
| [NXThemesInstaller](https://github.com/exelix11/SwitchThemeInjector/releases/latest) | 主题安装工具 |
| [JKSV](https://github.com/J-D-K/JKSV/releases/latest) | 游戏存档管理工具 |
| [tencent-switcher-gui](https://github.com/CaiMiao/Tencent-switcher-GUI/releases/latest) | 系统切换工具 |
| [aio-switch-updater](https://github.com/HamletDuFromage/aio-switch-updater/releases/latest) | 多工具合一任天堂Switch更新器 |
| [wiliwili](https://github.com/xfangfang/wiliwili/releases/latest) | 第三方B站客户端 |
| [SimpleModDownloader](https://github.com/PoloNX/SimpleModDownloader/releases/latest) | Mod下载器 |
| [Switchfin](https://github.com/dragonflylee/switchfin/releases/latest) | Jellyfin客户端 |
| [Moonlight](https://github.com/XITRIX/Moonlight-Switch/releases/latest) | 串流工具 |
| [NX-Shell](https://github.com/zdm65477730/NX-Shell/releases/latest) | 文件管理 |
| [Sphaira](https://github.com/ITotalJustice/sphaira/releases/latest) | Homebrew 启动器 |
| [hb-appstore](https://github.com/fortheusers/hb-appstore/releases/latest) | 黑商店 |
| [daybreak](https://www.tekqart.com/thread-258184-1-1.html) | 系统升级工具 |

### 补丁

| 组件 | 用途 |
| --- | --- |
| [theme-patches](https://github.com/exelix11/theme-patches) | 主题破解 |

### Ultrahand

| 组件 | 用途 |
| --- | --- |
| [nx-ovlloader](https://github.com/zdm65477730/nx-ovlloader/releases/latest) | 加载器 |
| [Ultrahand-Overlay](https://github.com/zdm65477730/Ultrahand-Overlay/releases/latest) | 菜单 |

### Ovl插件

| 组件 | 用途 |
| --- | --- |
| [EdiZon](https://github.com/zdm65477730/EdiZon-Overlay/releases/latest) | 金手指工具 |
| [ovl-sysmodules](https://github.com/zdm65477730/ovl-sysmodules/releases/latest) | 系统模块 |
| [StatusMonitor](https://github.com/zdm65477730/Status-Monitor-Overlay/releases/latest) | 系统监视 |
| [ReverseNX-RT](https://github.com/zdm65477730/ReverseNX-RT/releases/latest) | 掌机底座模式切换 |
| [ldn_mitm](https://github.com/zdm65477730/ldn_mitm/releases/latest) | 局域网联机 |
| [emuiibo](https://github.com/zdm65477730/emuiibo/releases/latest) | 虚拟Amiibo |
| [QuickNTP](https://github.com/zdm65477730/QuickNTP/releases/latest) | 时间同步 |
| [Fizeau](https://github.com/zdm65477730/Fizeau/releases/latest) | 色彩调整 |
| [sys-patch](https://github.com/zdm65477730/sys-patch/releases/latest) | 系统补丁 |
| [sys-clk](https://github.com/zdm65477730/sys-clk/releases/latest) | 超频插件 |
| [OC Toolkit](https://github.com/halop/OC_Toolkit_SC_EOS/releases/latest) | 调频插件 |

### 其他

| 组件 | 用途 |
| --- | --- |
| [MissionControl](https://github.com/ndeadly/MissionControl/releases/latest) | 蓝牙手柄插件 |

</details>

<details>
<summary>展开自动生成的配置与文件整理操作</summary>

- 移动 `fusee.bin` 至 `bootloader/payloads` 文件夹
- 将 `hekate_ctcaer_*.bin` 重命名为 `payload.bin`
- 在 `bootloader` 文件夹中创建 `hekate_ipl.ini`
- 在根目录中创建 `exosphere.ini`
- 在 `atmosphere/hosts` 文件夹中创建 `emummc.txt` 和 `sysmmc.txt`
- 在根目录中创建 `boot.ini`
- 在 `atmosphere/config` 文件夹中创建 `override_config.ini`
- 在 `atmosphere/config` 文件夹中创建 `system_settings.ini`
- 删除 `switch` 文件夹中 `haze.nro`
- 删除 `switch` 文件夹中 `daybreak.nro`
- 删除 `switch` 文件夹中 `reboot_to_payload.nro`

</details>

## 自动构建与下载校验

每天北京时间 **16:17** 请求自动构建，GitHub 调度可能延迟。也可在 Actions 页面使用 `Run workflow` 手动运行。

每次 Release 同时提供 `SwitchSD-ldn_mitm.zip` 和 `SwitchSD-roomcircuit.zip` 两个整合包。前者使用默认的 `ldn_mitm`，后者使用 RoomCircuit 替换同一模块槽位。两个包不能同时安装。Release 还包含 `SwitchSD.sha256` 和对应的组件版本清单。下载压缩包及校验文件后执行：

```bash
# Linux
sha256sum -c SwitchSD.zip.sha256

# macOS
shasum -a 256 -c SwitchSD.zip.sha256
```

<details>
<summary>展开构建策略、历史清理与开发验证说明</summary>

- 脚本、配置模板和构建 workflow 的修改会触发构建；README 单独修改不触发发布。
- 自动发布使用 `--strict`，所选组件失败时停止发布。普通本地运行保留警告模式，失败组件会写入 `description.txt`。
- 发布流程串行执行，构建源码固定为触发运行的提交，发布说明记录该提交 SHA。同日仍沿用日期标签并更新已有 Release。
- `--only` 局部更新会保留 `description.txt` 中其他组件上次成功记录的版本；失败组件单独列出，版本清单不替代文件完整性检查。
- 旧版本清理只处理有效 `YYYYMMDD` 日期标签的正式 Release，保留最近 5 个，并保护当前发布；草稿、预发布和其他标签不参与删除。可运行 `python3 scripts/prune_releases.py --repo huangqian8/SwitchScript --keep 5` 预览，只有显式传入 `--execute` 才会删除 Release 和对应标签。
- Actions 历史保留最近 5 次成功构建；最新成功构建之后的失败记录保留供排查，后续构建成功后清理此前的失败记录。运行中和排队中的记录不删除。清理由独立 job 在验证、构建结束后执行，构建失败时也会运行。
- 可运行 `python3 scripts/prune_workflow_runs.py --repo huangqian8/SwitchScript --workflow switchScript.yaml --keep 5` 预览历史清理；只有显式传入 `--execute` 才会删除运行记录及其日志。
- 离线回归检查：`python3 -m unittest discover -s tests -v`；脚本语法检查：`bash -n switchScript.sh`。

</details>

## 更新日志

- 2026-11-21 每次构建生成 `ldn_mitm` 和 RoomCircuit 两个互斥整合包，默认方案仍为 `ldn_mitm`
- 2026-11-20 默认启用 Ultrahand 加载器和 sys-patch 随系统启动，其他模块保持原有自启动策略

- 2026-11-19 Actions 历史改为保留最近 5 次成功构建及尚未被后续成功构建解决的失败记录；独立执行清理并保护运行中记录
- 2026-11-19 替换旧版 Release 清理工具，增加清理预览与保护规则；发布压缩包校验文件和组件版本清单
- 2026-11-19 完善构建触发、严格发布和失败报告；修复 API 缓存，增加请求超时重试、手动构建、发布并发控制与离线回归检查
- 2026-11-15 移除两个自制系统启动项中的 `kip1patch=nosigchk`，避免启动时请求该外部补丁导致报错（#34）

<details>
<summary>展开历史更新日志（2023—2026）</summary>

### 2026

- 2026-06-20 模板化配置文件，优化 `--only` 模式，兼容 `Bash 3.2+` 并增加最终结构校验
- 2026-04-18 添加 `Sphaira` 启动器
- 2026-03-01 精简优化 `switchScript.sh`

### 2025

- 2025-12-28 去除 `Zing` 和 `sys-tune`，更新 `DBI` 、 `Awoo Installer` 及 `emuiibo` 仓库地址
- 2025-10-06 更新 `system_settings.ini`
- 2025-05-27 精简代码，修正由于 `API` 限制而造成的运行错误
- 2025-05-23 批量更新插件地址
- 2025-05-12 更新 `Lockpick_RCM` 仓库地址
- 2025-05-11 更新 `hekate_ipl.ini`

### 2024

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

### 2023

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

</details>

## 截图

<details>
<summary>展开整合包截图</summary>

![整合包界面截图](https://raw.githubusercontent.com/huangqian8/SwitchPlugins/main/screenshot/screenshot.png)

</details>
