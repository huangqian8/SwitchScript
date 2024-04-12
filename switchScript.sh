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
mkdir -p ./SwitchSD/config/tesla
cd SwitchSD

### Fetch latest atmosphere from https://github.com/Atmosphere-NX/Atmosphere/releases/latest
curl -sL https://api.github.com/repos/Atmosphere-NX/Atmosphere/releases/latest \
  | jq '.name' \
  | xargs -I {} echo {} >> ../description.txt
curl -sL https://api.github.com/repos/Atmosphere-NX/Atmosphere/releases/latest \
  | grep -oP '"browser_download_url": "\Khttps://[^"]*atmosphere[^"]*.zip' \
  | sed 's/"//g' \
  | xargs -I {} curl -sL {} -o atmosphere.zip
if [ $? -ne 0 ]; then
    echo "atmosphere download\033[31m failed\033[0m."
else
    echo "atmosphere download\033[32m success\033[0m."
    unzip -oq atmosphere.zip
    rm atmosphere.zip
fi

### Fetch latest fusee.bin from https://github.com/Atmosphere-NX/Atmosphere/releases/latest
curl -sL https://api.github.com/repos/Atmosphere-NX/Atmosphere/releases/latest \
  | grep -oP '"browser_download_url": "\Khttps://[^"]*fusee.bin"' \
  | sed 's/"//g' \
  | xargs -I {} curl -sL {} -o fusee.bin
if [ $? -ne 0 ]; then
    echo "fusee download\033[31m failed\033[0m."
else
    echo "fusee download\033[32m success\033[0m."
    mkdir -p ./bootloader/payloads
    mv fusee.bin ./bootloader/payloads
fi

### Fetch latest Hekate + Nyx from https://github.com/CTCaer/hekate/releases/latest
curl -sL https://api.github.com/repos/CTCaer/hekate/releases/latest \
  | jq '.name' \
  | xargs -I {} echo {} >> ../description.txt
curl -sL https://api.github.com/repos/CTCaer/hekate/releases/latest \
  | grep -oP '"browser_download_url": "\Khttps://[^"]*hekate_ctcaer[^"]*.zip"' \
  | sed 's/"//g' \
  | xargs -I {} curl -sL {} -o hekate.zip
if [ $? -ne 0 ]; then
    echo "Hekate + Nyx download\033[31m failed\033[0m."
else
    echo "Hekate + Nyx download\033[32m success\033[0m."
    unzip -oq hekate.zip
    rm hekate.zip
fi

### Fetch Nyx CHS
curl -sL https://raw.githubusercontent.com/huangqian8/SwitchPlugins/main/lang/nyx.zip -o nyx.zip
if [ $? -ne 0 ]; then
    echo "Nyx CHS download\033[31m failed\033[0m."
else
    echo "Nyx CHS download\033[32m success\033[0m."
    mv ./bootloader/sys/nyx.bin ./bootloader/sys/nys-en.bin
    unzip -oq nyx.zip
    rm nyx.zip
fi

### Fetch logo
curl -sL https://raw.githubusercontent.com/huangqian8/SwitchPlugins/main/theme/logo.zip -o logo.zip
if [ $? -ne 0 ]; then
    echo "logo download\033[31m failed\033[0m."
else
    echo "logo download\033[32m success\033[0m."
    unzip -oq logo.zip
    rm logo.zip
fi

### Fetch latest SigPatches.zip
curl -sL https://sigmapatches.coomer.party/sigpatches.zip?12.02.2023 -o sigpatches.zip
if [ $? -ne 0 ]; then
    echo "SigPatches download\033[31m failed\033[0m."
else
    echo "SigPatches download\033[32m success\033[0m."
    unzip -oq sigpatches.zip
    rm sigpatches.zip
fi

### Fetch latest Lockpick_RCM.bin from https://github.com/Decscots/Lockpick_RCM/releases/latest
curl -sL https://api.github.com/repos/Decscots/Lockpick_RCM/releases/latest \
  | jq '.tag_name' \
  | xargs -I {} echo Lockpick_RCM {} >> ../description.txt
curl -sL https://api.github.com/repos/Decscots/Lockpick_RCM/releases/latest \
  | grep -oP '"browser_download_url": "\Khttps://[^"]*Lockpick_RCM.bin"' \
  | sed 's/"//g' \
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
  | grep -oP '"browser_download_url": "\Khttps://[^"]*TegraExplorer.bin"' \
  | sed 's/"//g' \
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
  | grep -oP '"browser_download_url": "\Khttps://[^"]*CommonProblemResolver.bin"' \
  | sed 's/"//g' \
  | xargs -I {} curl -sL {} -o CommonProblemResolver.bin
