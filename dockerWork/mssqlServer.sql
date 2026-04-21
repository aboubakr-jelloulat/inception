

docker image : docker run -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=StrongP@ssw0rd123!' -e 'MSSQL_PID=Express' -p 1433:1433 -d mcr.microsoft.com/mssql/server:2019-latest


✔ Server name: localhost,1433

✔ Authentication: SQL Login

User: sa

Password: StrongP@ssw0rd123!

✔ Important:
Do NOT use Trust server certificate randomly disabled/enabled
    Try:
    Encrypt = Optional (or Disabled if needed)
