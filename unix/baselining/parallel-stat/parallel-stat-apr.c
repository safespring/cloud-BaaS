/**
   Parallel consumer/worker filesystem stat():er
   Copyright Martin Millnert, 2014, martin.millnert@ipnett.com
   Using libapr and libaprutil,
   on debian:  apt-get install libapr1-dev libaprutil1-dev to compile this code
   on rpm-based systems: yum install apr-devel apr-util-devel
                         change #include "apr-1.0/apr_queue.h" to #include "apr-1/apr_queue.h"
   Written with an eye on apr-util/test/testqueue.c

   XXX: Add timings around readdir + around lstat to measure the accumulated waiting time
   XXX: do same in recursive-stat to compare.
   XXX: present at end of file, to see any speedup vs wall-time, etc
**/

#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <pthread.h>
//#include <time.h>
#include <sys/time.h>

#ifdef RH
#include "apr-1/apr_queue.h"
#include "apr-1/apr_portable.h"
#else
#include "apr-1.0/apr_queue.h"
#include "apr-1.0/apr_portable.h"
#endif

/*
const int DEBUG   = 0x1000;
const int VERBOSE = 0x0100;
const int NORMAL  = 0x0010;
const int QUIET   = 0x0000;
*/

const int DEBUG   = (1 << 4);
const int VERBOSE = (1 << 3);
const int NORMAL  = (1 << 2);
const int QUIET   = (1 << 1);

int logmask;

// file io things:

enum {
        WALK_OK = 0,
        WALK_BADPATTERN,
        WALK_NAMETOOLONG,
        WALK_BADIO,
};

#define WS_NONE         0
#define WS_RECURSIVE    (1 << 0)
#define WS_DEFAULT      WS_RECURSIVE
#define WS_FOLLOWLINK   (1 << 1)        /* follow symlinks */
#define WS_DOTFILES     (1 << 2)        /* per unix convention, .file is hidden */
#define WS_MATCHDIRS    (1 << 3)        /* if pattern is used on dir names too */

#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <dirent.h>
#include <regex.h>
#include <string.h>
#include <errno.h>
#include <err.h>
#include <time.h>
// end of file io things

apr_pool_t *context;

/* create thread argument struct for dirworker_thr_func() */
typedef struct _dirworker_thread_data_t {
  int         tid;
  int         direntrys_resolved;
  apr_queue_t *dirqueue;
  apr_queue_t *dentryqueue;
  int         spec;
} dirworker_thread_data_t;

/* create thread argument struct for dentryworker_thr_func() */
typedef struct _dentryworker_thread_data_t {
  int         tid;
  int         files_matched;
  apr_queue_t *dirqueue;
  apr_queue_t *dentryqueue;
  regex_t     reg;
  int         spec;
} dentryworker_thread_data_t;

/* create thread argument struct for monitor_thr_func() */
typedef struct _monitor_thread_data_t {
  int                        tid;
  apr_queue_t                *dirqueue;
  apr_queue_t                *dentryqueue;
  pthread_t                  *thr_dirworker;
  pthread_t                  *thr_dentryworker;
  dirworker_thread_data_t    *thr_data_dirworker;
  dentryworker_thread_data_t *thr_data_dentryworker;
  int                        dirworker_threads;
  int                        dentryworker_threads;

} monitor_thread_data_t;


int ifprint(FILE *stream, int severity, const char* format, ...) {
  if (((severity & logmask) == QUIET) ||
      ((severity & logmask) == NORMAL) ||
      ((severity & logmask) == VERBOSE) ||
      ((severity & logmask) == DEBUG)) {
    va_list args;
    va_start(args, format);
    vfprintf(stream, format, args);
    va_end(args);
  }
  return 0;
}

