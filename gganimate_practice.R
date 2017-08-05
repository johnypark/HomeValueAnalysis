theme_set(theme_bw())
set.seed(2016)
min_weight <- .0005
bws <- c(.25, .5, .75, 1)
x_data <- c(rnorm(30, 0), rnorm(15, 6))
dat <- data_frame(x = x_data) %>%
  mutate(y = rnorm(n(), .5, .025))

fits <- data_frame(x = x_data) %>%
  mutate(y = rnorm(n(), .5, .025))%>%
  inflate(bw = bws) %>%
  do(tidy(density(.$x, bw = .$bw[1], from = -4, to = 9, n = 100)))

centers <- sort(unique(fits$x))

prep <- dat %>%
  inflate(center = centers, bw = bws) %>%
  mutate(weight = dnorm(x, center, bw)) %>%
  filter(weight > min_weight)

ras <- expand.grid(x = seq(min(centers), max(centers), .05),
                   y = c(0, 1)) %>%
  inflate(center = centers, bw = bws) %>%
  mutate(weight = dnorm(x, center, bw)) %>%
  filter(weight > min_weight)