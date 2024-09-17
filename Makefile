m ?= $(shell date +%Y-%m-%d)
c ?= $(shell date +%Y-%m-%d)
BUILD_DIR := build
ENV_FILE := .env

include $(ENV_FILE)


.PHONY: pre_run
all: pre_run


_check_vcpkg:
	@if [ -d /usr/local/vcpkg ]; then \
		echo "vcpkg уже установлен. Пропускаем установку."; \
	else \
		make _install_vcpkg; \
	fi

_install_vcpkg:
	sudo apt-get update && \
	sudo apt-get install -y cmake gdb pkg-config linux-libc-dev && \
	sudo mkdir -p /usr/local/vcpkg && \
	sudo git clone https://github.com/microsoft/vcpkg.git /usr/local/vcpkg && \
	cd /usr/local/vcpkg && \
	sudo ./bootstrap-vcpkg.sh && \
	export PATH="$PATH:/usr/local/vcpkg" && \
	echo 'export PATH="$PATH:/usr/local/vcpkg"' >> ~/.bashrc && \
	source ~/.bashrc && \
	/usr/local/vcpkg/vcpkg integrate install && \
	sudo chown -R $USER:$USER /usr/local/vcpkg

i_all:_check_vcpkg v_install

v_find:
	/usr/local/vcpkg/vcpkg search "$(p)"
v_install:
	sudo /usr/local/vcpkg/vcpkg install --triplet $(VCPKG_TARGET_TRIPLET)

clean:
	rm -rf ./build
	rm -rf ./vcpkg_installed 


pre_build_release:
	mkdir -p $(BUILD_DIR)
	cd $(BUILD_DIR) && \
	cmake .. \
	-DAPP_NAME="$(APP_NAME)" \
	-DBUILD_MODE="Release" \
	-DCMAKE_TOOLCHAIN_FILE="$(CMAKE_TOOLCHAIN_FILE)" \
	-DVCPKG_TARGET_TRIPLET="$(VCPKG_TARGET_TRIPLET)" \
	&& \
	make

pre_build_debug:
	mkdir -p $(BUILD_DIR)
	cd $(BUILD_DIR) && \
	cmake .. \
	-DAPP_NAME="$(APP_NAME)" \
	-DBUILD_MODE="Debug" \
	-DCMAKE_TOOLCHAIN_FILE="$(CMAKE_TOOLCHAIN_FILE)" \
	-DVCPKG_TARGET_TRIPLET="$(VCPKG_TARGET_TRIPLET)" \
	&& \
	make

pre_run:pre_build_release
	./build/"$(APP_NAME)"
