#devtools::install()

er = EasyRedis::init()

# keys ====
er$keys()

# set and get ====
er$set("tmp", 123)
stopifnot(
	er$get("tmp") == 123
)
er$del("tmp")

# qset and qget ====
tmp2 = "abc"
er$qset(tmp2)
er$keys()
rm(tmp2)
er$qget(tmp2)

stopifnot(
	tmp2 == "abc"
)
er$del("tmp2")

# end ====
er$keys()




