#!/usr/bin/bash
# shellcheck disable=SC2034

#    Copyright (c) 2022 @grm34 Neternels Team
#
#    Permission is hereby granted, free of charge, to any person
#    obtaining a copy of this software and associated documentation
#    files (the "Software"), to deal in the Software without restriction,
#    including without limitation the rights to use, copy, modify, merge,
#    publish, distribute, sublicense, and/or sell copies of the Software,
#    and to permit persons to whom the Software is furnished to do so,
#    subject to the following conditions:
#
#    The above copyright notice and this permission notice shall be
#    included in all copies or substantial portions of the Software.
#
#    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
#    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
#    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
#    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
#    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


_ask_for_kernel_dir() {
    if [[ ${KERNEL_DIR} == default ]]; then
        QUESTION="Enter kernel path (e.q. /home/user/mykernel) :"
        _prompt "${QUESTION}"; read -r -e KERNEL_DIR
        until [[ -d ${KERNEL_DIR}/arch/arm64/configs ]]; do
            _error "[ ${KERNEL_DIR} ] is not a valid kernel directory !"
            _prompt "${QUESTION}"; read -r -e KERNEL_DIR
        done
    fi
}


_ask_for_toolchain() {
    _confirm "Do you wish to use default compiler: ${DEFAULT_COMPILER} ?"
    case ${CONFIRM} in
        n|N|no|No|NO)
            _note "Select Toolchain compiler :"
            TOOLCHAINS=(Proton-Clang Eva-GCC Proton-GCC)
            until [[ ${COMPILER} =~ ^[1-3]$ ]]; do
                _select Proton-Clang Eva-GCC Proton-GCC
                read -r COMPILER
            done
            COMPILER=${TOOLCHAINS[${COMPILER}-1]}
            ;;
        *)
            COMPILER=${DEFAULT_COMPILER}
    esac
}


_ask_for_codename() {
    if [[ ${CODENAME} == default ]]; then
        _prompt "Enter android device codename (e.q. X00TD) :"
        read -r CODENAME
    fi
}


_ask_for_defconfig() {
    cd "${KERNEL_DIR}"/arch/arm64/configs/ || \
        (_error "${KERNEL_DIR} not found !"; _exit)
    QUESTION="Enter defconfig name (e.q. neternels_defconfig) :"
    _prompt "${QUESTION}"; read -r -e DEFCONFIG
    until [[ -f ${DEFCONFIG} ]] && [[ ${DEFCONFIG} == *defconfig ]]; do
        _error "[ ${DEFCONFIG} ] is not a valid defconfig file !"
        _prompt "${QUESTION}"; read -r -e DEFCONFIG
    done
    cd "${DIR}" || (_error "${DIR} not found !"; _exit)
}


_ask_for_menuconfig() {
    _confirm "Do you wish to edit kernel with menuconfig ?"
    case ${CONFIRM} in
        n|N|no|No|NO)
            MENUCONFIG=False
            ;;
        *)
            MENUCONFIG=True
    esac
}


_ask_for_cores() {
    _confirm "Do you wish to use all availables CPU Cores ?"
    case ${CONFIRM} in
        n|N|no|No|NO)
            until [[ ${CORES} =~ ^[1-9]{1}[0-9]{0,1}$ ]]; do
                _prompt "Enter amount of cores to use :"
                read -r CORES
            done
            ;;
        *)
            CORES=$(nproc --all)
    esac
}


_ask_for_telegram() {
    if [[ ${TELEGRAM_CHAT_ID} ]] && [[ ${TELEGRAM_BOT_TOKEN} ]]; then
        _confirm "Do you wish to send build status to Telegram ?"
        case ${CONFIRM} in
            n|N|no|No|NO)
                BUILD_STATUS=False
                ;;
            *)
                BUILD_STATUS=True
        esac
    fi
}


_ask_for_make_clean() {
    _confirm "Do you wish to make clean build: ${LINUX_VERSION} ?"
    case ${CONFIRM} in
        n|N|no|No|NO)
            MAKE_CLEAN=False
            ;;
        *)
            MAKE_CLEAN=True
    esac
}


_ask_for_save_defconfig() {
    _confirm "Do you wish to save and use: ${DEFCONFIG} ?"
    case ${CONFIRM} in
        n|N|no|No|NO)
            SAVE_DEFCONFIG=False
            _confirm "Do you wish to continue with original defconfig ?"
            case ${CONFIRM} in
                n|N|no|No|NO)
                    ORIGINAL_DEFCONFIG=False
                    ;;
                *)
                    ORIGINAL_DEFCONFIG=True
            esac
            ;;
        *)
            SAVE_DEFCONFIG=True
    esac
}


_ask_for_new_build() {
    _confirm "Do you wish to start ${TAG}-${CODENAME}-${LINUX_VERSION} ?"
    case ${CONFIRM} in
        n|N|no|No|NO)
            NEW_BUILD=False
            ;;
        *)
            NEW_BUILD=True
    esac
}


_ask_for_flashable_zip() {
    _confirm "Do you wish to zip ${TAG}-${CODENAME}-${LINUX_VERSION} ?"
    case ${CONFIRM} in
        y|Y|yes|Yes|YES)
            FLASH_ZIP=True
            ;;
        *)
            FLASH_ZIP=False
    esac
}