/* thread dirworker function */
void *dirworker_thread_func(void *arg) {
  dirworker_thread_data_t *data = (dirworker_thread_data_t *)arg;
  int tid                       = data->tid;
  int *direntrys_resolved       = &data->direntrys_resolved;
  apr_queue_t *dirqueue         = data->dirqueue;
  apr_queue_t *dentryqueue      = data->dentryqueue;
  int spec                      = data->spec;
  //char errorbuf[200];
  apr_status_t rv;
  void *v;

  // file io things here
  char *val;
  char dname[FILENAME_MAX];
  struct dirent *dent;
  DIR *dir;
  //int res = WALK_OK;
  int dlen, flen;
  //char fn[FILENAME_MAX];

  ifprint(stdout, DEBUG, "dirworker[%d] running.\n", tid);

  while (1) {
    do {
      rv = apr_queue_pop(dirqueue, &v);
      if (rv == APR_EINTR) {
        ifprint(stderr, DEBUG, "dirworker[%d] interrupted\n", tid);
      }
    } while (rv == APR_EINTR);
    if (rv != APR_SUCCESS) {
      if (rv == APR_EOF) {
        ifprint(stderr, DEBUG, "dirworker[%d] - dirqueue terminated\n", tid);
        rv = APR_SUCCESS;
      } else {
        ifprint(stderr, DEBUG, "dirworker[%d] - thread exit", tid);
      }
      pthread_exit(NULL);
      return NULL;
    }
    // do stuff with the read value
    val = (char *)v;
    ifprint(stdout, DEBUG, "dirworker[%d] got a value from queue: '%s'.\n",
            tid, val);
    // resume readdir code here
    dlen = strlen(val);
    ifprint(stdout, DEBUG, "dirworker[%d] strlen(val) = %d, val[dlen-1] == '%c'.\n",
            tid, dlen, val[dlen-1]);
    if (dlen >= FILENAME_MAX - 1) {
      //free(v); // XXX: figure this out...
      //free(val);
      continue;  // WALK_NAMETOOLONG
    }
    if (val[dlen-1] == '/') {
      snprintf(dname, (size_t)dlen+1, "%s", val);
    } else {
      snprintf(dname, (size_t)dlen+2, "%s/", val);
    }
    //free(v); //XXX: figure this out...
    //free(val);
    ifprint(stdout, DEBUG, "dirworker[%d] dname: '%s'.\n",
            tid, dname);
    if (!(dir = opendir(dname))) {
      warn("can't open %s", dname);
      continue; // WALK_BADIO
    }
    // dir read loop
    *direntrys_resolved = *direntrys_resolved+1;
    errno = 0;
    while ((dent = readdir(dir))) {
      if (!(spec & WS_DOTFILES) && dent->d_name[0] == '.') {
        continue;
      }
      if (!strcmp(dent->d_name, ".") || !strcmp(dent->d_name, "..")) {
        continue;
      }
      flen = strlen(dent->d_name);
      //snprintf(fn, (size_t)len+1, "%s", dent->d_name);

      // now add to dentryworker_queue
      //char *filename = apr_palloc(context, dlen+flen+2);
      char *filename = malloc((size_t)(dlen+flen+2));
      snprintf(filename, (size_t)dlen+flen+2, "%s%s", dname, dent->d_name);
      ifprint(stdout, DEBUG, "dirworker[%d] -> dentryqueue: '%s'.\n", tid, filename);
      rv = apr_queue_push(dentryqueue, filename);

    }
    if (dir) {
      closedir(dir);
    }

  }
  return NULL; // not reached
}

