#!/bin/sh
set -e

### Credit to the Authors at https://rentry.org/CFWGuides
### Script created by Fraxalotl
### Mod by huangqian8

# -------------------------------------------

### Create a new folder for storing files
if [ -d SwitchSD ]; then
  rm -rf SwitchSD
fi
if [ -e description.txt ]; then
  rm -rf description.txt
fi
mkdir -p ./SwitchSD/atmosphere/config
mkdir -p ./SwitchSD/atmosphere/hosts
mkdir -p ./SwitchSD/switch/DBI
mkdir -p ./SwitchSD/switch/Checkpoint
mkdir -p ./SwitchSD/themes
mkdir -p ./SwitchSD/config/tesla
cd SwitchSD

### Fetch latest Hekate + Nyx from https://github.com/CTCaer/hekate/releases/latest
curl -sL https://api.github.com/repos/CTCaer/hekate/releases/latest \
  | jq '.name' \
  | xargs -I {} echo {} >> ../description.txt
curl -sL https://api.github.com/repos/CTCaer/hekate/releases/latest \
  | jq '.assets' | jq '.[0].browser_download_url' \
  | xargs -I {} curl -sL {} -o hekate.zip
if [ $? -ne 0 ]; then
    echo "Hekate + Nyx download\033[31m failed\033[0m."
else
    echo "Hekate + Nyx download\033[32m success\033[0m."
    unzip -oq hekate.zip
    rm hekate.zip
fi

### Fetch latest atmosphere from https://github.com/Atmosphere-NX/Atmosphere/releases/latest
curl -sL https://api.github.com/repos/Atmosphere-NX/Atmosphere/releases/latest \
  | jq '.name' \
  | xargs -I {} echo {} >> ../description.txt
curl -sL https://api.github.com/repos/Atmosphere-NX/Atmosphere/releases/latest \
  | jq '.assets' | jq '.[0].browser_download_url' \
  | xargs -I {} curl -sL {} -o atmosphere.zip
if [ $? -ne 0 ]; then
    echo "atmosphere download\033[31m failed\033[0m."
else
    echo "atmosphere download\033[32m success\033[0m."
    unzip -oq atmosphere.zip
    rm atmosphere.zip
fi

### Fetch latest SigPatches.zip from
curl -sL https://sigmapatches.coomer.party/sigpatches.zip?08.22.2023 -o sigpatches.zip
if [ $? -ne 0 ]; then
    echo "SigPatches download\033[31m failed\033[0m."
else
    echo "SigPatches download\033[32m success\033[0m."
    unzip -oq sigpatches.zip
    rm sigpatches.zip
fi

### Fetch latest fusee.bin from https://github.com/Atmosphere-NX/Atmosphere/releases/latest
curl -sL https://api.github.com/repos/Atmosphere-NX/Atmosphere/releases/latest \
  | jq '.assets' | jq '.[1].browser_download_url' \
  | xargs -I {} curl -sL {} -o fusee.bin
if [ $? -ne 0 ]; then
    echo "fusee download\033[31m failed\033[0m."
else
    echo "fusee download\033[32m success\033[0m."
    mv fusee.bin ./bootloader/payloads
fi

### Fetch latest Lockpick_RCM.bin from https://github.com/iczero/Lockpick_RCM/releases/latest
curl -sL https://api.github.com/repos/iczero/Lockpick_RCM/releases/latest \
  | jq '.tag_name' \
  | xargs -I {} echo Lockpick_RCM {} >> ../description.txt
curl -sL https://api.github.com/repos/iczero/Lockpick_RCM/releases/latest \
  | jq '.assets' | jq '.[0].browser_download_url' \
  | xargs -I {} curl -sL {} -o Lockpick_RCM.bin
if [ $? -ne 0 ]; then
    echo "Lockpick_RCM download\033[31m failed\033[0m."
else
    echo "Lockpick_RCM download\033[32m success\033[0m."
    mv Lockpick_RCM.bin ./bootloader/payloads
fi

