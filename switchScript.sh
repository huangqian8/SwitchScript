#!/bin/bash
set -euo pipefail
set -E

if [ "${DEBUG:-0}" = "1" ]; then
    set -x
    PS4='[${LINENO}] '
fi

trap 'rc=$?; echo "[ERROR] line=${LINENO} cmd=${BASH_COMMAND}" >&2; exit $rc' ERR

### Credit to the Authors at https://rentry.org/CFWGuides
### Script created by Fraxalotl
### Mod by huangqian8
### Optimized version

# -------------------------------------------

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SWITCHSD_DIR="${SCRIPT_DIR}/SwitchSD"
readonly DESCRIPTION_FILE="${SCRIPT_DIR}/description.txt"

# Colors for output
readonly RED='\033[31m'
readonly GREEN='\033[32m'
readonly YELLOW='\033[33m'
readonly NC='\033[0m' # No Color

# Logging functions
log_success() { echo -e "${1} ${GREEN}success${NC}."; }
log_error() { echo -e "${1} ${RED}failed${NC}."; }
log_info() { echo -e "${YELLOW}[INFO]${NC} ${1}"; }

# Description lines (name + version)
declare -a DESCRIPTION_LINES=()
declare -a FAILED_ITEMS=()
declare -a REQUIRED_ITEMS=("Atmosphere" "Fusee" "Hekate + Nyx CHS")
declare -A ITEM_STATUS=()
declare -A FAILED_STATUS=()
declare -A RELEASE_CACHE=()
declare -a DOWNLOAD_QUEUE_PIDS=()
declare -A DOWNLOAD_PID_TO_KEY=()
declare -A DOWNLOAD_KEY_STATUS=()
declare -A DOWNLOAD_KEY_DESC=()
declare -A ENABLED_GROUPS=()

MAX_PARALLEL_DOWNLOADS="${MAX_PARALLEL_DOWNLOADS:-5}"
DRY_RUN=0
ONLY_MODE=0

record_item() {
    local name="$1"
    local version="${2:-unknown}"
    DESCRIPTION_LINES+=("${name} (${version})")
    ITEM_STATUS["$name"]=1
}

record_failure() {
    local name="$1"
    if [ "${FAILED_STATUS["$name"]+set}" = "set" ]; then
        return 0
    fi
    FAILED_STATUS["$name"]=1
    FAILED_ITEMS+=("$name")
}

write_description_file() {
    : > "$DESCRIPTION_FILE"
    printf "%s\n" "${DESCRIPTION_LINES[@]}" >> "$DESCRIPTION_FILE"
}

validate_required_items() {
    local missing=0
    local item

    for item in "${REQUIRED_ITEMS[@]}"; do
        if [ "${ITEM_STATUS["$item"]+set}" != "set" ]; then
            log_error "Missing required component: $item"
            record_failure "$item"
            missing=1
        fi
    done

    if [ "$missing" -ne 0 ]; then
        echo "Required components are missing. Aborting." >&2
        exit 1
    fi
}

print_failure_summary() {
    local item
    if [ "${#FAILED_ITEMS[@]}" -eq 0 ]; then
        log_info "All downloads completed without recorded failures."
        return 0
    fi

    log_info "Some downloads failed (${#FAILED_ITEMS[@]}):"
    for item in "${FAILED_ITEMS[@]}"; do
        echo " - $item"
    done
}

print_usage() {
    cat << 'EOF'
Usage: switchScript.sh [options]

Options:
  --dry-run                Print selected plan and exit (no download/write)
  --only <groups>          Run only selected groups (comma-separated)
                           Groups: core,payload,homebrew,special,system,configs,finalize
  -h, --help               Show this help
EOF
}

group_enabled() {
    local group="$1"
    if [ "$ONLY_MODE" -eq 0 ]; then
        return 0
    fi
    [ "${ENABLED_GROUPS["$group"]+set}" = "set" ]
}

