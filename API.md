# BaaS API Usage

## Methods

- POST to create new information
- GET to read/retrieve information
- PUT to update (existing) information
- DELETE to delete (existing) information

## Data formats

- API input should be formatted as JSON.
- API output is depending on content negotiation (Accept header).

## Authentication

- All operations (GET/POST/PUT/DELETE) may be authenticated using an
  Authorization header of type Token.
- Plain HTTP Basic Authentication may be used for GET operations.

## Resources

- Domains
- Users
- Keys
- Nodes
- Platforms
- Applications
- Servers
- Schedules
- Policies

### Domains

- domain: fully qualified domain name (e.g., 'example.com')
- tag: short version of the domain name (e.g. 'example')
- description: domain description
- servers: list of TSM servers
- deduplication: percent of data not stored due to deduplication

#### List all domains (global admin)

    curl -v \
        --header "Authorization: Token dXNlcm5hbWU6cGFzc3dvcmQ" \
        http://127.0.0.1:3000/domains

#### Create new domain (global admin)

    curl -v \
        --header "Authorization: Token dXNlcm5hbWU6cGFzc3dvcmQ" \
        --data description="Example Inc." \
        http://127.0.0.1:3000/domains

#### Show domain information (global admin, domain admin)

    curl -v \
        --header "Authorization: Token dXNlcm5hbWU6cGFzc3dvcmQ" \
        http://127.0.0.1:3000/domains/example.com

#### Delete domain (global admin)

    curl -v \
        --header "Authorization: Token dXNlcm5hbWU6cGFzc3dvcmQ" \
        -X DELETE \
        http://127.0.0.1:3000/domains/example.com

#### Show domain users (global admin, domain admin)

    curl -v \
        --header "Authorization: Token dXNlcm5hbWU6cGFzc3dvcmQ" \
        http://127.0.0.1:3000/domains/example.com/users


#### Show domain nodes (global admin, domain admin)

    curl -v \
        --header "Authorization: Token dXNlcm5hbWU6cGFzc3dvcmQ" \
        http://127.0.0.1:3000/domains/example.com/nodes


### Users

- identity: federated user identity
- domain: user domain name
- authorized\_keys: list of user's keys
- cost\_centers: list of acceptable cost centers
- admin\_domain: set if user is domain admin
- admin\_global: set if user is global admin


#### Create new user (global admin)

    curl -v \
        --header "Authorization: Token dXNlcm5hbWU6cGFzc3dvcmQ" \
        --data identity=user@example.com \
        --data domain=example.com \
        http://127.0.0.1:3000/users

#### Show user information (global admin, domain admin, self)

    curl -v \
        --header "Authorization: Token dXNlcm5hbWU6cGFzc3dvcmQ" \
        http://127.0.0.1:3000/users/user@example.com

#### Delete user (global admin)

    curl -v \
        --header "Authorization: Token dXNlcm5hbWU6cGFzc3dvcmQ" \
        -X DELETE \
        http://127.0.0.1:3000/users/user@example.com


### Keys

- identity: federated user identity
- access\_key\_id: (generated)
- secret\_access\_key: (only readable upon creation)
- description: key description
- impersonator : set if user is allowed to impersonate other users

#### Create new API key

    curl -v \
        --header "Authorization: Token dXNlcm5hbWU6cGFzc3dvcmQ" \
        --data name=ipnett.se \
        http://127.0.0.1:3000/keys

#### Delete API key

    curl -v \
        --header "Authorization: Token dXNlcm5hbWU6cGFzc3dvcmQ" \
        -X DELETE \
        http://127.0.0.1:3000/keys/xyzzy

#### List all API key (global admin)

    curl -v \
        --header "Authorization: Token dXNlcm5hbWU6cGFzc3dvcmQ" \
        http://127.0.0.1:3000/keys

### Nodes

- hostname: node hostname (FQDN, optional)
- description: node description (optional)
- identity: node owner identity
- domain: node domain name
- mail: email address of administrator
- nodename: TSM node name
- password: TSM node password (only readable upon creation and rekey)
- server: TSM server name (FQDN)
- platform: node platform (operating system)
- application: node application (use)
- cost\_center: node cost center
- locked\_by\_user: set if node is locked by the user
- locked\_by\_service: set if node is locked by the server provider
- encryption: set if data should be encrypted before backup
- deduplication: set if data deduplication is enabled
- schedule: list of associated backup schedules
- policy: node backup policy


#### Create new backup node

    curl -v \
        --header "Authorization: Token dXNlcm5hbWU6cGFzc3dvcmQ" \
        --data hostname=server18.example.com \
        http://127.0.0.1:3000/nodes

#### Delete backup node

    curl -v \
        --header "Authorization: Token dXNlcm5hbWU6cGFzc3dvcmQ" \
        -X DELETE \
        http://127.0.0.1:3000/nodes/Eeph2jome7

#### Show backup node information

    curl -v \
        --header "Authorization: Token dXNlcm5hbWU6cGFzc3dvcmQ" \
        http://127.0.0.1:3000/nodes/Eeph2jome7

#### Get TSM configuration file

    curl -v \
        --header "Authorization: Token dXNlcm5hbWU6cGFzc3dvcmQ" \
        http://127.0.0.1:3000/nodes/Eeph2jome7/config

#### Regenerate node password

    curl -v \
        --header "Authorization: Token dXNlcm5hbWU6cGFzc3dvcmQ" \
        -X POST \
        http://127.0.0.1:3000/nodes/Eeph2jome7/rekey


### Platforms

- name: platform name
- description: platform description


#### Show available platforms

    curl -v \
        --header "Authorization: Token dXNlcm5hbWU6cGFzc3dvcmQ" \
        http://127.0.0.1:3000/platforms


### Applications

- name: application name
- description: application description

#### Show available applications

    curl -v \
        --header "Authorization: Token dXNlcm5hbWU6cGFzc3dvcmQ" \
        http://127.0.0.1:3000/applications
	

### Servers

- hostname: server hostname (FQDN)
- description: server description
- utilization: percent full (of maximum capacity)

#### List all available servers (global admin)

    curl -v \
        --header "Authorization: Token dXNlcm5hbWU6cGFzc3dvcmQ" \
        --header "Accept: application/json" \
        http://127.0.0.1:3000/servers

### Schedules

- name: schedule name
- description: schedule description

#### Show available backup schedules

    curl -v \
        --header "Authorization: Token dXNlcm5hbWU6cGFzc3dvcmQ" \
        http://127.0.0.1:3000/nodes/Eeph2jome7/schedules


### Backup Policies

- name: backup policy name
- description: backup policy description

#### Show available backup policies

    curl -v \
        --header "Authorization: Token dXNlcm5hbWU6cGFzc3dvcmQ" \
        http://127.0.0.1:3000/nodes/Eeph2jome7/policies
