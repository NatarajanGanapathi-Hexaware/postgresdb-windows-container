# Ref: https://github.com/brogersyh/Dockerfiles-for-windows/blob/master/postgresql/dockerfile

FROM microsoft/windowsservercore
# FROM microsoft/nanoserver 

ENV PGDATA c:\\sql
ENV PGPORT 5432
#not using PGUSER here due to need to run createuser downstream to create role
ENV PGUSERVAR postgres
ENV PGDOWNLOADVER postgresql-9.5.2-1-windows-x64-binaries.zip

# download and extract binaries
RUN powershell wget http://get.enterprisedb.com/postgresql/%PGDOWNLOADVER% \
  -outfile %PGDOWNLOADVER%

RUN powershell expand-archive %PGDOWNLOADVER% \
  -force -destinationpath /postgresql

# reduce image size by removing download zip
RUN del %PGDOWNLOADVER%

#install VC 2013 runtime required by postgresql
#use chocolatey pkg mgr to facilitate command-line installations
RUN @powershell -NoProfile -ExecutionPolicy unrestricted -Command "(iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))) >$null 2>&1" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin
RUN choco install vcredist2013 -y

# copy dependent script(s)
COPY . /install

WORKDIR /postgresql/pgsql/bin

# init postgresql db cluster, config and create and start service
RUN powershell /install/init-config-start-service %PGDATA% %PGUSERVAR%

EXPOSE 5432
# start postgreSQL using the designated data dir
CMD powershell /install/start detached %PGDATA% %PGUSERVAR%


# Build
# Docker build -t postgres:1.0.6 .

#Run
# Docker run -it -p 5432:5432 -d postgres:1.0.6


# docker run -d -p 5432:5432 postgresql