### Fetch latest TegraExplorer.bin form https://github.com/zdm65477730/TegraExplorer/releases
curl -sL https://api.github.com/repos/zdm65477730/TegraExplorer/releases/latest \
  | jq '.tag_name' \
  | xargs -I {} echo TegraExplorer {} >> ../description.txt
curl -sL https://api.github.com/repos/zdm65477730/TegraExplorer/releases/latest \
  | jq '.assets' | jq '.[0].browser_download_url' \
  | xargs -I {} curl -sL {} -o TegraExplorer.bin
if [ $? -ne 0 ]; then
    echo "TegraExplorer download\033[31m failed\033[0m."
else
    echo "TegraExplorer download\033[32m success\033[0m."
    mv TegraExplorer.bin ./bootloader/payloads
fi

### Fetch latest CommonProblemResolver.bin form https://github.com/zdm65477730/CommonProblemResolver/releases
curl -sL https://api.github.com/repos/zdm65477730/CommonProblemResolver/releases/latest \
  | jq '.tag_name' \
  | xargs -I {} echo CommonProblemResolver {} >> ../description.txt
curl -sL https://api.github.com/repos/zdm65477730/CommonProblemResolver/releases/latest \
  | jq '.assets' | jq '.[0].browser_download_url' \
  | xargs -I {} curl -sL {} -o CommonProblemResolver.bin
if [ $? -ne 0 ]; then
    echo "CommonProblemResolver download\033[31m failed\033[0m."
else
    echo "CommonProblemResolver download\033[32m success\033[0m."
    mv CommonProblemResolver.bin ./bootloader/payloads
fi

### Fetch lastest Safe_Reboot_Shutdown from https://github.com/dezem/Safe_Reboot_Shutdown/releases/latest
curl -sL https://api.github.com/repos/dezem/Safe_Reboot_Shutdown/releases/latest \
  | jq '.tag_name' \
  | xargs -I {} echo Safe_Reboot_Shutdown {} >> ../description.txt
curl -sL https://api.github.com/repos/dezem/Safe_Reboot_Shutdown/releases/latest \
  | jq '.assets' | jq '.[0].browser_download_url' \
  | xargs -I {} curl -sL {} -o Safe_Reboot_Shutdown.zip
if [ $? -ne 0 ]; then
    echo "Safe_Reboot_Shutdown download\033[31m failed\033[0m."
else
    echo "Safe_Reboot_Shutdown download\033[32m success\033[0m."
    unzip -oq Safe_Reboot_Shutdown.zip
    rm Safe_Reboot_Shutdown.zip
    mv Safe_Reboot_Shutdown.nro ./switch
fi

### Fetch lastest Switch_90DNS_tester from https://github.com/meganukebmp/Switch_90DNS_tester/releases/latest
curl -sL https://api.github.com/repos/meganukebmp/Switch_90DNS_tester/releases/latest \
  | jq '.tag_name' \
  | xargs -I {} echo Switch_90DNS_tester {} >> ../description.txt
curl -sL https://api.github.com/repos/meganukebmp/Switch_90DNS_tester/releases/latest \
  | jq '.assets' | jq '.[0].browser_download_url' \
  | xargs -I {} curl -sL {} -o Switch_90DNS_tester.nro
if [ $? -ne 0 ]; then
    echo "Switch_90DNS_tester download\033[31m failed\033[0m."
else
    echo "Switch_90DNS_tester download\033[32m success\033[0m."
    mv Switch_90DNS_tester.nro ./switch
fi

### Fetch lastest Checkpoint from https://github.com/BernardoGiordano/Checkpoint/releases/latest
curl -sL https://api.github.com/repos/BernardoGiordano/Checkpoint/releases/latest \
  | jq '.tag_name' \
  | xargs -I {} echo Checkpoint {} >> ../description.txt
curl -sL https://api.github.com/repos/BernardoGiordano/Checkpoint/releases/latest \
  | jq '.assets' | jq '.[0].browser_download_url' \
  | xargs -I {} curl -sL {} -o Checkpoint.nro
if [ $? -ne 0 ]; then
    echo "Checkpoint download\033[31m failed\033[0m."
else
    echo "Checkpoint download\033[32m success\033[0m."
    mv Checkpoint.nro ./switch/Checkpoint
