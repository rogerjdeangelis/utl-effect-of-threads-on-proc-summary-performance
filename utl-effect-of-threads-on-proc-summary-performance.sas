Effect of threads on proc summary performance

Dell I7 2760QM 16gb laptop 4 physical cores with 2 threads each (8 logical cores)

Conclusions for proc summary - proc sort has different results(sort has threaded I/O)

 1  For I/O bound tasks on threaded processors, there is no benefit to threading 'proc summary.
    May even be detrimental to overall performance.
    Setting 'NOTHREADS' reduces utilization at no cost to elapsed time? (I/O is not threaded)

 2  Proc Summary uses a maximum of 4 threads? (Max attainable system utilization is 50% with 4 of 8 threads).
    You can run 2 parallel 'proc summaries' with 8 logical cores and double the throughput(need sasfile?).
    You can run 8 parallel with 8 physical cores with sasfile.

 3  Eight physical cores with no threads outperforms 8 logical cores (2 physical with 2 threads each)
    If you have a robust I/O subsystem you can run 8 'proc summaries' in parallel?


 Dell I7 2760QM 16gb laptop 8 logical cores

 Benchmarks Two Scenariors

                                                Seconds
                                                -------
                                         NoThreads     Threads
                                         ---------     -------

  Compute bound       Elapsed               36            10*
  4 million 50 vars   CPU                   36 12%        41    50% system utilization**

  I/O Bound           Elapsed               24            23
  400 million 4 vars  2 core utilization    24 12%        35    20% system utilization(wasteful?)
                      4 threads

  * fastest;

 **Could run two of these at 100% COU utilization?

*                                _         _                           _
  ___ ___  _ __ ___  _ __  _   _| |_ ___  | |__   ___  _   _ _ __   __| |
 / __/ _ \| '_ ` _ \| '_ \| | | | __/ _ \ | '_ \ / _ \| | | | '_ \ / _` |
| (_| (_) | | | | | | |_) | |_| | ||  __/ | |_) | (_) | |_| | | | | (_| |
 \___\___/|_| |_| |_| .__/ \__,_|\__\___| |_.__/ \___/ \__,_|_| |_|\__,_|
                    |_|
;

* 50 variables 4 million obs

* Proc summary  (50 variables 4 million observations ~2gb);

data have(sortedby=id);
  call streaminit(1235);
  array xs[50] x1-x50;
  do id=1 to 100;
    do vals=1 to 40000;
       do idx=1 to 50;
          xs[idx]=rand('uniform');
       end;
       output;
    end;
  end;
  retain flag 'N';
  drop vals;
  stop;
run;quit;


PROCESS
=======

sasfile have load;

data log;

  do red='nothreads','threads';
     call symputx('red',red);
     rc=dosubl('
        %let beg=%sysfunc(time());
        proc summary data=have missing &red;
          by id;
          var x1-x50;
          output out=want mean= min= max= cv= std= css= skew= kurt= uss= / autoname;
       run;quit;
       %let elap=%sysevalf(%sysfunc(time()) - &beg);
     ');
     elap=symgetn('elap');
     output;
  end;

run;quit;

sasfile have close;

Up to 40 obs from LOG total obs=2

Obs       RED       RC      ELAP

 1     nothreads     0    36.0620
 2     threads       0    10.5620


NOTE: There were 4000000 observations read from the data set WORK.HAVE.
NOTE: The data set WORK.WANT has 100 observations and 453 variables.
NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           36.05 seconds
      cpu time            36.02 seconds


NOTE: There were 4000000 observations read from the data set WORK.HAVE.
NOTE: The data set WORK.WANT has 100 observations and 453 variables.
NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           10.53 seconds
      cpu time            41.32 seconds

*___    _____    _                           _
|_ _|  / / _ \  | |__   ___  _   _ _ __   __| |
 | |  / / | | | | '_ \ / _ \| | | | '_ \ / _` |
 | | / /| |_| | | |_) | (_) | |_| | | | | (_| |
|___/_/  \___/  |_.__/ \___/ \__,_|_| |_|\__,_|

;

*

data have(sortedby=id);
  call streaminit(1235);
  do id=1 to 10000;
    do vals=1 to 30000;
       value=rand('uniform');
       output;
    end;
  end;
  retain flag 'N';
  drop vals;
  stop;
run;quit;

PROCESS
=======

* 400 million and 4 vars;

sasfile have load;

data log ;

  do red= /*'nothreads',*/ 'threads';

     call symputx('red',red);
     rc=dosubl('
        %let beg=%sysfunc(time());
        proc summary data=have missing &red;
          by id;
          var value;
          output out=want n= / autoname;
          run;quit;
        %let elap=%sysevalf(%sysfunc(time()) - &beg);
     ');
     elap=symgetn('elap');
     output;

  end;

run;quit;

Up to 40 obs from LOG total obs=2

Obs       RED       RC      ELAP

 1     nothreads     0    23.8040
 2     threads       0    23.4250


NOTE: There were 300000000 observations read from the data set WORK.HAVE.
NOTE: The data set WORK.WANT has 10000 observations and 4 variables.
NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           23.79 seconds
      cpu time            23.74 seconds


NOTE: There were 300000000 observations read from the data set WORK.HAVE.
NOTE: The data set WORK.WANT has 10000 observations and 4 variables.
NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           23.42 seconds
      cpu time            35.14 seconds