parse_args() {
    local groups_arg group
    local -a _groups=()
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --dry-run)
                DRY_RUN=1
                ;;
            --only)
                shift
                [ "$#" -gt 0 ] || {
                    echo "Missing value for --only" >&2
                    print_usage
                    exit 1
                }
                groups_arg="$1"
                ONLY_MODE=1
                IFS=',' read -r -a _groups <<< "$groups_arg"
                for group in "${_groups[@]}"; do
                    case "$group" in
                        core|payload|homebrew|special|system|configs|finalize)
                            ENABLED_GROUPS["$group"]=1
                            ;;
                        all)
                            ONLY_MODE=0
                            ENABLED_GROUPS=()
                            ;;
                        *)
                            echo "Unknown group for --only: $group" >&2
                            print_usage
                            exit 1
                            ;;
                    esac
                done
                ;;
            -h|--help)
                print_usage
                exit 0
                ;;
            *)
                echo "Unknown option: $1" >&2
                print_usage
                exit 1
                ;;
        esac
        shift
    done
}

validate_runtime_options() {
    if ! [[ "$MAX_PARALLEL_DOWNLOADS" =~ ^[1-9][0-9]*$ ]]; then
        echo "Invalid MAX_PARALLEL_DOWNLOADS: $MAX_PARALLEL_DOWNLOADS" >&2
        exit 1
    fi
}

# Cleanup and create directories
cleanup_and_setup() {
    log_info "Setting up directories..."
    [ -d "$SWITCHSD_DIR" ] && rm -rf "$SWITCHSD_DIR"
    [ -e "$DESCRIPTION_FILE" ] && rm -f "$DESCRIPTION_FILE"
    
    # Create directory structure in batch
    mkdir -p "$SWITCHSD_DIR"/{atmosphere/{config,hosts,contents/{420000000007E51Anx-ovlloader,0000000000534C56ReverseNX-RT,4200000000000010ldn_mitm,0100000000000352emuiibo,0100000000000F12Fizeau,4200000000000000sys-tune,420000000000000Bsys-patch,010000000000bd00MissionControl,00FF0000636C6BFFsys-clk},kips},bootloader/payloads,config/ultrahand/lang,switch/{Switch_90DNS_tester,DBI,NX-Shell,HB-App-Store,HekateToolbox,JKSV,Moonlight,NXThemesInstaller,SimpleModDownloader,Switchfin,tencent-switcher-gui,wiliwili,NX-Activity-Log,Sphaira,.overlays,.packages}}
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
    record_failure "$description"
    return 1
}

reset_download_queue() {
    DOWNLOAD_QUEUE_PIDS=()
    DOWNLOAD_PID_TO_KEY=()
    DOWNLOAD_KEY_STATUS=()
    DOWNLOAD_KEY_DESC=()
}

reap_download_queue() {
    local -a running=()
    local pid key

    for pid in "${DOWNLOAD_QUEUE_PIDS[@]}"; do
        if kill -0 "$pid" 2>/dev/null; then
            running+=("$pid")
            continue
        fi

        key="${DOWNLOAD_PID_TO_KEY["$pid"]:-}"
        if [ -z "$key" ]; then
            continue
        fi

        if wait "$pid"; then
            DOWNLOAD_KEY_STATUS["$key"]="ok"
        else
            DOWNLOAD_KEY_STATUS["$key"]="fail"
            record_failure "${DOWNLOAD_KEY_DESC["$key"]:-$key}"
        fi

        unset "DOWNLOAD_PID_TO_KEY[$pid]"
    done

    DOWNLOAD_QUEUE_PIDS=("${running[@]}")
}

wait_for_download_slot() {
    while [ "${#DOWNLOAD_QUEUE_PIDS[@]}" -ge "$MAX_PARALLEL_DOWNLOADS" ]; do
        reap_download_queue
        sleep 0.1
    done
}

queue_download_job() {
    local key="$1"
    local url="$2"
    local output="$3"
    local description="$4"
    local pid

    wait_for_download_slot
    DOWNLOAD_KEY_STATUS["$key"]="pending"
    DOWNLOAD_KEY_DESC["$key"]="$description"

    (
        download_file "$url" "$output" "$description"
    ) &
    pid=$!

    DOWNLOAD_QUEUE_PIDS+=("$pid")
    DOWNLOAD_PID_TO_KEY["$pid"]="$key"
}

wait_for_all_downloads() {
    while [ "${#DOWNLOAD_QUEUE_PIDS[@]}" -gt 0 ]; do
        reap_download_queue
        sleep 0.1
    done
}

download_job_succeeded() {
    local key="$1"
    [ "${DOWNLOAD_KEY_STATUS["$key"]:-}" = "ok" ]
}

