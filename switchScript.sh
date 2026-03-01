#!/bin/bash
set -euo pipefail

### Credit to the Authors at https://rentry.org/CFWGuides
### Script created by Fraxalotl
### Mod by huangqian8
### Optimized version

# -------------------------------------------

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SWITCHSD_DIR="${SCRIPT_DIR}/SwitchSD"
readonly DESCRIPTION_FILE="${SCRIPT_DIR}/description.txt"
readonly MAX_PARALLEL_DOWNLOADS=5

# Colors for output
readonly RED='\033[31m'
readonly GREEN='\033[32m'
readonly YELLOW='\033[33m'
readonly NC='\033[0m' # No Color

# Logging functions
log_success() { echo -e "${1} ${GREEN}success${NC}."; }
log_error() { echo -e "${1} ${RED}failed${NC}."; }
log_info() { echo -e "${YELLOW}[INFO]${NC} ${1}"; }

# Cleanup and create directories
cleanup_and_setup() {
    log_info "Setting up directories..."
    [ -d "$SWITCHSD_DIR" ] && rm -rf "$SWITCHSD_DIR"
    [ -e "$DESCRIPTION_FILE" ] && rm -f "$DESCRIPTION_FILE"
    
    # Create directory structure in batch
    mkdir -p "$SWITCHSD_DIR"/{atmosphere/{config,hosts,contents/{420000000007E51Anx-ovlloader,0000000000534C56ReverseNX-RT,4200000000000010ldn_mitm,0100000000000352emuiibo,0100000000000F12Fizeau,4200000000000000sys-tune,420000000000000Bsys-patch,010000000000bd00MissionControl,00FF0000636C6BFFsys-clk},kips},bootloader/payloads,config/ultrahand/lang,switch/{Switch_90DNS_tester,DBI,NX-Shell,HB-App-Store,HekateToolbox,JKSV,Moonlight,NXThemesInstaller,SimpleModDownloader,Switchfin,tencent-switcher-gui,wiliwili,NX-Activity-Log,.overlays,.packages}}
}
# Download function with retry logic
download_file() {
    local url="$1"
    local output="$2"
    local description="$3"
    local max_retries=3
    local retry_count=0
    
    while [ $retry_count -lt $max_retries ]; do
        if curl -fsSL --connect-timeout 30 --max-time 300 "$url" -o "$output"; then
            log_success "$description download"
            return 0
        else
            retry_count=$((retry_count + 1))
            if [ $retry_count -lt $max_retries ]; then
                log_info "Retrying $description download (attempt $((retry_count + 1))/$max_retries)..."
                sleep 2
            fi
        fi
    done
    
    log_error "$description download"
    return 1
}

# Extract function
extract_and_cleanup() {
    local archive="$1"
    local description="$2"
    local extract_dir="${3:-.}"
    
    if [ -f "$archive" ]; then
        case "$archive" in
            *.zip) unzip -oq "$archive" -d "$extract_dir" ;;
            *.7z) 7z x "$archive" -o"$extract_dir" -y >/dev/null ;;
            *) log_error "Unknown archive format: $archive"; return 1 ;;
        esac
        rm -f "$archive"
        log_success "$description extraction"
    else
        log_error "$description extraction (file not found)"
        return 1
    fi
}

# Get latest release URL
get_latest_release_url() {
    local repo="$1"
    local pattern="$2"
    curl -fsSL "https://api.github.com/repos/$repo/releases/latest" | \
        grep -oP '"browser_download_url":\s*"\K[^"]*'"$pattern"'[^"]*' | head -1
}

