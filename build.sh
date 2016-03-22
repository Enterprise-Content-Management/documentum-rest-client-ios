SHELL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="RestMobileClientAsync"
TARGET_NAME="AsyncCoreRestClient"
TARGET_SDK="iphoneos9.2"
PROJECT_BUILD_DIR="${PROJECT_DIR}/build/Release-iphoneos"

# compile project
echo Building Project
cd "${SHELL_DIR}"
cd "${PROJECT_DIR}"
xcodebuild -target "${TARGET_NAME}" -sdk "${TARGET_SDK}" -configuration Release