fi

### Fetch lastest DBI from https://github.com/rashevskyv/dbi/releases/latest
curl -sL https://api.github.com/repos/rashevskyv/dbi/releases/latest \
  | jq '.name' \
  | xargs -I {} echo {} >> ../description.txt
curl -sL https://api.github.com/repos/rashevskyv/dbi/releases/latest \
  | jq '.assets' | jq '.[1].browser_download_url' \
  | xargs -I {} curl -sL {} -o DBI.nro
if [ $? -ne 0 ]; then
    echo "DBI download\033[31m failed\033[0m."
else
    echo "DBI download\033[32m success\033[0m."
    mv DBI.nro ./switch/DBI
fi

### Fetch lastest Awoo Installer from https://github.com/dragonflylee/Awoo-Installer/releases/latest
curl -sL https://api.github.com/repos/dragonflylee/Awoo-Installer/releases/latest \
  | jq '.name' \
  | xargs -I {} echo {} >> ../description.txt
curl -sL https://api.github.com/repos/dragonflylee/Awoo-Installer/releases/latest \
  | jq '.assets' | jq '.[0].browser_download_url' \
  | xargs -I {} curl -sL {} -o Awoo-Installer.zip
if [ $? -ne 0 ]; then
    echo "Awoo Installer download\033[31m failed\033[0m."
else
    echo "Awoo Installer download\033[32m success\033[0m."
    unzip -oq Awoo-Installer.zip
    rm Awoo-Installer.zip
fi

### Fetch lastest Hekate-toolbox from https://github.com/WerWolv/Hekate-Toolbox/releases/latest
curl -sL https://api.github.com/repos/WerWolv/Hekate-Toolbox/releases/latest \
  | jq '.tag_name' \
  | xargs -I {} echo HekateToolbox {} >> ../description.txt
curl -sL https://api.github.com/repos/WerWolv/Hekate-Toolbox/releases/latest \
  | jq '.assets' | jq '.[0].browser_download_url' \
  | xargs -I {} curl -sL {} -o HekateToolbox.nro
if [ $? -ne 0 ]; then
    echo "HekateToolbox download\033[31m failed\033[0m."
else
    echo "HekateToolbox download\033[32m success\033[0m."
    mv HekateToolbox.nro ./switch
fi

### Fetch lastest NX-Activity-Log from https://github.com/zdm65477730/NX-Activity-Log/releases/latest
curl -sL https://api.github.com/repos/zdm65477730/NX-Activity-Log/releases/latest \
  | jq '.tag_name' \
  | xargs -I {} echo NX-Activity-Log {} >> ../description.txt
curl -sL https://api.github.com/repos/zdm65477730/NX-Activity-Log/releases/latest \
  | jq '.assets' | jq '.[0].browser_download_url' \
  | xargs -I {} curl -sL {} -o NX-Activity-Log.zip
if [ $? -ne 0 ]; then
    echo "NX-Activity-Log download\033[31m failed\033[0m."
else
    echo "NX-Activity-Log download\033[32m success\033[0m."
    unzip -oq NX-Activity-Log.zip
    rm NX-Activity-Log.zip
fi

### Fetch lastest NXThemesInstaller from https://github.com/exelix11/SwitchThemeInjector/releases/latest
curl -sL https://api.github.com/repos/exelix11/SwitchThemeInjector/releases/latest \
  | jq '.tag_name' \
  | xargs -I {} echo NXThemesInstaller {} >> ../description.txt
curl -sL https://api.github.com/repos/exelix11/SwitchThemeInjector/releases/latest \
  | jq '.assets' | jq '.[0].browser_download_url' \
  | xargs -I {} curl -sL {} -o NXThemesInstaller.nro
if [ $? -ne 0 ]; then
    echo "NXThemesInstaller download\033[31m failed\033[0m."
else
    echo "NXThemesInstaller download\033[32m success\033[0m."
    mv NXThemesInstaller.nro ./switch
fi

### Fetch lastest JKSV from https://github.com/J-D-K/JKSV/releases/latest
curl -sL https://api.github.com/repos/J-D-K/JKSV/releases/latest \
  | jq '.name' \
  | xargs -I {} echo JKSV {} >> ../description.txt