# Main download and setup function
main() {
    cleanup_and_setup
    cd "$SWITCHSD_DIR"
    
    log_info "Starting downloads..."

    # Core system downloads
    log_info "Downloading core system files..."
    
    # Atmosphere
    local atmosphere_info=$(curl -fsSL https://api.github.com/repos/Atmosphere-NX/Atmosphere/releases/latest)
    local atmosphere_url=$(echo "$atmosphere_info" | grep -oP '"browser_download_url":\s*"\K[^"]*atmosphere[^"]*\.zip')
    local fusee_url=$(echo "$atmosphere_info" | grep -oP '"browser_download_url":\s*"\K[^"]*fusee\.bin')
    
    if [ -n "$atmosphere_url" ] && download_file "$atmosphere_url" "atmosphere.zip" "Atmosphere"; then
        extract_and_cleanup "atmosphere.zip" "Atmosphere"
    fi
    
    if [ -n "$fusee_url" ] && download_file "$fusee_url" "fusee.bin" "Fusee"; then
        mv fusee.bin ./bootloader/payloads/
    fi
    
    # Hekate
    local hekate_url=$(get_latest_release_url "easyworld/hekate" "hekate_ctcaer.*_sc\.zip")
    if [ -n "$hekate_url" ] && download_file "$hekate_url" "hekate.zip" "Hekate + Nyx CHS"; then
        extract_and_cleanup "hekate.zip" "Hekate + Nyx CHS"
    fi
    
    # Sigpatches and logo
    download_file "https://raw.githubusercontent.com/huangqian8/SwitchPlugins/main/plugins/sigpatches.zip" "sigpatches.zip" "Sigpatches" && \
        extract_and_cleanup "sigpatches.zip" "Sigpatches"
    
    download_file "https://raw.githubusercontent.com/huangqian8/SwitchPlugins/main/theme/logo.zip" "logo.zip" "Logo" && \
        extract_and_cleanup "logo.zip" "Logo"

    # Payload downloads
    log_info "Downloading payloads..."
    
    declare -A payloads=(
        ["zdm65477730/Lockpick_RCMDecScots"]="Lockpick_RCM\.bin:Lockpick_RCM"
        ["zdm65477730/TegraExplorer"]="TegraExplorer\.bin:TegraExplorer"
        ["zdm65477730/CommonProblemResolver"]="CommonProblemResolver\.bin:CommonProblemResolver"
    )
    
    for repo_pattern in "${!payloads[@]}"; do
        IFS=':' read -r pattern name <<< "${payloads[$repo_pattern]}"
        local url=$(get_latest_release_url "$repo_pattern" "$pattern")
        if [ -n "$url" ] && download_file "$url" "${name}.bin" "$name"; then
            mv "${name}.bin" ./bootloader/payloads/
        fi
    done

    # Homebrew applications
    log_info "Downloading homebrew applications..."
    
    declare -A homebrew_apps=(
        ["meganukebmp/Switch_90DNS_tester"]="Switch_90DNS_tester\.nro:switch/Switch_90DNS_tester/Switch_90DNS_tester.nro:Switch_90DNS_tester"
        ["gzk47/DBIPatcher"]="DBI.*\.zhcn\.nro:switch/DBI/DBI.nro:DBI"
        ["WerWolv/Hekate-Toolbox"]="HekateToolbox\.nro:switch/HekateToolbox/HekateToolbox.nro:HekateToolbox"
        ["zdm65477730/NX-Activity-Log"]="NX-Activity-Log\.nro:switch/NX-Activity-Log/NX-Activity-Log.nro:NX-Activity-Log"
        ["exelix11/SwitchThemeInjector"]="NXThemesInstaller\.nro:switch/NXThemesInstaller/NXThemesInstaller.nro:NXThemesInstaller"
        ["J-D-K/JKSV"]="JKSV\.nro:switch/JKSV/JKSV.nro:JKSV"
        ["CaiMiao/Tencent-switcher-GUI"]="tencent-switcher-gui\.nro:switch/tencent-switcher-gui/tencent-switcher-gui.nro:Tencent-switcher-GUI"
        ["PoloNX/SimpleModDownloader"]="SimpleModDownloader\.nro:switch/SimpleModDownloader/SimpleModDownloader.nro:SimpleModDownloader"
        ["dragonflylee/switchfin"]="Switchfin\.nro:switch/Switchfin/Switchfin.nro:Switchfin"
        ["XITRIX/Moonlight-Switch"]="Moonlight-Switch\.nro:switch/Moonlight/Moonlight-Switch.nro:Moonlight"
        ["zdm65477730/NX-Shell"]="NX-Shell\.nro:switch/NX-Shell/NX-Shell.nro:NX-Shell"
        ["fortheusers/hb-appstore"]="appstore\.nro:switch/HB-App-Store/appstore.nro:hb-appstore"
    )
    
    for repo_info in "${!homebrew_apps[@]}"; do
        IFS=':' read -r pattern target_path name <<< "${homebrew_apps[$repo_info]}"
        local url=$(get_latest_release_url "$repo_info" "$pattern")
        local temp_file=$(basename "$target_path")
        if [ -n "$url" ] && download_file "$url" "$temp_file" "$name"; then
            mkdir -p "$(dirname "$target_path")"
            mv "$temp_file" "$target_path"
        fi
    done

    # Special downloads with custom handling
    log_info "Downloading special packages..."
    
    # Awoo Installer
    local awoo_url=$(get_latest_release_url "Huntereb/Awoo-Installer" "Awoo-Installer\.zip")
    [ -n "$awoo_url" ] && download_file "$awoo_url" "Awoo-Installer.zip" "Awoo Installer" && \
        extract_and_cleanup "Awoo-Installer.zip" "Awoo Installer"
    
    # AIO Switch Updater
    local aio_url=$(get_latest_release_url "HamletDuFromage/aio-switch-updater" "aio-switch-updater\.zip")
    [ -n "$aio_url" ] && download_file "$aio_url" "aio-switch-updater.zip" "aio-switch-updater" && \
        extract_and_cleanup "aio-switch-updater.zip" "aio-switch-updater"
    
    # Wiliwili
    local wiliwili_url=$(get_latest_release_url "xfangfang/wiliwili" "wiliwili-NintendoSwitch\.zip")
    if [ -n "$wiliwili_url" ] && download_file "$wiliwili_url" "wiliwili-NintendoSwitch.zip" "wiliwili"; then
        extract_and_cleanup "wiliwili-NintendoSwitch.zip" "wiliwili"
        [ -d wiliwili ] && mv wiliwili/wiliwili.nro ./switch/wiliwili/ && rm -rf wiliwili
    fi
    
    # Daybreak
    download_file "https://raw.githubusercontent.com/huangqian8/SwitchPlugins/main/plugins/daybreak_x.zip" "daybreak_x.zip" "daybreak" && \
        extract_and_cleanup "daybreak_x.zip" "daybreak"
    
    # Theme patches
    if git clone --depth 1 https://github.com/exelix11/theme-patches 2>/dev/null; then
        log_success "theme-patches download"
        mkdir -p themes
        [ -d theme-patches/systemPatches ] && mv theme-patches/systemPatches ./themes/
        rm -rf theme-patches
    else
        log_error "theme-patches download"
    fi

    # System modules and overlays
    log_info "Downloading system modules and overlays..."
    
    declare -A system_modules=(
        ["zdm65477730/nx-ovlloader"]="nx-ovlloader\.zip:nx-ovlloader"
        ["zdm65477730/Ultrahand-Overlay"]="Ultrahand\.zip:Ultrahand-Overlay"
        ["zdm65477730/EdiZon-Overlay"]="EdiZon\.zip:EdiZon"
        ["zdm65477730/ovl-sysmodules"]="ovl-sysmodules\.zip:ovl-sysmodules"
        ["zdm65477730/Status-Monitor-Overlay"]="StatusMonitor\.zip:StatusMonitor"
        ["zdm65477730/ReverseNX-RT"]="ReverseNX-RT\.zip:ReverseNX-RT"
        ["zdm65477730/ldn_mitm"]="ldn_mitm\.zip:ldn_mitm"
        ["zdm65477730/QuickNTP"]="QuickNTP\.zip:QuickNTP"
        ["zdm65477730/Fizeau"]="Fizeau\.zip:Fizeau"
        ["zdm65477730/sys-patch"]="sys-patch\.zip:sys-patch"
        ["zdm65477730/sys-clk"]="sys-clk.*\.zip:sys-clk"
        ["ndeadly/MissionControl"]="MissionControl.*\.zip:MissionControl"
    )
    
    for repo_pattern in "${!system_modules[@]}"; do
        IFS=':' read -r pattern name <<< "${system_modules[$repo_pattern]}"
        local url=$(get_latest_release_url "$repo_pattern" "$pattern")
        [ -n "$url" ] && download_file "$url" "${name}.zip" "$name" && \
            extract_and_cleanup "${name}.zip" "$name"
    done
    
    # Emuiibo (special handling)
    local emuiibo_url=$(get_latest_release_url "XorTroll/emuiibo" "emuiibo\.zip")
    if [ -n "$emuiibo_url" ] && download_file "$emuiibo_url" "emuiibo.zip" "emuiibo"; then
        extract_and_cleanup "emuiibo.zip" "emuiibo"
        [ -d SdOut ] && cp -rf SdOut/* ./ && rm -rf SdOut
    fi
    
    # OC Toolkit (dual download)
    local oc_info=$(curl -fsSL https://api.github.com/repos/halop/OC_Toolkit_SC_EOS/releases/latest)
    local kip_url=$(echo "$oc_info" | grep -oP '"browser_download_url":\s*"\K[^"]*kip\.zip')
    local toolkit_url=$(echo "$oc_info" | grep -oP '"browser_download_url":\s*"\K[^"]*OC\.Toolkit\.u\.zip')
    
    if [ -n "$kip_url" ] && [ -n "$toolkit_url" ] && download_file "$kip_url" "kip.zip" "OC Toolkit KIP" && download_file "$toolkit_url" "OC.Toolkit.u.zip" "OC Toolkit"; then
        log_success "OC_Toolkit_SC_EOS download"
        extract_and_cleanup "kip.zip" "OC Toolkit KIP" "./atmosphere/kips/"
        extract_and_cleanup "OC.Toolkit.u.zip" "OC Toolkit" "./switch/.packages/"
    else
        log_error "OC_Toolkit_SC_EOS download"
    fi

    # Generate configuration files
    generate_configs
    
    # Cleanup and finalization
    finalize_setup
    
    log_info "Setup completed successfully!"
    echo -e "\n${GREEN}Your Switch SD card is prepared!${NC}"
}

# Configuration generation functions
generate_configs() {
    log_info "Generating configuration files..."
    
    # Generate description file
    cat > "$DESCRIPTION_FILE" << 'EOF'
Atmosphere
fusee
Hekate + Nyx CHS
sigpatches
Lockpick_RCM
TegraExplorer
CommonProblemResolver
Switch_90DNS_tester
DBI
Awoo-Installer
Hekate-Toolbox
NX-Activity-Log
NXThemesInstaller
JKSV
Tencent-switcher-GUI
aio-switch-updater
wiliwili
SimpleModDownloader
Switchfin
Moonlight
NX-Shell
hb-appstore
daybreak
nx-ovlloader
Ultrahand-Overlay
EdiZon
ovl-sysmodules
StatusMonitor
ReverseNX-RT
ldn_mitm
emuiibo
QuickNTP
Fizeau
sys-patch
sys-clk
OC_Toolkit_SC_EOS
MissionControl
EOF
    
    # Generate hekate_ipl.ini
    cat > ./bootloader/hekate_ipl.ini << 'EOF'
[config]
autoboot=0
autoboot_list=0
bootwait=3
backlight=100
noticker=0
autohosoff=1
autonogc=1
updater2p=0
bootprotect=0

[CFW (emuMMC)]
emummcforce=1
fss0=atmosphere/package3
kip1patch=nosigchk
atmosphere=1
icon=bootloader/res/icon_Atmosphere_emunand.bmp
id=cfw-emu

[CFW (sysMMC)]
emummc_force_disable=1
fss0=atmosphere/package3
kip1patch=nosigchk
atmosphere=1
icon=bootloader/res/icon_Atmosphere_sysnand.bmp
id=cfw-sys

[Stock SysNAND]
emummc_force_disable=1
fss0=atmosphere/package3
icon=bootloader/res/icon_stock.bmp
stock=1
id=ofw-sys
EOF
    
    # Generate exosphere.ini
    cat > ./exosphere.ini << 'EOF'
[exosphere]
debugmode=1
debugmode_user=0
disable_user_exception_handlers=0
enable_user_pmu_access=0
; 控制真实系统启用隐身模式。
blank_prodinfo_sysmmc=1
; 控制虚拟系统启用隐身模式。
blank_prodinfo_emummc=1
allow_writing_to_cal_sysmmc=0
log_port=0
log_baud_rate=115200
log_inverted=0
EOF
    
    # Generate DNS blocking files
    local dns_content='# 屏蔽任天堂服务器
127.0.0.1 *nintendo.*
127.0.0.1 *nintendo-europe.com
127.0.0.1 *nintendoswitch.*
127.0.0.1 ads.doubleclick.net
127.0.0.1 s.ytimg.com
127.0.0.1 ad.youtube.com
127.0.0.1 ads.youtube.com
127.0.0.1 clients1.google.com
207.246.121.77 *conntest.nintendowifi.net
207.246.121.77 *ctest.cdn.nintendo.net
69.25.139.140 *ctest.cdn.n.nintendoswitch.cn
95.216.149.205 *conntest.nintendowifi.net
95.216.149.205 *ctest.cdn.nintendo.net
95.216.149.205 *90dns.test'
    
    echo "$dns_content" > ./atmosphere/hosts/emummc.txt
    echo "$dns_content" > ./atmosphere/hosts/sysmmc.txt
    
    # Generate boot.ini
    cat > ./boot.ini << 'EOF'
[payload]
file=payload.bin
EOF
    
    # Generate override_config.ini
    cat > ./atmosphere/config/override_config.ini << 'EOF'
[hbl_config]
program_id_0=010000000000100D
override_address_space=39_bit
; 按住R键点击相册进入HBL自制软件界面。
override_key_0=R
EOF
    
    # Generate system_settings.ini
    cat > ./atmosphere/config/system_settings.ini << 'EOF'
; =============================================
; Atmosphere 防封禁核心配置文件
; =============================================

[eupld]
; 禁用错误报告上传
upload_enabled = u8!0x0

[ro]
; 放宽NRO验证限制，便于自制软件运行
ease_nro_restriction = u8!0x1

[atmosphere]
; 金手指默认关闭，按需开启更安全
dmnt_cheats_enabled_by_default = u8!0x0
; 崩溃10秒后自动重启 (10000毫秒)
fatal_auto_reboot_interval = u64!0x2710
; 启用DNS屏蔽，阻止连接任天堂服务器
enable_dns_mitm = u8!0x1
add_defaults_to_dns_hosts = u8!0x1
; 虚拟系统使用外部蓝牙配对
enable_external_bluetooth_db = u8!0x1

[usb]
; 强制开启USB 3.0
usb30_force_enabled = u8!0x1

[tc]
; 温控设置 - 保持默认即可
sleep_enabled = u8!0x0

; =============================================
; 🛡 防封禁核心配置 - 禁用所有任天堂服务
; =============================================

[bgtc]
; 禁用所有后台任务
enable_halfawake = u32!0x0
minimum_interval_normal = u32!0x7FFFFFFF
minimum_interval_save = u32!0x7FFFFFFF

[npns]
; 禁用新闻推送服务
background_processing = u8!0x0
sleep_periodic_interval = u32!0x7FFFFFFF

[ns.notification]
; 完全禁用系统更新检查和服务通信
enable_download_task_list = u8!0x0
enable_network_update = u8!0x0
enable_request_on_cold_boot = u8!0x0
retry_interval_min = u32!0x7FFFFFFF

[account]
; 禁用账户验证和许可证检查
na_required_for_network_service = u8!0x0
na_license_verification_enabled = u8!0x0

[capsrv]
; 禁用截图和录像验证
enable_album_screenshot_filedata_verification = u8!0x0
enable_album_movie_filehash_verification = u8!0x0

[friends]
; 禁用好友后台服务
background_processing = u8!0x0

[prepo]
; 禁用数据统计上报
transmission_interval_min = u32!0x7FFFFFFF
save_system_report = u8!0x0

[olsc]
; 禁用云存档服务
default_auto_upload_global_setting = u8!0x0
default_auto_download_global_setting = u8!0x0

[ns.rights]
; 跳过账户验证（重要权限检查）
skip_account_validation_on_rights_check = u8!0x1

; =============================================
; ⚡ 性能优化配置
; =============================================

[account.daemon]
; 延长账户服务间隔
background_awaking_periodicity = u32!0x7FFFFFFF

[notification.presenter]
; 禁用通知重试
connection_retry_count = u32!0x0

[systemupdate]
; 禁用系统更新重试
bgnup_retry_seconds = u32!0x7FFFFFFF

[pctl]
; 延长家长控制检查间隔
intermittent_task_interval_seconds = u32!0x7FFFFFFF
EOF
    
    log_success "Configuration files generation"
}

finalize_setup() {
    log_info "Finalizing setup..."
    
    # Rename hekate payload
    find . -name "*hekate_ctcaer*" -exec mv {} payload.bin \; 2>/dev/null && \
        log_success "Rename hekate_ctcaer_*.bin to payload.bin" || \
        log_error "Rename hekate_ctcaer_*.bin to payload.bin"
    
    # Remove unneeded files
    rm -f switch/haze.nro switch/reboot_to_payload.nro switch/daybreak.nro
    
    log_success "Setup finalization"
}

# Run main function
main "$@"