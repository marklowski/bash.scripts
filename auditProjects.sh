#!/bin/bash
# Audit PNPM Packages of multiple Projects

#
# Include's
#
source $BASH_COLOR_INCL
source $BASH_ICON_INCL

#
# Global Variables
#
_PROJECTS="$(pwd)/"
_NODE_BASED="node_modules"
_FILE_BASED="package.json"
_PNPM_BASED="pnpm-lock.yaml"
_NPM_BASED="package-lock.json"

#
# check if Projects are _NODE_BASED, and list them accordingly.
#
listProjects() {
    echo -e "${_FG_CYAN}The following Sub-Directories would be checked:${_TX_RESET}"

    for directories in $_PROJECTS*
    do
        if [[ -d $directories ]]; then
            cd $directories

            if [[ -d "$_NODE_BASED" || -f "$_FILE_BASED" ]]; then
                if [[ -f "$_PNPM_BASED" ]]; then
                    nodeVariant="${_FG_YELLOW}$i_dev_code pnpm${_TX_RESET} project"
                elif [[ -f "$_NPM_BASED" ]]; then
                    nodeVariant="${_FG_RED}$i_dev_npm  npm${_TX_RESET} project"
                else
                    nodeVariant="${_FG_RED}required *-lock* file is missing${_TX_RESET}"
                fi
                outputString="${_SPACE_4}${nodeVariant}: ${directories##*/}"
                echo -e "${outputString}"
            fi
        fi
    done
}

#
# check if Projects are node based, subsequently check Package Versions.
#
checkProjects() {
    for directories in $_PROJECTS*
    do
        if [[ -d $directories ]]; then
            cd $directories

            if [[ -d "$_NODE_BASED" || -f "$_FILE_BASED" ]]; then
                echo -e "${_FG_WHITE}Checking Project:${_TX_RESET} ${directories##*/}"

                if [[ -f "$_NPM_BASED" ]]; then
                    npm audit
                    npm outdated
                else
                    pnpm audit
                    pnpm outdated
                fi
            fi
            echo ""
        fi
    done
}

#
# check specific project for Vulnerabilities && Updates.
#
checkProject() {
    projectDirectory="$1"
    cd $projectDirectory

    echo -e "${_FG_WHITE}Checking Project:${_TX_RESET} ${projectDirectory##*/}"
    if [[ -d "$_NODE_BASED" || -f "$_FILE_BASED" ]]; then

        if [[ -f "$_NPM_BASED" ]]; then
            npm audit
            npm outdated
        else
            pnpm audit
            pnpm outdated
        fi
    fi
}

#
# output script description.
#
printHelp() {
    echo -e "${_FG_CYAN}Listing Help: ${_TX_RESET}"
    echo -e "${_SPACE_2}${_FG_WHITE}-l: ${_TX_RESET} List would be Checked Projects"
    echo -e "${_SPACE_2}${_FG_WHITE}-c: ${_TX_RESET} Check the above Project List for Vulnerabilities && Updates"
    echo -e "${_SPACE_2}${_FG_WHITE}-s: ${_TX_RESET} Check Single Project for Vulnerabilities && Updates"
    echo -e "${_SPACE_4}${_FG_YELLOW}arg:${_TX_RESET} project path"
    echo ""
    echo -e "${_FG_YELLOW}Not yet Implemented: ${_TX_RESET}"
    echo -e "${_SPACE_2}${_FG_RED}-D: ${_TX_RESET} Delete node_modules Folder && package-lock-json"
    echo -e "${_SPACE_2}${_FG_RED}-i: ${_TX_RESET} Install NPM Packages"
    echo -e "${_SPACE_2}${_FG_RED}-u: ${_TX_RESET} Upgrade All NPM Packages"
}

#
# handle script options.
#
while getopts ":hlcs:" opt; do
    case ${opt} in
        c  ) ( checkProjects ) | more; exit 1 ;;
        s  ) checkProject "$OPTARG" exit 1 ;;
        l  ) ( listProjects ) | more; exit 1 ;;
        h  ) printHelp exit 1 ;;
        \? ) echo -e "${_FG_YELLOW}Unknown Option: ${_TX_RESET} -$OPTARG" >&2; exit 1;;
        :  ) echo -e "${_FG_YELLOW}Missing option argument for ${_TX_RESET} -$OPTARG" >&2; exit 1;;
        *  ) echo -e "${_FG_RED}Unimplemented Option: ${_TX_RESET} -$OPTARG" >&2; exit 1;;
    esac
done

# Standard Behaviour when, no option was supplied.
if ((OPTIND == 1)); then printHelp; fi
shift $((OPTIND -1))
exit $PIPESTATUS
