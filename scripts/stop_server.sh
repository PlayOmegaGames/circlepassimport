#!/bin/bash

# Check if the server is running
if ps aux | grep "[b]eam.smp" > /dev/null; then
    # Find the PID of the Elixir Phoenix server
    pid=$(ps aux | grep "[b]eam.smp" | awk '{print $2}')

    # Stop the server using the PID
   sudo kill $pid

    # Wait for the process to terminate
    while ps -p $pid > /dev/null; do
        sleep 1
    done

    echo "Server stopped successfully."
else
    echo "Server is not running."
fi