# Используем официальный образ для C++
FROM gcc:latest

# Устанавливаем необходимые пакеты
RUN apt-get update && apt-get install -y cmake

# Задаем рабочую директорию
WORKDIR /usr/src/cpp20_web_backend_template

# Копируем все файлы в контейнер
COPY . .

# Собираем проект
RUN mkdir build && cd build && cmake .. && make

# Указываем команду, которая будет выполнена при запуске контейнера
CMD ["./build/cpp20_web_backend_template"]
