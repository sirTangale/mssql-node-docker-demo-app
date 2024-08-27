#run the setup script to create the DB and the schema in the DB
#do this in a loop because the timing for when the SQL instance is ready is indeterminate
#!/bin/bash

LOG_FILE="/tmp/mssql-log.txt"

# Function to log messages
log_message() {
    local message="$1"
    echo "$(date +"%Y-%m-%d %T"): $message" >> "$LOG_FILE"
}

# Wait for SQL Server to be started
for i in {1..100}; do
    /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P Yukon900 -d master -Q "SELECT 1" -C
    if [ $? -eq 0 ]; then
        log_message "SQL Server is up and running"
        break
    else
        log_message "Waiting for SQL Server to be ready... Attempt $i"
        sleep 5
    fi
done

# Check if SQL Server is up and running
/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P Yukon900 -d master -Q "SELECT 1" -C
if [ $? -ne 0 ]; then
    log_message "SQL Server is not accessible after waiting. Exiting."
    exit 1
fi

# Run the init script
/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P Yukon900 -d master -i setup.sql -C
if [ $? -eq 0 ]; then
    log_message "init.sql setup completed successfully"
else
    log_message "init.sql setup failed"
fi

#import the data from the csv file
/opt/mssql-tools18/bin/bcp DemoData.dbo.Products in "/usr/src/app/Products.csv" -c -t',' -S localhost -U sa -P Yukon900


