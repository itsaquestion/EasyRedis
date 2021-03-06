
# getHost = function(host = NULL) {
# 	host = host %||% getEnv("Redis_host")
# 	if (is.null(host)) { stop("Unknow host") }
# 	host
# }
#
# getpassword = function(password = NULL) {
# 	password %||% getEnv("Redis_password")
# }

#' getEnv get env value.
#'
#' @param x env value name
#'
#' @return the value. if value == "" then return NULL
#' @export
#'
getEnv = function(x) {
	ret = Sys.getenv(x)
	if (ret == "") {
		ret = NULL
	}
	ret
}

checkHost = function(host = NULL, port = 6379) {
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


checkRedis = function(redis_host, redis_port, redis_password,no_deley) {
  stopNull(except = "redis_password")
	rConnect(redis_host, redis_port, redis_password, no_deley)
	redisClose()
}

rConnect = function(redis_host, redis_port, redis_password, no_deley) {
	# redisConnect遇到“需要密码，但是没提供”这种情况，
	# 不会stop，指挥print个信息，所以只能捕获这个信息
	stopNull(except = "redis_password")

	msg = NULL
	tryCatch({
		msg = capture.output({
			redisConnect(host = redis_host, port = redis_port, password = redis_password,
			             nodelay = no_deley)
		})
	}, error = function(e) {
		# "密码错"，则会正常stop
		stop("Invalid connection! Host and port is OK, check password.")
	})

	if (any(grepl("NOAUTH", msg))) {
		stop("Redis: password required.")
	}

}


#' ErInit: init a EasyRedis object
#'
#' @param host redis host.
#' @param port redis port
#' @param password redis password
#'
#' @return a EasyRedis object
#' @import purrr
#' @import rredis
#' @import glue
#' @import pingr
#' @import NullCheck
#' @export
#'
#' @examples
#' er = EasyRedis::ErInit()
#' x = "apple"
#' er$qSet(x)
#' er$get("x") # "apple"
#'
ErInit = function(host = "localhost", port = 6379, password = NULL,no_deley = F) {
	# 读写redis的简易OO结构

	# 私有成员 ====
	redis_host = host
	redis_port = port
	redis_password = password
	redis_nodeley = no_deley

	checkHost(redis_host, redis_port)

	checkRedis(redis_host, redis_port, redis_password,redis_nodeley)

	wrapper = function(fun) {
		rConnect(redis_host, redis_port, redis_password,redis_nodeley)
		ret = fun()
		redisClose()
		ret
	}

	set = function(key, value) {
		# set 一个对象
		stopNull(except = "value")
		invisible(wrapper(function() { redisSet(key, value) }))
	}

	get = function(key) {
		stopNull()
		# get 一个对象
		if (!key %in% keys()) {
			stop(glue("Key \"{key}\" not exists."))
			return(NULL)
		}
		wrapper(function() { redisGet(key) })
	}

	qSet = function(x, key = NULL) {
		# set 一个对象，不指定key，就用变量名当key
		obj_name = deparse(substitute(x))

		key = key %||% obj_name
		set(key, x)
	}

	qGet = function(x, env = parent.frame()) {
		# 直接赋值到caller的环境。
		key = deparse(substitute(x))
		value = get(key)
		env[[deparse(substitute(x))]] <- value
	}

	keys = function() {
		wrapper(function() { redisKeys() })
	}

	del = function(key, ask = T) {

		do_del = F

		if (ask) {
			ans = menu(c("Yes", "No"), title = glue("Delete key \"{key}\"?"))
			if (ans == 1) {
				do_del = T
			}
		} else {
			do_del = T
		}

		if (do_del) {
			invisible(wrapper(function() { redisDelete(key) }))
		}
	}

	# 接口 ====
	ret = list(
		set = set,
		get = get,
		qSet = qSet,
		qGet = qGet,
		keys = keys,
		del = del
	 )

	class(ret) = c("ER",class(ret))

	ret
}
