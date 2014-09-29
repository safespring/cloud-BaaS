// file system stat() timing tester.
// Copyright 2014 Martin Millnert, IPnett AB
// Based on http://rosettacode.org/wiki/Walk_a_directory/Recursively#Library:_POSIX 
// http://stackoverflow.com/questions/7035733/unix-c-program-to-list-directories-recursively 

#include <unistd.h>
#include <dirent.h>
#include <regex.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <err.h>
#include <time.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/time.h>

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
int do_print = 0; // 0 == false, 1 == true
const char *COUNT_FMTSTRING = "\rFiles stat()'ed: %d";

int walk_recur(char *dname, regex_t *reg, int spec)
{
	struct dirent *dent;
	DIR *dir;
	struct stat st;
	char fn[FILENAME_MAX];
	int res = WALK_OK;
	int len = strlen(dname);
	if (len >= FILENAME_MAX - 1)
		return WALK_NAMETOOLONG;
 
	strncpy(fn, dname,FILENAME_MAX);  /* if only strlcpy was available on glibc... */
	fn[FILENAME_MAX-1]='\0';  /* forcibly truncate and zero-terminate input */
	fn[len++] = '/';
 
	if (!(dir = opendir(dname))) {
		warn("can't open %s", dname);
		return WALK_BADIO;
	}
 
	errno = 0;
	while ((dent = readdir(dir))) {
		if (!(spec & WS_DOTFILES) && dent->d_name[0] == '.')
			continue;
		if (!strcmp(dent->d_name, ".") || !strcmp(dent->d_name, ".."))
			continue;
 
		strncpy(fn + len, dent->d_name, FILENAME_MAX - len);
		if (lstat(fn, &st) == -1) {
			warn("Can't stat %s", fn);
			res = WALK_BADIO;
			continue;
		}
 
		/* don't follow symlink unless told so */
		if (S_ISLNK(st.st_mode) && !(spec & WS_FOLLOWLINK))
			continue;
 
		/* will be false for symlinked dirs */
		if (S_ISDIR(st.st_mode)) {
			/* recursively follow dirs */
			if ((spec & WS_RECURSIVE))
				walk_recur(fn, reg, spec);
 
			if (!(spec & WS_MATCHDIRS)) continue;
		}
 
		/* pattern match */
		if (!regexec(reg, fn, 0, 0, 0)) {
			if (do_print) puts(fn);
			files_matched++;
		}
	}
	printf(COUNT_FMTSTRING, files_matched);

	if (dir) closedir(dir);
	return res ? res : errno ? WALK_BADIO : WALK_OK;
}
 
int walk_dir(char *dname, char *pattern, int spec)
{
	regex_t r;
	int res;
	if (regcomp(&r, pattern, REG_EXTENDED | REG_NOSUB))
		return WALK_BADPATTERN;
	res = walk_recur(dname, &r, spec);
	regfree(&r);
 
	return res;
}
 
int listdir(char *startdir, char *pattern)
{
	//int r = walk_dir(".", ".\\.c$", WS_DEFAULT|WS_MATCHDIRS);

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
	printf("\n");
	printf("Listing completed:\n");
	printf("  %d files stat()'ed\n", files_matched);
	printf("  %.2f seconds elapsed\n", elapsed_s);
	printf("  %.2f files stat()'ed per second\n", files_per_second);

	return 0;
}

int main(int argc, char *argv[])
{
  if(argc < 2)
  {
    printf("usage: %s <directory>\n", argv[0]);
    return 0;
  }
  char *pattern = ".*";
  char *startdir = argv[1];

  listdir(startdir, pattern);
  return 0;
}
