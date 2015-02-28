# recursive file stat benchmarking utility

A utility that will perform recursive stat() on all files at and below a
given starting directory.

Uses `fstatat` instead of `lstat` that `recursive-stat` does.
`fstatat` is a stat relative to the dir entry, rather than recursive
lookup through a full path, which saves cycles. Cached entries makes the
save in CPU cycles / memory lookups pretty slim however.

Useful to measure a system's IO performance for e.g. file backup purposes.
A file backup software which uses file stat information for determining
whether a file has changed or not, is limited by this performance of a system.

## Compilation

    cd /usr/local/src
    git clone https://github.com/IPnett/cloud-BaaS
    cd cloud-BaaS/unix/baselining/recursive-fstat
    make

## Usage example

    # Clear dirty objects and then free all cached pages, dentries and inodes
    sudo sync ; sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
    # run the tool
    sudo ./recursive-fstat /