# Extract function
extract_and_cleanup() {
    local archive="$1"
    local description="$2"
    local extract_dir="${3:-.}"
    
    if [ -f "$archive" ]; then
        case "$archive" in
            *.zip) unzip -oq "$archive" -d "$extract_dir" ;;
            *.7z)
                if ! command -v 7z >/dev/null 2>&1; then
                    log_error "$description extraction (missing dependency: 7z)"
                    return 1
                fi
                7z x "$archive" -o"$extract_dir" -y >/dev/null
                ;;
            *) log_error "Unknown archive format: $archive"; return 1 ;;
        esac
        rm -f "$archive"
        log_success "$description extraction"
    else
        log_error "$description extraction (file not found)"
        return 1
    fi
}

# Ensure required dependencies exist
check_dependencies() {
    local missing=0
    for bin in curl jq unzip git; do
        if ! command -v "$bin" >/dev/null 2>&1; then
            log_error "Missing dependency: $bin"
            missing=1
        fi
    done

    [ "$missing" -eq 0 ] || {
        echo "Please install required dependencies first." >&2
        exit 1
    }
}

# Get release JSON with per-repo cache
get_release_json() {
    local repo="$1"
    local api="https://api.github.com/repos/$repo/releases/latest"
    local release_json

    if [ "${RELEASE_CACHE["$repo"]+set}" = "set" ]; then
        printf '%s' "${RELEASE_CACHE["$repo"]}"
        return 0
    fi

    release_json=$(github_api_get "$api") || return 1
    RELEASE_CACHE["$repo"]="$release_json"
    printf '%s' "$release_json"
}

# Get latest release asset URL + tag: prints "url|tag"
get_latest_release_asset() {
    local repo="$1"
    local pattern="$2"
    local release_json url tag

    release_json=$(get_release_json "$repo") || return 1
    tag=$(jq -r '.tag_name // "unknown"' <<< "$release_json")
    url=$(jq -r --arg re "$pattern" '.assets[]?.browser_download_url | select(test($re))' <<< "$release_json" | head -n1)

    if [ -n "$url" ] && [ "$url" != "null" ]; then
        echo "${url}|${tag}"
        return 0
    fi

    echo "[DEBUG] latest release asset not found repo=$repo pattern=$pattern tag=$tag" >&2
    return 1
}

github_api_get() {
    local url="$1"
    local -a args=( -fsSL -H "Accept: application/vnd.github+json" )
    if [ -n "${GITHUB_TOKEN:-}" ]; then
        args+=( -H "Authorization: Bearer ${GITHUB_TOKEN}" )
    fi
    curl "${args[@]}" "$url"
}

