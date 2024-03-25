#!/usr/bin/env bash
#
# Copyright (C) 2024 PeterKnecht93
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

# [
bold='\e[1m'
italic='\e[3m'

end='\e[0m'
red='\e[91m'
green='\e[92m'
blue='\e[94m'
yellow='\e[93m'
# ]

if [[ $# == 0 ]]; then
    echo -ne "${green}Enter package name (Samsung apps only): ${end}"
    read -r "PACKAGE"

    echo -ne "${green}Enter your device model (${yellow}SM-XXXXX${green} format): ${end}"
    read -r "MODEL"

    echo -ne "${green}Enter your android version (SDK format - ${yellow}19 30 34${green} etc.): ${end}"
    read -r "SDK"

    echo ""
elif [[ $# == 3 ]]; then
    PACKAGE=$1
    MODEL=$2
    SDK=$3
else
    echo -e "${italic}Usage: $0 <package> <model> <sdk> ${end} or"
    echo -e "${italic}Usage: $0 ${end} for inputting details manually \n"
    echo -e "${bold}package:${end} Package Name 'com.package.name'"
    echo -e "${bold}model:${end} Model Number 'SM-XXXXX'"
    echo -e "${bold}sdk:${end} SDK Level (19-34)"
    echo ""
    exit 1
fi

URL_FORMAT="https://vas.samsungapps.com/stub/stubDownload.as?appId=${PACKAGE}&deviceId=${MODEL}\
&mcc=425&mnc=01&csc=ILO&sdkVer=${SDK}&pd=0&systemId=1608665720954&callerId=com.sec.android.app.samsungapps\
&abiType=64&extuk=0191d6627f38685f"
URL=$(curl -s "$URL_FORMAT")

MATCH=(
    "$(echo "$URL" | grep -w "resultCode" | sed "s/<resultCode>//; s/<\/resultCode>//")"
    "$(echo "$URL" | grep -w "resultMsg" | sed "s/<resultMsg>//; s/<\/resultMsg>//")"
    "$(echo "$URL" | grep -Po '(?<=<downloadURI><!\[CDATA\[).*(?=\]\]></downloadURI>)')"
    "$(echo "$URL" | sed -n 's/.*<versionCode>\([0-9]\+\)<\/versionCode>.*/\1/p')"
    "$(echo "$URL" | grep -w "versionName" | sed "s/<versionName>//; s/<\/versionName>//")"
)

for match in "${MATCH[@]}"; do
    if [[ -z $match ]]; then
        error_msg=$(grep -oP 'resultMsg>\K.*?(?=<\/resultMsg>)' <<< "$URL")

        if [[ -n $error_msg ]]; then
            echo -e "${blue}Samsung Servers: ${red}$error_msg${end}"
        else
            echo -e "${red}No result!${end}"
        fi
        exit 1
    fi
done

echo -e "${blue}The available versionCode is: ${yellow}${MATCH[3]}${end}"
echo -e "${blue}The available versionName is: ${yellow}${MATCH[4]}${end}"
echo ""

echo -ne "${blue}Do you want to download the APK? ${yellow}[Y/n]: ${end}"
read -r "input"
echo ""

case "$input" in
"Y" | "y" | "")
    APK="${PACKAGE}-${MATCH[3]}.apk"

    echo -e "${blue}Download started!...${end}"
    wget -O "$APK" "${MATCH[2]}" &> /dev/null
    echo -e "${blue}APK saved: ${yellow}\"$PWD/$APK\"${end}"
    ;;
esac

echo ""