
getHost = function(host = NULL) {
	host = host %||% getEnv("Redis_host")
	if (is.null(host)) { stop("Unknow host") }
	host
}

getpassword = function(password = NULL) {
	password %||% getEnv("Redis_password")
}

getEnv = function(x) {
	ret = Sys.getenv(x)
	if (ret == "") {
		ret = NULL
	}
	ret
}

checkServer <- function(host = NULL, port = 6379) {
	# 测试服务器的可连接性和redis登陆

	ping = ping_port(host, port, count = 1)

	if (is.na(ping)) {
		stop(glue("Connect to \"{host}:{port}\" failed! Check the host and port."))
	}

}


checkRedis = function(redis_host, redis_port, redis_password) {
	# redisConnect遇到“需要密码，但是没提供”这种情况，
	# 不会stop，而只是print个信息，所以只能捕获这个信息

	msg = NULL
	tryCatch({
		msg = capture.output({
			redisConnect(host = redis_host, port = redis_port, password = redis_password)
		})
	}, error = function(e) {
		# "密码错"，则会正常stop
		stop("Invalid connection! Host and port is OK, check password.")
	})

	if (any(grepl("NOAUTH", msg))) {
		stop("Redis: password required.")
	}

	redisClose()
}


#' init a EasyRedis object
#'
#' @param host
#' @param port
#' @param password
#'
#' @return a EasyRedis object
#' @import purrr
#' @import rredis
#' @import glue
#' @import pingr
#' @export
#'
#' @examples
#' er = EasyRedis::init()
#' x = "apple"
#' er$qset(x)
#' er$get("x") # "apple"
#'
init = function(host = NULL, port = 6379, password = NULL) {
	# 读写redis的简易OO结构

	# 私有成员 ====
	redis_host = getHost(host)
	redis_port = port
	redis_password = getpassword(password)

	checkServer(redis_host, redis_port)

	checkRedis(redis_host, redis_port, redis_password)


	set = function(key, value) {
		# set 一个对象
		redisConnect(redis_host, redis_port, redis_password)
		redisSet(key, value)
		redisClose()
	}

	get = function(key) {
		# get 一个对象
		#key = deparse(substitute(x))
		redisConnect(redis_host, redis_port, redis_password)
		ret = redisGet(key)
		redisClose()
		ret
	}

	qset = function(x, key = NULL) {
		# set 一个对象，不指定key，就用变量名当key
		key = key %||% deparse(substitute(x))
		set(key, x)
	}

	qget = function(x, env = parent.frame()) {
		# 直接赋值到caller的环境。
		key = deparse(substitute(x))
		value = get(key)
		env[[deparse(substitute(x))]] <- value
	}

	# 接口 ====
	ret = list(
		set = set,
		get = get,
		qset = qset,
		qget = qget
	 )

	class(ret) = c("er",class(ret))

	ret
}