# Main download and setup function
main() {
    parse_args "$@"
    validate_runtime_options
    check_dependencies

    if [ "$DRY_RUN" -eq 1 ]; then
        log_info "Dry-run mode enabled. No download or filesystem changes will be made."
        if [ "$ONLY_MODE" -eq 0 ]; then
            log_info "Selected groups: all"
        else
            log_info "Selected groups:"
            group_enabled core && echo " - core"
            group_enabled payload && echo " - payload"
            group_enabled homebrew && echo " - homebrew"
            group_enabled special && echo " - special"
            group_enabled system && echo " - system"
            group_enabled configs && echo " - configs"
            group_enabled finalize && echo " - finalize"
        fi
        return 0
    fi

    cleanup_and_setup
    cd "$SWITCHSD_DIR"
    
    log_info "Starting downloads..."

    # Core system downloads
    if group_enabled core; then
        log_info "Downloading core system files..."
        
        # Atmosphere
        local atmosphere_url atmosphere_tag
        IFS='|' read -r atmosphere_url atmosphere_tag < <(get_latest_release_asset "Atmosphere-NX/Atmosphere" "atmosphere.*\\.zip") || true

        local fusee_url
        IFS='|' read -r fusee_url _ < <(get_latest_release_asset "Atmosphere-NX/Atmosphere" "fusee\\.bin") || true

        if [ -n "$atmosphere_url" ] && download_file "$atmosphere_url" "atmosphere.zip" "Atmosphere"; then
            extract_and_cleanup "atmosphere.zip" "Atmosphere"
            record_item "Atmosphere" "$atmosphere_tag"
        else
            record_failure "Atmosphere"
        fi

        if [ -n "$fusee_url" ] && download_file "$fusee_url" "fusee.bin" "Fusee"; then
            mv fusee.bin ./bootloader/payloads/
            record_item "Fusee" "$atmosphere_tag"
        else
            record_failure "Fusee"
        fi

        # Hekate
        local hekate_url hekate_tag
        IFS='|' read -r hekate_url hekate_tag < <(get_latest_release_asset "easyworld/hekate" "hekate_ctcaer.*_sc\\.zip") || true
        if [ -n "$hekate_url" ] && download_file "$hekate_url" "hekate.zip" "Hekate + Nyx CHS"; then
            extract_and_cleanup "hekate.zip" "Hekate + Nyx CHS"
            record_item "Hekate + Nyx CHS" "$hekate_tag"
        else
            record_failure "Hekate + Nyx CHS"
        fi
        
        # Sigpatches and logo
        if download_file "https://raw.githubusercontent.com/huangqian8/SwitchPlugins/main/plugins/sigpatches.zip" "sigpatches.zip" "Sigpatches"; then
            extract_and_cleanup "sigpatches.zip" "Sigpatches"
            record_item "Sigpatches" "raw-main"
        fi

        if download_file "https://raw.githubusercontent.com/huangqian8/SwitchPlugins/main/theme/logo.zip" "logo.zip" "Logo"; then
            extract_and_cleanup "logo.zip" "Logo"
            record_item "Logo" "raw-main"
        fi
    fi

    # Payload downloads
    if group_enabled payload; then
        log_info "Downloading payloads..."
        
        declare -A payloads=(
            ["zdm65477730/Lockpick_RCMDecScots"]="Lockpick_RCM\.bin:Lockpick_RCM"
            ["zdm65477730/TegraExplorer"]="TegraExplorer\.bin:TegraExplorer"
            ["zdm65477730/CommonProblemResolver"]="CommonProblemResolver\.bin:CommonProblemResolver"
        )
        declare -A payload_key_name=()
        declare -A payload_key_tag=()
        local -a payload_keys=()
        
        local -a payload_repos=()
        mapfile -t payload_repos < <(printf '%s\n' "${!payloads[@]}" | sort)

        reset_download_queue
        local payload_idx=0
        for repo_pattern in "${payload_repos[@]}"; do
            IFS=':' read -r pattern name <<< "${payloads[$repo_pattern]}"
            local url tag key
            IFS='|' read -r url tag < <(get_latest_release_asset "$repo_pattern" "$pattern") || true
            if [ -z "$url" ]; then
                record_failure "$name"
                continue
            fi

            key="payload_${payload_idx}"
            payload_idx=$((payload_idx + 1))
            payload_keys+=("$key")
            payload_key_name["$key"]="$name"
            payload_key_tag["$key"]="$tag"
            queue_download_job "$key" "$url" "${name}.bin" "$name"
        done
        wait_for_all_downloads

        local key
        for key in "${payload_keys[@]}"; do
            local name tag
            name="${payload_key_name["$key"]}"
            tag="${payload_key_tag["$key"]}"
            if download_job_succeeded "$key"; then
                mv "${name}.bin" ./bootloader/payloads/
                record_item "$name" "$tag"
            fi
        done
    fi

    # Homebrew applications
    if group_enabled homebrew; then
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
        declare -A homebrew_key_name=()
        declare -A homebrew_key_tag=()
        declare -A homebrew_key_target=()
        declare -A homebrew_key_file=()
        local -a homebrew_keys=()
        
        local -a homebrew_repos=()
        mapfile -t homebrew_repos < <(printf '%s\n' "${!homebrew_apps[@]}" | sort)

        reset_download_queue
        local homebrew_idx=0
        for repo_info in "${homebrew_repos[@]}"; do
            IFS=':' read -r pattern target_path name <<< "${homebrew_apps[$repo_info]}"
            local url tag key temp_file
            IFS='|' read -r url tag < <(get_latest_release_asset "$repo_info" "$pattern") || true
            if [ -z "$url" ]; then
                record_failure "$name"
                continue
            fi

            key="homebrew_${homebrew_idx}"
            homebrew_idx=$((homebrew_idx + 1))
            temp_file=".download_${key}_$(basename "$target_path")"

            homebrew_keys+=("$key")
            homebrew_key_name["$key"]="$name"
            homebrew_key_tag["$key"]="$tag"
            homebrew_key_target["$key"]="$target_path"
            homebrew_key_file["$key"]="$temp_file"
            queue_download_job "$key" "$url" "$temp_file" "$name"
        done
        wait_for_all_downloads

        local key
        for key in "${homebrew_keys[@]}"; do
            local name tag target_path temp_file
            name="${homebrew_key_name["$key"]}"
            tag="${homebrew_key_tag["$key"]}"
            target_path="${homebrew_key_target["$key"]}"
            temp_file="${homebrew_key_file["$key"]}"
            if download_job_succeeded "$key"; then
                mkdir -p "$(dirname "$target_path")"
                mv "$temp_file" "$target_path"
                record_item "$name" "$tag"
            fi
        done
    fi

    # Special downloads with custom handling
    if group_enabled special; then
        log_info "Downloading special packages..."
        
        # Awoo Installer
        local awoo_url awoo_tag
        IFS='|' read -r awoo_url awoo_tag < <(get_latest_release_asset "Huntereb/Awoo-Installer" "Awoo-Installer\\.zip") || true
        if [ -n "$awoo_url" ] && download_file "$awoo_url" "Awoo-Installer.zip" "Awoo Installer"; then
            extract_and_cleanup "Awoo-Installer.zip" "Awoo Installer"
            record_item "Awoo Installer" "$awoo_tag"
        fi

        # Sphaira - homebrew menu
        local sphaira_url sphaira_tag
        IFS='|' read -r sphaira_url sphaira_tag < <(get_latest_release_asset "ITotalJustice/sphaira" "sphaira\\.zip") || true
        if [ -n "$sphaira_url" ] && download_file "$sphaira_url" "sphaira.zip" "Sphaira"; then
            extract_and_cleanup "sphaira.zip" "Sphaira"
            record_item "Sphaira" "$sphaira_tag"
        fi

        # AIO Switch Updater
        local aio_url aio_tag
        IFS='|' read -r aio_url aio_tag < <(get_latest_release_asset "HamletDuFromage/aio-switch-updater" "aio-switch-updater\\.zip") || true
        if [ -n "$aio_url" ] && download_file "$aio_url" "aio-switch-updater.zip" "aio-switch-updater"; then
            extract_and_cleanup "aio-switch-updater.zip" "aio-switch-updater"
            record_item "aio-switch-updater" "$aio_tag"
        fi

        # Wiliwili
        local wiliwili_url wiliwili_tag
        IFS='|' read -r wiliwili_url wiliwili_tag < <(get_latest_release_asset "xfangfang/wiliwili" "wiliwili-NintendoSwitch\\.zip") || true
        if [ -n "$wiliwili_url" ] && download_file "$wiliwili_url" "wiliwili-NintendoSwitch.zip" "wiliwili"; then
            extract_and_cleanup "wiliwili-NintendoSwitch.zip" "wiliwili"
            [ -d wiliwili ] && mv wiliwili/wiliwili.nro ./switch/wiliwili/ && rm -rf wiliwili
            record_item "wiliwili" "$wiliwili_tag"
        fi

        # Daybreak
        if download_file "https://raw.githubusercontent.com/huangqian8/SwitchPlugins/main/plugins/daybreak_x.zip" "daybreak_x.zip" "daybreak"; then
            extract_and_cleanup "daybreak_x.zip" "daybreak"
            record_item "daybreak" "raw-main"
        fi
        
        # Theme patches
        if git clone --depth 1 https://github.com/exelix11/theme-patches 2>/dev/null; then
            log_success "theme-patches download"
            local theme_patch_version
            theme_patch_version=$(git -C theme-patches rev-parse --short HEAD 2>/dev/null || echo "unknown")
            mkdir -p themes
            [ -d theme-patches/systemPatches ] && mv theme-patches/systemPatches ./themes/
            rm -rf theme-patches
            record_item "theme-patches" "$theme_patch_version"
        else
            log_error "theme-patches download"
            record_failure "theme-patches"
        fi
    fi

    # System modules and overlays
    if group_enabled system; then
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
        declare -A system_key_name=()
        declare -A system_key_tag=()
        local -a system_keys=()
        
        local -a system_repos=()
        mapfile -t system_repos < <(printf '%s\n' "${!system_modules[@]}" | sort)

        reset_download_queue
        local system_idx=0
        for repo_pattern in "${system_repos[@]}"; do
            IFS=':' read -r pattern name <<< "${system_modules[$repo_pattern]}"
            local url tag key
            IFS='|' read -r url tag < <(get_latest_release_asset "$repo_pattern" "$pattern") || true
            if [ -z "$url" ]; then
                record_failure "$name"
                continue
            fi

            key="system_${system_idx}"
            system_idx=$((system_idx + 1))
            system_keys+=("$key")
            system_key_name["$key"]="$name"
            system_key_tag["$key"]="$tag"
            queue_download_job "$key" "$url" "${name}.zip" "$name"
        done
        wait_for_all_downloads

        local key
        for key in "${system_keys[@]}"; do
            local name tag
            name="${system_key_name["$key"]}"
            tag="${system_key_tag["$key"]}"
            if download_job_succeeded "$key"; then
                extract_and_cleanup "${name}.zip" "$name"
                record_item "$name" "$tag"
            fi
        done
        
        # Emuiibo (special handling)
        local emuiibo_url emuiibo_tag
        IFS='|' read -r emuiibo_url emuiibo_tag < <(get_latest_release_asset "XorTroll/emuiibo" "emuiibo\\.zip") || true
        if [ -n "$emuiibo_url" ] && download_file "$emuiibo_url" "emuiibo.zip" "emuiibo"; then
            extract_and_cleanup "emuiibo.zip" "emuiibo"
            [ -d SdOut ] && cp -rf SdOut/* ./ && rm -rf SdOut
            record_item "emuiibo" "$emuiibo_tag"
        fi
    fi
    
    # OC Toolkit (dual download)
    if group_enabled special; then
        local oc_info oc_tag kip_url toolkit_url
        oc_info=$(get_release_json "halop/OC_Toolkit_SC_EOS") || true
        if [ -n "$oc_info" ]; then
            oc_tag=$(jq -r '.tag_name // "unknown"' <<< "$oc_info")
            kip_url=$(jq -r '.assets[]?.browser_download_url | select(test("kip\\.zip"))' <<< "$oc_info" | head -n1)
            toolkit_url=$(jq -r '.assets[]?.browser_download_url | select(test("OC\\.Toolkit\\.u\\.zip"))' <<< "$oc_info" | head -n1)
        else
            oc_tag=""
            kip_url=""
            toolkit_url=""
        fi

        if [ -n "$kip_url" ] && [ -n "$toolkit_url" ] && download_file "$kip_url" "kip.zip" "OC Toolkit KIP" && download_file "$toolkit_url" "OC.Toolkit.u.zip" "OC Toolkit"; then
            log_success "OC_Toolkit_SC_EOS download"
            extract_and_cleanup "kip.zip" "OC Toolkit KIP" "./atmosphere/kips/"
            extract_and_cleanup "OC.Toolkit.u.zip" "OC Toolkit" "./switch/.packages/"
            record_item "OC_Toolkit_SC_EOS" "$oc_tag"
        else
            log_error "OC_Toolkit_SC_EOS download"
            record_failure "OC_Toolkit_SC_EOS"
        fi
    fi

    if group_enabled core; then
        validate_required_items
    fi
    print_failure_summary

    # Write runtime description (with versions)
    if group_enabled core || group_enabled payload || group_enabled homebrew || group_enabled special || group_enabled system; then
        write_description_file
    fi

    # Generate configuration files
    if group_enabled configs; then
        generate_configs
    fi
    
    # Cleanup and finalization
    if group_enabled finalize; then
        finalize_setup
    fi
    
    log_info "Setup completed successfully!"
    echo -e "\n${GREEN}Your Switch SD card is prepared!${NC}"
}

# Configuration generation functions
generate_configs() {
    log_info "Generating configuration files..."
    
    # description.txt is generated dynamically in main() via write_description_file()

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
    local removed_boot2_flags=0
    
    # Rename hekate payload
    find . -name "*hekate_ctcaer*" -exec mv {} payload.bin \; 2>/dev/null && \
        log_success "Rename hekate_ctcaer_*.bin to payload.bin" || \
        log_error "Rename hekate_ctcaer_*.bin to payload.bin"
    
    # Remove unneeded files
    rm -f switch/haze.nro switch/reboot_to_payload.nro switch/daybreak.nro

    if [ -d atmosphere/contents ]; then
        removed_boot2_flags=$(find atmosphere/contents -type f -name "boot2.flag" -print | wc -l | tr -d ' ')
        find atmosphere/contents -type f -name "boot2.flag" -delete
    fi
    log_info "Removed ${removed_boot2_flags} boot2.flag file(s) from atmosphere/contents"
    
    log_success "Setup finalization"
}

# Run main function
main "$@"