if [ $? -ne 0 ]; then
    echo "CommonProblemResolver download\033[31m failed\033[0m."
else
    echo "CommonProblemResolver download\033[32m success\033[0m."
    mv CommonProblemResolver.bin ./bootloader/payloads
fi

### Fetch lastest Switch_90DNS_tester
curl -sL https://raw.githubusercontent.com/huangqian8/SwitchPlugins/main/plugins/Switch_90DNS_tester.zip -o Switch_90DNS_tester.zip
if [ $? -ne 0 ]; then
    echo "Switch_90DNS_tester download\033[31m failed\033[0m."
else
    echo "Switch_90DNS_tester download\033[32m success\033[0m."
    unzip -oq Switch_90DNS_tester.zip
    rm Switch_90DNS_tester.zip
fi

### Fetch lastest DBI from https://github.com/rashevskyv/dbi/releases/latest
curl -sL https://api.github.com/repos/rashevskyv/dbi/releases/latest \
  | jq '.name' \
  | xargs -I {} echo {} >> ../description.txt
curl -sL https://api.github.com/repos/rashevskyv/dbi/releases/latest \
  | grep -oP '"browser_download_url": "\Khttps://[^"]*DBI.nro"' \
  | sed 's/"//g' \
  | xargs -I {} curl -sL {} -o DBI.nro
if [ $? -ne 0 ]; then
    echo "DBI download\033[31m failed\033[0m."
else
    echo "DBI download\033[32m success\033[0m."
    mkdir -p ./switch/DBI
    mv DBI.nro ./switch/DBI
fi

### Fetch lastest Awoo Installer from https://github.com/dragonflylee/Awoo-Installer/releases/latest
curl -sL https://api.github.com/repos/dragonflylee/Awoo-Installer/releases/latest \
  | jq '.name' \
  | xargs -I {} echo {} >> ../description.txt
curl -sL https://api.github.com/repos/dragonflylee/Awoo-Installer/releases/latest \
  | grep -oP '"browser_download_url": "\Khttps://[^"]*Awoo-Installer.zip"' \
  | sed 's/"//g' \
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
  | grep -oP '"browser_download_url": "\Khttps://[^"]*HekateToolbox.nro"' \
  | sed 's/"//g' \
  | xargs -I {} curl -sL {} -o HekateToolbox.nro
if [ $? -ne 0 ]; then
    echo "HekateToolbox download\033[31m failed\033[0m."
else
    echo "HekateToolbox download\033[32m success\033[0m."
    mkdir -p ./switch/HekateToolbox
    mv HekateToolbox.nro ./switch/HekateToolbox
fi

### Fetch lastest NX-Activity-Log
curl -sL https://raw.githubusercontent.com/huangqian8/SwitchPlugins/main/plugins/NX-Activity-Log.zip -o NX-Activity-Log.zip
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
  | grep -oP '"browser_download_url": "\Khttps://[^"]*NXThemesInstaller.nro"' \
  | sed 's/"//g' \
  | xargs -I {} curl -sL {} -o NXThemesInstaller.nro
if [ $? -ne 0 ]; then
    echo "NXThemesInstaller download\033[31m failed\033[0m."
else
    echo "NXThemesInstaller download\033[32m success\033[0m."
    mkdir -p ./switch/NXThemesInstaller
    mv NXThemesInstaller.nro ./switch/NXThemesInstaller
fi

### Fetch lastest JKSV from https://github.com/J-D-K/JKSV/releases/latest
curl -sL https://api.github.com/repos/J-D-K/JKSV/releases/latest \
  | jq '.name' \
  | xargs -I {} echo JKSV {} >> ../description.txt
curl -sL https://api.github.com/repos/J-D-K/JKSV/releases/latest \
  | grep -oP '"browser_download_url": "\Khttps://[^"]*JKSV.nro"' \
  | sed 's/"//g' \
  | xargs -I {} curl -sL {} -o JKSV.nro
if [ $? -ne 0 ]; then
    echo "JKSV download\033[31m failed\033[0m."
else
    echo "JKSV download\033[32m success\033[0m."
    mkdir -p ./switch/JKSV
    mv JKSV.nro ./switch/JKSV
fi

### Fetch lastest tencent-switcher-gui from https://github.com/CaiMiao/Tencent-switcher-GUI/releases/latest
curl -sL https://api.github.com/repos/CaiMiao/Tencent-switcher-GUI/releases/latest \
  | jq '.tag_name' \
  | xargs -I {} echo tencent-switcher-gui {} >> ../description.txt
