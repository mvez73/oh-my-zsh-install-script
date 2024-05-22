#/usr/bin/env bash

# Selection menu is from this githubSO: https://gist.github.com/sergiofbsilva/099172ea597657b0d0008dc367946953

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

packageManager=""
if [ -x "$(command -v apk)" ];
then
    packageManager="apk install -y "
elif [ -x "$(command -v apt)" ];
then
    packageManager="apt install -y "
elif [ -x "$(command -v apt-get)" ];
then
    packageManager="apt-get install -y "
elif [ -x "$(command -v dnf)" ];
then
    packageManager="dnf install -y "
elif [ -x "$(command -v yum)" ];
then
    packageManager="yum install -y "
elif [ -x "$(command -v pacman)" ];
then
    packageManager="pacman -S install --noconfirm "
elif [ -x "$(command -v zypper)" ];
then
    packageManager="zypper intall -y "
else
    echo "Package manager not found. Aborting..."; exit 1 ;
fi

# Check if git is installed
if [ $(dpkg-query -W -f='${Status}' git 2>/dev/null | grep -c "ok installed") -eq 0 ];
  then
    read -p "You need git installed to run this script. Do you want to install it? $GREEN(y)Yes$RESTORE/$RED(n)No$RESTORE " yn;
    case $yn in
    [yY][eE][sS]|[yY]) echo $GREEN"Installing git"$RESTORE; sleep 2; sudo $packageManager git;;
    [nN][oO]|[nN]) echo $RED"Aborting..."$RESTORE; exit 1 ;;
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

echo $GREEN"Installing powerlevel10k theme"$RESTORE
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
echo $GREEN"Theme powerlevel10k installed"$RESTORE
sleep 2

echo $GREEN"Modifying .zshrc to use powerlevel10k"$RESTORE
sed -i 's+ZSH_THEME="robbyrussell"+ZSH_THEME="powerlevel10k/powerlevel10k"+' .zshrc
sleep 2

echo $GREEN"Continuing with plugins"$RESTORE
echo $GREEN"Check the plugin(s) you want to install and press ENTER"$RESTORE
sleep 2

