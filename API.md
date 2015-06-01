# RESTinTSM - a RESTful API for IBM TSM

## General

### Methods

- POST to create new information
- GET to read/retrieve information
- PUT to update (existing) information
- DELETE to delete (existing) information

### Data formats

- API input should be formatted as JSON.
- API output is depending on content negotiation (Accept header).

### Authentication

- Plain HTTP Basic Authentication may be used for GET operations.
- All operations (GET/POST/PUT/DELETE) may be authenticated using an
  Authorization header of type Token (similar to HTTP Basic Authentication,
  with "Basic" replaced with "Token").
- Use _access key indentifier_ as username and _secret access key_ as password.




## Domains

Domains have a fully qualified domain name (e.g. 'example.com'), as well as a
shorter domain tag (e.g. 'example') and a description. Each domain is assigned
zero or more TSM servers.

### List All Domains

#### Resource

    GET https://hostname/tsm/v1/domains

#### Response

Returns a list of href, domain and tag for all domains.

### View Domain

#### Resource

    GET https://hostname/tsm/v1/domains/DOMAIN

#### Response

Returns a _200 OK_ response containing the following information:

- **domain** - fully qualified domain name (e.g., 'example.com')
- **tag** - short version of the domain name (e.g. 'example')
- **description** - domain description
- **servers** - list of TSM servers
- **deduplication** - percent of data not stored due to deduplication (weighted
  average across all TSM servers used by the domain)

### Create Domain

#### Resource

    POST https://hostname/tsm/v1/domains

#### Request

_Required Parameters:_

- **domain** - fully qualified domain name (e.g., 'example.com')
- **tag** - short version of the domain name (e.g. 'example')
- **description** - domain description

_Optional Parameters:_

- **servers**

#### Response

Returns a _201 Created_ response, with a _Location_ header pointing to the
created resources.

### Delete Domain

#### Resource

    DELETE https://hostname/tsm/v1/domains/DOMAIN

### Update Domain

#### Resource

    PUT https://hostname/tsm/v1/domains/DOMAIN

#### Request

_Optional Parameters:_

- **description** - domain description
- **servers** - list of TSM servers




## Users

### List All Users

List all users or users in a single domain. Optionally display domain
administrators only.

#### Resource

    GET https://hostname/tsm/v1/users
    GET https://hostname/tsm/v1/domains/DOMAIN/users
    GET https://hostname/tsm/v1/domains/DOMAIN/users?admin_domain=1

#### Response

Returns a list of href, domain and identity for all users.

### View User

#### Resource

    GET https://hostname/tsm/v1/users/IDENTITY

#### Response

Returns a _200 OK_ response containing the following information:

- **identity** - federated identity
- **domain** - fully qualified domain name (e.g., 'example.com')
- **authorized\_keys**
- **cost\_centers** - list of cost centers users is authorized to use
- **admin\_global** - user is global administrator
- **admin\_domain** - user is domain administrator

### Create User

#### Resource

    POST https://hostname/tsm/v1/users

#### Request

_Required Parameters:_

- **identity** - federated identity

_Optional Parameters:_

- **cost\_centers** - list of cost centers users is authorized to use
- **admin\_global** - user is global administrator
- **admin\_domain** - user is domain administrator

#### Response

Returns a _201 Created_ response, with a _Location_ header pointing to the
created resources.

### Delete User

#### Resource

    DELETE https://hostname/tsm/v1/users/IDENTITY

#### Request

#### Response

### Update User

#### Resource

    PUT https://hostname/tsm/v1/users/IDENTITY

#### Request

_Optional Parameters:_

- **cost\_centers** - list of cost centers users is authorized to use
- **admin\_global** - set if user is global administrator
- **admin\_domain** - set if user is domain administrator





## Keys

### List All Keys

#### Resource

    GET https://hostname/tsm/v1/keys
    GET https://hostname/tsm/v1/users/IDENTITY/keys

#### Response

### View Key

#### Resource

    GET https://hostname/tsm/v1/keys/ACCESS-KEY-ID

#### Response

- **access\_key\_id**
- **identity** - federated identity
- **description** - key description
- **impersonator**  - key may be used to impersonate anyone
- **readonly** - key may only be used to read information
- **enroller** - key may only be used to enroll nodes
- **enroller\_count** - key is limited to enroll this may nodes

### Create Key

#### Resource

    POST https://hostname/tsm/v1/keys

#### Request

_Optional Parameters:_

- **description** - key description
- **readonly** - key may only be used to read information
- **enroller** - key may only be used to enroll nodes
- **enroller\_count** - key is limited to enroll this may nodes

#### Response

Returns a _201 Created_ response, with a _Location_ header pointing to the
created resources, as well as the following data:

- **access\_key\_id**
- **secret\_access\_key**

