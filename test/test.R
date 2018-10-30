#devtools::install()
MyUtils::rmAll()


er = EasyRedis::init()


stopifnot(
	"ER" %in% class(er)
)

# keys ====
er$keys()

# set and get ====
er$set("tmp", 123)

er$get("adfs")

stopifnot(
	er$get("tmp") == 123
)
er$del("tmp",F)

# qSet and qGet ====
tmp2 = "abc"
er$qSet(tmp2)
er$keys()
rm(tmp2)
er$qGet(tmp2)

stopifnot(
	tmp2 == "abc"
)
er$del("tmp2",F)

# key exist ====
er$keys()

stopifnot(
	is.null(er$get("tmp"))
)

er$keys()
er$get("wind_check")


er$set(NA, 123)
er$set("tmp", NA)

er$qGet(tmp)
tmp

er$set(NULL, 123)
er$set(vector(), 123)