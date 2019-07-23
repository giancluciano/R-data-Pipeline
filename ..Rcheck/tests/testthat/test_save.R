context("save file")

test_that("saving datasets", {
  expect_true(save_dataset('/home/gian/Projects/PipeAndCrud/database/', cars))
  expect_true(save_dataset('/home/gian/Projects/PipeAndCrud/database/', iris, "cars"))
  expect_true(save_dataset('/home/gian/Projects/PipeAndCrud/database/', airquality, c("iris","cars")))
})
