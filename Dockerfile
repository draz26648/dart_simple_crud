FROM dart:stable

WORKDIR /app

COPY pubspec.* ./
RUN dart pub get

COPY . .
RUN dart pub get --offline

EXPOSE 8080

CMD ["dart", "bin/server.dart"]