curl -sL https://api.github.com/repos/J-D-K/JKSV/releases/latest \
  | jq '.assets' | jq '.[0].browser_download_url' \
  | xargs -I {} curl -sL {} -o JKSV.nro
if [ $? -ne 0 ]; then
    echo "JKSV download\033[31m failed\033[0m."
else
    echo "JKSV download\033[32m success\033[0m."
    mv JKSV.nro ./switch
fi

### Fetch lastest tencent-switcher-gui from https://github.com/CaiMiao/Tencent-switcher-GUI/releases/latest
curl -sL https://api.github.com/repos/CaiMiao/Tencent-switcher-GUI/releases/latest \
  | jq '.tag_name' \
  | xargs -I {} echo tencent-switcher-gui {} >> ../description.txt
curl -sL https://api.github.com/repos/CaiMiao/Tencent-switcher-GUI/releases/latest \
  | jq '.assets' | jq '.[0].browser_download_url' \
  | xargs -I {} curl -sL {} -o tencent-switcher-gui.nro
if [ $? -ne 0 ]; then
    echo "tencent-switcher-gui download\033[31m failed\033[0m."
else
    echo "tencent-switcher-gui download\033[32m success\033[0m."
    mv tencent-switcher-gui.nro ./switch
fi

### Fetch lastest Breeze from https://github.com/tomvita/Breeze-Beta/releases/latest
curl -sL https://api.github.com/repos/tomvita/Breeze-Beta/releases/latest \
  | jq '.tag_name' \
  | xargs -I {} echo Breeze {} >> ../description.txt
curl -sL https://api.github.com/repos/tomvita/Breeze-Beta/releases/latest \
  | jq '.assets' | jq '.[0].browser_download_url' \
  | xargs -I {} curl -sL {} -o Breeze.zip
if [ $? -ne 0 ]; then
    echo "Breeze download\033[31m failed\033[0m."
else
    echo "Breeze download\033[32m success\033[0m."
    unzip -oq Breeze.zip
    rm Breeze.zip
fi

### Fetch lastest Sigpatch-Updater from https://github.com/ITotalJustice/sigpatch-updater/releases/latest
curl -sL https://api.github.com/repos/ITotalJustice/sigpatch-updater/releases/latest \
  | jq '.tag_name' \
  | xargs -I {} echo sigpatch-updater {} >> ../description.txt
curl -sL https://api.github.com/repos/ITotalJustice/sigpatch-updater/releases/latest \
  | jq '.assets' | jq '.[0].browser_download_url' \
  | xargs -I {} curl -sL {} -o sigpatch-updater.nro
if [ $? -ne 0 ]; then
    echo "Sigpatch-Updater download\033[31m failed\033[0m."
else
    echo "Sigpatch-Updater download\033[32m success\033[0m."
    mv sigpatch-updater.nro ./switch
fi

### Fetch lastest AtmoPackUpdater from https://github.com/PoloNX/AtmoPackUpdater/releases
curl -sL https://api.github.com/repos/PoloNX/AtmoPackUpdater/releases/latest \
  | jq '.tag_name' \
  | xargs -I {} echo AtmoPackUpdater {} >> ../description.txt
curl -sL https://api.github.com/repos/PoloNX/AtmoPackUpdater/releases/latest \
  | jq '.assets' | jq '.[0].browser_download_url' \
  | xargs -I {} curl -sL {} -o AtmoPackUpdater.nro
if [ $? -ne 0 ]; then
    echo "AtmoPackUpdater download\033[31m failed\033[0m."
else
    echo "AtmoPackUpdater download\033[32m success\033[0m."
    mv AtmoPackUpdater.nro ./switch
fi

### Fetch lastest systemPatches from https://github.com/exelix11/theme-patches
git clone https://github.com/exelix11/theme-patches
if [ $? -ne 0 ]; then
    echo "theme-patches download\033[31m failed\033[0m."
else
    echo "theme-patches download\033[32m success\033[0m."
    mv -f theme-patches/systemPatches themes/
    rm -rf theme-patches
