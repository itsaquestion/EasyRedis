#devtools::install()

er = EasyRedis::init()

er$get("yy")


er$set("x",NULL)

x = "apple"
er$qset(x)
er$get("x")

er$qget(yy)


system.time(
	er$get("yy")
)

er = EasyRedis::init(host = "cn.imtass.me",password = "909090aA_")
er$get("yy")