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
// ガウス過程回帰　入力多次元ver.

data {
   int N1;
   int D;
   vector[D] x1[N1];
   vector[N1] y1;
   int N2;
   vector[D] x2[N2];
   }
transformed data {
   real delta = 1e-9;
   int N = N1 + N2;
   vector[D] x[N];
   for (n1 in 1:N1) x[n1] = x1[n1];
   for (n2 in 1:N2) x[N1 + n2] = x2[n2];
}
parameters {
   real<lower=0> rho;
   real<lower=0> alpha;
   real<lower=0> sigma;
   vector[N] eta;
}
transformed parameters {
   vector[N] f;
   {
      matrix[N, N] L_K;
      matrix[N, N] K = cov_exp_quad(x, alpha, rho);
      // diagonal elements
      for (n in 1:N)
         K[n, n] = K[n, n] + delta;
      L_K = cholesky_decompose(K);
      f = L_K * eta;
   }
}
model {
   rho ~ inv_gamma(5, 5);
   alpha ~ normal(0, 1);
   sigma ~ normal(0, 1);
   eta ~ normal(0, 1);
   y1 ~ normal(f[1:N1], sigma);
}
generated quantities {
   vector[N2] y2;
   for (n2 in 1:N2)
      y2[n2] = normal_rng(f[N1 + n2], sigma);
}
