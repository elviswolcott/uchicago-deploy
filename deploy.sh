# copy files over
rsync -r --delete-after --quiet $TRAVIS_BUILD_DIR/$BUILD_PATH $CNETID@linux.cs.uchicago.edu:~/html/$DEPLOY_PATH
# connect and share deploy path
ssh $CNETID@linux.cs.uchicago.edu "export DEPLOY_PATH=$DEPLOY_PATH"
# connect and run contents of after-deploy.sh
ssh $CNETID@linux.cs.uchicago.edu 'bash -s' < ./after_deploy.sh