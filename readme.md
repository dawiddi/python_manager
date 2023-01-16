# Python Manager
The script can be invoked by
```shell
> ./build_python.sh --v 3.11.1
```
After build you will be asked, if you want to make that current bugfix version (in this case v1), the main one to be called.
Accepting it will create a symlink to that current version in `./bin`. Make sure to add that directory to your PATH. Python then can be called from anywhere by:
```shell
> python3.11 --version
Python 3.11.1
```
## Changing the python version
Minor versions always stay available, e.g. Python 3.11 and 3.10 can be installed in parallel. Calling python will always invoke a specific bugfix version. To change a bugfix version, just run the build script again. If the version already is available, building can be skipped. In the end, it can be selected for usage.
```shell
> ./build_python.sh --v 3.11.0
...
Do you want to use this bugfix version (0) as main minor version (3.11)? (yY/nN): y
> python3.11 --version
Python 3.11.0
> ./build_python.sh --v 3.11.1
Version already exists. Do you want to recompile? (yY/nN): n
Do you want to use this bugfix version (1) as main minor version (3.11)? (yY/nN): y
> python3.11 --version
Python 3.11.1
```
