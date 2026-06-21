#!/usr/bin/env bash
set -euo pipefail
set -E

if [ -z "${BASH_VERSINFO[0]+set}" ] || [ "${BASH_VERSINFO[0]}" -lt 3 ]; then
    echo "Bash 3.2 or newer is required. Current version: ${BASH_VERSION:-unknown}" >&2
    exit 1
fi

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
readonly TEMPLATE_DIR="${SCRIPT_DIR}/templates"
readonly DOWNLOAD_TMP_SUFFIX=".download-part"
readonly HTTP_USER_AGENT="SwitchScript/1.0"

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
declare -a ITEM_STATUS=()
declare -a FAILED_STATUS=()
declare -a RELEASE_CACHE_REPOS=()
declare -a RELEASE_CACHE_JSON=()
declare -a DOWNLOAD_QUEUE_PIDS=()
declare -a DOWNLOAD_PID_KEYS=()
declare -a DOWNLOAD_KEY_STATUS_KEYS=()
declare -a DOWNLOAD_KEY_STATUS_VALUES=()
declare -a DOWNLOAD_KEY_DESC_KEYS=()
declare -a DOWNLOAD_KEY_DESC_VALUES=()
declare -a ENABLED_GROUPS=()

MAX_PARALLEL_DOWNLOADS="${MAX_PARALLEL_DOWNLOADS:-5}"
DRY_RUN=0
ONLY_MODE=0

array_name_contains() {
    local needle="$1"
    local array_name="$2"
    local i item
    eval "local count=\${#$array_name[@]}"

    for ((i = 0; i < count; i++)); do
        eval "item=\${$array_name[$i]}"
        [ "$item" = "$needle" ] && return 0
    done
    return 1
}

kv_set() {
    local key="$1"
    local value="$2"
    local keys_name="$3"
    local values_name="$4"
    local i key_at_i
    eval "local count=\${#$keys_name[@]}"

    for ((i = 0; i < count; i++)); do
        eval "key_at_i=\${$keys_name[$i]}"
        if [ "$key_at_i" = "$key" ]; then
            eval "$values_name[$i]=\$value"
            return 0
        fi
    done

    eval "$keys_name+=(\"\$key\")"
    eval "$values_name+=(\"\$value\")"
}

kv_get() {
    local key="$1"
    local keys_name="$2"
    local values_name="$3"
    local default="${4:-}"
    local i key_at_i value_at_i
    eval "local count=\${#$keys_name[@]}"

    for ((i = 0; i < count; i++)); do
        eval "key_at_i=\${$keys_name[$i]}"
        if [ "$key_at_i" = "$key" ]; then
            eval "value_at_i=\${$values_name[$i]}"
            printf '%s' "$value_at_i"
            return 0
        fi
    done

    printf '%s' "$default"
    return 1
}

kv_has() {
    local key="$1"
    local keys_name="$2"
    local i key_at_i
    eval "local count=\${#$keys_name[@]}"

    for ((i = 0; i < count; i++)); do
        eval "key_at_i=\${$keys_name[$i]}"
        [ "$key_at_i" = "$key" ] && return 0
    done
    return 1
}

record_item() {
    local name="$1"
    local version="${2:-unknown}"
    DESCRIPTION_LINES+=("${name} (${version})")
    ITEM_STATUS+=("$name")
}

record_failure() {
    local name="$1"
    if array_name_contains "$name" FAILED_STATUS; then
        return 0
    fi
    FAILED_STATUS+=("$name")
    FAILED_ITEMS+=("$name")
}

has_failures() {
    [ "${#FAILED_ITEMS[@]}" -gt 0 ]
}

write_description_file() {
    : > "$DESCRIPTION_FILE"
    if [ "${#DESCRIPTION_LINES[@]}" -gt 0 ]; then
        printf "%s\n" "${DESCRIPTION_LINES[@]}" >> "$DESCRIPTION_FILE"
    fi
}

