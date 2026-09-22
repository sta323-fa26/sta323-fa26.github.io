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
#' @param mapping        Optional aes() mapping (rarely needed; the ellipse
#'                        geometry is fully determined by `sigma` and `c`).
#' @param data            Optional data (rarely needed).
#' @param geom            Geom to use to draw the ellipse boundary. Defaults to "path".
#' @param position        Position adjustment. Defaults to "identity".
#' @param sigma           A 2x2 positive-definite covariance matrix.
#' @param c               Positive constant defining the ellipse level x^T Sigma^{-1} x = c.
#' @param segments        Number of points used to trace the ellipse boundary.
#' @param na.rm           Remove missing values silently? Defaults to FALSE.
#' @param show.legend     Should this layer be included in the legends?
#' @param inherit.aes     If FALSE, overrides the default aesthetics.
#' @param include_axes    If TRUE, also draws the two principal axes of the
#'                         ellipse (i.e. the eigenvectors of `sigma`, scaled
#'                         to reach the ellipse boundary, through the origin
#'                         in both directions). Defaults to FALSE.
#' @param axis_colors     Length-2 vector of colors for the (large-spread,
#'                         small-spread) axes, used only when
#'                         `include_axes = TRUE`.
#' @param axis_linewidth  Line width for the axes, used only when
#'                         `include_axes = TRUE`.
#' @param arrow_length    A grid::unit() giving the arrowhead size for the
#'                         axes, used only when `include_axes = TRUE`.
#' @param ...             Other arguments passed to the ellipse geom
#'                         (e.g. colour, linewidth).
#'
#' @return A ggplot2 layer (or, when `include_axes = TRUE`, a list of layers
#'   — an ellipse layer, an axes layer, and a color scale — which can be
#'   added to a ggplot object with `+` just like a single layer).
#' @export
stat_cov_ellipse <- function(mapping = NULL, data = NULL, geom = "path",
                              position = "identity", sigma, c,
                              segments = 300, na.rm = FALSE,
                              show.legend = NA, inherit.aes = TRUE,
                              include_axes = FALSE,
                              axis_colors = c("firebrick", "#0072B2"),
                              axis_linewidth = 1,
                              arrow_length = grid::unit(0.2, "cm"), ...) {

  if (missing(sigma)) stop("`sigma` (a 2x2 covariance matrix) must be supplied.")
  if (missing(c))     stop("`c` (a positive constant) must be supplied.")

  # A single dummy row is enough to give compute_group() one group to act on;
  # the actual (x, y) coordinates it returns are computed entirely from
  # `sigma` and `c`, not from this placeholder data.
  if (is.null(data)) data <- data.frame(x = 0, y = 0)

  ellipse_layer <- layer(
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

  if (!include_axes) return(ellipse_layer)

  # Eigenvectors of Sigma give the principal-axis *directions*; Sigma's own
  # eigenvalues (not Sigma^{-1}'s) give the correct semi-axis *lengths*,
  # sqrt(c * lambda) -- see stat_cov_ellipse's ellipse math above.
  eig <- eigen(sigma)

  axes_df <- data.frame(
    x    = 0,
    y    = 0,
    xend = eig$vectors[1, ] * sqrt(c * eig$values),
    yend = eig$vectors[2, ] * sqrt(c * eig$values),
    axis = factor(c("first component", "second component"),
                   levels = c("first component", "second component"))
  )
  # Mirror each half-axis to the opposite side of the origin, so the full
  # axis line is drawn rather than just a single ray.
  axes_df <- rbind(axes_df, transform(axes_df, xend = -xend, yend = -yend))

  axes_layer <- geom_segment(
    data = axes_df,
    mapping = aes(x = x, y = y, xend = xend, yend = yend, colour = axis),
    arrow = grid::arrow(length = arrow_length),
    linewidth = axis_linewidth,
    inherit.aes = FALSE
  )

  axes_scale <- scale_colour_manual(
    values = stats::setNames(axis_colors, c("first component", "second component")),
    name = NULL
  )

  list(ellipse_layer, axes_layer, axes_scale)
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
    stat_cov_ellipse(sigma = Sigma, c = 4, colour = "#0072B2", linewidth = 1,
                      include_axes = TRUE) +
    coord_fixed() +
    labs(
      x = expression(x[1]), y = expression(x[2]),
      title = expression(x^T * Sigma^{-1} * x == c)
    ) +
    theme_minimal()
}
