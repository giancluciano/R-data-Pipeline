context("save file")

test_that("saving datasets", {
  file.remove('/home/gian/Projects/PipeAndCrud/database/database')
  database <<- PipeAndCrud::init_database( path_to = '/home/gian/Projects/PipeAndCrud/database/')
  trabs <- readRDS('/home/gian/Projects/PipeAndCrud/database/trabs.rds')
  expect_true(database$save(cars))
  expect_true(database$save(trabs,'cars'))
  expect_error(database$delete('cars'))
  database <<- PipeAndCrud::init_database( path_to = '/home/gian/Projects/PipeAndCrud/database/')
  expect_equivalent(trabs,database$read('trabs'))
  expect_error(database$delete('cars2'))
})
