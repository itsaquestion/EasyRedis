#devtools::install()

er = EasyRedis::init()

er$get("yy")


er$set("x",NULL)

x = "apple"
er$qset(x)
er$get("x")

