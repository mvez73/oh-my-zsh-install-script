#!/bin/sh

# Color variables
RED=$(echo -en '\033[00;31m')
GREEN=$(echo -en '\033[00;32m')
YELLOW=$(echo -en '\033[00;33m')
BLUE=$(echo -en '\033[00;34m')
MAGENTA=$(echo -en '\033[00;35m')
PURPLE=$(echo -en '\033[00;35m')
CYAN=$(echo -en '\033[00;36m')
LIGHTGRAY=$(echo -en '\033[00;37m')
LRED=$(echo -en '\033[01;31m')
LGREEN=$(echo -en '\033[01;32m')
LYELLOW=$(echo -en '\033[01;33m')
LBLUE=$(echo -en '\033[01;34m')
LMAGENTA=$(echo -en '\033[01;35m')
LPURPLE=$(echo -en '\033[01;35m')
LCYAN=$(echo -en '\033[01;36m')
WHITE=$(echo -en '\033[01;37m')
# Clear the color after that
RESTORE=$(echo -en '\033[0m')

# Check if git is installed
if [ $(dpkg-query -W -f='${Status}' git 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  read -p "Do you want to proceed? $GREEN(y)Yes$RESTORE/$RED(n)No$RESTORE " yn;
  case $yn in
  [yY][eE][sS]|[yY] ) echo $GREEN"Installing git"$RESTORE; sleep 2; sudo apt install -y git;;
  [nN][oO]|[nN] ) echo $RED"Aborting..."$RESTORE; exit 1 ;;
  *) exit ;;
  esac
fi

echo $GREEN"Installing zsh"$RESTORE
sudo apt install zsh -y
echo $GREEN"zsh is now installed"$RESTORE
sleep 2

echo $GREEN"Installing oh-my-zsh"$RESTORE
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
sleep 2

echo $GREEN"Modifying .zshrc to use powerlevel10k and add new plugins"$RESTORE
sed -i 's+ZSH_THEME="robbyrussell"+ZSH_THEME="powerlevel10k/powerlevel10k"+' .zshrc
sed -i 's+plugins=(git)+plugins=(git zsh-autosuggestions zsh-syntax-highlighting you-should-use)+' .zshrc
sleep 2

echo $GREEN"Continuing with theme and plugins"$RESTORE
sleep 2

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
echo $GREEN"Theme powerlevel10k installed"$RESTORE
sleep 1
git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
echo $GREEN"Plugin zsh-autosuggestions installed"$RESTORE
sleep 1
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
echo $GREEN"Plugin zsh-syntax-highlighting installed"$RESTORE
sleep 1
git clone https://github.com/MichaelAquilina/zsh-you-should-use.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/you-should-use
echo $GREEN"Plugin you-should-use installed"$RESTORE
sleep 1

echo $GREEN"Changing your default shell to zsh"$RESTORE
sudo chsh -s $(which zsh) $(whoami)

exec zsh
# From here the powerlevel10k config should launch
