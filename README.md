> Automate deployments to your UChicago homepage

# Setup

Add `.travis.yml` to your repository, change the `CNETID` in line 15 to your CNet ID, and enable builds for the repository at [travis-ci.com](https://travis-ci.com). Then, copy `after_deploy.sh` and `deploy.sh` into your repository. 

The most complex part of setup is creating and encrypting an SSH key to allow Travis to SSH into `linux.cs.uchicago.edu`.

1. Create an SSH key and save it to `deploy_rsa` and `deploy_rsa.pub` **without** a password.
    ```bash
    ssh-keygen -t rsa -b 4096 -C 'build@travis-ci.com' -f deploy_rsa
    ```
1. Encrypt the private key so that only Travis can read it (requires the [Travis CLI](https://github.com/travis-ci/travis.rb#installation)).
    ```bash
    travis encrypt-file deploy_rsa
    ```
1. Look through the output for something like
    ```text
    storing secure env variables for decryption

    Please add the following to your build script (before_install stage in your .travis.yml, for instance):

        openssl aes-256-cbc -K $encrypted_f1dcb18ceeef_key -iv $encrypted_f1dcb18ceeef_iv -in deploy_rsa_.enc -out deploy_rsa -d

    Pro Tip: You can add it automatically by running with --add.
    ```
    All that matters is the hash (the part between `encrypted` and `key`. For example in `$encrypted_f1dcb18ceeef_key` the hash is **f1dcb18ceeef**. Take this value and replace the hashes in line 19 of `.travis.yml`.
1. Copy the public key to `linux.cs.uchicago.edu` to allow connections using the private key.
    ```bash
    ssh-copy-id -i deploy_rsa.pub <your-cnetid>@linux.cs.uchicago.edu
    ```
1. Optional: test the key by using it to SSH into `linux.cs.uchicago.edu`.
    ```bash
    chmod 600 deploy_rsa
    ssh -i deploy_rsa <your-cnetid>@linux.cs.uchicago.edu
    ```
1. Delete the plaintext key (**DO NOT EVER CHECK THIS IN TO SOURCE CONTROL**).
    ```bash
    rm deploy_rsa
    rm deploy_rsa.pub
    ```
1. Check in the encrypted key and deploy scripts.
    ```bash
    git add deploy_rsa.enc deploy.sh after_deploy.sh .travis.yml
    git commit -m "add encrypted ssh key"
    git push
    ```

## Note for Windows (WSL) users

This setup has been tested using the Windows Subsystem for Linux (WSL) to run Ubuntu bash. ([Official installation guide](https://docs.microsoft.com/en-us/windows/wsl/install-win10))

SSH will not accept keys that are readable by other users. By default, WSL doesn't track Linux permission bits on drives mounted by Windows (more information on the [WSL blog](https://devblogs.microsoft.com/commandline/chmod-chown-wsl-improvements/)). This means `chmod` won't actually change the permissions on your key! 

Luckily, recent versions of windows (newer than 17063 should work) support storing additional metadata for files to have Linux **and** Windows.

Open `/etc/wsl.conf` in your editor of choice
```bash
vi /etc/wsl.conf
```
and copy in these settings.
```ini
[automount]
enabled = true
options = "metadata"
mountFsTab = false
```
Restart Windows to ensure changes take effect.

# Running a build

By default, Travis **will not** deploy your site to your personal homepage when you make a commit, even though it will run tests. This is because you don't always want your site to have the latest version of your code (especially if something is a WIP). To handle this, Travis has been set to only run the `deploy` stage on the `master` branch when a tag is present. Tags are basically pointers to a certain commit and can be created with `git tag`.

To deploy the contents of the `master` branch:

```bash
git checkout master
git pull
git tag "message"
git push --tags
git push
```
This will ensure you are on the latest commit, tag it with your message (often a version number like 1.0.4) and push the commits and tags to GitHub. The Travis build will notice the tag and run the deploy stage after tests (this means it won't deploy if your tests fail).

# How it works

When you make a commit, Travis starts the jobs defined in `.travis.yml`. Each stage starts with installing dependencies and finishes with running a particular script. If one stage passes, the build continues to the next stage. 

The provided setup is fairly simple, it runs tests on each commit.
If there is a tag, Travis runs a build and then deploys the files to your personal homepage.

The deploy process is fairly simple. First, it establishes a `ssh` connection to `linux.cs.uchicago.edu` and copies over the built files. Then, it runs `after_deploy.sh` on `linux.cs.uchicago.edu` to set the proper permissions on the files for the webserver to read them. You can look in `.travis.yml`, `deploy.sh` and `after_deploy.sh` if you are interested in how exactly this is accomplished.

# Troubleshooting
This config expects `npm test` to run any tests for your site and `npm run build` to produce a static version of your site in the `build` directory. This works with `create-react-app` out of the box and most common `webpack` based setups. 

If you are using a different setup, the `.travis.yml` can be modified to run different commands by changing replacing `npm test` and `npm run build` or changing the environment variables (under `env`) to different paths. 

For more information on how to customize your build, see the [Travis CI docs](https://docs.travis-ci.com/user/customizing-the-build).

For more information on personal homepages, see the [How do I?](https://howto.cs.uchicago.edu/techstaff:personal_homepage) page.

