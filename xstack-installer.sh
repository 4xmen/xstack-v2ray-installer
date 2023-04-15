#!/usr/bin/env bash


# COLORS
RED='\033[0;31m'
NC='\033[0m'
BLUE='\033[0;34m'
WHITE='\033[0;37m' 
RED='\033[0;31m' 
# Set the color variable
green='\033[0;32m'
# Clear the color after that
clear='\033[0m'


# Functions

function progress {
    barr=''
    for (( y=50; y <= 100; y++ )); do
        sleep 0.05
        barr="${barr} "
 
        echo -ne "\r"
        echo -ne "\e[43m$barr\e[0m"
 
        local left="$(( 100 - $y ))"
        printf " %${left}s"
        echo -n "${y}% Please Wait"
    done
    echo -e "\n"
}

# check port 80 is in use or no
check_port() {
    if [ -z "$(netstat -tulpn | grep :'80\s')" ];
    then
        return 1;
    else
    echo -e "${RED}[ERROR]${clear} Port 80 is currently in use."
        exit;
    fi

}

show_menu(){
    normal=`echo "\033[m"`
    menu=`echo "\033[36m"` #Blue
    number=`echo "\033[33m"` #yellow
    bgred=`echo "\033[41m"`
    fgred=`echo "\033[31m"`
    printf "\n${menu}*********************************************${normal}\n"
    printf "${menu}*                                           *${normal}\n"
    printf "${menu}*         ${RED}X${WHITE}stack plugin started!${menu}            *${normal}\n"
    printf "${menu}*                                           *${normal}\n"
    printf "${menu}*********************************************${normal}\n"
    printf "${menu}**${number} 0)${menu} Install the script requirements ${normal}\n"
    printf "${menu}**${number} 1)${menu} Setup Domain on IP ${normal}\n"
    printf "${menu}**${number} 2)${menu} Install X-UI ${normal}\n"
    printf "${menu}**${number} 3)${menu} Uninstall X-UI ${normal}\n"
    printf "${menu}**${number} 4)${menu} setup SSL on X-UI panel ${normal}\n"
    printf "${menu}**${number} 5)${menu} Install API Panel on Server ${normal}\n"
    printf "${menu}**${number} 6)${menu} Exit ${normal}\n"
    printf "${menu}*********************************************${normal}\n"
    printf "Please choice: ${normal}"
    read opt
}

# check nano is installed or no 
nano_check(){
    REQUIRED_PKG="nano"
    PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
    progress
    echo -e Packege $REQUIRED_PKG was ${green}installed${clear}.
    if [ "" = "$PKG_OK" ]; then
    echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."
    apt-get --yes install $REQUIRED_PKG #install nano if not installed
    fi
}

# install wget,curl,certbot,sqlite3,git and then unzip that
install_check(){
    progress
    apt-get install nano wget curl net-tools certbot sqlite3 git unzip -y
}

install_req() {
        update_fun
        install_check 
        nano_check 
}
# first server update and upgrade
update_fun(){
    apt-get update
    apt-get upgrade
}

# Command for install and set api panel
install_API_Panel() {





            if ! check_xui_nue; then
            FILE=$(find / -name x-ui*.db | awk '{print $1}')
            if [[ -f "$FILE" ]]; then
                apt-get apache2 php php-mysql sqlite3 libsqlite3-dev php-sqlite3

                mv /var/www/html/index.html /var/www/html/index.back

                chmod 751 /etc/

                chmod 777 /etc/x-ui*/

                chmod 777 ${FILE}

                cd /var/www/html/
                

                # wget -q https://github.com/4xmen/x-ui/releases/download/0.5.4/api-x-ui.zip -O api-x-ui.zip
                wget -O api-x-ui.zip -N https://github.com/4xmen/x-ui/releases/download/0.5.4/api-x-ui.zip

                unzip api-x-ui.zip



                progress
                # SED=$(sed -i "s/\$fileAddress = "defval";/\$fileAddress = \"$FILE\";/" config.php)
                # SED=$(sed -i "s/\$fileAddress = .*/\$fileAddress = \"$FILE\";/" config.php)
                # SED=$(grep -q -F '$fileAddress =' config.php && sed -i 's/\$fileAddress = .*/\$fileAddress = "dsdsdsds";/' config.php || echo '$fileAddress not found!')
                SED=$(grep -q -F '$fileAddress =' config.php && sed -i "s/\(\$fileAddress = \).*/\1\"$FILE\";/" config.php || echo '$fileAddress not found!')
                echo $SED
                




            else
            echo -e "${RED}[ERORR]${clear} The database file was not found! Please reinstall."
            fi
            else
            echo -e "${RED}[ERORR]${clear} Unfortunately, x-ui is not installed yet!please istall that."
            exit 1;
            


        fi



}


# check x-ui is installed or no for install
check_xui(){
    
    if ! netstat -tulpn | grep 'x-ui'
    then 
    progress
    else 
    echo ""
    echo ""
    echo -e "${RED}[ERROR]${clear} You have already installed x-ui ! please unistall that."
    exit 1
    fi
}

# check x-ui is installed or no for uninstall
check_xui_nue(){
    
    if ! netstat -tulpn | grep 'x-ui'
    then 
    echo -e "${RED}[ERROR]${clear} Unfortunately, x-ui is not installed yet!please istall that."
    exit 1
    else 
    progress
    return 1
    fi
}

# check root access in terminal
check_root(){
    if [ "$EUID" -ne 0 ]
    then echo -e "${RED}[ERROR]${clear} Please run as root !"
    exit
    fi
}

