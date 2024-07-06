#!/bin/bash

function Update() {
	if [[ "$(arch)" == "arm64" ]]; then
		if [[ ! -d "$HOMEBREW_PREFIX/share/android-ndk" ]]; then
			brew install android_ndk
			brew install upx
			rustup target add aarch64-linux-android
		fi
	else
		if [[ -z "$ANDROID_NDK_HOME" ]]; then
			sudo apt install upx
			mkdir -p ~/Android
			wget -P ~/Android/ -c https://googledownloads.cn/android/repository/android-ndk-r26d-linux.zip
			unzip ~/Android/android-ndk-r26d-linux.zip -d ~/Android/
			echo 'export NDK=~/Android/android-ndk-r26d' >>~/.bashrc
			echo 'export PATH=${PATH}:$NDK' >>~/.bashrc
			source ~/.bashrc
		fi
	fi
}

function BuildForUbuntu() {
	if [[ -d "./target/aarch64-linux-android" ]]; then
		cargo clean
	fi

	export ANDROID_NDK_HOME=~/Android/android-ndk-r26d
	export CC=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android29-clang
	export AR=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-ar

	mkdir -p ~/.cargo
	cat >~/.cargo/config.toml <<EOL
[target.aarch64-linux-android]
linker = "$CC"
ar = "$AR"
EOL

	PATH="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH"

	cargo build --release --target aarch64-linux-android
	cargo build --target aarch64-linux-android
}

function BuildForMacOS() {
	if [[ -d "./target/aarch64-linux-android" ]]; then
		cargo clean
	fi

	export ANDROID_NDK_HOME="$HOMEBREW_PREFIX/share/android-ndk"
	export CC=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/darwin-x86_64/bin/aarch64-linux-android29-clang
	export AR=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/darwin-x86_64/bin/llvm-ar

	mkdir -p ~/.cargo
	cat >~/.cargo/config.toml <<EOL
[target.aarch64-linux-android]
linker = "$CC"
ar = "$AR"
EOL

	cargo build --release --target aarch64-linux-android
	cargo build --target aarch64-linux-android
}

function Upx() {
	upx -9 ./target/aarch64-linux-android/release/unpack &
	upx ./target/aarch64-linux-android/debug/unpack &
	wait
}

case $1 in
"-check")
	Update
	;;
"-build_linux")
	BuildForUbuntu
	Upx
	;;
"-build_mac")
	BuildForMacOS
	Upx
	;;
esac