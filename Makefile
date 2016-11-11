# A Makefile which syncs files to a remote host.
# Copyright Jason Pepas, released under the terms of the MIT License.
# See https://github.com/pepaslabs/rsync-via-make
#
# If your editor doesn't know how to edit files on a remote host (and it isn't
# practical for you to use vim/emacs), this is a cheap substitute:
#
#   while true; do make; sleep 1; done
#
# Strategy:
# - Compare the file modification times against a stamp.
# - If they are more recent than the stamp, run rsync and update the stamp.

# Edit this rule to contain the destination server and filesystem path:
RSYNC_DESTINATION = example.com:/some/path/

# The stamp file is used to determine if any files have been modified since
# the last time we ran rsync.
STAMP_FILE := .rsync-stamp

# rsync will be run if any of $(SRC_FILES) have been modified since our last
# run (i.e., since the last time we touched the stamp file).
# $(SRC_FILES) starts out as all of the files in our current directory:
SRC_FILES := $(wildcard *)
# ...but we need to filter out the stamp file and this Makefile:
SRC_FILES := $(filter-out $(STAMP_FILE), $(SRC_FILES))
SRC_FILES := $(filter-out Makefile, $(SRC_FILES))

# By default, make runs the first rule which doesn't start with a dot, which is
# a problem for us, so we create an 'all' which runs our desired rule.
all: $(STAMP_FILE)

# Use rsync to sync the files in `pwd` to the remote host if any of them are
# more recent than our stamp file:
$(STAMP_FILE): $(SRC_FILES)
	rsync -av --exclude=Makefile --exclude=$(STAMP_FILE) . $(RSYNC_DESTINATION)
	touch $(STAMP_FILE)

# The "all" target does not refer to an real file, so mark it as being PHONY.
.PHONY: all
