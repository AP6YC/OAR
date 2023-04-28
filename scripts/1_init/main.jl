using DrWatson
@quickactivate :OAR

@info datadir()
@info srcdir()
@info plotsdir()
@info scriptsdir()
@info papersdir()

exp_name = "1_init"

@info OAR.work_dir(exp_name)