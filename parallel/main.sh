#!/bin/bash

TOTAL_WORKERS=2
TASKS=(10 14 15 3 24 32 2 25 24 2 21)
NEXT_TASK=0
PIDS=( )

for (( i = 0; i < TOTAL_WORKERS; i++ )); do
    TASK=${TASKS[$NEXT_TASK]}
    (( NEXT_TASK+=1 ))
    if [[ -n $TASK ]]; then
        ./worker.sh "$TASK"&
        PIDS+=( "$!" )
    fi
done

while [[ ${#PIDS[@]} != 0 ]]; do
    for INDEX in "${!PIDS[@]}"; do
        PID=${PIDS[$INDEX]}
        kill -0 "$PID" 2&>1 > /dev/null
        if [[ $? = 1 ]]; then
            unset PIDS["$INDEX"]
            TASK=${TASKS[$NEXT_TASK]}
            (( NEXT_TASK+=1 ))
            if [[ -n $TASK ]]; then
                ./worker.sh "$TASK"&
                PIDS+=( "$!" )
            fi
        fi
    done
    sleep 1
done
