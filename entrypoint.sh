# run mport-data.sh in background and sqlservr in foreground, and start the app
/usr/src/app/import-data.sh & /opt/mssql/bin/sqlservr & npm start 
