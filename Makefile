m ?= $(shell date +%Y-%m-%d)
c ?= $(shell date +%Y-%m-%d)

CC = $(shell which gcc)
CXX = $(shell which g++)

current_date := $(shell date +%Y%m%d%H%M%S)
BUILD_DIR := build
ENV_FILE := .env

include $(ENV_FILE)


.PHONY: install_vcpkg pre_run
all: install_vcpkg pre_run

_install_vcpkg:
	apt-get update && \
	apt-get install -y cmake gdb pkg-config linux-libc-dev && \
	mkdir -p /usr/local/vcpkg && \
	git clone https://github.com/microsoft/vcpkg.git /usr/local/vcpkg && \
	/usr/local/vcpkg/bootstrap-vcpkg.sh && \
	/usr/local/vcpkg/vcpkg integrate install

_check_vcpkg:
	@if [ -d /usr/local/vcpkg ]; then \
		echo "vcpkg уже установлен пропускаем установку"; \
	else \
		make _install_vcpkg; \
	fi

v_find:
	/usr/local/vcpkg/vcpkg search "$(p)"
v_install:
	echo $(VCPKG_TARGET_TRIPLET)
	/usr/local/vcpkg/vcpkg install --triplet $(VCPKG_TARGET_TRIPLET)

install_vcpkg:_check_vcpkg v_install

clean:
	rm -rf ./build
	rm -rf ./vcpkg_installed 

copy_config:
	mkdir -p $(BUILD_DIR)
	cp ./server_config.json ./build/server_config.json
	cp ./.env ./build/.env

pre_build_release:copy_config
	mkdir -p $(BUILD_DIR)
	cd $(BUILD_DIR) && \
	cmake .. \
	-DAPP_NAME="$(APP_NAME)" \
	-DBUILD_MODE="Release" \
	-DCMAKE_C_COMPILER="$(CC)" \
	-DCMAKE_CXX_COMPILER="$(CXX)" \
	-DCMAKE_TOOLCHAIN_FILE="$(CMAKE_TOOLCHAIN_FILE)" \
	-DVCPKG_TARGET_TRIPLET="$(VCPKG_TARGET_TRIPLET)" \
	&& \
	make

pre_build_debug:copy_config
	mkdir -p $(BUILD_DIR)
	cd $(BUILD_DIR) && \
	cmake .. \
	-DAPP_NAME="$(APP_NAME)" \
	-DBUILD_MODE="Debug" \
	-DCMAKE_C_COMPILER="$(CC)" \
	-DCMAKE_CXX_COMPILER="$(CXX)" \
	-DCMAKE_TOOLCHAIN_FILE="$(CMAKE_TOOLCHAIN_FILE)" \
	-DVCPKG_TARGET_TRIPLET="$(VCPKG_TARGET_TRIPLET)" \
	&& \
	make

pre_run:pre_build_release
	./build/"$(APP_NAME)"

test:
	echo "$(CC)"

d_check_db_connection:
	@set -e; \
    echo "Checking MySQL connection...";\
    COUNTER=0; \
    while [ "$$COUNTER" -lt 10 ]; do \
        HEALTH_STATUS=$$(docker inspect -f '{{.State.Health.Status}}' mysql-backend-template-db); \
        if [ "$$HEALTH_STATUS" = "healthy" ]; then \
            echo "Container is healthy!"; \
            exit 0; \
        else \
            echo "Container is not healthy (status: $$HEALTH_STATUS). Retrying in 5 seconds..."; \
            sleep 5; \
            COUNTER=$$((COUNTER + 1)); \
        fi; \
    done; \
    echo "Container is not healthy after 10 retries."; \
    exit 1


d_build:
	docker compose build
d_build_no_cache:
	docker compose build --no-cache
d_stop:
	docker compose down
d_down:
	docker compose down
d_run:
	docker compose up -d
d_up:
	docker compose up -d
d_start:
	docker compose up -d
d_build_start:
	docker compose build
	docker compose up -d
d_rebuild: d_down d_build_no_cache d_up
	echo "rebuild"
d_allbuild: d_down d_build d_up
	echo "rebuild"