curl -sL https://api.github.com/repos/CaiMiao/Tencent-switcher-GUI/releases/latest \
  | grep -oP '"browser_download_url": "\Khttps://[^"]*tencent-switcher-gui.nro"' \
  | sed 's/"//g' \
  | xargs -I {} curl -sL {} -o tencent-switcher-gui.nro
if [ $? -ne 0 ]; then
    echo "tencent-switcher-gui download\033[31m failed\033[0m."
else
    echo "tencent-switcher-gui download\033[32m success\033[0m."
    mkdir -p ./switch/tencent-switcher-gui
    mv tencent-switcher-gui.nro ./switch/tencent-switcher-gui
fi

### Fetch lastest aio-switch-updater from https://github.com/HamletDuFromage/aio-switch-updater/releases/latest
curl -sL https://api.github.com/repos/HamletDuFromage/aio-switch-updater/releases/latest \
  | jq '.tag_name' \
  | xargs -I {} echo aio-switch-updater {} >> ../description.txt
curl -sL https://api.github.com/repos/HamletDuFromage/aio-switch-updater/releases/latest \
  | grep -oP '"browser_download_url": "\Khttps://[^"]*aio-switch-updater.zip"' \
  | sed 's/"//g' \
  | xargs -I {} curl -sL {} -o aio-switch-updater.zip
if [ $? -ne 0 ]; then
    echo "aio-switch-updater download\033[31m failed\033[0m."
else
    echo "aio-switch-updater download\033[32m success\033[0m."
    unzip -oq aio-switch-updater.zip
    rm aio-switch-updater.zip
fi

### Fetch lastest wiliwili from https://github.com/xfangfang/wiliwili/releases/latest
curl -sL https://api.github.com/repos/xfangfang/wiliwili/releases/latest \
  | jq '.tag_name' \
  | xargs -I {} echo wiliwili {} >> ../description.txt
curl -sL https://api.github.com/repos/xfangfang/wiliwili/releases/latest \
  | grep -oP '"browser_download_url": "\Khttps://[^"]*wiliwili-NintendoSwitch.zip"' \
  | sed 's/"//g' \
  | xargs -I {} curl -sL {} -o wiliwili-NintendoSwitch.zip
if [ $? -ne 0 ]; then
    echo "wiliwili download\033[31m failed\033[0m."
else
    echo "wiliwili download\033[32m success\033[0m."
    unzip -oq wiliwili-NintendoSwitch.zip
    mkdir -p ./switch/wiliwili
    mv wiliwili/wiliwili.nro ./switch/wiliwili
    rm -rf wiliwili
    rm wiliwili-NintendoSwitch.zip
fi

### Fetch lastest SimpleModDownloader from https://github.com/PoloNX/SimpleModDownloader/releases/latest
curl -sL https://api.github.com/repos/PoloNX/SimpleModDownloader/releases/latest \
  | jq '.tag_name' \
  | xargs -I {} echo SimpleModDownloader {} >> ../description.txt
curl -sL https://api.github.com/repos/PoloNX/SimpleModDownloader/releases/latest \
  | grep -oP '"browser_download_url": "\Khttps://[^"]*SimpleModDownloader.nro"' \
  | sed 's/"//g' \
  | xargs -I {} curl -sL {} -o SimpleModDownloader.nro
if [ $? -ne 0 ]; then
    echo "SimpleModDownloader download\033[31m failed\033[0m."
else
    echo "SimpleModDownloader download\033[32m success\033[0m."
    mkdir -p ./switch/SimpleModDownloader
    mv SimpleModDownloader.nro ./switch/SimpleModDownloader
fi

### Fetch lastest Switchfin from https://github.com/dragonflylee/switchfin/releases/latest
curl -sL https://api.github.com/repos/dragonflylee/switchfin/releases/latest \
  | jq '.tag_name' \
  | xargs -I {} echo Switchfin {} >> ../description.txt
curl -sL https://api.github.com/repos/dragonflylee/switchfin/releases/latest \
  | grep -oP '"browser_download_url": "\Khttps://[^"]*Switchfin.nro"' \
  | sed 's/"//g' \
  | xargs -I {} curl -sL {} -o Switchfin.nro
if [ $? -ne 0 ]; then
    echo "Switchfin download\033[31m failed\033[0m."
else
    echo "Switchfin download\033[32m success\033[0m."
    mkdir -p ./switch/Switchfin
    mv Switchfin.nro ./switch/Switchfin
