# runs on linux.cs.uchicago.edu
# setup permissions on $HOME and $HOME/html/$DEPLOY_PATH
chmod 711 $HOME
mkdir -m 755 -p $HOME/html/$DEPLOY_PATH
# set all the directories to 755
find $HOME/html/$DEPLOY_PATH -type d -exec chmod 755 {} \;
# set all the files to 644
find $HOME/html/$DEPLOY_PATH -type f -exec chmod 644 {} \;
# set permissions for just $HOME
chmod 711 $HOME