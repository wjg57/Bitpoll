This is a fork of https://www.fs-infmath.uni-kiel.de/git/FS-InfMath/Bitpoll

the following changes have been made:

- Add documentation to configuration and build files according to the
  experiences made when I tried to get this to fly on my machine.
- Use absolute path names so the build and run also work in dockge
- Allow proper shutdown of uwsgi in container
- Add shell procedure to create the initial configuration and directory structure

How to use:

- run ./configure to create the directory structure and to initialize some
  variables.
- Modify run/config/settings.py for your environment (URL, Mail, ...)
- run "docker compose build" to initially build the containter
  NOTE: You can use
	"docker build --build-arg UID=xxxx --build-arg GID=yyyy ."
  instead, but docker compose is much simpler.
  (If you have to repeat this step due to errors or changes in the source
   it is probably best to append a --no-cache option to either command!)
- (If required: copy previously saved configuration to run/config)
- run "docker compose up -d" to start container
- run "docker compose down" to stop container
- run "./configure clean" to return to pristine state.
  ----> It is advisable to save your modified configuration in run/config
	to some place outside of "run" if you still want it!
