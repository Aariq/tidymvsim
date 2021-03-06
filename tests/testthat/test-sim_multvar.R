context("Simulated multivariate data functions")

test_that("sim_cat returns a tibble", {
  expect_that(sim_cat(n_obs =  30, n_groups = 2), is_a("tbl_df"))
})

test_that("sim_cat works with uneven group size", {
  expect_that(sim_cat(n_obs =  30, n_groups = 5), is_a("tbl_df"))
})

test_that("sim_cat gives warnings/erros when too many groups", {
  expect_that(sim_cat(n_obs =  30, n_groups = 11), throws_error())
  expect_that(sim_cat(n_obs =  30, n_groups = 7), gives_warning())
})

test_that("sim_covar returns a tibble", {
  expect_that(
    sim_cat(n_obs = 30, n_groups = 2) %>%
      sim_covar(n_vars = 5, var = 1, cov = 0.5, name = "test"),
    is_a("tbl_df")
  )
})

test_that("sim_covar handles var and cov longer than 1", {
  expect_that(
    sim_cat(n_obs =  30, n_groups = 2) %>%
      sim_covar(n_vars =  3, var = c(1, 0.5, 1), cov = 0.5),
    is_a("tbl_df")
  )

  expect_that(
    sim_cat(n_obs =  30, n_groups = 2) %>%
      sim_covar(n_vars =  3, var = 1, cov = c(0.4, 0.5, 0.6)),
    throws_error()
  )
})

context("group_by() works with sim_ functions")

test_that("group_by() %>% sim_discr() works", {
  expect_is(
    sim_cat(n_obs =  10, n_groups = 2) %>%
      group_by(group) %>%
      sim_discr(n_vars =  10, var = 1, cov = 0, group_means = c(-1, 1)),
    "tbl_df"
  )
})

test_that("no grouping variable causes sim_discr to error", {
  expect_error(
    sim_cat(N=10, n_groups = 2) %>%
      sim_discr(n_vars =  20, var = 1, cov = 0, group_means = c(1,2))
  )
})

test_that("sim_covar() works the same on grouped data frames", {
  df <- sim_cat(n_obs =  10, n_groups = 2)
  expect_equivalent(
    df %>% sim_covar(n_vars =  10, var = 1, cov = 0.5, seed = 10),
    df %>% group_by(group) %>% sim_covar(n_vars =  10, var = 1, cov = 0.5, seed = 10)
    )
})

test_that("sim_missing() works the same with grouped dataframes", {
  expect_equivalent(
    chickwts %>% group_by(feed) %>% sim_missing(prop = 0.01, seed = 22),
    chickwts %>% sim_missing(prop = 0.01, seed = 22))
  })

context("check RNG is working as expected")

test_that("RNG is consistent for sim_covar", {
  expect_that(
    sim_cat(n_obs =  30, n_groups = 2) %>%
      sim_covar(n_vars =  5, var = 1, cov = 0.5, seed = 100),
    is_identical_to(
      sim_cat(n_obs =  30, n_groups = 2) %>%
        sim_covar(n_vars =  5, var = 1, cov = 0.5, seed = 100)
    )
  )
})

test_that("RNG is consistent for sim_discr", {
  expect_that(
    sim_cat(n_obs =  30, n_groups = 2) %>%
      group_by(group) %>%
      sim_discr(n_vars =  5, var = 1, cov = 0.5, group_means = c(0,1), seed = 100),
    is_identical_to(
      sim_cat(n_obs =  30, n_groups = 2) %>%
        group_by(group) %>%
        sim_discr(n_vars =  5, var = 1, cov = 0.5, group_means = c(0,1), seed = 100)
    )
  )
})

context("Testing sim_missing()")

test_that("sim_missing adds NAs", {
  expect_true(
    sim_cat(n_obs =  30, n_groups = 3) %>%
      sim_covar(n_vars =  6, var = 1, cov = 0.5) %>%
      sim_missing(prop =  0.1) %>%
      anyNA()
  )
})

test_that("sim_missing adds the correct proprotion of NAs", {
  expect_that(
    sim_cat(n_obs =  10, n_groups = 2) %>%
      sim_covar(n_vars =  10, var = 1, cov = 0.5) %>%
      sim_missing(prop = 0.1) %>%
      is.na() %>%
      sum(),
    is_equivalent_to(10)
  )
})

test_that("sim_missing works with small proportions", {
  expect_warning(
    sim_cat(n_obs =  10, n_groups = 2) %>%
      sim_covar(n_vars =  10, var = 1, cov = 0, name = "uncorr") %>%
      sim_covar(n_vars =  10, var = 1, cov = 0.5, name = "corr") %>%
      group_by(group) %>%
      sim_discr(n_vars =  5, var = 1, cov = 0, group_means = c(-1, 1), name = "discr") %>%
      sim_missing(prop = 0.0001)
  )
})

context("functions work if not supplied a data frame or tibble with the .data argument")

test_that("sim_cat accepts a tibble for .data", {
  df <- tibble::tibble(x = sample(1:20, 20))
  expect_that(
    sim_cat(df, n_groups = 2),
    is_a("tbl_df")
  )
})

test_that("sim_covar works with no .data supplied", {
  df <- sim_covar(n_obs =  20, n_vars =  10, var = 1, cov = .5)
  expect_that(df, is_a("tbl_df"))
  expect_equivalent(dim(df), c(20,10))
})

test_that("sim_discr throws error if not given .data", {
  expect_error(
    sim_discr(n_vars =  10, var = 0, cov = 0, group_means = c(1, 1, 0))
  )
})

test_that("sim_missing throws error if not given .data", {
  expect_error(sim_missing(prop = 0.5))
})
