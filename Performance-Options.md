Some hints regarding TSM Backup client performance.

Tuning the client options can help you use more of the local resources
to speed up the backup transfers, at the cost of more CPU, Network and
I/O.

Since we assume most people have decent internet links now, getting
the data over the wire as quickly as possible is probably the most
important part in order to finish the backup and restore tasks as fast
as possible.

Also, since we force encryption on all transport, CPU resources limit
somewhat how fast a single stream from youcan ship data over to our
end. Most servers and clients today have more than one core/thread and
often more than one CPU, so adding a few more threads for TSM to ship
data will definitely help.

The client options discussed in this guide are set in the TSM config
file "dsm.sys", found by default in different places on different
OSes: 

Linux/Unix:
"/opt/tivoli/tsm/client/ba/bin/dsm.sys"

MacOSX:
"/Library/Application Support/tivoli/tsm/client/ba/bin/dsm.sys"

Windows:
"C:\Program Files\tivoli\tsm\baclient\dsm.sys"

These are simple text files and can be edited with any simple text
editor of your choice. Remember the default comment char is * and not
#.

-- PARALELLISM

In order to allow more resources while shipping data over, and to
allow more than one thread to collect lists of files needing backup
since the last time, the option RESOURCEUTILIZATION needs to be bumped
from the default value to something larger, upto 10. This means upto 8
streams could be used for communicating with the server, and upto 4
threads looking over the local file systems for new and changed
files. The complete matrix of the meaning of settings 1 to 10 is
available at

<http://publib.boulder.ibm.com/tividd/td/TSMM/SC32-9101-01/en_US/HTML/SC32-9101-01.htm#_Toc58484215>
but the general idea is that a higher value leads to more cores being
dedicated to finding and sending files.

Add:

RESOURCEUTILIZATION 5

to the dsm.sys file, and the next run will use up a few more cores on
your server, hopefully shortening the time it takes for the actual
network transfer.

This could be useful to make the initial finish faster, and later
incremental runs could run with a lower setting in order to leave more
for the regular tasks of your server if it is acceptable to have
longer run times in order to not peg all CPU cores while running.

-- NETWORK SETTINGS

While tuning you might want to bump TSM client tcp window limits and
buffer sizes too, since many of the options are defaulting to rather
conservative low values that were appropriate a long time ago. Among
the ones that may have a positive impact while bumping memory usage up
a meg or two are:

TCPBUFSIZE (default is 32, max 512 in kilobytes)

TCPWINDOWSIZE (default 63/64, max 2048 in kilobytes) 

This may also need a bump or two in the appropriate sysctls if your
Linux or Solaris OS is old. Newer machines either have better defaults
or even auto-tune some of these without need for manual tweaking.
Generic network tuning guides are plenty on the net.

(Make sure you find recent ones, since many guides are outdated and
focus on not starving a 64M ram machine with a "fast" 100Mbit/s
interface)

-- CPU NATIVE AES INSTRUCTIONS

On the topic of encrypting traffic, the IBM software crypto software
that comes with the TSM client (gsk8, Global Security Kit v8) should
be as recent as possible. Newer versions include support for native
AES-NI instructions found on Intel CPUs from the models
Westmere/SandyBridge and newer AMDs. More complete list is available
here: http://en.wikipedia.org/wiki/AES_instruction_set#Supporting_CPUs

MacOSX clients get a recent GS kit along with the TSM v7.1x client
bundle, Linux users should check their rpm database: rpm -qa |grep gsk

gskssl64-8.0-50.20.x86_64
gskcrypt64-8.0-50.20.x86_64

to make sure it is version 8.0.5x or higher in order to get native
support for AES-NI in case your CPU does have it.

IBM claims Sparc64 Ultra T1 and T2 CMT processors with on-CPU crypto
chips will benefit also, but we haven't tested any of those for crypto
performance. 

-- LOCAL DEDUPLICATION AND COMPRESSION

Among all the options to tweak and tune how to send data faster, the
overall best option is to not send it at all of course. This comes
with a price, but depending on how you weigh your resources, it still
is a choice you can make. Compression is rather simple, a yes/no
option to have all data compressed before going over the wire like
this:

COMPRESSION yes

Compression eats cpu but attempts to minimize the data that has to be
sent over, and also minimized the amount one has to encrypt/decrypt at
both ends.

Another way to minimize the amount of data you have to send is using
deduplication, where you match outgoing datablock checksums with lists
of previously sent datablocks. When done serverside, it will match
against other machines in your own domain, so backing up lots of
machines using the same operating system will reduce the amount of
used space since the remote end will only store each such file once.
When done locally, it means you can have log files that append only a
small amount of data (or get renamed/rotated) where most of the
content is identical and only send over the unique parts.

Using local deduplication means that you keep a local cache (default
256M) of the hashes you have sent earlier, so that your client can
look up all datablocks before shipping them over the network, and in
the case where a duplicate checksum/hash is found, you can skip past
it and move on to the next file/datablock. Like compression, this is a
local operation, which trades CPU and resources at every client for a
reduction in total network traffic and backup time.

Still, if you know you have lots of similar/identical files, or large
files that slowly grow over time, this will make sure only new parts
of those files are sent over the network. In our service offering, we
will be removing duplicate data server-side also, so the end result
does not differ much in terms of where the deduplication happens, but
sending the same data over and over might be worth preventing. 
 
To enable client side deduplication, simply add:

DEDUPLICATION yes

and

ENABLEDEDUPCACHE yes

If you don't enable the DEDUPCACHE, it will ask the server it this
particular piece of data has been seen before, so this may be a far
slower option for large backup jobs compared to checking against a
local file.  It will reduce the network traffic though. Good for
satellite links or cell phone internet I guess.

To set the local cache size (in megabytes, 256 default):

DEDUPCACHESIZE 2048

To place it somewhere specific:

DEDUPCACHEPATH /path/to/cache/dir/

Using deduplication together with compression has no negative impact,
whenever the client has something to send over the network to the
server, it will be compressed.  The deduplication decision has already
been made at that point.






