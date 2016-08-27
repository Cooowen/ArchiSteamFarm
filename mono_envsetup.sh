#!/bin/bash

MONO_DEBUG_IF_AVAILABLE() {
	local PREVIOUS_MONO_DEBUG="$MONO_DEBUG"

	# Add change if needed
	if [[ -z "$PREVIOUS_MONO_DEBUG" ]]; then
		export MONO_DEBUG="$1"
	elif echo "$PREVIOUS_MONO_DEBUG" | grep -Fq "$1"; then
		return 0
	else
		export MONO_DEBUG="${PREVIOUS_MONO_DEBUG},${1}"
	fi

	# If we did a change, check if Mono supports that option
	# If not, it will be listed as invalid option on line 1
	if mono "" 2>&1 | head -n 1 | grep -Fq "$1"; then
		export MONO_DEBUG="$PREVIOUS_MONO_DEBUG"
		return 1
	fi

	return 0
}

VERSION_GREATER() {
	if [[ "$1" = "$2" ]]; then
		return 1
	fi

	! VERSION_LESS_EQUAL "$1" "$2"
}

VERSION_GREATER_EQUAL() {
	! VERSION_LESS "$1" "$2"
}

VERSION_LESS() {
	if [[ "$1" = "$2" ]]; then
		return 1
	fi

	VERSION_LESS_EQUAL "$1" "$2"
}

VERSION_LESS_EQUAL() {
	[[  "$1" = "$(echo -e "$1\n$2" | sort -V | head -n 1)" ]]
}


MONO_VERSION="$(mono -V | head -n 1 | cut -d ' ' -f 5)"

if VERSION_GREATER_EQUAL "$MONO_VERSION" "4.6.0"; then
	MONO_DEBUG_IF_AVAILABLE "no-compact-seq-points"
fi