validate_required_items() {
    local missing=0
    local item

    for item in "${REQUIRED_ITEMS[@]}"; do
        if ! array_name_contains "$item" ITEM_STATUS; then
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
    array_name_contains "$group" ENABLED_GROUPS
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
                            if ! array_name_contains "$group" ENABLED_GROUPS; then
                                ENABLED_GROUPS+=("$group")
                            fi
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

create_switchsd_dirs() {
    mkdir -p "$SWITCHSD_DIR"/{atmosphere/{config,hosts,contents/{420000000007E51Anx-ovlloader,0000000000534C56ReverseNX-RT,4200000000000010ldn_mitm,0100000000000352emuiibo,0100000000000F12Fizeau,4200000000000000sys-tune,420000000000000Bsys-patch,010000000000bd00MissionControl,00FF0000636C6BFFsys-clk},kips},bootloader/payloads,config/ultrahand/lang,switch/{Switch_90DNS_tester,DBI,NX-Shell,HB-App-Store,HekateToolbox,JKSV,Moonlight,NXThemesInstaller,SimpleModDownloader,Switchfin,tencent-switcher-gui,wiliwili,NX-Activity-Log,Sphaira,.overlays,.packages}}
}

# Cleanup and create directories
cleanup_and_setup() {
    log_info "Setting up directories..."
    [ -d "$SWITCHSD_DIR" ] && rm -rf "$SWITCHSD_DIR"
    [ -e "$DESCRIPTION_FILE" ] && rm -f "$DESCRIPTION_FILE"
    create_switchsd_dirs
}

setup_workspace() {
    if [ "$ONLY_MODE" -eq 0 ]; then
        cleanup_and_setup
        return 0
    fi

    log_info "Setting up directories without removing existing SwitchSD contents..."
    create_switchsd_dirs
}

cleanup_stale_download_parts() {
    if [ -d "$SWITCHSD_DIR" ]; then
        find "$SWITCHSD_DIR" -type f -name "*${DOWNLOAD_TMP_SUFFIX}" -delete
    fi
}

# Download function with retry logic
download_file() {
    local url="$1"
    local output="$2"
    local description="$3"
    local max_retries=3
    local retry_count=0
    local tmp_output="${output}${DOWNLOAD_TMP_SUFFIX}"

    rm -f "$tmp_output"
    
    while [ $retry_count -lt $max_retries ]; do
        if curl -fsSL -A "$HTTP_USER_AGENT" --connect-timeout 30 --max-time 300 "$url" -o "$tmp_output"; then
            mv "$tmp_output" "$output"
            log_success "$description download"
            return 0
        else
            rm -f "$tmp_output"
            retry_count=$((retry_count + 1))
            if [ $retry_count -lt $max_retries ]; then
                log_info "Retrying $description download (attempt $((retry_count + 1))/$max_retries)..."
                sleep 2
            fi
        fi
    done
    
    log_error "$description download"
    record_failure "$description"
    rm -f "$tmp_output"
    return 1
}

reset_download_queue() {
    DOWNLOAD_QUEUE_PIDS=()
    DOWNLOAD_PID_KEYS=()
    DOWNLOAD_KEY_STATUS_KEYS=()
    DOWNLOAD_KEY_STATUS_VALUES=()
    DOWNLOAD_KEY_DESC_KEYS=()
    DOWNLOAD_KEY_DESC_VALUES=()
}

reap_download_queue() {
    local -a running=()
    local -a running_keys=()
    local pid key i

    for ((i = 0; i < ${#DOWNLOAD_QUEUE_PIDS[@]}; i++)); do
        pid="${DOWNLOAD_QUEUE_PIDS[$i]}"
        key="${DOWNLOAD_PID_KEYS[$i]}"
        if kill -0 "$pid" 2>/dev/null; then
            running+=("$pid")
            running_keys+=("$key")
            continue
        fi

        if [ -z "$key" ]; then
            continue
        fi

        if wait "$pid"; then
            kv_set "$key" "ok" DOWNLOAD_KEY_STATUS_KEYS DOWNLOAD_KEY_STATUS_VALUES
        else
            kv_set "$key" "fail" DOWNLOAD_KEY_STATUS_KEYS DOWNLOAD_KEY_STATUS_VALUES
            record_failure "$(kv_get "$key" DOWNLOAD_KEY_DESC_KEYS DOWNLOAD_KEY_DESC_VALUES "$key")"
        fi
    done

    if [ "${#running[@]}" -gt 0 ]; then
        DOWNLOAD_QUEUE_PIDS=("${running[@]}")
        DOWNLOAD_PID_KEYS=("${running_keys[@]}")
    else
        DOWNLOAD_QUEUE_PIDS=()
        DOWNLOAD_PID_KEYS=()
    fi
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
    kv_set "$key" "pending" DOWNLOAD_KEY_STATUS_KEYS DOWNLOAD_KEY_STATUS_VALUES
    kv_set "$key" "$description" DOWNLOAD_KEY_DESC_KEYS DOWNLOAD_KEY_DESC_VALUES

    (
        download_file "$url" "$output" "$description"
    ) &
    pid=$!

    DOWNLOAD_QUEUE_PIDS+=("$pid")
    DOWNLOAD_PID_KEYS+=("$key")
}

wait_for_all_downloads() {
    while [ "${#DOWNLOAD_QUEUE_PIDS[@]}" -gt 0 ]; do
        reap_download_queue
        sleep 0.1
    done
}

download_job_succeeded() {
    local key="$1"
    [ "$(kv_get "$key" DOWNLOAD_KEY_STATUS_KEYS DOWNLOAD_KEY_STATUS_VALUES "")" = "ok" ]
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
        echo "Please install required dependencies first: curl jq unzip git." >&2
        exit 1
    }
}

copy_template() {
    local src="$1"
    local dest="$2"

    if [ ! -f "$TEMPLATE_DIR/$src" ]; then
        log_error "Missing template: $src"
        return 1
    fi

    mkdir -p "$(dirname "$dest")"
    cp "$TEMPLATE_DIR/$src" "$dest"
}

validate_final_structure() {
    log_info "Validating final SwitchSD structure..."

    local missing=0
    local -a required_paths=(
        "atmosphere/package3"
        "bootloader/hekate_ipl.ini"
        "exosphere.ini"
        "boot.ini"
        "atmosphere/config/override_config.ini"
        "atmosphere/config/system_settings.ini"
        "atmosphere/hosts/emummc.txt"
        "atmosphere/hosts/sysmmc.txt"
        "bootloader/payloads/fusee.bin"
        "payload.bin"
    )
    local path

    for path in "${required_paths[@]}"; do
        if [ ! -e "$path" ]; then
            log_error "Missing expected file: $path"
            missing=1
        fi
    done

    if [ "$missing" -ne 0 ]; then
        echo "Final structure validation failed." >&2
        exit 1
    fi

    log_success "Final structure validation"
}

# Get release JSON with per-repo cache
get_release_json() {
    local repo="$1"
    local api="https://api.github.com/repos/$repo/releases/latest"
    local release_json

    if kv_has "$repo" RELEASE_CACHE_REPOS; then
        kv_get "$repo" RELEASE_CACHE_REPOS RELEASE_CACHE_JSON
        return 0
    fi

    release_json=$(github_api_get "$api") || return 1
    kv_set "$repo" "$release_json" RELEASE_CACHE_REPOS RELEASE_CACHE_JSON
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
    local -a args=( -fsSL -A "$HTTP_USER_AGENT" -H "Accept: application/vnd.github+json" )
    if [ -n "${GITHUB_TOKEN:-}" ]; then
        args+=( -H "Authorization: Bearer ${GITHUB_TOKEN}" )
    fi
    if ! curl "${args[@]}" "$url"; then
        echo "[WARN] GitHub API request failed: $url" >&2
        echo "[WARN] If this happens often, set GITHUB_TOKEN to avoid unauthenticated API limits." >&2
        return 1
    fi
}

# Main download and setup function
main() {
    parse_args "$@"
    validate_runtime_options

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

    check_dependencies

    setup_workspace
    cleanup_stale_download_parts
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
        
        local -a payloads=(
            "zdm65477730/CommonProblemResolver|CommonProblemResolver\\.bin|CommonProblemResolver"
            "zdm65477730/Lockpick_RCMDecScots|Lockpick_RCM\\.bin|Lockpick_RCM"
            "zdm65477730/TegraExplorer|TegraExplorer\\.bin|TegraExplorer"
        )
        local -a payload_key_names=()
        local -a payload_key_tags=()
        local -a payload_keys=()

        reset_download_queue
        local payload_idx=0
        for payload_info in "${payloads[@]}"; do
            IFS='|' read -r repo_pattern pattern name <<< "$payload_info"
            local url tag key
            IFS='|' read -r url tag < <(get_latest_release_asset "$repo_pattern" "$pattern") || true
            if [ -z "$url" ]; then
                record_failure "$name"
                continue
            fi

            key="payload_${payload_idx}"
            payload_idx=$((payload_idx + 1))
            payload_keys+=("$key")
            payload_key_names+=("$name")
            payload_key_tags+=("$tag")
            queue_download_job "$key" "$url" "${name}.bin" "$name"
        done
        wait_for_all_downloads

        local key i
        for ((i = 0; i < ${#payload_keys[@]}; i++)); do
            key="${payload_keys[$i]}"
            local name tag
            name="${payload_key_names[$i]}"
            tag="${payload_key_tags[$i]}"
            if download_job_succeeded "$key"; then
                mv "${name}.bin" ./bootloader/payloads/
                record_item "$name" "$tag"
            fi
        done
    fi

    # Homebrew applications
    if group_enabled homebrew; then
        log_info "Downloading homebrew applications..."
        
        local -a homebrew_apps=(
            "CaiMiao/Tencent-switcher-GUI|tencent-switcher-gui\\.nro|switch/tencent-switcher-gui/tencent-switcher-gui.nro|Tencent-switcher-GUI"
            "J-D-K/JKSV|JKSV\\.nro|switch/JKSV/JKSV.nro|JKSV"
            "PoloNX/SimpleModDownloader|SimpleModDownloader\\.nro|switch/SimpleModDownloader/SimpleModDownloader.nro|SimpleModDownloader"
            "WerWolv/Hekate-Toolbox|HekateToolbox\\.nro|switch/HekateToolbox/HekateToolbox.nro|HekateToolbox"
            "XITRIX/Moonlight-Switch|Moonlight-Switch\\.nro|switch/Moonlight/Moonlight-Switch.nro|Moonlight"
            "dragonflylee/switchfin|Switchfin\\.nro|switch/Switchfin/Switchfin.nro|Switchfin"
            "exelix11/SwitchThemeInjector|NXThemesInstaller\\.nro|switch/NXThemesInstaller/NXThemesInstaller.nro|NXThemesInstaller"
            "fortheusers/hb-appstore|appstore\\.nro|switch/HB-App-Store/appstore.nro|hb-appstore"
            "gzk47/DBIPatcher|DBI.*\\.zhcn\\.nro|switch/DBI/DBI.nro|DBI"
            "meganukebmp/Switch_90DNS_tester|Switch_90DNS_tester\\.nro|switch/Switch_90DNS_tester/Switch_90DNS_tester.nro|Switch_90DNS_tester"
            "zdm65477730/NX-Activity-Log|NX-Activity-Log\\.nro|switch/NX-Activity-Log/NX-Activity-Log.nro|NX-Activity-Log"
            "zdm65477730/NX-Shell|NX-Shell\\.nro|switch/NX-Shell/NX-Shell.nro|NX-Shell"
        )
        local -a homebrew_key_names=()
        local -a homebrew_key_tags=()
        local -a homebrew_key_targets=()
        local -a homebrew_key_files=()
        local -a homebrew_keys=()

        reset_download_queue
        local homebrew_idx=0
        for repo_info in "${homebrew_apps[@]}"; do
            IFS='|' read -r repo pattern target_path name <<< "$repo_info"
            local url tag key temp_file
            IFS='|' read -r url tag < <(get_latest_release_asset "$repo" "$pattern") || true
            if [ -z "$url" ]; then
                record_failure "$name"
                continue
            fi

            key="homebrew_${homebrew_idx}"
            homebrew_idx=$((homebrew_idx + 1))
            temp_file=".download_${key}_$(basename "$target_path")"

            homebrew_keys+=("$key")
            homebrew_key_names+=("$name")
            homebrew_key_tags+=("$tag")
            homebrew_key_targets+=("$target_path")
            homebrew_key_files+=("$temp_file")
            queue_download_job "$key" "$url" "$temp_file" "$name"
        done
        wait_for_all_downloads

        local key i
        for ((i = 0; i < ${#homebrew_keys[@]}; i++)); do
            key="${homebrew_keys[$i]}"
            local name tag target_path temp_file
            name="${homebrew_key_names[$i]}"
            tag="${homebrew_key_tags[$i]}"
            target_path="${homebrew_key_targets[$i]}"
            temp_file="${homebrew_key_files[$i]}"
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
        rm -rf theme-patches
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
        
        local -a system_modules=(
            "ndeadly/MissionControl|MissionControl.*\\.zip|MissionControl"
            "zdm65477730/EdiZon-Overlay|EdiZon\\.zip|EdiZon"
            "zdm65477730/Fizeau|Fizeau\\.zip|Fizeau"
            "zdm65477730/QuickNTP|QuickNTP\\.zip|QuickNTP"
            "zdm65477730/ReverseNX-RT|ReverseNX-RT\\.zip|ReverseNX-RT"
            "zdm65477730/Status-Monitor-Overlay|StatusMonitor\\.zip|StatusMonitor"
            "zdm65477730/Ultrahand-Overlay|Ultrahand\\.zip|Ultrahand-Overlay"
            "zdm65477730/ldn_mitm|ldn_mitm\\.zip|ldn_mitm"
            "zdm65477730/nx-ovlloader|nx-ovlloader\\.zip|nx-ovlloader"
            "zdm65477730/ovl-sysmodules|ovl-sysmodules\\.zip|ovl-sysmodules"
            "zdm65477730/sys-clk|sys-clk.*\\.zip|sys-clk"
            "zdm65477730/sys-patch|sys-patch\\.zip|sys-patch"
        )
        local -a system_key_names=()
        local -a system_key_tags=()
        local -a system_keys=()

        reset_download_queue
        local system_idx=0
        for repo_info in "${system_modules[@]}"; do
            IFS='|' read -r repo_pattern pattern name <<< "$repo_info"
            local url tag key
            IFS='|' read -r url tag < <(get_latest_release_asset "$repo_pattern" "$pattern") || true
            if [ -z "$url" ]; then
                record_failure "$name"
                continue
            fi

            key="system_${system_idx}"
            system_idx=$((system_idx + 1))
            system_keys+=("$key")
            system_key_names+=("$name")
            system_key_tags+=("$tag")
            queue_download_job "$key" "$url" "${name}.zip" "$name"
        done
        wait_for_all_downloads

        local key i
        for ((i = 0; i < ${#system_keys[@]}; i++)); do
            key="${system_keys[$i]}"
            local name tag
            name="${system_key_names[$i]}"
            tag="${system_key_tags[$i]}"
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

    if group_enabled core && group_enabled configs && group_enabled finalize; then
        validate_final_structure
    fi

    if has_failures; then
        log_info "Setup completed with warnings. Review failed items above."
        echo -e "\n${YELLOW}Your Switch SD card is prepared, but some optional items failed.${NC}"
    else
        log_info "Setup completed successfully!"
        echo -e "\n${GREEN}Your Switch SD card is prepared!${NC}"
    fi
}

# Configuration generation functions
generate_configs() {
    log_info "Generating configuration files..."

    copy_template "hekate_ipl.ini" "./bootloader/hekate_ipl.ini"
    copy_template "exosphere.ini" "./exosphere.ini"
    copy_template "dns_mitm.txt" "./atmosphere/hosts/emummc.txt"
    copy_template "dns_mitm.txt" "./atmosphere/hosts/sysmmc.txt"
    copy_template "boot.ini" "./boot.ini"
    copy_template "override_config.ini" "./atmosphere/config/override_config.ini"
    copy_template "system_settings.ini" "./atmosphere/config/system_settings.ini"
    
    log_success "Configuration files generation"
}

finalize_setup() {
    log_info "Finalizing setup..."
    local removed_boot2_flags=0
    local hekate_payload
    
    # Rename hekate payload
    hekate_payload=$(find . -maxdepth 1 -type f -name "hekate_ctcaer*.bin" -print -quit)
    if [ -n "$hekate_payload" ]; then
        mv "$hekate_payload" payload.bin
        log_success "Rename hekate_ctcaer_*.bin to payload.bin"
    elif [ -f payload.bin ]; then
        log_info "payload.bin already exists."
    else
        log_error "Rename hekate_ctcaer_*.bin to payload.bin"
        record_failure "payload.bin"
    fi
    
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
