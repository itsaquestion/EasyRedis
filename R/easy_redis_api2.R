
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

checkHost <- function(host = NULL, port = 6379) {
	# 测试服务器的可连接性

	# 预防连接不佳，尝试Ping 3次
	ping = ping_port(host, port, count = 1)
	counter = 1
	while (is.na(ping) & counter < 3) {
		ping = ping_port(host, port, count = 1)
		counter = counter + 1
	}

	if (is.na(ping)) {
		stop(glue("Connect to \"{host}:{port}\" failed! Check the port."))
	}

}


checkRedis = function(redis_host, redis_port, redis_password) {
	rConnect(redis_host, redis_port, redis_password)
	redisClose()
}

rConnect = function(redis_host, redis_port, redis_password) {
	# redisConnect遇到“需要密码，但是没提供”这种情况，
	# 不会stop，指挥print个信息，所以只能捕获这个信息

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

	checkHost(redis_host, redis_port)

	checkRedis(redis_host, redis_port, redis_password)

	wrapper = function(fun) {
		rConnect(redis_host, redis_port, redis_password)
		ret = fun()
		redisClose()
		ret
	}

	set = function(key, value) {
		# set 一个对象
		
		invisible(wrapper(function() { redisSet(key, value) }))
	}

	get = function(key) {
		# get 一个对象
		if (!key %in% keys()) {
			warning(glue("Key \"{key}\" not exists."))
			return(NULL)
		}
		wrapper(function() { redisGet(key) })
	}

	qset = function(x, key = NULL) {
		# set 一个对象，不指定key，就用变量名当key
		obj_name = deparse(substitute(x))

		#if (missing(x)) {
			#stop(glue("{obj_name} is missing."))
		#}

		key = key %||% obj_name
		set(key, x)
	}

	qget = function(x, env = parent.frame()) {
		# 直接赋值到caller的环境。
		key = deparse(substitute(x))
		value = get(key)
		env[[deparse(substitute(x))]] <- value
	}

	keys = function() {
		wrapper(function() { redisKeys() })
	}

	del = function(key) {
		invisible(wrapper(function() { redisDelete(key) }))
	}

	# 接口 ====
	ret = list(
		set = set,
		get = get,
		qset = qset,
		qget = qget,
		keys = keys,
		del = del
	 )

	class(ret) = c("er",class(ret))

	ret
}
