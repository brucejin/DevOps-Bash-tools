#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-06-24 01:17:21 +0100 (Wed, 24 Jun 2020)
#
#  https://github.com/harisekhon/bash-tools
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/harisekhon
#

# https://developer.spotify.com/documentation/web-api/reference/library/get-users-saved-tracks/

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1090
. "$srcdir/lib/spotify.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
Returns the URIs of a Spotify user's Liked Songs (aka Saved Tracks) using the Spotify API

Spotify track URIs can be used as backups to restore a playlist's contents or copying to a new playlist, or combined with spotify_set_tracks_uri_to_liked.sh

$usage_auth_msg

Caveat: due to limitations of the Spotify API, this requires an interactively authorized access token, which you will be prompted for if you haven't already got one in your shell environment. To set up an authorized token for an hour in your current shell, you can run the following command (make sure you don't have an access token in the environment from spotify_api_token.sh otherwise you will get a 401 error):

$usage_token_private
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="[<curl_options>]"

help_usage "$@"

# defined in lib/spotify.sh
# shellcheck disable=SC2154
url_path="/v1/me/tracks?limit=$limit&offset=$offset"

output(){
    jq -r '.items[] | [.track.uri] | @tsv' <<< "$output"
}

export SPOTIFY_PRIVATE=1

spotify_token

while not_null "$url_path"; do
    output="$("$srcdir/spotify_api.sh" "$url_path" "$@")"
    die_if_error_field "$output"
    url_path="$(get_next "$output")"
    output
done
