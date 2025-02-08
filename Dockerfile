FROM dart:stable AS build

# Set working directory
WORKDIR /app

# Copy pubspec files
COPY pubspec.* ./
RUN dart pub get

# Copy rest of the application source code
COPY . .

# Get dependencies
RUN dart pub get --offline

# Ensure correct permissions
RUN chmod +x /app/bin/server.dart

# Expose port
EXPOSE 8080

# Start server
CMD ["dart", "run", "bin/server.dart"]
