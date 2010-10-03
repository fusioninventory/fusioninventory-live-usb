clean:
	sudo rm -rf binary binary.img binary.list binary.packages chroot .stage

clean-all: clean
	sudo rm -rf cache

build:
	sudo lb build

. PHONY : clean
