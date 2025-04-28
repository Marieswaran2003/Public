#!/bin/bash

# Define constants
USER_NAME="training18"
USER_HOME="/home/$USER_NAME"
PORTS=(8001 8002 8003 8004)
MARKS_PER_QUESTION=60
MAX_MARKS=300
PASSING_MARKS=210
TOTAL_MARKS=0

# Function to check if a container is running
validate_container() {
	    local container_name=$1
	        local expected_message=$2
		    local port=$3

		        echo "Validating container $container_name on port $port..."

			    # Check if the container is running under the correct user
			        if ssh training18@workstation podman ps --filter "name=$container_name" | grep -q "$container_name"; then
					        echo "  Container $container_name is running."
						    else
							            echo "  ERROR: Container $container_name is not running."
								            return 1
									        fi

										    # Test container response
										        local response
											    response=$(curl -s http://localhost:$port)

											        if [[ $response == "$expected_message" ]]; then
													        echo "  Response validated successfully: $response"
														        return 0
															    else
																            echo "  ERROR: Response mismatch. Got: $response, Expected: $expected_message"
																	            return 1
																		        fi
																		}

																	# Validate each question
																	echo "Starting validation..."

																	# Q1: Running Simple Containers
																	validate_container "acme-demo-html" "<html><body><h1>Welcome to Nginx</h1></body></html>" 8001
																	if [[ $? -eq 0 ]]; then
																		    TOTAL_MARKS=$((TOTAL_MARKS + MARKS_PER_QUESTION))
																	fi

																	# Q2: Interacting with the Containers
																	validate_container "acme-demo-nginx" "<html><body><h1>Im running successfully man all the best for your exams" 8002
																	if [[ $? -eq 0 ]]; then
																		    TOTAL_MARKS=$((TOTAL_MARKS + MARKS_PER_QUESTION))
																	fi

																	# Q3: Injecting Variables in to Containers
																# Validate containers running on the same port
																validate_container "acme_nginx_container_1" "Acme_Container_1" 8003
														
		STATUS_1=$1?														validate_container "acme_nginx_container_2" "Acme_Container_2" 8003
		STATUS_2=$2?
																
																if [[ $STATUS_1 -eq 0 || $STATUS_2 -eq 0 ]]; then		
			    														TOTAL_MARKS=$((TOTAL_MARKS + MARKS_PER_QUESTION))
																fi
																	# Q4: Building Custom Container Image
																	echo "Validating custom container images..."
echo "Validating custom container images..."

# Check if the SQL file exists in the specified directory
sql_file="/home/training18/projects/mariadb/exports/app.sql"
 echo "  SQL file found: $sql_file"

if [ -f "$sql_file" ]; then
	        TOTAL_MARKS=$((TOTAL_MARKS + MARKS_PER_QUESTION))
	else
		    echo "  ERROR: SQL file not found in $sql_file"
fi
																	# Q5: Multi-container Deployment

															echo "Validating network, volume, and containers..."
																
# Check if the network exists
network_name="acme-wp"
if ssh training18@workstation podman network ls | grep -q "$network_name"; then
	    echo "  Network '$network_name' created successfully."
    else
	        echo "  ERROR: Network '$network_name' not found."
		    exit 1  # If the network is not found, stop the script here.
fi

# Check if the volume exists
volume_name="acme-wp-backend"
 if ssh training18@workstation podman volume ls | grep -q "$volume_name"; then
	    echo "  Volume '$volume_name' created successfully."
    else
	        echo "  ERROR: Volume '$volume_name' not found."
		    exit 1  # If the volume is not found, stop the script here.
fi

volume_name="acme-wp-app"
if ssh training18@workstation podman volume ls | grep -q "$volume_name"; then
	    echo "  Volume '$volume_name' created successfully."
    else
	        echo "  ERROR: Volume '$volume_name' not found."
		    exit 1  # If the volume is not found, stop the script here.
fi

volume_name="acme-wordpress-data"

if ssh training18@workstation podman volume ls | grep -q "$volume_name"; then

	    echo "  Volume '$volume_name' created successfully."

    else
	        echo "  ERROR: Volume '$volume_name' not found."
		    exit 1  # If the volume is not found, stop the script here.
fi


# Check if the containers are running in the network
containers=("mariadb" "acme-wp-app" "acme-wordpress:1.0")
containers_running=true

for container in "${containers[@]}"; do
	    # Check if the container is running and connected to the correct network
	        if ssh training18@workstation podman ps --filter "name=$containers" | grep -q "$containers" && ssh training18@workstation podman inspect --format '{{.NetworkSettings.Networks.acme_network}}' $containers > /dev/null; then
			        echo "  Container '$container' is running and connected to network '$network_name'."
				    else
					            echo "  ERROR: Container '$container' is either not running or not connected to network '$network_name'."
						            containers_running=false
							        fi
							done
							
# If all checks passed, award marks
if [[ $containers_running == true ]]; then
	    TOTAL_MARKS=$((TOTAL_MARKS + MARKS_PER_QUESTION))
    else
	        echo "  ERROR: Some containers are not running or not connected to the correct network."
fi
# Q6: Troubleshooting Multi-container Stack

																	# Summary
																	echo "Validation completed."
																	echo "----------------------------------------"
																	echo "Total Marks Scored: $TOTAL_MARKS / $MAX_MARKS"

																	if [[ $TOTAL_MARKS -ge $PASSING_MARKS ]]; then
																		    echo "RESULT: PASSED"
																	    else
																		        echo "RESULT: FAILED"
																	fi

																	exit 0

