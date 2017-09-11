#!/usr/bin/env bash

set -e

# Color codes
# ----------------------------------------
# Black        0;30     Dark Gray     1;30
# Red          0;31     Light Red     1;31
# Green        0;32     Light Green   1;32
# Brown/Orange 0;33     Yellow        1;33
# Blue         0;34     Light Blue    1;34
# Purple       0;35     Light Purple  1;35
# Cyan         0;36     Light Cyan    1;36
# Light Gray   0;37     White         1;37
# ----------------------------------------

GREEN='\033[0;32m'
ORANGE='\033[0;33m'
NC='\033[0m' # No Color

CASKS=('java' 'google-chrome' 'google-drive' 'google-hangouts' 'opera' 'vlc' 'jdownloader' 'evernote' 'iterm2' 'sublime-text' 'skype' 'whatsapp' 'mkvtools' 'kodi' 'deluge' 'android-platform-tools' 'macpass');
FORMULAS=('awscli' 'git' 'zsh' 'zsh-autosuggestions' 'zsh-completions' 'zsh-git-prompt' 'zsh-history-substring-search' 'zsh-navigation-tools' 'zsh-syntax-highlighting' 'zsh-lovers' 'ansible' 'terraform' 'python3' 'shellcheck' 'dnsmasq' 'ipcalc' 'git' 'bash-completion' 'jq' 'tree')

echo -e "${ORANGE}Updating brew...${NC}"
brew update

for c in "${CASKS[@]}"
do
	if brew cask ls --versions "$c" > /dev/null; then
		echo -e "${GREEN}cask ${c} already installed. $( brew cask ls --versions "$c" )${NC}"
	else
		echo -e "${ORANGE}Installing $c ..${NC}"
		brew cask install "$c"
		echo -e "${GREEN}Done.${NC}"
	fi
done


for f in "${FORMULAS[@]}"
do
	if brew ls --versions "$f" > /dev/null; then
		echo -e "${GREEN}formula $f already installed. $( brew  ls --versions "$f" )${NC}"
	else
		echo -e "${ORANGE}Installing $f ..${NC}"
		brew install "$f"
		echo -e "${GREEN}Done.${NC}"
	fi
done

echo -e "${ORANGE}Setting up pip3..${NC}"
mkdir -p ~/.pip

cat << EOF > ~/.pip/pip.conf
[list]
format=columns
EOF

echo -e "${ORANGE}Installing python modules..${NC}"
pip3 install pep8 boto3 ipython
echo -e "${GREEN}Done.${NC}\n"
pip3 list


# Copy the default configuration file.
cp $(brew list dnsmasq | grep /dnsmasq.conf.example$) /usr/local/etc/dnsmasq.conf
# Copy the daemon configuration file into place.
sudo cp $(brew list dnsmasq | grep /homebrew.mxcl.dnsmasq.plist$) /Library/LaunchDaemons/
# Start Dnsmasq automatically.
sudo launchctl load /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist

echo "address=/jarvis.local.net/192.168.0.102" >> /usr/local/etc/dnsmasq.conf

sudo launchctl stop homebrew.mxcl.dnsmasq
sudo launchctl start homebrew.mxcl.dnsmasq

sudo mkdir -p /etc/resolver/
sudo tee /etc/resolver/jarvis.local.net >/dev/null <<EOF
nameserver 127.0.0.1
EOF
