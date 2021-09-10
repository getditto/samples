build:
	mkdir -p dist;
	g++ -std=c++17 ./src/main.cpp -I ./sdk -lditto -ldl -framework Security,CoreFoundation,CoreBluetooth,ObjC -pthread -L ./sdk -o dist/main;
	