FROM ubuntu:18.04

RUN apt update && apt install -y curl git unzip xz-utils zip libglu1-mesa openjdk-8-jdk wget

WORKDIR /app

RUN git clone https://github.com/flutter/flutter.git
ENV PATH "$PATH:/app/flutter/bin"
ENV PATH "$PATH:/app/flutter/bin/cache/dart-sdk/bin"

RUN flutter channel master
RUN flutter upgrade
RUN flutter doctor

COPY pubspec.* ./
RUN flutter pub get

COPY . .

ENV PORT 8080
ENV HOST 0.0.0.0

RUN flutter pub get --offline
RUN dart compile exe bin/server.dart -o bin/server -D HOST=$HOST -D PORT=$PORT

EXPOSE 8080

CMD ["/app/bin/server"]