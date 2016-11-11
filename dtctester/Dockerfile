FROM microsoft/windowsservercore

WORKDIR /dtctester

COPY /files .

ENV MSDTC_SQLSERVER_HOSTNAME sqlserver
ENV MSDTC_SQLSERVER_PORT 1433
ENV MSDTC_SQLSERVER_USER sa
ENV MSDTC_SQLSERVER_PASSWORD Passw0rd
ENV MSDTC_TEST_DATABASE ODBCTest

CMD ["powershell", ".\\entrypoint.ps1", "-Verbose"]