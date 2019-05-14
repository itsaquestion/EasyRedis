library(testthat)

context("easy redis")

test_that("basic usage",{
  er = ErInit()
  a_value = 123
  er$set("tmp",a_value)
  expect_equal(er$get("tmp"),a_value)
  er$keys()

  expect_true(
    "ER" %in% class(er)
  )

  # keys ====
  er$keys()

  # set and get ====


  er$get("tmp")


  ptm <- proc.time()
  er$get("tmp")
  proc.time() - ptm


  expect_equal(
    er$get("tmp"), 123
  )
  er$del("tmp",F)

  # qSet and qGet ====
  tmp2 = "abc"
  er$qSet(tmp2)
  er$keys()
  rm(tmp2)
  er$qGet(tmp2)

  expect_equal(
    tmp2,"abc"
  )
  er$del("tmp2",F)

  # key exist ====
  er$keys()

  expect_error(
    is.null(er$get("tmp"))
  )

  er$keys()


})