fi

### Fetch lastest theme-patches from https://github.com/exelix11/theme-patches
git clone https://github.com/exelix11/theme-patches
if [ $? -ne 0 ]; then
    echo "theme-patches download\033[31m failed\033[0m."
else
    echo "theme-patches download\033[32m success\033[0m."
    mkdir themes
    mv -f theme-patches/systemPatches ./themes/
    rm -rf theme-patches
fi

### Fetch nx-ovlloader
curl -sL https://raw.githubusercontent.com/huangqian8/SwitchPlugins/main/plugins/nx-ovlloader.zip -o nx-ovlloader.zip
if [ $? -ne 0 ]; then
    echo "nx-ovlloader download\033[31m failed\033[0m."
else
    echo "nx-ovlloader download\033[32m success\033[0m."
    unzip -oq nx-ovlloader.zip
    rm nx-ovlloader.zip
fi

### Write config.ini in /config/tesla
cat > ./config/tesla/config.ini << ENDOFFILE
[tesla]
; 特斯拉自定义快捷键。
key_combo=L+ZL+R
ENDOFFILE
if [ $? -ne 0 ]; then
    echo "Writing config.ini in ./config/tesla\033[31m failed\033[0m."
else
    echo "Writing config.ini in ./config/tesla\033[32m success\033[0m."
fi

### Fetch Tesla-Menu
curl -sL https://raw.githubusercontent.com/huangqian8/SwitchPlugins/main/plugins/Tesla-Menu.zip -o Tesla-Menu.zip
if [ $? -ne 0 ]; then
    echo "Tesla-Menu download\033[31m failed\033[0m."
else
    echo "Tesla-Menu download\033[32m success\033[0m."
    unzip -oq Tesla-Menu.zip
    rm Tesla-Menu.zip
fi

### Write sort.cfg in /config/Tesla-Menu/sort.cfg
cat > ./config/Tesla-Menu/sort.cfg << ENDOFFILE
EdiZon
ovl-sysmodules
StatusMonitor
sys-clk-overlay
ReverseNX-RT
ldn_mitm
emuiibo
QuickNTP
Fizeau
Zing
sys-tune
ENDOFFILE

### Fetch EdiZon
curl -sL https://raw.githubusercontent.com/huangqian8/SwitchPlugins/main/plugins/EdiZon.zip -o EdiZon.zip
if [ $? -ne 0 ]; then
    echo "EdiZon download\033[31m failed\033[0m."
else
    echo "EdiZon download\033[32m success\033[0m."
    unzip -oq EdiZon.zip
    rm EdiZon.zip
fi

### Fetch ovl-sysmodules
curl -sL https://raw.githubusercontent.com/huangqian8/SwitchPlugins/main/plugins/ovl-sysmodules.zip -o ovl-sysmodules.zip
if [ $? -ne 0 ]; then
    echo "ovl-sysmodules download\033[31m failed\033[0m."
else
    echo "ovl-sysmodules download\033[32m success\033[0m."
    unzip -oq ovl-sysmodules.zip
    rm ovl-sysmodules.zip
fi

### Fetch StatusMonitor
curl -sL https://raw.githubusercontent.com/huangqian8/SwitchPlugins/main/plugins/StatusMonitor.zip -o StatusMonitor.zip
if [ $? -ne 0 ]; then
    echo "StatusMonitor download\033[31m failed\033[0m."
else
    echo "StatusMonitor download\033[32m success\033[0m."
    unzip -oq StatusMonitor.zip
    rm StatusMonitor.zip
fi

### Fetch sys-clk
curl -sL https://raw.githubusercontent.com/huangqian8/SwitchPlugins/main/plugins/sys-clk.zip -o sys-clk.zip
if [ $? -ne 0 ]; then
    echo "sys-clk download\033[31m failed\033[0m."
else
    echo "sys-clk download\033[32m success\033[0m."
    unzip -oq sys-clk.zip
    rm sys-clk.zip
fi

### Fetch ReverseNX-RT
curl -sL https://raw.githubusercontent.com/huangqian8/SwitchPlugins/main/plugins/ReverseNX-RT.zip -o ReverseNX-RT.zip
if [ $? -ne 0 ]; then
    echo "ReverseNX-RT download\033[31m failed\033[0m."
else
    echo "ReverseNX-RT download\033[32m success\033[0m."
    unzip -oq ReverseNX-RT.zip
    rm ReverseNX-RT.zip
fi

