// file system fstatat() timing tester.
// Copyright 2014 Martin Millnert, IPnett AB
// Based on http://rosettacode.org/wiki/Walk_a_directory/Recursively#Library:_POSIX
// http://stackoverflow.com/questions/7035733/unix-c-program-to-list-directories-recursively

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <fcntl.h>
#include <unistd.h>
#include <dirent.h>
#include <regex.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <err.h>

enum {
	WALK_OK = 0,
	WALK_BADPATTERN,
	WALK_NAMETOOLONG,
	WALK_BADIO,
};

#define WS_NONE		0
#define WS_RECURSIVE	(1 << 0)
#define WS_DEFAULT	WS_RECURSIVE
#define WS_FOLLOWLINK	(1 << 1)	/* follow symlinks */
#define WS_DOTFILES	(1 << 2)	/* per unix convention, .file is hidden */
#define WS_MATCHDIRS	(1 << 3)	/* if pattern is used on dir names too */

int files_matched = 0;
int opendirs = 0, stats = 0;
double opendirtime = 0, statstime = 0;
const char *COUNT_FMTSTRING = "\rFiles stat()'ed: %d";

int walk_recur(int fd, int spec)
{
	struct dirent *dent;
	DIR *dir;
	struct stat st;
	char *dname;
	int res, dirfd;
	int dlen, flen;
	struct timeval dt0, dt1, st0, st1;
	long long elapsed;
	double elapsed_s;

	res  = WALK_OK;			// default value

	gettimeofday(&dt0, 0);
	if (!(dir = fdopendir(fd))) {
		warn("can't open %d", fd);
		return WALK_BADIO;
	}
	gettimeofday(&dt1, 0);
	elapsed = (dt1.tv_sec-dt0.tv_sec)*1000000LL + dt1.tv_usec-dt0.tv_usec;
	elapsed_s = elapsed/(double)1000000;
	opendirtime += elapsed_s;
	opendirs++;

	errno = 0;

	while ((dent = readdir(dir))) {
		dname = dent->d_name;  // for convenience
		if ((!(spec & WS_DOTFILES) && dname[0] == '.') ||
		    (dname[0] == '.' || !strncmp(dname, "..", (size_t)2))) {
			gettimeofday(&dt0, 0);
			continue;
		}

		gettimeofday(&st0, 0);
		if (fstatat(fd, dname, &st, AT_SYMLINK_NOFOLLOW) == -1) {
			gettimeofday(&st1, 0);
			stats++;
			elapsed = (st1.tv_sec-st0.tv_sec)*1000000LL + st1.tv_usec-st0.tv_usec;
			elapsed_s = elapsed/(double)1000000;
			statstime += elapsed_s;
			warn("Can't stat fd: %d, '%s'", fd, dname);
			res = WALK_BADIO;
			gettimeofday(&dt0, 0);
			continue;
		}
		gettimeofday(&st1, 0);
		stats++;
		elapsed = (st1.tv_sec-st0.tv_sec)*1000000LL + st1.tv_usec-st0.tv_usec;
		elapsed_s = elapsed/(double)1000000;
		statstime += elapsed_s;

		/* don't follow symlink unless told so */
		if (S_ISLNK(st.st_mode) && !(spec & WS_FOLLOWLINK)) {
			continue;
		}

		/* will be false for symlinked dirs */
		if (S_ISDIR(st.st_mode)) {
			if (!(dirfd = openat(fd, dname, O_DIRECTORY))) {
				// something bad with IO..
				printf("badio, %d, %s\n", fd, dname);
				return WALK_BADIO;
			}
			/* recursively follow dirs */
			if ((spec & WS_RECURSIVE)) {
				walk_recur(dirfd, spec);
 			}
			if (!(spec & WS_MATCHDIRS)) {
				continue;
			}
		}

		files_matched++;
	}
	printf(COUNT_FMTSTRING, files_matched);

	if (dir) {
		closedir(dir);
	}
	return res ? res : errno ? WALK_BADIO : WALK_OK;
}

int walk_dir(char *dirname, char *pattern, int spec)
{
	int res, fd;
	DIR *dir;

	if (!(dir = opendir(dirname))) {
		warn("can't open %s", dirname);
		return WALK_BADIO;
	}
	if (!(fd = dirfd(dir))) {
		warn("can't get fd from %s", dirname);
		return WALK_BADIO;
	}
	res = walk_recur(fd, spec);

	return res;
}

int listdir(char *startdir, char *pattern)
{
	struct timeval t0, t1;

	gettimeofday(&t0, 0);
	int r = walk_dir(startdir, pattern, WS_DEFAULT|WS_MATCHDIRS);
	switch(r) {
	case WALK_OK:		break;
	case WALK_BADIO:	err(1, "IO error");
	case WALK_BADPATTERN:	err(1, "Bad pattern");
	case WALK_NAMETOOLONG:	err(1, "Filename too long");
	default:
		err(1, "Unknown error?");
	}

	gettimeofday(&t1, 0);
	long long elapsed = (t1.tv_sec-t0.tv_sec)*1000000LL + t1.tv_usec-t0.tv_usec;
	double elapsed_s = elapsed/(double)1000000;
        double files_per_second = files_matched/elapsed_s;
        double stats_per_second = stats/statstime;
        double opendirs_per_second = stats/opendirtime;
	printf("\n");
	printf("Listing completed:\n");
	printf("  %.2f seconds elapsed\n", elapsed_s);
	printf("  %d files matched()'ed\n", files_matched);
	printf("  %.2f matched files stat()'ed per second\n", files_per_second);
	printf("  %d stat()'s executed\n", stats);
	printf("  %.2f seconds spent executing stat()'s\n", statstime);
	printf("  %.2f stat()'s per second\n", stats_per_second);
	printf("  %d opendirs executed\n", opendirs);
	printf("  %.2f seconds spent executing opendir()'s\n", opendirtime);
	printf("  %.2f opendirs per second\n", opendirs_per_second);

	return 0;
}

int main(int argc, char *argv[])
{
	if(argc < 2) {
		printf("usage: %s <directory>\n", argv[0]);
		return 0;
	}
	char *pattern = ".*";
	char *startdir = argv[1];

	listdir(startdir, pattern);
	return 0;
}
