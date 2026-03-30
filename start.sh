#!/bin/sh
set -e

# run actions in background
rasa run actions -p 5055 --debug &

# run core as main process
exec rasa run -m models --enable-api --cors "*" -p 5005 --debug