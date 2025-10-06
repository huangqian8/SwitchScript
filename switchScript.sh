#!/bin/sh
set -e

### Credit to the Authors at https://rentry.org/CFWGuides
### Script created by Fraxalotl
### Mod by huangqian8

# -------------------------------------------

### Create a few new folders for storing files
if [ -d SwitchSD ]; then
  rm -rf SwitchSD
fi
if [ -e description.txt ]; then
  rm -rf description.txt
fi
mkdir -p ./SwitchSD/atmosphere/config
mkdir -p ./SwitchSD/atmosphere/hosts
mkdir -p ./SwitchSD/atmosphere/contents/420000000007E51Anx-ovlloader
mkdir -p ./SwitchSD/atmosphere/contents/0000000000534C56ReverseNX-RT
mkdir -p ./SwitchSD/atmosphere/contents/4200000000000010ldn_mitm
mkdir -p ./SwitchSD/atmosphere/contents/0100000000000352emuiibo
mkdir -p ./SwitchSD/atmosphere/contents/0100000000000F12Fizeau
mkdir -p ./SwitchSD/atmosphere/contents/4200000000000000sys-tune
mkdir -p ./SwitchSD/atmosphere/contents/420000000000000Bsys-patch
mkdir -p ./SwitchSD/atmosphere/contents/010000000000bd00MissionControl
mkdir -p ./SwitchSD/atmosphere/contents/00FF0000636C6BFFsys-clk
mkdir -p ./SwitchSD/atmosphere/kips
mkdir -p ./SwitchSD/bootloader/payloads
mkdir -p ./SwitchSD/config/ultrahand/lang
mkdir -p ./SwitchSD/switch/Switch_90DNS_tester
mkdir -p ./SwitchSD/switch/DBI
mkdir -p ./SwitchSD/switch/NX-Shell
mkdir -p ./SwitchSD/switch/HB-App-Store
mkdir -p ./SwitchSD/switch/HekateToolbox
mkdir -p ./SwitchSD/switch/JKSV
mkdir -p ./SwitchSD/switch/Moonlight
mkdir -p ./SwitchSD/switch/NXThemesInstaller
mkdir -p ./SwitchSD/switch/SimpleModDownloader
mkdir -p ./SwitchSD/switch/Switchfin
mkdir -p ./SwitchSD/switch/tencent-switcher-gui
mkdir -p ./SwitchSD/switch/wiliwili
mkdir -p ./SwitchSD/switch/NX-Activity-Log
mkdir -p ./SwitchSD/switch/.overlays
mkdir -p ./SwitchSD/switch/.packages

cd SwitchSD

