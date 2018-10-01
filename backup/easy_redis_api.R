import = modules::import
export = modules::export

import(purrr)
import("rredis")
import(glue)
import(pingr)

#====================

export("init")
export("set")
export("get")
export("qset")

#===================

redis_host = NULL
redis_password = NULL
redis_port = 6379

init_ok = FALSE


init <- function(host = NULL, port = 6379, password = NULL) {

	redis_host == getHost(host)
	redis_port <<- port
	redis_password <<- getpassword(password)

	if (!checkServer(redis_host, redis_port)) {
		stop(glue("Connect to \"{host}:{port}\" failed Check the host and port"))
	}

	tryCatch({
		redisConnect(host = redis_host, port = port, password = redis_password)
	}, error = function(e) {
		stop("Invalid connection Host and port OK, check password")
	})

	redisClose()

	init_ok <<- TRUE



}

getHost = function(host = NULL) {
	host %||% getEnv("Redis_host") %||% "localhost"
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


qset = function(x) {
	checkInit()
	key = key %||% deparse(substitute(x))
	redisConnect(redis_host, redis_port, redis_password)
	redisSet(key, x)
	redisClose()

}

set = function(key, value) {
	checkInit()
	redisConnect(redis_host, redis_port, redis_password)
	redisSet(key, value)
	redisClose()
}


get = function(key) {
	checkInit()
	#key = deparse(substitute(x))
	redisConnect(redis_host, redis_port, redis_password)
	ret = redisGet(key)
	redisClose()
	ret
}

checkInit = function() {
	if (!init_ok) {
		stop("init() fist!")
	}
}

#' checkServer
#'
#' @return 
#' @export
#' @import purrr
#' @import rredis
#' @import glue
#' @import pingr
#' @examples
checkServer <- function(host = NULL, port = 6379) {
	# 测试服务器的可连接性和redis登陆

	redis_host = getHost(host)

	ping = pingr::ping_port(redis_host, port, count = 1)

	if (is.na(ping)) {
		#warning(glue("Connect to \"{host}:{port}\" failed Check the host and port"))
		return(F)
	}

	TRUE
}
