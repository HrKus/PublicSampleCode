//
// This Stan program defines a simple model, with a
// vector of values 'y' modeled as normally distributed
// with mean 'mu' and standard deviation 'sigma'.
//
// Learn more about model development with Stan at:
//
//    http://mc-stan.org/users/interfaces/rstan.html
//    https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started
//

data {
  int N;
  int K;
  int D;
  vector[N] Y[K];
}

transformed data {
  vector[N] Mu;
  Mu = rep_vector(0, N);
}

parameters {
  matrix[D,N] x;
  vector<lower=0>[K] theta[5];
}

model {
  matrix[N,N] cov[K];
  vector[D] x_copy[N];

  for (n in 1:N)
    x_copy[n] = x[,n];
  for (k in 1:K)
    cov[k] = gp_exp_quad_cov(x_copy, theta[1,k], theta[2,k]) +
             theta[3,k] +
             theta[4,k]*crossprod(x) +
             diag_matrix(rep_vector(theta[5,k], N));
  to_vector(x) ~ normal(0, 1);
  for (i in 1:5)
    theta[i] ~ student_t(4, 0, 5);
  for (k in 1:K)
    Y[k] ~ multi_normal(Mu, cov[k]);
}