fi

### Rename hekate_ctcaer_*.bin to payload.bin
find . -name "*hekate_ctcaer*" -exec mv {} payload.bin \;
if [ $? -ne 0 ]; then
    echo "Rename hekate_ctcaer_*.bin to payload.bin\033[31m failed\033[0m."
else
    echo "Rename hekate_ctcaer_*.bin to payload.bin\033[32m success\033[0m."
fi

### Write hekate_ipl.ini in /bootloader/ directory
cat > ./bootloader/hekate_ipl.ini << ENDOFFILE
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

[Fusee]
icon=bootloader/res/icon_ams.bmp
payload=bootloader/payloads/fusee.bin

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
ENDOFFILE
if [ $? -ne 0 ]; then
    echo "Writing hekate_ipl.ini in ./bootloader/ directory\033[31m failed\033[0m."
else
    echo "Writing hekate_ipl.ini in ./bootloader/ directory\033[32m success\033[0m."
fi

### write exosphere.ini in root of SD Card
cat > ./exosphere.ini << ENDOFFILE
[exosphere]
debugmode=1
debugmode_user=0
disable_user_exception_handlers=0
enable_user_pmu_access=0
blank_prodinfo_sysmmc=1
blank_prodinfo_emummc=1
allow_writing_to_cal_sysmmc=0
log_port=0
log_baud_rate=115200
log_inverted=0
ENDOFFILE
if [ $? -ne 0 ]; then
    echo "Writing exosphere.ini in root of SD card\033[31m failed\033[0m."
else
    echo "Writing exosphere.ini in root of SD card\033[32m success\033[0m."
fi

### Write emummc.txt in /atmosphere/hosts
cat > ./atmosphere/hosts/emummc.txt << ENDOFFILE
# Block Nintendo Servers
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
95.216.149.205 *90dns.test
ENDOFFILE
cp ./atmosphere/hosts/emummc.txt ./atmosphere/hosts/sysmmc.txt
if [ $? -ne 0 ]; then
    echo "Writing emummc.txt and sysmmc.txt in ./atmosphere/hosts\033[31m failed\033[0m."
else
    echo "Writing emummc.txt and sysmmc.txt in ./atmosphere/hosts\033[32m success\033[0m."
fi

### Write boot.ini in root of SD Card
cat > ./boot.ini << ENDOFFILE
[payload]
file=payload.bin
ENDOFFILE
if [ $? -ne 0 ]; then
    echo "Writing boot.ini in root of SD card\033[31m failed\033[0m."
else
    echo "Writing boot.ini in root of SD card\033[32m success\033[0m."
fi

### Write config.ini in /config/tesla
cat > ./config/tesla/config.ini << ENDOFFILE
[tesla]
key_combo=L+ZL+R
ENDOFFILE
if [ $? -ne 0 ]; then
    echo "Writing config.ini in ./config/tesla\033[31m failed\033[0m."
else
    echo "Writing config.ini in ./config/tesla\033[32m success\033[0m."
fi

### Write override_config.ini in /atmosphere/config
cat > ./atmosphere/config/override_config.ini << ENDOFFILE
[hbl_config] 
program_id_0=010000000000100D
override_address_space=39_bit
override_key_0=R
ENDOFFILE
if [ $? -ne 0 ]; then
    echo "Writing override_config.ini in ./atmosphere/config\033[31m failed\033[0m."
else
    echo "Writing override_config.ini in ./atmosphere/config\033[32m success\033[0m."
fi

### Write system_settings.ini in /atmosphere/config
cat > ./atmosphere/config/system_settings.ini << ENDOFFILE
[eupld]
; 禁用将错误报告上传到任天堂
upload_enabled = u8!0x0

[ro]
; 控制 RO 是否应简化其对 NRO 的验证。
; （注意：这通常不是必需的，可以使用 IPS 补丁。
ease_nro_restriction = u8!0x1

[atmosphere]
; 是否自动开启所有金手指。0=关。1=开。
dmnt_cheats_enabled_by_default = u8!0x0

; 如果你希望大气记住你上次金手指状态，请删除下方；号
; dmnt_always_save_cheat_toggles = u8!0x1

