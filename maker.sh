#!/usr/bin/bash

#   Copyright 2021 Neternels-Builder by darkmaster @grm34 Neternels Team
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.


_make_clean_build() {
    _confirm "Do you wish to make clean build (${LINUX_VERSION})?"
    case ${CONFIRM} in
        n|N|no|No|NO)
            _note "Make dirty build..."
            _clean_anykernel
            ;;
        *)
            _note "Make clean build (this could take a while)..."
            _check make -C "${KERNEL_DIR}" clean
            _check make -C "${KERNEL_DIR}" mrproper
            _check rm -rf "${OUT_DIR}"
            _clean_anykernel
    esac
}


_make_defconfig() {
    _note "Make ${DEFCONFIG} (${LINUX_VERSION})..."

    # Send build status to Telegram
    if [[ ${BUILD_STATUS} == True ]]; then
        _send_msg "<b>${CODENAME}-${LINUX_VERSION}</b> | \
<code>New build started by ${BUILDER} with ${COMPILER} compiler</code>"
    fi

    # Make defconfig
    _check make -C "${KERNEL_DIR}" O="${OUT_DIR}" ARCH=arm64 "${DEFCONFIG}"
}


_make_menuconfig() {
    if [ "${MENUCONFIG}" == True ]; then
        _note "Make menuconfig..."

        # Send build status to Telegram
        if [[ ${BUILD_STATUS} == True ]]; then
            _send_msg "<b>${CODENAME}-${LINUX_VERSION}</b> | \
<code>Started menuconfig</code>"
        fi

        # Make Menuconfig
        _check make -C "${KERNEL_DIR}" O="${OUT_DIR}" ARCH=arm64 \
            menuconfig "${OUT_DIR}"/.config

        # Save new defconfig
        _confirm "Do you wish to save and use ${DEFCONFIG}"
        case ${CONFIRM} in
            n|N|no|No|NO)
                _confirm "Do you wish to continue"
                case ${CONFIRM} in
                    n|N|no|No|NO)
                        _error "aborted by user!"
                        _exit
                        ;;
                    *)
                        return
                esac
                ;;
            *)
                _note "Saving ${DEFCONFIG} in arch/arm64/configs..."
                _check cp "${KERNEL_DIR}"/arch/arm64/configs/"${DEFCONFIG}" \
                    "${KERNEL_DIR}"/arch/arm64/configs/"${DEFCONFIG}"_save
                _check cp "${OUT_DIR}"/.config \
                    "${KERNEL_DIR}"/arch/arm64/configs/"${DEFCONFIG}"
        esac
    fi
}


_make_build() {
    _note "Starting new build for ${CODENAME} (${LINUX_VERSION})..."

    # Send build status to Telegram
    if [[ ${BUILD_STATUS} == True ]]; then
        _send_msg "<b>${CODENAME}-${LINUX_VERSION}</b> | \
<code>Started compiling kernel</code>"
    fi

    # Link Time Optimization (LTO)
    if [[ ${LTO} == True ]];then
		export LD=ld.lld
        export LD_LIBRARY_PATH=${DIR}/toolchains/proton/lib
	fi

    # Get compiler string
    KBUILD_COMPILER_STRING=\
$(toolchains/proton/bin/clang --version | head -n 1 | \
perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')

    # Make build
    case ${COMPILER} in

        PROTON)
            export KBUILD_COMPILER_STRING
            export PATH=${DIR}/toolchains/proton/bin:${PATH}

            _check make -C "${KERNEL_DIR}" -j"${CORES}" \
                O="${OUT_DIR}" \
                ARCH=arm64 \
                SUBARCH=arm64 \
                CROSS_COMPILE=aarch64-linux-gnu- \
                CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
                CC=clang \
                AR=llvm-ar \
                NM=llvm-nm \
                OBJCOPY=llvm-objcopy \
                OBJDUMP=llvm-objdump \
                STRIP=llvm-strip
            ;;

        PROTONxGCC)
            export KBUILD_COMPILER_STRING
            export PATH=\
${DIR}/toolchains/proton/bin:${DIR}/toolchains/gcc64/bin:\
${DIR}/toolchains/gcc32/bin:/usr/bin:${PATH}

            _check make -C "${KERNEL_DIR}" -j"${CORES}" \
                O="${OUT_DIR}" \
                ARCH=arm64 \
                SUBARCH=arm64 \
                CC=clang \
                CROSS_COMPILE=aarch64-linux-gnu- \
                CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
                AR=llvm-ar \
                AS=llvm-as \
                NM=llvm-nm \
                STRIP=llvm-strip \
                OBJCOPY=llvm-objcopy \
                OBJDUMP=llvm-objdump \
                OBJSIZE=llvm-size \
                READELF=llvm-readelf \
                HOSTCC=clang \
                HOSTCXX=clang++ \
                HOSTAR=llvm-ar \
                CLANG_TRIPLE=aarch64-linux-gnu-
            ;;

        GCC)
            KBUILD_COMPILER_STRING=\
$(toolchains/gcc64/bin/aarch64-elf-gcc --version | head -n 1)
            export KBUILD_COMPILER_STRING
            export PATH=\
${DIR}/toolchains/gcc32/bin:${DIR}/toolchains/gcc64/bin:/usr/bin/:${PATH}

            _check make -C "${KERNEL_DIR}" -j"${CORES}" \
                O="${OUT_DIR}" \
                ARCH=arm64 \
                SUBARCH=arm64 \
                CROSS_COMPILE_ARM32=arm-eabi- \
                CROSS_COMPILE=aarch64-elf- \
                AR=aarch64-elf-ar \
                OBJDUMP=aarch64-elf-objdump \
                STRIP=aarch64-elf-strip
    esac
}