### Delete Key

#### Resource

    DELETE https://hostname/tsm/v1/keys/ACCESS-KEY-ID

#### Request

#### Response




## Nodes

### List All Nodes

List all nodes, nodes in a specific domain or nodes owned by a specific user.
Optionally filter by hostname.

#### Resource

    GET https://hostname/tsm/v1/nodes
    GET https://hostname/tsm/v1/nodes?hostname=HOSTNAME
    GET https://hostname/tsm/v1/users/IDENTITY/nodes
    GET https://hostname/tsm/v1/users/IDENTITY/nodes?hostname=HOSTNAME
    GET https://hostname/tsm/v1/domains/DOMAIN/nodes
    GET https://hostname/tsm/v1/domains/DOMAIN/nodes?hostname=HOSTNAME

#### Response

### View Node

#### Resource

    GET https://hostname/tsm/v1/nodes/NODENAME

#### Response

- **nodename** - TSM nodename
- **hostname** - node hostname
- **mail** - email address of node contact
- **description** - node description
- **identity** - node owner identity
- **domain** - node domain
- **server** - TSM server
- **platform** - node platform (operating system)
- **application** - node application (use)
- **cost\_center** - node cost center
- **locked\_by\_user** - node is locked by the user
- **locked\_by\_service** - node is locked by the provider
- **encryption** - data should be encrypted before backup
- **deduplication** - data deduplication is enabled
- **compression** - data compression is enabled
- **allow\_backup\_delete** - backup delete allowed
- **activated** - node has ever contacted the server
- **schedules** - list of associated backup schedules
- **policy** - node backup policy
- **last_hostname** - Last hostname reported via TSM
- **last\_ip\_address** - Last IP address reported via TSM
- **last\_mac\_address** - Last MAC address reported via TSM
- **last\_access\_time** - Last known contact reported via TSM

### Create Node

#### Resource

    POST https://hostname/tsm/v1/nodes

#### Request

_Required Parameters:_

- **cost\_center** - node cost center

_Optional Parameters:_

- **hostname** - node hostname
- **mail** - email address of node contact
- **description** - node description
- **encryption** - data should be encrypted before backup
- **deduplication** - data deduplication is enabled
- **compression** - data compression is enabled
- **allow\_backup\_delete** - backup delete allowed
- **platform** - node platform (operating system)
- **application** - node application (use)

#### Response

Returns a _201 Created_ response, with a _Location_ header pointing to the
created resources.

- **nodename** - TSM nodename
- **password** - TSM password
- **server** - TSM server

### Delete Node

#### Resource

    DELETE https://hostname/tsm/v1/nodes/NODENAME

#### Request

#### Response

### Update Node

#### Resource

    PUT https://hostname/tsm/v1/nodes/NODENAME

#### Request

_Optional Parameters:_

- **identity** - node owner identity
- **schedules** - list of associated backup schedules
- **policy** - node backup policy
- **hostname** - node hostname
- **mail** - email address of node contact
- **platform** - node platform (operating system)
- **description** - node description
- **cost\_center** - node cost center
- **locked\_by\_user** - node is locked by the user
- **locked\_by\_service** - node is locked by the provider
- **allow\_backup\_delete** - backup delete allowed

#### Response

### Request Node Rekeying

#### Resource

    POST https://hostname/tsm/v1/nodes/NODENAME/rekey

#### Request

#### Response

- **nodename** - TSM nodename
- **password** - TSM password

### Get Node TSM Configuration

#### Resource

    GET https://hostname/tsm/v1/nodes/NODENAME/config

#### Request

#### Response

An zip archive (application/zip) containing TSM configuration for the node.

### Get Node TSM Software

#### Resource

    GET https://hostname/tsm/v1/nodes/NODENAME/software

#### Request

#### Response

A file containing TSM software for the node.

### Get Possible Node Schedules

#### Resource

    GET https://hostname/tsm/v1/nodes/NODENAME/schedules

#### Request

#### Response

- **name** - schedule name
- **description** - schedule description

### Get Possible Node Backup Policies

#### Resource

    GET https://hostname/tsm/v1/nodes/NODENAME/policies

#### Request

#### Response

- **name** - backup policy name
- **description** - backup policy description




## Platforms

### List All Platforms

#### Resource

    GET https://hostname/tsm/v1/platforms

#### Response

- **name** - platform name
- **description** - platform description




## Applications

### List All Applications

#### Resource

    GET https://hostname/tsm/v1/applications

#### Response

- **name** - application name
- **description** - application description




## Servers

### List All Servers

#### Resource

    GET https://hostname/tsm/v1/servers

#### Response

- **hostname** - server hostname (FQDN)
- **description** - server description
- **utilization** - percent full (of maximum capacity)
