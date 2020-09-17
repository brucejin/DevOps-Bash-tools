#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-09-15 14:52:47 +0100 (Tue, 15 Sep 2020)
#
#  https://github.com/HariSekhon/bash-tools
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/HariSekhon
#

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1090
. "$srcdir/lib/utils.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
Lists all tags for the given Google Cloud Registry docker image

Each tag for the given image is output on a separate line for easy further piping and filtering

If the image isn't found in GCR, will return nothing and no error code since this is the default GCloud SDK behaviour

Requires GCloud SDK to be installed and configured
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="<gcr.io>/<project_id>/<image>:<tag>"

help_usage "$@"

num_args 1 "$@"

image="$1"

regex='^([^\.]+\.)?gcr\.io/[^/]+/[^:]+$'
if ! [[ "$image" =~ $regex ]]; then
    usage "unrecognized GCR image name - should be in a format matching this regex: $regex"
fi

gcloud container images list-tags "$image" --format='csv[no-heading,delimiter="\n"](tags[])' |
grep -v '^[[:space:]]*$'