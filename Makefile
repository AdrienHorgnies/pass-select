install:
	mkdir -p ~/.password-store/.extensions
	sudo ln -fs $(shell realpath select.bash) /usr/lib/password-store/extensions

uninstall:
	sudo rm /usr/lib/password-store/extensions/select.bash
