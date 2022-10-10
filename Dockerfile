# FROM dart:beta AS build
FROM ubuntu:18.04

RUN apt update && apt install -y curl git unzip xz-utils zip libglu1-mesa openjdk-8-jdk wget

# RUN useradd -ms /bin/bash developer
# USER developer
WORKDIR /app

RUN git clone https://github.com/flutter/flutter.git
ENV PATH "$PATH:/app/flutter/bin"
ENV PATH "$PATH:/app/flutter/bin/cache/dart-sdk/bin"

RUN flutter channel master
RUN flutter upgrade
RUN flutter doctor

# WORKDIR /app
COPY pubspec.* ./
RUN flutter pub get

COPY . .

# RUN flutter pub get
RUN flutter pub get --offline
RUN dart compile exe bin/server.dart -o bin/server

# FROM scratch
# COPY --from=build /runtime/ /
# COPY --from=build /app/bin/server /app/bin/

# COPY --from=build /app/public/ /public

EXPOSE 8080
CMD ["/app/bin/server"]