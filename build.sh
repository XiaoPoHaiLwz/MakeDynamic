function AndroidNdk() {
	if [[ -z "$ANDROID_NDK_HOME" ]]; then
		mkdir ~/Android
		wget -P ~/Android/ -c https://googledownloads.cn/android/repository/android-ndk-r26d-linux.zip
		unzip ~/Android/android-ndk-r26d-linux.zip -d ~/Android/
		echo 'export NDK=/home/xiaopohai/Android/android-ndk-r26d' >>~/.bashrc
		echo 'export PATH=${PATH}:$NDK' >>~/.bashrc
		source ~/.bashrc
	fi
}

function Build() {
	if [[ -d "./target/aarch64-linux-android" ]]; then
		cargo clean
	fi

	export ANDROID_NDK_HOME=/home/xiaopohai/Android/android-ndk-r26d

	export CC=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android29-clang

	export CXX=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android29-clang++

	export AR=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-ar

	export RANLIB=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-ranlib

	cat >~/.cargo/config.toml <<EOL
[target.aarch64-linux-android]
linker = "$CC"
ar = "$AR"
EOL

	PATH="/home/xiaopohai/Android/android-ndk-r26d/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH"

	cargo build --release --target aarch64-linux-android
	cargo build --target aarch64-linux-android

}

function Upx(){
    upx -9 ./target/aarch64-linux-android/release/unpack &
    upx ./target/aarch64-linux-android/debug/unpack &
	wait
}

Build
Upx