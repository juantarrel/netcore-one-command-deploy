
function makeBackup {

    NAME_PROJECT=$1

    if ! [ -d "~/Projects/$NAME_PROJECT" ]; then
        return 0;
    fi

    echo -e "\033[0;32mConnected\033[m"
    if ! [ -d "Backups" ]; then
        mkdir Backups
        echo -e "\033[0;32mBackups folder created\033[m"
    fi

    echo "Creating backup for current project..."

    cp -rf ~/Projects/$NAME_PROJECT Backups

    cd Backups

    if [ -d "$NAME_PROJECT/vendor" ]; then
        rm -rf $NAME_PROJECT/vendor
        echo -e "\033[0;32mVendor deleted\033[m"
    fi

    if [ -d "$NAME_PROJECT/node_modules" ]; then
        rm -rf $NAME_PROJECT/node_modules
        echo -e "\033[0;32mNode modules deleted\033[m"
    fi

    tar -zcvf `echo "$(date "+%Y-%m-%d-%H-%M-%S").tar.gz"` `echo "$NAME_PROJECT"`>/dev/null
    rm -rf $NAME_PROJECT
    echo -e "\033[0;32mBackup created\033[m"

    if [[ $? -gt 0 ]]; then
        echo "The is an error"
        return 1
    fi
}

function pullProject {
    echo "Pulling branch to project..."

    if [ -d ~/Projects/$1 ]; then
        if [ -f ~/Projects/$1/.env ]; then
            cp ~/Projects/$1/.env ~/Projects/
        fi
        rm -r ~/Projects/$1
    fi

    echo "Cloning repository"
    cd ~/Projects
    git clone $2
    echo -e "\033[0;32mRepository cloned\033[m"

    cd $1

    git checkout $3

    if [ -f ~/Projects/.env ]; then
        cp ~/Projects/.env ~/Projects/$1/
    fi

    echo "Removing git files..."
    sudo rm -rf .git*

    echo "Running migrations..."
    cd Loyalty.Database/
    dotnet run 

    echo "Creating binary"

    cd ../LoyaltyAPI
    dotnet publish -o awssite

    if [ -d ~/Projects/awssite ]; then
        sudo rm -R ~/Projects/awssite
    fi

    sudo cp -r awssite ../../

    echo "Restarting service..."
    sudo systemctl stop my-web-api.service
    sudo systemctl start my-web-api.service

}