/* thread dentryworker function */
void *dentryworker_thread_func(void *arg) {
  dentryworker_thread_data_t *data = (dentryworker_thread_data_t *)arg;
  int tid                       = data->tid;
  int *files_matched            = &data->files_matched;
  apr_queue_t *dirqueue         = data->dirqueue;
  apr_queue_t *dentryqueue      = data->dentryqueue;
  regex_t     *reg              = &data->reg;
  int spec                      = data->spec;
  //char errorbuf[200];
  apr_status_t rv;
  void *v;


  // file io things here
  char *val;
  //char dname[FILENAME_MAX];
  //struct dirent *dent;
  //DIR *dir;
  //int res = WALK_OK;
  int len;
  //char fn[FILENAME_MAX];
  struct stat st;
  char filename[FILENAME_MAX];

  ifprint(stdout, DEBUG, "dentryworker[%d] running.\n", tid);
  while (1) {
    do {
      rv = apr_queue_pop(dentryqueue, &v);
      if (rv == APR_EINTR) {
        ifprint(stderr, DEBUG, "dentryworker[%d] interrupted\n", tid);
      }
    } while (rv == APR_EINTR);
    if (rv != APR_SUCCESS) {
      if (rv == APR_EOF) {
        ifprint(stderr, DEBUG, "dentryworker[%d] - dentryqueue terminated\n", tid);
        rv = APR_SUCCESS;
      } else {
        ifprint(stderr, DEBUG, "dentryworker[%d] - thread exit", tid);
      }
      pthread_exit(NULL);
      return NULL;
    }
    // do stuff with the read value
    val = (char *)v;
    ifprint(stdout, DEBUG, "dentryworker[%d] got a value from queue: '%s'.\n",
            tid, val);
    // resume readdir code here
    len = strlen(val);
    snprintf(filename, (size_t)len+1, "%s", val);
    //free(v);  //XXX:  figure this out...
    //free(val); 
    ifprint(stdout, DEBUG, "dentryworker[%d] strlen(filename) = %d.\n",
            tid, len);
    if (lstat(filename, &st) == -1) {
      warn("Can't stat %s", filename);
      continue; // WALK_BADIO
    }

    /* don't follow symlinks unless told so */
    if (S_ISLNK(st.st_mode) && !(spec & WS_FOLLOWLINK)) {
      continue;
    }

    /* will be false for symlinked dirs */
    if (S_ISDIR(st.st_mode)) {
      /* add dir to dirqueue... */
      if ((spec & WS_RECURSIVE)) {
        // now add to dirworker_queue
        //char *dirname = apr_palloc(context, len+1);
        char *dirname = malloc((size_t)(len+2));
        snprintf(dirname, (size_t)len+2, "%s/", filename);
        ifprint(stdout, DEBUG, "dentryworker[%d] -> dirqueue: '%s'.\n", tid, dirname);
        rv = apr_queue_push(dirqueue, dirname);
      }
      if (!(spec & WS_MATCHDIRS)) {
        continue;
      }
    }

    /* pattern match */
    if (!regexec(reg, filename, 0, 0, 0)) {
      ifprint(stdout, VERBOSE, "dentryworker[%d] matched '%s'.\n", tid, filename);
      *files_matched = *files_matched + 1;
    }

  }
  return NULL; // not reached
}

/* thread monitor function */
void *monitor_thread_func(void *arg) {
  monitor_thread_data_t *data = (monitor_thread_data_t *)arg;
  apr_queue_t                *dirqueue              = data->dirqueue;
  apr_queue_t                *dentryqueue           = data->dentryqueue;
  //pthread_t                  *thr_dirworker         = data->thr_dirworker;
  //pthread_t                  *thr_dentryworker      = data->thr_dentryworker;
  //dirworker_thread_data_t    *thr_data_dirworker    = data->thr_data_dirworker;
  dentryworker_thread_data_t *thr_data_dentryworker = data->thr_data_dentryworker;
  //int                        dirworker_threads      = data->dirworker_threads;
  int                        dentryworker_threads   = data->dentryworker_threads;

  char errorbuf[200];
  apr_status_t rv;

  struct timespec tim1, tim2;
  tim1.tv_sec = 0;
  tim1.tv_nsec = 100000000L;  // check status 10 times per second

  int dis, des;
  int stage = 0;
  int stagelimit = 25;   // presume completed after 25*1/!0 second => 2.5 sec
                         // remember to deduct this time from total execution time...

  int files_matched, i;

  ifprint(stdout, DEBUG, "monitor[%d] running.\n", data->tid);

  while (1) {
    dis = apr_queue_size(dirqueue);
    des = apr_queue_size(dentryqueue);
    ifprint(stdout, VERBOSE, "monitor_thread_func observes:\n");
    ifprint(stdout, VERBOSE, "\t   dirqueue length: %d\n", dis);
    ifprint(stdout, VERBOSE, "\tdentryqueue length: %d\n", des);
    if ((dis == 0) && (des == 0)) {
      stage++;
      ifprint(stdout, DEBUG, "stage increased to %d.\n", stage);
    } else if (stage > 0){
      stage = 0;
      ifprint(stdout, DEBUG, "stage reset to %d.\n", stage);
    }

    // count and print file_matches
    files_matched = 0;
    for (i = 0 ; i < dentryworker_threads ; i++) {
      files_matched += thr_data_dentryworker[i].files_matched;
      //ifprint(stdout, DEBUG, "dentryworker[%d] matched %d files.\n", i, thr_data_dentryworker[i].files_matched);
    }
    ifprint(stdout, NORMAL, "\rFiles stat()'ed: %d", files_matched);

    if (stage == stagelimit) {
      // terminate the dirqueue
      ifprint(stdout, DEBUG, "stage reached stagelimit at %d.\n", stage);
      rv = apr_queue_term(dirqueue);
      ifprint(stdout, DEBUG, "%-60s", "Terminating the dirqueue");
      if (rv != APR_SUCCESS) {
        fflush(stdout);
        ifprint(stderr, DEBUG, "Failed\nCould not create dirqueue %d\n", rv);
        apr_strerror(rv, errorbuf, 200);
        ifprint(stderr, DEBUG, "%s\n", errorbuf);
        exit(-1);
      }
      ifprint(stdout, DEBUG, "OK\n");

      // terminate the dentryqueue
      rv = apr_queue_term(dentryqueue);
      ifprint(stdout, DEBUG, "%-60s", "Terminating the dentryqueue");
      if (rv != APR_SUCCESS) {
        fflush(stdout);
        ifprint(stderr, DEBUG, "Failed\nCould not create dentryqueue %d\n", rv);
        apr_strerror(rv, errorbuf, 200);
        ifprint(stderr, DEBUG, "%s\n", errorbuf);
        exit(-1);
      }
      ifprint(stdout, DEBUG, "OK\n");

      ifprint(stdout, DEBUG, "monitor[%d] exiting.\n", data->tid);
      pthread_exit(NULL);
    }
    if (nanosleep(&tim1, &tim2) < 0) {
      ifprint(stderr, DEBUG, "nanosleep syscall failed\n");
    }
  }

  // never reached
  return NULL;
}