### Fetch ldn_mitm
curl -sL https://raw.githubusercontent.com/huangqian8/SwitchPlugins/main/plugins/ldn_mitm.zip -o ldn_mitm.zip
if [ $? -ne 0 ]; then
    echo "ldn_mitm download\033[31m failed\033[0m."
else
    echo "ldn_mitm download\033[32m success\033[0m."
    unzip -oq ldn_mitm.zip
    rm ldn_mitm.zip
fi

### Fetch emuiibo
curl -sL https://raw.githubusercontent.com/huangqian8/SwitchPlugins/main/plugins/emuiibo.zip -o emuiibo.zip
if [ $? -ne 0 ]; then
    echo "emuiibo download\033[31m failed\033[0m."
else
    echo "emuiibo download\033[32m success\033[0m."
    unzip -oq emuiibo.zip
    rm emuiibo.zip
fi

### Fetch QuickNTP
curl -sL https://raw.githubusercontent.com/huangqian8/SwitchPlugins/main/plugins/QuickNTP.zip -o QuickNTP.zip
if [ $? -ne 0 ]; then
    echo "QuickNTP download\033[31m failed\033[0m."
else
    echo "QuickNTP download\033[32m success\033[0m."
    unzip -oq QuickNTP.zip
    rm QuickNTP.zip
fi

### Fetch Fizeau
curl -sL https://raw.githubusercontent.com/huangqian8/SwitchPlugins/main/plugins/Fizeau.zip -o Fizeau.zip
if [ $? -ne 0 ]; then
    echo "Fizeau download\033[31m failed\033[0m."
else
    echo "Fizeau download\033[32m success\033[0m."
    unzip -oq Fizeau.zip
    rm Fizeau.zip
fi

### Fetch Zing
curl -sL https://raw.githubusercontent.com/huangqian8/SwitchPlugins/main/plugins/Zing.zip -o Zing.zip
if [ $? -ne 0 ]; then
    echo "Zing download\033[31m failed\033[0m."
else
    echo "Zing download\033[32m success\033[0m."
    unzip -oq Zing.zip
    rm Zing.zip
fi

### Fetch sys-tune
curl -sL https://raw.githubusercontent.com/huangqian8/SwitchPlugins/main/plugins/sys-tune.zip -o sys-tune.zip
if [ $? -ne 0 ]; then
    echo "sys-tune download\033[31m failed\033[0m."
else
    echo "sys-tune download\033[32m success\033[0m."
    unzip -oq sys-tune.zip
    rm sys-tune.zip
fi

### Fetch sys-patch
curl -sL https://raw.githubusercontent.com/huangqian8/SwitchPlugins/main/plugins/sys-patch.zip -o sys-patch.zip
if [ $? -ne 0 ]; then
    echo "sys-patch download\033[31m failed\033[0m."
else
    echo "sys-patch download\033[32m success\033[0m."
    unzip -oq sys-patch.zip
    rm sys-patch.zip
fi

### 
cat >> ../description.txt << ENDOFFILE
nx-ovlloader
Tesla-Menu
EdiZon
ovl-sysmodules
StatusMonitor
sys-clk
ReverseNX-RT
ldn_mitm
emuiibo
QuickNTP
Fizeau
Zing
sys-tune
sys-patch
ENDOFFILE

### Rename hekate_ctcaer_*.bin to payload.bin
find . -name "*hekate_ctcaer*" -exec mv {} payload.bin \;
if [ $? -ne 0 ]; then
    echo "Rename hekate_ctcaer_*.bin to payload.bin\033[31m failed\033[0m."
else
    echo "Rename hekate_ctcaer_*.bin to payload.bin\033[32m success\033[0m."
fi

### Write hekate_ipl.ini in /bootloader/
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
; 控制真实系统启用隐身模式。
blank_prodinfo_sysmmc=1
; 控制虚拟系统启用隐身模式。
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

### Write emummc.txt & sysmmc.txt in /atmosphere/hosts
cat > ./atmosphere/hosts/emummc.txt << ENDOFFILE
# 屏蔽任天堂服务器
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

### Write override_config.ini in /atmosphere/config
cat > ./atmosphere/config/override_config.ini << ENDOFFILE
[hbl_config] 
program_id_0=010000000000100D
override_address_space=39_bit
; 按住R键点击相册进入HBL自制软件界面。
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
; 开启USB3.0，尾数改为0是关闭
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

### Delete unneeded files
rm -f switch/haze.nro
rm -f switch/reboot_to_hekate.nro
rm -f switch/reboot_to_payload.nro

# -------------------------------------------

echo ""
echo "\033[32mYour Switch SD card is prepared!\033[0m"