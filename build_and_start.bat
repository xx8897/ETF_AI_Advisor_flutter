@echo off
echo "Changing directory to dart_backend..."
cd dart_backend

echo "Building and starting the Dart Frog server..."
dart pub get && C:\Users\xx8897\AppData\Local\Pub\Cache\bin\dart_frog.bat build && dart build/bin/server.dart --port 8080 --host 0.0.0.0
