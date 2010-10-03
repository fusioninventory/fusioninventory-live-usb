build: /usr/bin/live-build
	sudo lb build

clean:
	sudo rm -rf binary binary.img binary.list binary.packages chroot .stage

clean-all: clean
	sudo rm -rf cache

/usr/bin/live-build:
	sudo aptitude install live-build

. PHONY : clean
