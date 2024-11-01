#!/bin/bash

# Step 1: Search for a virtual environment containing 'bin/activate'
echo "Searching for virtual environments..."
venvs=( $(find . -type f -name "activate" -path "*/bin/activate" -printf '%h\n' | sed 's|/bin||' | sort -u) )

if [ ${#venvs[@]} -eq 0 ]; then
    echo "No virtual environments found."
    exit 1
elif [ ${#venvs[@]} -eq 1 ]; then
    venv=${venvs[0]}
else
    echo "Multiple virtual environments found:"
    for i in "${!venvs[@]}"; do
        echo "$((i+1)): ${venvs[$i]}"
    done
    read -p "Select the virtual environment number: " choice
    venv=${venvs[$((choice-1))]}
fi

# Step 2: Activate the chosen virtual environment
activate_script="$venv/bin/activate"
if [ -f "$activate_script" ]; then
    echo "Activating virtual environment at $venv"
    source "$activate_script"
else
    echo "Activation script not found at $activate_script. Exiting."
    exit 1
fi

# Step 3: Find Django project by searching for manage.py
echo "Searching for Django project directories..."
projects=( $(find . -type f -name "manage.py" -printf '%h\n') )

if [ ${#projects[@]} -eq 0 ]; then
    echo "No Django projects found."
    deactivate
    exit 1
elif [ ${#projects[@]} -eq 1 ]; then
    project_dir=${projects[0]}
else
    echo "Multiple Django projects found:"
    for i in "${!projects[@]}"; do
        echo "$((i+1)): ${projects[$i]}"
    done
    read -p "Select the Django project number: " choice
    project_dir=${projects[$((choice-1))]}
fi

cd "$project_dir"
echo "Changed directory to Django project at $project_dir"

# Step 4: Check for active ports and increment for the server
used_ports=$(netstat -tuln | grep LISTEN | awk '{print $4}' | grep -o '[0-9]*$' | sort -n | uniq)
starting_port=8000
for port in $used_ports; do
    if [ $starting_port -eq $port ]; then
        ((starting_port++))
    fi
done

# Step 5: Prompt to run the server in the background
read -p "Do you want to run the Django server in the background? (y/n): " run_in_background

# Step 6: Start the Django server based on the user's choice
if [[ $run_in_background == "y" || $run_in_background == "Y" ]]; then
    echo "Starting Django server in the background on port $starting_port"
    nohup python3 manage.py runserver 0.0.0.0:$starting_port &> django_server.log &
    echo "Server started in the background. Output is logged to django_server.log."
else
    echo "Starting Django server on port $starting_port in the foreground"
    python3 manage.py runserver 0.0.0.0:$starting_port
fi

# Script end

