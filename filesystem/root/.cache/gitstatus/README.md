The `gitstatusd-linux-x86_64` binary is preloaded in the `gitstatus` cache to prevent it
from needing to be downloaded at every first startup of the container, which was increasing
startup times considerably.

`gitstatus` is used to display in shell prompt the status of git repository of current
working directory.
