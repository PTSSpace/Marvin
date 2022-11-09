
<h1 align="center">
  Marvin
</h1>


## About 
MARVIN is an Open Source Inventory, Supply Chain and Traceability System. It is designed to comply with EN 9100 and implemented at Planetary Transportation Systems GmbH.

## Contributors
MArvIN can only exist thanks to the support of PTS and the Budibase community.

## License
Copyright (c) 2022 [Planetary Transportation Systems GmbH](https://www.pts.space). All rights reserved. The software is distributed under GPL 3 License attached in this repository

## Features
MARVIN is a Planetary Transportation Systems GmbH internally developed, web-based tool to trace PCB Design, Production and Testing for space applications.

Key Features
* Traceability of Production Processes
* Component Batch identification and testing
* Assembly traceability

* Based on ECSS and EN 9001/9100 requirements
* Full forward and backward traceability
* Extended Customisability for flexible usage patterns

### User Friendly
Marvin delivers an integrated system for highly detailed Identification and Traceability reports with user friendly data entry for compliance with regulators. It provides Tracking of your raw materials through the production chain from suppliers, locations, transport, tests and product assembly. 

### Adaptable
Based on the low code platform Budibase and postgreSQL, MArvIN is both, easy to adapt and fast to integrate. 

## Setup and Installation
Marvin was tested and developed using Ubuntu 20.04. Other operating systems will most probably work.

### Minimum dependencies
* [postgreSQL](https://www.postgresql.org/download/linux/ubuntu/)
* [Docker](https://www.docker.com)
* [Budibase](https://docs.budibase.com/docs/budibase-cli-setup)

### Recommended
* [phpPgAdmin](https://github.com/phppgadmin/phppgadmin/releases)

### Setup


#### Database
Start posgreSQL
```
sudo systemctl start postgresql.service
```
[Import](https://www.postgresql.org/docs/8.1/backup.html#BACKUP-DUMP-RESTORE) Database structure 
```
psql marvin < marvin_db_(version).sql
```
#### Frontend
##### Initialize Budibase
Initialize and start budibase. If you cannot start using "budi", change directory to the chosen install path.
``` 
budi hosting --init

budi hosting --start
```

After some time Budibase will be available via HTTP at the configured port number. (default: http://127.0.0.1:10000)

##### Install Frontend 
Import the frontend file using the import tool.


## How to use

The data in Marvin is stored within a PostgreSQL Database. The simplified data diagram below shows a course overview of its structure. The tables Parts and Designs contain "abstract" entities of which "real world" manifestations exist in "Components" & "Products. The items in "Components" & "Products" can be N:N related, meaning multiple components can be added to multiple products. Furthermore for many entities in the database tests & events can be saved which happened to a specific entity (e.g. batch testing, incoming inspections, etc).

![database_schema_simple](doc/simplified_db_schema.jpg)