int main(int argc, char **argv) {
  /* initialize stuff */
  apr_queue_t *dirqueue, *dentryqueue;
  apr_status_t rv;
  char errorbuf[200];
  int dirqueue_size    = 1000000;
  int dentryqueue_size = 4096;

  int dirworker_threads    = 8;
  int dentryworker_threads = 256;
  int monitor_threads      = 1;

  pthread_t thr_dirworker[dirworker_threads];
  pthread_t thr_dentryworker[dentryworker_threads];
  pthread_t thr_monitor[monitor_threads];

  int i, rc;

  /* do some getopt stuff here... */
  //logmask = NORMAL | VERBOSE | DEBUG;
  logmask = NORMAL;

  if (argc < 2) {
    printf("Usage: %s <directory>\n", argv[0]);
    return 0;
  }

  char *pattern  = ".*"; // match everything...
  char *startdir = argv[1];
  //int spec = WS_DEFAULT | WS_MATCHDIRS;
  int spec = WS_DEFAULT;

  /* create a thread_data_t argument array */
  dirworker_thread_data_t    dirworker_thr_data[dirworker_threads];
  dentryworker_thread_data_t dentryworker_thr_data[dentryworker_threads];
  monitor_thread_data_t      monitor_thr_data[monitor_threads];

  /* initialize apr memory pool */

  apr_initialize();

  ifprint(stdout, DEBUG, "%-60s", "Initializing the context");
  if (apr_pool_create(&context, NULL) != APR_SUCCESS) {
    fflush(stdout);
    ifprint(stderr, DEBUG, "Failed.\nCould not initialize\n");
    exit(-1);
  }
  ifprint(stdout, DEBUG, "OK\n");

  /* create dirqueue */
  rv  = apr_queue_create(&dirqueue, dirqueue_size, context);

  ifprint(stdout, DEBUG, "%-60s", "Initializing the dirqueue");
  if (rv != APR_SUCCESS) {
    fflush(stdout);
    ifprint(stderr, DEBUG, "Failed\nCould not create dirqueue %d\n", rv);
    apr_strerror(rv, errorbuf, 200);
    ifprint(stderr, DEBUG, "%s\n", errorbuf);
    exit(-1);
  }
  ifprint(stdout, DEBUG, "OK\n");

  /* create dentryqueue */
  rv  = apr_queue_create(&dentryqueue, dentryqueue_size, context);

  ifprint(stdout, DEBUG, "%-60s", "Initializing the dentryqueue");
  if (rv != APR_SUCCESS) {
    fflush(stdout);
    ifprint(stderr, DEBUG, "Failed\nCould not create dentryqueue %d\n", rv);
    apr_strerror(rv, errorbuf, 200);
    ifprint(stderr, DEBUG, "%s\n", errorbuf);
    exit(-1);
  }
  ifprint(stdout, DEBUG, "OK\n");


  /* create dirworker threads */
  for (i = 0; i < dirworker_threads; ++i) {
    dirworker_thr_data[i].tid         = i;
    dirworker_thr_data[i].dirqueue    = dirqueue;
    dirworker_thr_data[i].dentryqueue = dentryqueue;
    dirworker_thr_data[i].spec        = spec;

    if ((rc = pthread_create(&thr_dirworker[i], NULL, dirworker_thread_func, &dirworker_thr_data[i]))) {
      ifprint(stderr, DEBUG, "error: pthread_create dirworker, rc: %d\n", rc);
      return EXIT_FAILURE;
    }
  }

  /* create dentryworker threads */
  for (i = 0; i < dentryworker_threads; ++i) {
    dentryworker_thr_data[i].tid = i;
    dentryworker_thr_data[i].dirqueue      = dirqueue;
    dentryworker_thr_data[i].dentryqueue   = dentryqueue;
    dentryworker_thr_data[i].files_matched = 0;
    dentryworker_thr_data[i].spec          = spec;

    if (regcomp(&dentryworker_thr_data[i].reg, pattern, REG_EXTENDED | REG_NOSUB)) {
      return WALK_BADPATTERN;
    }

    if ((rc = pthread_create(&thr_dentryworker[i], NULL, dentryworker_thread_func, &dentryworker_thr_data[i]))) {
      ifprint(stderr, DEBUG, "error: pthread_create dentryworker, rc: %d\n", rc);
      return EXIT_FAILURE;
    }
  }

  /* create monitor threads */
  for (i = 0; i < monitor_threads; ++i) {
    /* prepare monitordata */
    monitor_thr_data[i].tid = i;
    monitor_thr_data[i].dirqueue              = dirqueue;
    monitor_thr_data[i].dentryqueue           = dentryqueue;
    monitor_thr_data[i].thr_dirworker         = thr_dirworker;
    monitor_thr_data[i].thr_dentryworker      = thr_dentryworker;
    monitor_thr_data[i].thr_data_dirworker    = dirworker_thr_data;
    monitor_thr_data[i].thr_data_dentryworker = dentryworker_thr_data;
    monitor_thr_data[i].dirworker_threads     = dirworker_threads;
    monitor_thr_data[i].dentryworker_threads  = dentryworker_threads;

    if ((rc = pthread_create(&thr_monitor[i], NULL, monitor_thread_func, &monitor_thr_data[i]))) {
      ifprint(stderr, DEBUG, "error: pthread_create monitor, rc: %d\n", rc);
      return EXIT_FAILURE;
    }
  }

  /* Start the execution of the program by feeding the dirqueue with its first directory */
  struct timeval t0, t1;
  gettimeofday(&t0, 0);
  int startdir_len = strlen(argv[1]);
  ifprint(stdout, DEBUG, "length of startdir ('%s') = %d.\n", startdir, startdir_len);
  char *firstdir = apr_palloc(context, startdir_len+1);
  snprintf(firstdir, (size_t)startdir_len+1, "%s", startdir);
  ifprint(stdout, DEBUG, "firstdir = '%s'.\n", firstdir);
  rv = apr_queue_push(dirqueue, firstdir);
  if (rv != APR_SUCCESS) {
    ifprint(stderr, NORMAL, "error with first insert into dirqueue. exiting\n");
    return EXIT_FAILURE;
  }

  /* block until all dirworker threads complete */
  for (i = 0; i < dirworker_threads; ++i) {
    pthread_join(thr_dirworker[i], NULL);
  }

  /* block until all dentryworker threads complete */
  for (i = 0; i < dentryworker_threads; ++i) {
    pthread_join(thr_dentryworker[i], NULL);
  }

  /* block until all monitor threads complete */
  for (i = 0; i < monitor_threads; ++i) {
    pthread_join(thr_monitor[i], NULL);
  } 

  gettimeofday(&t1, 0);
  long long elapsed = (t1.tv_sec-t0.tv_sec)*1000000LL + t1.tv_usec-t0.tv_usec;
  double elapsed_s = elapsed/(double)1000000-2.5;
  int files_matched = 0;
  for (i = 0 ; i < dentryworker_threads ; i++) {
    files_matched += dentryworker_thr_data[i].files_matched;
    ifprint(stdout, VERBOSE, "dentryworker[%d] matched %d files.\n", i, dentryworker_thr_data[i].files_matched);
  }
  double files_per_second = files_matched/elapsed_s;
  ifprint(stdout, NORMAL, "\n");
  ifprint(stdout, NORMAL, "Listing completed:\n");
  ifprint(stdout, NORMAL, "  %d files stat()'ed\n", files_matched);
  ifprint(stdout, NORMAL, "  %.2f seconds elapsed\n", elapsed_s);
  ifprint(stdout, NORMAL, "  %.2f files stat()'ed per second\n", files_per_second);

  return EXIT_SUCCESS;
}
