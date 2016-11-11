# **Distributed Transaction Coordinator Tester tool in a Windows container**
Contains Docker Compose file which starts SQL Server container and a client based on 
 [dtctester.exe][dtctester] to validate whether distributed transactions are possible
 between containers.

# How to use?
## Environment Information
Make sure you have a usable Windows environment with Docker Compose installed.
 The versions below are tested and compatible. 
```
PS C:\> [System.Environment]::OSVersion

Platform ServicePack Version      VersionString
-------- ----------- -------      -------------
 Win32NT             10.0.14393.0 Microsoft Windows NT 10.0.14393.0
```
```
PS C:\> docker version
Client:
 Version:      1.13.0-dev
 API version:  1.25
 Go version:   go1.7.1
 Git commit:   24582e8
 Built:        Tue Oct 18 09:06:49 2016
 OS/Arch:      windows/amd64

Server:
 Version:      1.13.0-dev
 API version:  1.25
 Go version:   go1.7.1
 Git commit:   24582e8
 Built:        Tue Oct 18 09:06:49 2016
 OS/Arch:      windows/amd64
```
```
PS C:\> docker-compose version
docker-compose version 1.8.1, build 004ddae
docker-py version: 1.10.3
CPython version: 2.7.12
OpenSSL version: OpenSSL 1.0.2h  3 May 2016
```
## Docker Compose
You need to allow TCP connection to the Docker daemon. Read this [blog post][docker-compose] to
 configure it or may try with the these steps:

1. Go to *%ProgramData%\docker\config*
2. Create *daemon.json* if it is not present
3. Add the following configuration to daemon.json
```
{
    "hosts": ["tcp://127.0.0.1:2375", "npipe:////./pipe/win_engine"]
}
```
4. Set the following environment variables
```
DOCKER_HOST="tcp://127.0.0.1:2375"
COMPOSE_HTTP_TIMEOUT=180
```
5. Restart Docker service
```
PS C:\> Restart-Service docker 
```
6. Build, run and observe
```
docker-compose build
docker-compose up
```

# What it does?
It starts a SQL Server container that creates a test database to be used from the dtctester tool. During start up
 of both containers their network, DTC and ODBC configurations are logged into the console. The containers try
 to ping one another which will validate that there aren't any connectivity problems.

The dtctester container executes the *dtctester.exe* tool which reports the DTC test status. After this the *Test-Dtc*
 cmdlet is executed which tries to validate the DTC setup and whether it i functional between the two containers. 

# Sample output that indicates problems with DTC configuration

```
dtctester_1  | VERBOSE: Running dtctester tool...
dtctester_1  | Executed: C:\dtctester\dtctester.exe
dtctester_1  | DSN:  sqlserver
dtctester_1  | User Name: sa
dtctester_1  | Password: Passw0rd
dtctester_1  | tablename= #dtc19901
dtctester_1  | Creating Temp Table for Testing: #dtc19901
dtctester_1  | Warning: No Columns in Result Set From Executing: 'create table #dtc19901 (ival int)'
dtctester_1  | Initializing DTC
dtctester_1  | Beginning DTC Transaction
dtctester_1  | Enlisting Connection in Transaction
dtctester_1  | Error:
dtctester_1  | SQLSTATE=25S12,Native error=-2147168242,msg='[Microsoft][ODBC SQL Server Driver]Distributed transaction error'
dtctester_1  | Error:
dtctester_1  | SQLSTATE=24000,Native error=0,msg=[Microsoft][ODBC SQL Server Driver]Invalid cursor state
dtctester_1  | Typical Errors in DTC Output When
dtctester_1  | a.  Firewall Has Ports Closed
dtctester_1  | -OR-
dtctester_1  | b.  Bad WINS/DNS entries
dtctester_1  | -OR-
dtctester_1  | c.  Misconfigured network
dtctester_1  | -OR-
dtctester_1  | d.  Misconfigured SQL Server machine that has multiple netcards.
dtctester_1  | Aborting DTC Transaction
dtctester_1  | Releasing DTC Interface Pointers
dtctester_1  | Successfully Released pTransaction Pointer.
dtctester_1  |
dtctester_1  | VERBOSE: Running Test-Dtc cmdlet...
dtctester_1  | Get-NetFirewallRule : There are no more endpoints available from the endpoint
dtctester_1  | mapper.
dtctester_1  | At C:\Windows\system32\WindowsPowerShell\v1.0\Modules\MsDtc\TestDtc.psm1:94
dtctester_1  | char:21
dtctester_1  | + ...     $rule = Get-NetFirewallRule -ID $ruleId  -ErrorVariable errorVari ...
dtctester_1  | +                 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
dtctester_1  |     + CategoryInfo          : NotSpecified: (MSFT_NetFirewallRule:root/standar
dtctester_1  |    dcimv2/MSFT_NetFirewallRule) [Get-NetFirewallRule], CimException
dtctester_1  |     + FullyQualifiedErrorId : Windows System Error 1753,Get-NetFirewallRule
dtctester_1  |
dtctester_1  | VERBOSE: Test-Dtc cmdlet failed...
dtctester_1  |  There are no more endpoints available from the endpoint mapper.
```

# BFE service cannot start
The suspected problem is that the Windows Firewall service cannot start due to
 failures in some of its dependances. This command lists all dependant services:
```
PS C:\> Get-Service BFE,MpsSvc,RpcEptMapper,RpcSs,DcomLaunch,MpsDrv

Status   Name               DisplayName
------   ----               -----------
Stopped  BFE                Base Filtering Engine
Running  DcomLaunch         DCOM Server Process Launcher
Running  MpsDrv             Windows Firewall Authorization Driver
Stopped  MpsSvc             Windows Firewall
Running  RpcEptMapper       RPC Endpoint Mapper
Running  RpcSs              Remote Procedure Call (RPC)
```
```
PS C:\> Get-Service BFE -DependentServices

Status   Name               DisplayName
------   ----               -----------
Stopped  WdNisSvc           Windows Defender Network Inspection...
Stopped  WdNisDrv           Windows Defender Network Inspection...
Stopped  SharedAccess       Internet Connection Sharing (ICS)
Stopped  RemoteAccess       Routing and Remote Access
Stopped  PolicyAgent        IPsec Policy Agent
Stopped  NcaSvc             Network Connectivity Assistant
Stopped  MpsSvc             Windows Firewall
Stopped  IKEEXT             IKE and AuthIP IPsec Keying Modules
```

[dtctester]: https://support.microsoft.com/en-us/kb/293799
[docker-compose]: https://blogs.technet.microsoft.com/virtualization/2016/10/18/use-docker-compose-and-service-discovery-on-windows-to-scale-out-your-multi-service-container-application/
