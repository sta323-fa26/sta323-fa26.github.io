# stat_cov_ellipse.R
#
# A ggplot2 extension that draws the ellipse
#
#     x^T Sigma^{-1} x = c
#
# for a given covariance matrix Sigma and constant c.
#
# Usage:
#   source("stat_cov_ellipse.R")
#   ggplot() + stat_cov_ellipse(sigma = matrix(c(4, 1.4, 1.4, 1), nrow = 2), c = 4)

library(ggplot2)

# ---- ggproto Stat --------------------------------------------------------
#
# compute_group() builds the ellipse boundary points by:
#   1. eigen-decomposing Sigma = V diag(lambda) V^T
#   2. scaling a unit circle by sqrt(c * lambda) along each eigenvector
#   3. rotating the scaled circle into the eigenvector basis (V %*% ...)
#
# This traces exactly the set of points x satisfying x^T Sigma^{-1} x = c.

StatCovEllipse <- ggproto("StatCovEllipse", Stat,

  required_aes = character(0),

  compute_group = function(data, scales, sigma, c, segments = 300) {

    if (!is.matrix(sigma) || nrow(sigma) != 2 || ncol(sigma) != 2) {
      stop("`sigma` must be a 2x2 covariance matrix.")
    }
    if (!isTRUE(all.equal(sigma, t(sigma)))) {
      warning("`sigma` is not symmetric; results may not be meaningful.")
    }
    if (c <= 0) {
      stop("`c` must be positive.")
    }

    eig <- eigen(sigma)

    if (any(eig$values <= 0)) {
      stop("`sigma` must be positive definite (all eigenvalues > 0).")
    }

    theta  <- seq(0, 2 * pi, length.out = segments)
    circle <- rbind(cos(theta), sin(theta))

    ellipse <- t(eig$vectors %*% diag(sqrt(c * eig$values)) %*% circle)

    data.frame(x = ellipse[, 1], y = ellipse[, 2])
  }
)

# ---- User-facing layer functions -----------------------------------------

#' Draw the ellipse x^T Sigma^{-1} x = c
#'
#' @param mapping     Optional aes() mapping (rarely needed; the ellipse
#'                     geometry is fully determined by `sigma` and `c`).
#' @param data         Optional data (rarely needed).
#' @param geom         Geom to use to draw the ellipse boundary. Defaults to "path".
#' @param position     Position adjustment. Defaults to "identity".
#' @param sigma        A 2x2 positive-definite covariance matrix.
#' @param c            Positive constant defining the ellipse level x^T Sigma^{-1} x = c.
#' @param segments     Number of points used to trace the ellipse boundary.
#' @param na.rm        Remove missing values silently? Defaults to FALSE.
#' @param show.legend  Should this layer be included in the legends?
#' @param inherit.aes  If FALSE, overrides the default aesthetics.
#' @param ...          Other arguments passed to the geom (e.g. colour, linewidth).
#'
#' @return A ggplot2 layer.
#' @export
stat_cov_ellipse <- function(mapping = NULL, data = NULL, geom = "path",
                              position = "identity", sigma, c,
                              segments = 300, na.rm = FALSE,
                              show.legend = NA, inherit.aes = TRUE, ...) {

  if (missing(sigma)) stop("`sigma` (a 2x2 covariance matrix) must be supplied.")
  if (missing(c))     stop("`c` (a positive constant) must be supplied.")

  # A single dummy row is enough to give compute_group() one group to act on;
  # the actual (x, y) coordinates it returns are computed entirely from
  # `sigma` and `c`, not from this placeholder data.
  if (is.null(data)) data <- data.frame(x = 0, y = 0)

  layer(
    stat = StatCovEllipse,
    data = data,
    mapping = mapping,
    geom = geom,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      sigma  = sigma,
      c      = c,
      segments = segments,
      na.rm  = na.rm,
      ...
    )
  )
}

#' Convenience wrapper: geom_cov_ellipse()
#'
#' Identical to stat_cov_ellipse() but named as a geom_*() for those who
#' prefer that calling convention.
#'
#' @inheritParams stat_cov_ellipse
#' @export
geom_cov_ellipse <- function(mapping = NULL, data = NULL,
                              position = "identity", sigma, c,
                              segments = 300, na.rm = FALSE,
                              show.legend = NA, inherit.aes = TRUE, ...) {
  stat_cov_ellipse(
    mapping = mapping, data = data, geom = "path", position = position,
    sigma = sigma, c = c, segments = segments, na.rm = na.rm,
    show.legend = show.legend, inherit.aes = inherit.aes, ...
  )
}

# ---- Example (only runs if you source interactively) ---------------------
if (interactive()) {

  Sigma <- matrix(c(4, 1.4,
                     1.4, 1), nrow = 2)

  ggplot() +
    stat_cov_ellipse(sigma = Sigma, c = 4, colour = "#0072B2", linewidth = 1) +
    stat_cov_ellipse(sigma = Sigma, c = 1, colour = "#D55E00", linewidth = 1) +
    coord_fixed() +
    labs(
      x = expression(x[1]), y = expression(x[2]),
      title = expression(x^T * Sigma^{-1} * x == c)
    ) +
    theme_minimal()
}