function prompt_for_multiselect {

    # little helpers for terminal print control and key input
    ESC=$( printf "\033")
    cursor_blink_on()   { printf "$ESC[?25h"; }
    cursor_blink_off()  { printf "$ESC[?25l"; }
    cursor_to()         { printf "$ESC[$1;${2:-1}H"; }
    print_inactive()    { printf "$2   $1 "; }
    print_active()      { printf "$2  $ESC[7m $1 $ESC[27m"; }
    get_cursor_row()    { IFS=';' read -sdR -p $'\E[6n' ROW COL; echo ${ROW#*[}; }
    key_input()         {
        local key
        IFS= read -rsn1 key 2>/dev/null >&2
        if [[ $key = ""      ]]; then echo enter; fi;
        if [[ $key = $'\x20' ]]; then echo space; fi;
        if [[ $key = $'\x1b' ]]; then
        read -rsn2 key
        if [[ $key = [A ]]; then echo up;    fi;
        if [[ $key = [B ]]; then echo down;  fi;
        fi
    }
    toggle_option()    {
        local arr_name=$1
        eval "local arr=(\"\${${arr_name}[@]}\")"
        local option=$2
        if [[ ${arr[option]} == true ]]; then
        arr[option]=
        else
        arr[option]=true
        fi
        eval $arr_name='("${arr[@]}")'
    }

    local retval=$1
    local options
    local defaults

    IFS=';' read -r -a options <<< "$2"
    if [[ -z $3 ]]; then
        defaults=()
    else
        IFS=';' read -r -a defaults <<< "$3"
    fi
    local selected=()

    for ((i=0; i<${#options[@]}; i++)); do
        selected+=("${defaults[i]:-false}")
        printf "\n"
    done

    # determine current screen position for overwriting the options
    local lastrow=`get_cursor_row`
    local startrow=$(($lastrow - ${#options[@]}))

    # ensure cursor and input echoing back on upon a ctrl+c during read -s
    trap "cursor_blink_on; stty echo; printf '\n'; exit" 2
    cursor_blink_off

    local active=0
    while true; do
        # print options by overwriting the last lines
        local idx=0
        for option in "${options[@]}"; do
            local prefix="[ ]"
            if [[ ${selected[idx]} == true ]]; then
                prefix="[x]"
            fi

            cursor_to $(($startrow + $idx))
            if [ $idx -eq $active ]; then
                print_active "$option" "$prefix"
            else
                print_inactive "$option" "$prefix"
            fi
            ((idx++))
        done

        # user key control
        case `key_input` in
            space)  toggle_option selected $active;;
            enter)  break;;
            up)     ((active--));
                    if [ $active -lt 0 ]; then active=$((${#options[@]} - 1)); fi;;
            down)   ((active++));
                    if [ $active -ge ${#options[@]} ]; then active=0; fi;;
        esac
    done

    # cursor position back to normal
    cursor_to $lastrow
    printf "\n"
    cursor_blink_on

    eval $retval='("${selected[@]}")'
}

# Usage Example

OPTIONS_VALUES=("1" "2" "3" "4" "5")
OPTIONS_LABELS=("zsh-autosuggestions" "zsh-syntax-highlighting" "you-should-use" "copyfile" "sudo")

for i in "${!OPTIONS_VALUES[@]}"; do
	OPTIONS_STRING+="${OPTIONS_VALUES[$i]} (${OPTIONS_LABELS[$i]});"
done

prompt_for_multiselect SELECTED "$OPTIONS_STRING"

for i in "${!SELECTED[@]}"; do
	if [ "${SELECTED[$i]}" == "true" ]; then
		CHECKED+=("${OPTIONS_VALUES[$i]}")
	fi
done

if [[ ${CHECKED[@]} =~ "1" ]]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    sed -i "s+plugins=(git+plugins=(git zsh-autosuggestions+" .zshrc
    echo $GREEN"Plugin zsh-autosuggestions installed"$RESTORE
    sleep 1
fi

if [[ ${CHECKED[@]} =~ "2" ]]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    sed -i "s+plugins=(git+plugins=(git zsh-syntax-highlighting+" .zshrc
    echo $GREEN"Plugin zsh-syntax-highlighting installed"$RESTORE
    sleep 1
fi

if [[ ${CHECKED[@]} =~ "3" ]]; then
    git clone https://github.com/MichaelAquilina/zsh-you-should-use.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/you-should-use
    sed -i "s+plugins=(git+plugins=(git you-should-use+" .zshrc
    echo $GREEN"Plugin you-should-use installed"$RESTORE
    sleep 1
fi

if [[ ${CHECKED[@]} =~ "4" ]]; then
    sed -i "s+plugins=(git+plugins=(git copyfile+" .zshrc
    echo $GREEN"Plugin copyfile activated"$RESTORE
    sleep 1
fi

if [[ ${CHECKED[@]} =~ "5" ]]; then
    sed -i "s+plugins=(git+plugins=(git sudo+" .zshrc
    echo $GREEN"Plugin sudo activated"$RESTORE
    sleep 1
fi

if [[ $packageManager =~ "apt" ]]; then
    read -p "Do you wish to install Fastfetch? $GREEN(y)Yes$RESTORE/$RED(n)No$RESTORE " yn;
    case $yn in
    [yY][eE][sS]|[yY]) wget -O /tmp/fastfetch-linux-amd64.deb https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-amd64.deb; sudo $packageManager /tmp/fastfetch-linux-amd64.deb; rm /tmp/fastfetch-linux-amd64.deb; sed -i "1i fastfetch" .zshrc;;
    [nN][oO]|[nN]) echo $RED"Aborting..."$RESTORE;;
    *) exit ;;
    esac
fi;

echo $GREEN"Changing your default shell to zsh"$RESTORE
sudo chsh -s $(which zsh) $(whoami)

exec zsh
# From here the powerlevel10k config should launch
