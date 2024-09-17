# Используем базовый образ Ubuntu
FROM ubuntu:22.04

# Установка необходимых пакетов и зависимостей
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    g++ \
    cmake \
    mysql-client \
    git \
	pkg-config \
	linux-libc-dev \
    curl zip unzip tar \
    libboost-all-dev \
    libssl-dev \
    libmysqlclient-dev \
    && rm -rf /var/lib/apt/lists/*

# Копируем проект в контейнер
WORKDIR /app
RUN git clone https://github.com/microsoft/vcpkg.git /usr/local/vcpkg && \
    /usr/local/vcpkg/bootstrap-vcpkg.sh && \
    /usr/local/vcpkg/vcpkg integrate install

ENV PATH="/usr/local/vcpkg:${PATH}"


COPY start-container /usr/local/bin/start-container
RUN chmod +x /usr/local/bin/start-container

# RUN usermod -u 1000 www-data

EXPOSE $BACKEND_PORT


ENTRYPOINT ["start-container"]