latest_release_info=$(curl -sL https://api.github.com/repos/Atmosphere-NX/Atmosphere/releases/latest)
download_url=$(echo "$latest_release_info" | grep -oP '"browser_download_url": "\Khttps://[^"]*atmosphere[^"]*.zip' | sed 's/"//g')
curl -sL "$download_url" -o atmosphere.zip && {
    echo "atmosphere download\033[32m success\033[0m."
    unzip -oq atmosphere.zip
    rm atmosphere.zip
} || echo "atmosphere download\033[31m failed\033[0m."
download_url=$(echo "$latest_release_info" | grep -oP '"browser_download_url": "\Khttps://[^"]*fusee.bin' | sed 's/"//g')
curl -sL "$download_url" -o fusee.bin && {
    echo "fusee download\033[32m success\033[0m."
    mv fusee.bin ./bootloader/payloads
} || echo "fusee download\033[31m failed\033[0m."

latest_release_info=$(curl -sL https://api.github.com/repos/easyworld/hekate/releases/latest)
download_url=$(echo "$latest_release_info" | grep -oP '"browser_download_url": "\Khttps://[^"]*hekate_ctcaer[^"]*_sc.zip' | sed 's/"//g')
curl -sL "$download_url" -o hekate.zip && {
    echo "Hekate + Nyx CHS download\033[32m success\033[0m."
    unzip -oq hekate.zip
    rm hekate.zip
} || echo "Hekate + Nyx CHS download\033[31m failed\033[0m."

### Fetch Sigpatches from https://gbatemp.net/threads/sigpatches-for-atmosphere-hekate-fss0-fusee-package3.571543/
curl -sL https://raw.githubusercontent.com/huangqian8/SwitchPlugins/main/plugins/sigpatches.zip -o sigpatches.zip
if [ $? -ne 0 ]; then
    echo "sigpatches download\033[31m failed\033[0m."
else
    echo "sigpatches download\033[32m success\033[0m."
    unzip -oq sigpatches.zip
    rm sigpatches.zip
fi

curl -sL https://raw.githubusercontent.com/huangqian8/SwitchPlugins/main/theme/logo.zip -o logo.zip
if [ $? -ne 0 ]; then
    echo "logo download\033[31m failed\033[0m."
else
    echo "logo download\033[32m success\033[0m."
    unzip -oq logo.zip
    rm logo.zip
fi

latest_release_info=$(curl -sL https://api.github.com/repos/zdm65477730/Lockpick_RCMDecScots/releases/latest)
download_url=$(echo "$latest_release_info" | grep -oP '"browser_download_url": "\Khttps://[^"]*Lockpick_RCM.bin' | sed 's/"//g')
curl -sL "$download_url" -o Lockpick_RCM.bin && {
    echo "Lockpick_RCM download\033[32m success\033[0m."
    mv Lockpick_RCM.bin ./bootloader/payloads
} || echo "Lockpick_RCM download\033[31m failed\033[0m."

latest_release_info=$(curl -sL https://api.github.com/repos/zdm65477730/TegraExplorer/releases/latest)
download_url=$(echo "$latest_release_info" | grep -oP '"browser_download_url": "\Khttps://[^"]*TegraExplorer.bin' | sed 's/"//g')
curl -sL "$download_url" -o TegraExplorer.bin && {
    echo "TegraExplorer download\033[32m success\033[0m."
    mv TegraExplorer.bin ./bootloader/payloads
} || echo "TegraExplorer download\033[31m failed\033[0m."

latest_release_info=$(curl -sL https://api.github.com/repos/zdm65477730/CommonProblemResolver/releases/latest)
download_url=$(echo "$latest_release_info" | grep -oP '"browser_download_url": "\Khttps://[^"]*CommonProblemResolver.bin' | sed 's/"//g')
curl -sL "$download_url" -o CommonProblemResolver.bin && {
    echo "CommonProblemResolver download\033[32m success\033[0m."
    mv CommonProblemResolver.bin ./bootloader/payloads
} || echo "CommonProblemResolver download\033[31m failed\033[0m."

latest_release_info=$(curl -sL https://api.github.com/repos/meganukebmp/Switch_90DNS_tester/releases/latest)
download_url=$(echo "$latest_release_info" | grep -oP '"browser_download_url": "\Khttps://[^"]*Switch_90DNS_tester.nro' | sed 's/"//g')
curl -sL "$download_url" -o Switch_90DNS_tester.nro && {
    echo "Switch_90DNS_tester download\033[32m success\033[0m."
    mv Switch_90DNS_tester.nro ./switch/Switch_90DNS_tester
} || echo "Switch_90DNS_tester download\033[31m failed\033[0m."

latest_release_info=$(curl -sL https://api.github.com/repos/rashevskyv/dbi/releases/135856657)
download_url=$(echo "$latest_release_info" | grep -oP '"browser_download_url": "\Khttps://[^"]*DBI.nro' | sed 's/"//g')
curl -sL "$download_url" -o DBI.nro && {
    echo "DBI download\033[32m success\033[0m."
    mv DBI.nro ./switch/DBI
} || echo "DBI download\033[31m failed\033[0m."

latest_release_info=$(curl -sL https://api.github.com/repos/dragonflylee/Awoo-Installer/releases/latest)
download_url=$(echo "$latest_release_info" | grep -oP '"browser_download_url": "\Khttps://[^"]*Awoo-Installer.zip' | sed 's/"//g')
curl -sL "$download_url" -o Awoo-Installer.zip && {
    echo "Awoo Installer download\033[32m success\033[0m."
    unzip -oq Awoo-Installer.zip
    rm Awoo-Installer.zip
} || echo "Awoo Installer download\033[31m failed\033[0m."

latest_release_info=$(curl -sL https://api.github.com/repos/WerWolv/Hekate-Toolbox/releases/latest)
download_url=$(echo "$latest_release_info" | grep -oP '"browser_download_url": "\Khttps://[^"]*HekateToolbox.nro' | sed 's/"//g')
curl -sL "$download_url" -o HekateToolbox.nro && {
    echo "HekateToolbox download\033[32m success\033[0m."
    mv HekateToolbox.nro ./switch/HekateToolbox
} || echo "HekateToolbox download\033[31m failed\033[0m."

latest_release_info=$(curl -sL https://api.github.com/repos/zdm65477730/NX-Activity-Log/releases/latest)
download_url=$(echo "$latest_release_info" | grep -oP '"browser_download_url": "\Khttps://[^"]*NX-Activity-Log.nro' | sed 's/"//g')
curl -sL "$download_url" -o NX-Activity-Log.nro && {
    echo "NX-Activity-Log download\033[32m success\033[0m."
    mv NX-Activity-Log.nro ./switch/NX-Activity-Log
} || echo "NX-Activity-Log download\033[31m failed\033[0m."

latest_release_info=$(curl -sL https://api.github.com/repos/exelix11/SwitchThemeInjector/releases/latest)
download_url=$(echo "$latest_release_info" | grep -oP '"browser_download_url": "\Khttps://[^"]*NXThemesInstaller.nro' | sed 's/"//g')
curl -sL "$download_url" -o NXThemesInstaller.nro && {
    echo "NXThemesInstaller download\033[32m success\033[0m."
    mv NXThemesInstaller.nro ./switch/NXThemesInstaller
} || echo "NXThemesInstaller download\033[31m failed\033[0m."

latest_release_info=$(curl -sL https://api.github.com/repos/J-D-K/JKSV/releases/latest)
download_url=$(echo "$latest_release_info" | grep -oP '"browser_download_url": "\Khttps://[^"]*JKSV.nro' | sed 's/"//g')
curl -sL "$download_url" -o JKSV.nro && {
    echo "JKSV download\033[32m success\033[0m."
    mv JKSV.nro ./switch/JKSV
} || echo "JKSV download\033[31m failed\033[0m."

latest_release_info=$(curl -sL https://api.github.com/repos/CaiMiao/Tencent-switcher-GUI/releases/latest)
download_url=$(echo "$latest_release_info" | grep -oP '"browser_download_url": "\Khttps://[^"]*tencent-switcher-gui.nro' | sed 's/"//g')
curl -sL "$download_url" -o tencent-switcher-gui.nro && {
    echo "Tencent-switcher-GUI download\033[32m success\033[0m."
    mv tencent-switcher-gui.nro ./switch/tencent-switcher-gui
} || echo "Tencent-switcher-GUI download\033[31m failed\033[0m."

latest_release_info=$(curl -sL https://api.github.com/repos/HamletDuFromage/aio-switch-updater/releases/latest)
download_url=$(echo "$latest_release_info" | grep -oP '"browser_download_url": "\Khttps://[^"]*aio-switch-updater.zip' | sed 's/"//g')
curl -sL "$download_url" -o aio-switch-updater.zip && {
    echo "aio-switch-updater download\033[32m success\033[0m."
    unzip -oq aio-switch-updater.zip
    rm aio-switch-updater.zip
} || echo "aio-switch-updater download\033[31m failed\033[0m."

latest_release_info=$(curl -sL https://api.github.com/repos/xfangfang/wiliwili/releases/latest)
download_url=$(echo "$latest_release_info" | grep -oP '"browser_download_url": "\Khttps://[^"]*wiliwili-NintendoSwitch.zip' | sed 's/"//g')
curl -sL "$download_url" -o wiliwili-NintendoSwitch.zip && {
    echo "wiliwili download\033[32m success\033[0m."
    unzip -oq wiliwili-NintendoSwitch.zip
    mv wiliwili/wiliwili.nro ./switch/wiliwili
    rm -rf wiliwili
    rm wiliwili-NintendoSwitch.zip
} || echo "wiliwili download\033[31m failed\033[0m."

latest_release_info=$(curl -sL https://api.github.com/repos/PoloNX/SimpleModDownloader/releases/latest)
download_url=$(echo "$latest_release_info" | grep -oP '"browser_download_url": "\Khttps://[^"]*SimpleModDownloader.nro' | sed 's/"//g')
curl -sL "$download_url" -o SimpleModDownloader.nro && {
    echo "SimpleModDownloader download\033[32m success\033[0m."
    mv SimpleModDownloader.nro ./switch/SimpleModDownloader
} || echo "SimpleModDownloader download\033[31m failed\033[0m."

latest_release_info=$(curl -sL https://api.github.com/repos/dragonflylee/switchfin/releases/latest)
download_url=$(echo "$latest_release_info" | grep -oP '"browser_download_url": "\Khttps://[^"]*Switchfin.nro' | sed 's/"//g')
curl -sL "$download_url" -o Switchfin.nro&& {
    echo "Switchfin download\033[32m success\033[0m."
    mv Switchfin.nro ./switch/Switchfin
} || echo "Switchfin download\033[31m failed\033[0m."

latest_release_info=$(curl -sL https://api.github.com/repos/XITRIX/Moonlight-Switch/releases/latest)
download_url=$(echo "$latest_release_info" | grep -oP '"browser_download_url": "\Khttps://[^"]*Moonlight-Switch.nro' | sed 's/"//g')
curl -sL "$download_url" -o Moonlight-Switch.nro&& {
    echo "Moonlight download\033[32m success\033[0m."
    mv Moonlight-Switch.nro ./switch/Moonlight
} || echo "Moonlight download\033[31m failed\033[0m."

latest_release_info=$(curl -sL https://api.github.com/repos/zdm65477730/NX-Shell/releases/latest)
download_url=$(echo "$latest_release_info" | grep -oP '"browser_download_url": "\Khttps://[^"]*NX-Shell.nro' | sed 's/"//g')
curl -sL "$download_url" -o NX-Shell.nro&& {
    echo "NX-Shell download\033[32m success\033[0m."
    mv NX-Shell.nro ./switch/NX-Shell
} || echo "NX-Shell download\033[31m failed\033[0m."

latest_release_info=$(curl -sL https://api.github.com/repos/fortheusers/hb-appstore/releases/latest)
download_url=$(echo "$latest_release_info" | grep -oP '"browser_download_url": "\Khttps://[^"]*appstore.nro' | sed 's/"//g')
curl -sL "$download_url" -o appstore.nro&& {
    echo "hb-appstore download\033[32m success\033[0m."
    mv appstore.nro ./switch/HB-App-Store
} || echo "hb-appstore download\033[31m failed\033[0m."

curl -sL https://raw.githubusercontent.com/huangqian8/SwitchPlugins/main/plugins/daybreak_x.zip -o daybreak_x.zip
if [ $? -ne 0 ]; then
    echo "daybreak download\033[31m failed\033[0m."
else
    echo "daybreak download\033[32m success\033[0m."
    unzip -oq daybreak_x.zip
    rm daybreak_x.zip
fi

git clone https://github.com/exelix11/theme-patches
if [ $? -ne 0 ]; then
    echo "theme-patches download\033[31m failed\033[0m."
else
    echo "theme-patches download\033[32m success\033[0m."
    mkdir themes
    mv -f theme-patches/systemPatches ./themes/
    rm -rf theme-patches
fi

latest_release_info=$(curl -sL https://api.github.com/repos/zdm65477730/nx-ovlloader/releases/latest)
download_url=$(echo "$latest_release_info" | grep -oP '"browser_download_url": "\Khttps://[^"]*nx-ovlloader.zip' | sed 's/"//g')
curl -sL "$download_url" -o nx-ovlloader.zip&& {
    echo "nx-ovlloader download\033[32m success\033[0m."
    unzip -oq nx-ovlloader.zip
    rm nx-ovlloader.zip
} || echo "nx-ovlloader download\033[31m failed\033[0m."

latest_release_info=$(curl -sL https://api.github.com/repos/zdm65477730/Ultrahand-Overlay/releases/latest)
download_url=$(echo "$latest_release_info" | grep -oP '"browser_download_url": "\Khttps://[^"]*Ultrahand.zip' | sed 's/"//g')
curl -sL "$download_url" -o Ultrahand.zip&& {
    echo "Ultrahand-Overlay download\033[32m success\033[0m."
    unzip -oq Ultrahand.zip
    rm Ultrahand.zip
} || echo "Ultrahand-Overlay download\033[31m failed\033[0m."

latest_release_info=$(curl -sL https://api.github.com/repos/zdm65477730/EdiZon-Overlay/releases/latest)
download_url=$(echo "$latest_release_info" | grep -oP '"browser_download_url": "\Khttps://[^"]*EdiZon.zip' | sed 's/"//g')
curl -sL "$download_url" -o EdiZon.zip&& {
    echo "EdiZon download\033[32m success\033[0m."
    unzip -oq EdiZon.zip
    rm EdiZon.zip
} || echo "EdiZon download\033[31m failed\033[0m."

latest_release_info=$(curl -sL https://api.github.com/repos/zdm65477730/ovl-sysmodules/releases/latest)
download_url=$(echo "$latest_release_info" | grep -oP '"browser_download_url": "\Khttps://[^"]*ovl-sysmodules.zip' | sed 's/"//g')
curl -sL "$download_url" -o ovl-sysmodules.zip&& {
    echo "ovl-sysmodules download\033[32m success\033[0m."
    unzip -oq ovl-sysmodules.zip
    rm ovl-sysmodules.zip
} || echo "ovl-sysmodules download\033[31m failed\033[0m."

latest_release_info=$(curl -sL https://api.github.com/repos/zdm65477730/Status-Monitor-Overlay/releases/latest)
download_url=$(echo "$latest_release_info" | grep -oP '"browser_download_url": "\Khttps://[^"]*StatusMonitor.zip' | sed 's/"//g')
curl -sL "$download_url" -o StatusMonitor.zip&& {
    echo "StatusMonitor download\033[32m success\033[0m."
    unzip -oq StatusMonitor.zip
    rm StatusMonitor.zip
} || echo "StatusMonitor download\033[31m failed\033[0m."

latest_release_info=$(curl -sL https://api.github.com/repos/zdm65477730/ReverseNX-RT/releases/latest)
download_url=$(echo "$latest_release_info" | grep -oP '"browser_download_url": "\Khttps://[^"]*ReverseNX-RT.zip' | sed 's/"//g')
curl -sL "$download_url" -o ReverseNX-RT.zip&& {
    echo "ReverseNX-RT download\033[32m success\033[0m."
    unzip -oq ReverseNX-RT.zip
    rm ReverseNX-RT.zip
} || echo "ReverseNX-RT download\033[31m failed\033[0m."

latest_release_info=$(curl -sL https://api.github.com/repos/zdm65477730/ldn_mitm/releases/latest)
download_url=$(echo "$latest_release_info" | grep -oP '"browser_download_url": "\Khttps://[^"]*ldn_mitm.zip' | sed 's/"//g')
curl -sL "$download_url" -o ldn_mitm.zip&& {
    echo "ldn_mitm download\033[32m success\033[0m."
    unzip -oq ldn_mitm.zip
    rm ldn_mitm.zip
} || echo "ldn_mitm download\033[31m failed\033[0m."

latest_release_info=$(curl -sL https://api.github.com/repos/zdm65477730/emuiibo/releases/latest)
download_url=$(echo "$latest_release_info" | grep -oP '"browser_download_url": "\Khttps://[^"]*emuiibo.zip' | sed 's/"//g')
curl -sL "$download_url" -o emuiibo.zip&& {
    echo "emuiibo download\033[32m success\033[0m."
    unzip -oq emuiibo.zip
    rm emuiibo.zip
} || echo "emuiibo download\033[31m failed\033[0m."

latest_release_info=$(curl -sL https://api.github.com/repos/zdm65477730/QuickNTP/releases/latest)
download_url=$(echo "$latest_release_info" | grep -oP '"browser_download_url": "\Khttps://[^"]*QuickNTP.zip' | sed 's/"//g')
curl -sL "$download_url" -o QuickNTP.zip&& {
    echo "QuickNTP download\033[32m success\033[0m."
    unzip -oq QuickNTP.zip
    rm QuickNTP.zip
} || echo "QuickNTP download\033[31m failed\033[0m."

latest_release_info=$(curl -sL https://api.github.com/repos/zdm65477730/Fizeau/releases/latest)
download_url=$(echo "$latest_release_info" | grep -oP '"browser_download_url": "\Khttps://[^"]*Fizeau.zip' | sed 's/"//g')
curl -sL "$download_url" -o Fizeau.zip&& {
    echo "Fizeau download\033[32m success\033[0m."
    unzip -oq Fizeau.zip
    rm Fizeau.zip
} || echo "Fizeau download\033[31m failed\033[0m."

curl -sL https://raw.githubusercontent.com/huangqian8/SwitchPlugins/main/plugins/Zing.zip -o Zing.zip
if [ $? -ne 0 ]; then
    echo "Zing download\033[31m failed\033[0m."
else
    echo "Zing download\033[32m success\033[0m."
    unzip -oq Zing.zip
    rm Zing.zip
fi

latest_release_info=$(curl -sL https://api.github.com/repos/HookedBehemoth/sys-tune/releases/latest)
download_url=$(echo "$latest_release_info" | grep -oP '"browser_download_url": "\Khttps://[^"]*sys-tune[^"]*.zip' | sed 's/"//g')
curl -sL "$download_url" -o sys-tune.zip&& {
    echo "sys-tune download\033[32m success\033[0m."
    unzip -oq sys-tune.zip
    rm sys-tune.zip
} || echo "sys-tune download\033[31m failed\033[0m."

latest_release_info=$(curl -sL https://api.github.com/repos/zdm65477730/sys-patch/releases/latest)
download_url=$(echo "$latest_release_info" | grep -oP '"browser_download_url": "\Khttps://[^"]*sys-patch.zip' | sed 's/"//g')
curl -sL "$download_url" -o sys-patch.zip&& {
    echo "sys-patch download\033[32m success\033[0m."
     unzip -oq sys-patch.zip
    rm sys-patch.zip
} || echo "sys-patch download\033[31m failed\033[0m."

latest_release_info=$(curl -sL https://api.github.com/repos/zdm65477730/sys-clk/releases/latest)
download_url=$(echo "$latest_release_info" | grep -oP '"browser_download_url": "\Khttps://[^"]*sys-clk[^"]*.zip' | sed 's/"//g')
curl -sL "$download_url" -o sys-clk.zip&& {
    echo "sys-clk download\033[32m success\033[0m."
    unzip -oq sys-clk.zip
    rm sys-clk.zip
} || echo "sys-clk download\033[31m failed\033[0m."

latest_release_info=$(curl -sL https://api.github.com/repos/halop/OC_Toolkit_SC_EOS/releases/latest)
download_url_1=$(echo "$latest_release_info" | grep -oP '"browser_download_url": "\Khttps://[^"]*kip.zip' | sed 's/"//g')
download_url_2=$(echo "$latest_release_info" | grep -oP '"browser_download_url": "\Khttps://[^"]*OC.Toolkit.u.zip' | sed 's/"//g')
curl -sL "$download_url_1" -o kip.zip&&curl -sL "$download_url_2" -o OC.Toolkit.u.zip&& {
    echo "OC_Toolkit_SC_EOS download\033[32m success\033[0m."
    unzip -oq kip.zip -d ./atmosphere/kips/
    unzip -oq OC.Toolkit.u.zip -d ./switch/.packages/
    rm kip.zip
    rm OC.Toolkit.u.zip
} || echo "OC_Toolkit_SC_EOS download\033[31m failed\033[0m."

latest_release_info=$(curl -sL https://api.github.com/repos/ndeadly/MissionControl/releases/latest)
download_url=$(echo "$latest_release_info" | grep -oP '"browser_download_url": "\Khttps://[^"]*MissionControl[^"]*.zip' | sed 's/"//g')
curl -sL "$download_url" -o MissionControl.zip&& {
    echo "MissionControl download\033[32m success\033[0m."
    unzip -oq MissionControl.zip
    rm MissionControl.zip
} || echo "MissionControl download\033[31m failed\033[0m."

cat >> ../description.txt << ENDOFFILE
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
Zing
sys-tune
sys-patch
sys-clk
OC_Toolkit_SC_EOS
MissionControl
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
ENDOFFILE
if [ $? -ne 0 ]; then
    echo "Writing system_settings.ini in ./atmosphere/config\033[31m failed\033[0m."
else
    echo "Writing system_settings.ini in ./atmosphere/config\033[32m success\033[0m."
fi

### Delete unneeded files
rm -f switch/haze.nro
rm -f switch/reboot_to_payload.nro
rm -f switch/daybreak.nro

# -------------------------------------------

echo ""
echo "\033[32mYour Switch SD card is prepared!\033[0m"