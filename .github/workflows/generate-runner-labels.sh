#!/bin/bash
set -euo pipefail

warp_prefix="warpdev"
if [ "$WARP_ENV" == "warpbuild-prod" ]; then
    warp_prefix="warp"
fi

generate_ubuntu_runner_labels() {
    local cores=(2 4 8 16 32)
    local labels=(2204 2404 latest)
    local architectures=(x64 arm64)
    local suffixes=('' -spot)

    for core in "${cores[@]}"; do
        for label in "${labels[@]}"; do
            for architecture in "${architectures[@]}"; do
                for spot in "${suffixes[@]}"; do
                    echo "${warp_prefix}-ubuntu-${label}-${architecture}-${core}x${spot}"
                done
            done
        done
    done
}

generate_macos_runner_labels() {
    if [ "$WARP_ENV" == "warpbuild-prod" ]; then
        local cores=(6)
    else
        local cores=(3)
    fi
    local labels=(13 14 15 latest)
    local architectures=(arm64)

    for core in "${cores[@]}"; do
        for label in "${labels[@]}"; do
            for architecture in "${architectures[@]}"; do
                echo "${warp_prefix}-macos-${label}-${architecture}-${core}x"
            done
        done
    done
}

generate_windows_runner_labels() {
    local cores=(2 4 8 16 32)
    local labels=(2022 latest)
    local architectures=(x64)

    # Currently Windows spot isn't available due to quota issues on Azure
    # local suffixes=('' -spot)
    local suffixes=('')

    for core in "${cores[@]}"; do
        for label in "${labels[@]}"; do
            for architecture in "${architectures[@]}"; do
                for spot in "${suffixes[@]}"; do
                    echo "${warp_prefix}-windows-${label}-${architecture}-${core}x${spot}"
                done
            done
        done
    done
}

generate_all_labels() {
    if [ "$RUN_UBUNTU" == "true" ]; then
        generate_ubuntu_runner_labels
    fi

    if [ "$RUN_MACOS" == "true" ]; then
        generate_macos_runner_labels
    fi

    if [ "$RUN_WINDOWS" == "true" ]; then
        generate_windows_runner_labels
    fi
}

# convert to json array
generate_all_labels | jq -cRs 'split("\n") | map(select(length>0))'