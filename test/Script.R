#devtools::install()

er = EasyRedis::init()

er$get("yy")


er$set("x",NULL)

x = "123"
er$qset(x)
er$get("x")

er$qget(yy)


system.time(
	er$get("yy")
)

er = EasyRedis::init()
er$get("yy")


er = EasyRedis::init()