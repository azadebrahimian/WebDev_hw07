#!/bin/bash

export MIX_ENV=prod
export PORT=4793

CFGD=$(readlink -f ~/.config/event_app)

if [ ! -e "$CFGD/base" ]; then
            echo "run deploy first"
            exit 1
fi

DB_PASS=$(cat "$CFGD/db_pass")
export DATABASE_URL=ecto://events:$DB_PASS@localhost/event_app_prod

SECRET_KEY_BASE=$(cat "$CFGD/base")
export SECRET_KEY_BASE

_build/prod/rel/event_app/bin/event_app start