# first choice for setup domain on IP
setupDomain() {
        update_fun
        sleep 1 
        

        if ! check_port; then

        printf "Please enter email:"
        read email

        printf "Please enter domain:"
        read domain

        certbot certonly --standalone --non-interactive --preferred-challenges http --agree-tos --email ${email} -d ${domain}

        echo -e "${green}[success]${clear} the domain was setup :)"
        echo ""
        echo "launch again xstack installer!"
        fi




}


# seconde choice is for install x-ui panel 
installXUI() {
        update_fun
        if ! check_xui; then
            exit 1
            else
            echo -e "${green}[SUCCESS]${clear} Your server has been checked and is ready to install"
            wget -q https://raw.githubusercontent.com/4xmen/x-ui/master/install.sh -O install.sh

            printf "Please enter username:"
            read username

            printf "Please enter password:"
            read password

            printf "Please enter port:"
            read port

            

            echo "y
                $username
                $password
                $port
                " | bash install.sh;


        fi

}

# third choice for uninstall x-ui
uninstallXUI() {
        if ! check_xui_nue; then
            echo -e "${green}[SUCCESS]${clear} Your server has been checked and is ready to uninstall"
            printf "Are you sure to uninstall x-ui? Y/n : "
            read questunistall
            if [[ $questunistall == 'Y' || $questunistall == 'y' ]]; then
                echo 'Y' | x-ui uninstall
                progress
                rm /usr/bin/x-ui -f
                echo -e "${green}[SUCCESS]${clear} x-ui successfully uninstalled"
            else
                exit 1
            fi
            else
            exit 1


        fi

}




# setup SSL on panel without going to the panel
setupSSL() {

        if ! check_xui_nue; then
            FILE=/etc/x-ui/x-ui.db
            sql='select * from settings'
            if [[ -f "$FILE" ]]; then

            if sqlite3 ${FILE} "select * from settings where key='webCertFile';" | grep -i 'webCertFile' && sqlite3 ${FILE} "select * from settings where key='webKeyFile';" | grep -i 'webKeyFile'; then
                    
                    CertificatePath=$(certbot certificates | grep -oP '(?<=Certificate Path: ).*(?=.pem)')
                    PrivateKeyPath=$(certbot certificates | grep -oP '(?<=Private Key Path: ).*(?=.pem)')

                    webCertFile="${CertificatePath}.pem"
                    webKeyFile="${PrivateKeyPath}.pem"


                    progress
                    sqlite3 ${FILE} "UPDATE settings SET key='webCertFile',value=\"${webCertFile}\" WHERE key='webCertFile';"
                    echo -e "${green}[SUCCESS]${clear} The certificate public key file is set."


                    progress
                    sqlite3 ${FILE} "UPDATE settings SET key='webKeyFile',value=\"${webKeyFile}\" WHERE key='webKeyFile';"
                    echo -e "${green}[SUCCESS]${clear} The certificate key file is set."





                    x-ui restart
                    echo -e "${green}[SUCCESS]${clear} ssl was successfully set on the panel."



            else

                    CertificatePath=$(certbot certificates | grep -oP '(?<=Certificate Path: ).*(?=.pem)')
                    PrivateKeyPath=$(certbot certificates | grep -oP '(?<=Private Key Path: ).*(?=.pem)')

                    webCertFile="${CertificatePath}.pem"
                    webKeyFile="${PrivateKeyPath}.pem"


                    

                    progress
                    sqlite3 /etc/x-ui/x-ui.db "insert into settings (key,value) values (\"webCertFile\",\"$webCertFile\");"
                    echo -e "${green}[SUCCESS]${clear} The certificate public key file is set."

                    progress
                    sqlite3 /etc/x-ui/x-ui.db "insert into settings (key,value) values (\"webKeyFile\",\"$webKeyFile\");"
                    echo -e "${green}[SUCCESS]${clear} The certificate key file is set."


                    x-ui restart


                    echo -e "${green}[SUCCESS]${clear} ssl was successfully set on the panel."

                    
            fi


            else
            echo -e "${RED}[ERORR]${clear} The database file was not found! Please reinstall."
            fi
            else
            echo -e "${RED}[ERORR]${clear} Unfortunately, x-ui is not installed yet!please istall that."
            exit 1;
            


        fi
}

# starting installer with check root access and then show menu
start_shell(){
    string="
▀████    ▐████▀    ▄████████     ███        ▄████████  ▄████████    ▄█   ▄█▄ 
  ███▌   ████▀    ███    ███ ▀█████████▄   ███    ███ ███    ███   ███ ▄███▀ 
   ███  ▐███      ███    █▀     ▀███▀▀██   ███    ███ ███    █▀    ███▐██▀   
   ▀███▄███▀      ███            ███   ▀   ███    ███ ███         ▄█████▀    
   ████▀██▄     ▀███████████     ███     ▀███████████ ███        ▀▀█████▄    
  ▐███  ▀███             ███     ███       ███    ███ ███    █▄    ███▐██▄   
 ▄███     ███▄     ▄█    ███     ███       ███    ███ ███    ███   ███ ▀███▄ 
████       ███▄  ▄████████▀     ▄████▀     ███    █▀  ████████▀    ███   ▀█▀ 
                                                                   ▀         
"
clear

for ((i=0; i<=${#string}; i++)); do
   printf '%s' "${string:$i:1}"
   sleep 0.0005
done




DIR=/etc/nginx/sites-available/default

echo ""


check_root
show_menu
}
start_shell


case $opt in

  0)
    install_req
    ;;

  1)
    setupDomain
    ;;

  2)
    installXUI
    ;;
  3)
    uninstallXUI 
    ;;  
  4)
    setupSSL 
    ;;  
  5)
    install_API_Panel 
    ;;  
  6)
    echo "installer was closed !"
    exit
    ;;


  *)
    echo -e "${RED}[ERROR]${WHITE} Wrong input, please be careful!"
    exit 1
    ;;
esac