; 如果大气崩溃，10秒后自动重启
; 1秒=1000毫秒，转换16进制
fatal_auto_reboot_interval = u64!0x2710

; 使电源菜单的“重新启动”按钮重新启动到payload
; 设置"normal"正常重启l 设置"rcm"重启RCM，
; power_menu_reboot_function = str!payload

; 启动90DNS与任天堂服务器屏蔽
enable_dns_mitm = u8!0x1
add_defaults_to_dns_hosts = u8!0x1

; 是否将蓝牙配对数据库用与虚拟系统
enable_external_bluetooth_db = u8!0x1

[usb]
; 开启USB3.0   尾数改为0是关闭
usb30_force_enabled = u8!0x1

[tc]
sleep_enabled = u8!0x0
holdable_tskin = u32!0xEA60
tskin_rate_table_console = str!”[[-1000000, 28000, 0, 0], [28000, 42000, 0, 51], [42000, 48000, 51, 102], [48000, 55000, 102, 153], [55000, 60000, 153, 255], [60000, 68000, 255, 255]]”
tskin_rate_table_handheld = str!”[[-1000000, 28000, 0, 0], [28000, 42000, 0, 51], [42000, 48000, 51, 102], [48000, 55000, 102, 153], [55000, 60000, 153, 255], [60000, 68000, 255, 255]]”
ENDOFFILE
if [ $? -ne 0 ]; then
    echo "Writing system_settings.ini in ./atmosphere/config\033[31m failed\033[0m."
else
    echo "Writing system_settings.ini in ./atmosphere/config\033[32m success\033[0m."
fi

### Fetch lastest Tesla3 from https://github.com/laila509/Tesla-plugins/releases/latest
curl -sL https://api.github.com/repos/laila509/Tesla-plugins/releases/latest \
  | jq '.assets' | jq '.[0].browser_download_url' \
  | xargs -I {} curl -sL {} -o tesla.zip
if [ $? -ne 0 ]; then
    echo "tesla download\033[31m failed\033[0m."
else
    echo "tesla download\033[32m success\033[0m."
    unzip -oq tesla.zip
    rm tesla.zip
    rm 大气层Tesla终极版插件包.txt
    rm -rf switch/DeepSea-Toolbox
    sed -i "s/L+DDOWN/L+Zl+R/g" config/tesla/config.ini
fi

###
cat >> ../description.txt << ENDOFFILE
ovlloader
ovlmenu
ovl-sysmodules
EdiZon
StatusMonitor
sys-clk
ReverseNX-RT
emuiibo
ldn_mitm
fastcfwswitch
Edizon-SE
MissionControl
sys-con
ENDOFFILE

### Fetch Chinese lang
mkdir -p switch/.overlays/lang/fastCFWswitch
curl -sL https://raw.githubusercontent.com/zdm65477730/fastCFWswitch/master/lang/zh-Hans.json -o switch/.overlays/lang/fastCFWswitch/zh-Hans.json
curl -sL https://raw.githubusercontent.com/zdm65477730/fastCFWswitch/master/lang/zh-Hant.json -o switch/.overlays/lang/fastCFWswitch/zh-Hant.json

### Fetch lastest Zing from https://github.com/tomvita/Zing/releases/latest
curl -sL https://api.github.com/repos/tomvita/Zing/releases/latest \
  | jq '.tag_name' \
  | xargs -I {} echo Zing {} >> ../description.txt
curl -sL https://api.github.com/repos/tomvita/Zing/releases/latest \
  | jq '.assets' | jq '.[0].browser_download_url' \
  | xargs -I {} curl -sL {} -o Zing.ovl
if [ $? -ne 0 ]; then
    echo "Zing download\033[31m failed\033[0m."
else
    echo "Zing download\033[32m success\033[0m."
    mv Zing.ovl ./switch/.overlays
fi

### Delete reboot_to_payload.nro & reboot_to_hekate.nro
rm switch/reboot_to_payload.nro
rm switch/reboot_to_hekate.nro

# -------------------------------------------

echo ""
echo "\033[32mYour Switch SD card is prepared!\033[0m"